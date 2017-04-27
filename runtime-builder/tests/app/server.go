// Copyright 2017 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"runtime"
	"strings"
	"time"

	"cloud.google.com/go/compute/metadata"
	"cloud.google.com/go/errors"
	"cloud.google.com/go/logging"
	monitoring "cloud.google.com/go/monitoring/apiv3"
	"github.com/golang/protobuf/ptypes/timestamp"
	metricpb "google.golang.org/genproto/googleapis/api/metric"
	monitoredrespb "google.golang.org/genproto/googleapis/api/monitoredres"
	monitoringpb "google.golang.org/genproto/googleapis/monitoring/v3"
)

type appHandler func(http.ResponseWriter, *http.Request) error

func (h appHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if err := h(w, r); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

var (
	ctx       = context.Background()
	projectID string
)

func main() {
	if metadata.OnGCE() {
		var err error
		if projectID, err = metadata.ProjectID(); err != nil {
			log.Fatal("getting project ID on GCE:", err)
		}
	} else {
		projectID = os.Getenv("PROJECT_ID")
	}
	http.HandleFunc("/", mainHandler)
	http.HandleFunc("/_ah/health", healthCheckHandler)
	http.HandleFunc("/version", versionHandler)
	http.Handle("/lookup_host", appHandler(lookupHostHandler))
	http.Handle("/logging", appHandler(loggingHandler))
	http.Handle("/logging_standard", appHandler(standardLoggingHandler))
	http.Handle("/logging_custom", appHandler(customLoggingHandler))
	http.Handle("/monitoring", appHandler(monitoringHandler))
	http.Handle("/exception", appHandler(exceptionHandler))
	http.Handle("/custom", appHandler(customHandler))
	log.Print("Listening on port 8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func mainHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	fmt.Fprint(w, "Hello World!")
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "ok")
}

func versionHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Go version=%s\nGOARCH=%s\nGOOS=%s\n", runtime.Version(), runtime.GOARCH, runtime.GOOS)
}

func lookupHostHandler(w http.ResponseWriter, r *http.Request) error {
	addrs, err := net.LookupHost(r.Host)
	if err != nil {
		return fmt.Errorf("error lookup host: %v", err)
	}
	fmt.Fprint(w, strings.Join(addrs, "\n"))
	return nil
}

func loggingHandler(w http.ResponseWriter, r *http.Request) error {
	c, err := logging.NewClient(ctx, projectID)
	if err != nil {
		return fmt.Errorf("failed to create logging client: %v", err)
	}

	decoder := json.NewDecoder(r.Body)
	var b struct {
		LogName string `json:"log_name"`
		Token   string `json:"token"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	defer r.Body.Close()

	lg := c.Logger(b.LogName)
	lg.LogSync(ctx, logging.Entry{Payload: b.Token})
	return nil
}

func standardLoggingHandler(w http.ResponseWriter, r *http.Request) error {
	c, err := logging.NewClient(ctx, projectID)
	if err != nil {
		return fmt.Errorf("failed to create logging client: %v", err)
	}

	decoder := json.NewDecoder(r.Body)
	var b struct {
		Token string `json:"token"`
		Level string `json:"level"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	defer r.Body.Close()

	lg := c.Logger("appengine.googleapis.com/stderr")
	slg := lg.StandardLogger(logging.ParseSeverity(b.Level))
	slg.Println(b.Token)
	return nil
}

func customLoggingHandler(w http.ResponseWriter, r *http.Request) error {
	c, err := logging.NewClient(ctx, projectID)
	if err != nil {
		return fmt.Errorf("failed to create logging client: %v", err)
	}

	decoder := json.NewDecoder(r.Body)
	var b struct {
		LogName string `json:"log_name"`
		Token   string `json:"token"`
		Level   string `json:"level"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	defer r.Body.Close()

	lg := c.Logger(b.LogName)
	slg := lg.StandardLogger(logging.ParseSeverity(b.Level))
	slg.Println(b.Token)
	return nil
}

func monitoringHandler(w http.ResponseWriter, r *http.Request) error {
	c, err := monitoring.NewMetricClient(ctx)
	if err != nil {
		return fmt.Errorf("failed to create metric client: %v", err)
	}

	decoder := json.NewDecoder(r.Body)
	var b struct {
		Name  string `json:"name"`
		Token int64  `json:"token"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	defer r.Body.Close()

	p := &monitoringpb.Point{
		Interval: &monitoringpb.TimeInterval{
			EndTime: &timestamp.Timestamp{
				Seconds: time.Now().Unix(),
			},
		},
		Value: &monitoringpb.TypedValue{
			Value: &monitoringpb.TypedValue_Int64Value{
				Int64Value: b.Token,
			},
		},
	}

	if err := c.CreateTimeSeries(ctx, &monitoringpb.CreateTimeSeriesRequest{
		Name: monitoring.MetricProjectPath(projectID),
		TimeSeries: []*monitoringpb.TimeSeries{
			{
				Metric: &metricpb.Metric{
					Type: b.Name,
				},
				Resource: &monitoredrespb.MonitoredResource{
					Type: "global",
					Labels: map[string]string{
						"project_id": projectID,
					},
				},
				Points: []*monitoringpb.Point{
					p,
				},
			},
		},
	}); err != nil {
		return fmt.Errorf("writing time series data: %v", err)
	}

	_, err = fmt.Fprint(w, "ok")
	return err
}

func exceptionHandler(w http.ResponseWriter, r *http.Request) error {
	c, err := errors.NewClient(ctx, projectID, "default", "", false)
	if err != nil {
		return fmt.Errorf("failed to create error reporting client: %v", err)
	}
	decoder := json.NewDecoder(r.Body)
	var b struct {
		Token int64 `json:"token"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	defer r.Body.Close()

	c.Report(ctx, r, b.Token)
	_, err = fmt.Fprint(w, "ok")
	return err
}

func customHandler(w http.ResponseWriter, r *http.Request) error {
	var tests = []struct {
		Name    string `json:"name"`
		Path    string `json:"path"`
		Timeout int    `json:"timeout"`
	}{
		{
			Name:    "Version",
			Path:    "/version",
			Timeout: 500,
		},
		{
			Name:    "Lookup Host",
			Path:    "/lookup_host",
			Timeout: 500,
		},
	}
	return json.NewEncoder(w).Encode(tests)
}
