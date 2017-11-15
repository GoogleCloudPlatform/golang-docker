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

// The server command is a sample app that talks to various Stackdriver APIs.
// This app is used as a post-push verification for the runtime builder.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"runtime"
	"strconv"
	"strings"
	"time"

	"app/internal/foo"

	"cloud.google.com/go/compute/metadata"
	"cloud.google.com/go/errorreporting"
	"cloud.google.com/go/logging"
	monitoring "cloud.google.com/go/monitoring/apiv3"
	"github.com/golang/protobuf/ptypes"
	metricpb "google.golang.org/genproto/googleapis/api/metric"
	monitoredrespb "google.golang.org/genproto/googleapis/api/monitoredres"
	monitoringpb "google.golang.org/genproto/googleapis/monitoring/v3"
)

const (
	// envVM is set in App Engine when vm:true is set.
	envVM = "GAE_APPENGINE_HOSTNAME"

	// envFlex is set in App Engine when env:flex is set.
	envFlex = "GAE_INSTANCE"
)

type appHandler func(http.ResponseWriter, *http.Request) error

func (h appHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if err := h(w, r); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

var (
	projectID string
	lgClient  *logging.Client
	mtClient  *monitoring.MetricClient
	errClient *errorreporting.Client
)

func main() {
	var err error
	if metadata.OnGCE() {
		if projectID, err = metadata.ProjectID(); err != nil {
			log.Fatal("getting project ID on GCE:", err)
		}
	} else {
		projectID = os.Getenv("PROJECT_ID")
	}

	// Initialize Stackdriver API clients
	ctx := context.Background()
	if lgClient, err = logging.NewClient(ctx, projectID); err != nil {
		log.Fatalf("failed to create logging client: %v", err)
	}
	if mtClient, err = monitoring.NewMetricClient(ctx); err != nil {
		log.Fatalf("failed to create metric client: %v", err)
	}
	if errClient, err = errorreporting.NewClient(ctx, projectID, errorreporting.Config{
		ServiceName: "default",
	}); err != nil {
		log.Fatalf("failed to create error reporting client: %v", err)
	}

	http.HandleFunc("/", mainHandler)
	http.HandleFunc("/_ah/health", healthCheckHandler)
	http.HandleFunc("/version", versionHandler)
	http.Handle("/tzinfo", appHandler(tzinfoHandler))
	http.Handle("/lookup_host", appHandler(lookupHostHandler))
	http.Handle("/logging_custom", appHandler(customLoggingHandler))
	http.Handle("/monitoring", appHandler(monitoringHandler))
	http.Handle("/exception", appHandler(exceptionHandler))
	http.Handle("/custom", appHandler(customHandler))
	http.Handle("/ping_foo", appHandler(pingFooHandler))
	http.Handle("/environment", appHandler(environmentHandler))
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
	fmt.Fprint(w, "OK")
}

func versionHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Go version=%s\nGOARCH=%s\nGOOS=%s\n", runtime.Version(), runtime.GOARCH, runtime.GOOS)
}

func tzinfoHandler(w http.ResponseWriter, r *http.Request) error {
	loc, err := time.LoadLocation("US/Pacific")
	if err != nil {
		return err
	}
	fmt.Fprintln(w, loc.String())
	return nil
}

func lookupHostHandler(w http.ResponseWriter, r *http.Request) error {
	addrs, err := net.LookupHost(r.Host)
	if err != nil {
		return fmt.Errorf("error lookup host: %v", err)
	}
	fmt.Fprint(w, strings.Join(addrs, "\n"))
	return nil
}

func customLoggingHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != http.MethodPost {
		return fmt.Errorf("wrong request method: %v, requires POST", r.Method)
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
	r.Body.Close()

	lg := lgClient.Logger(b.LogName)
	slg := lg.StandardLogger(logging.ParseSeverity(b.Level))
	slg.Println(b.Token)
	return nil
}

func monitoringHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != http.MethodPost {
		return fmt.Errorf("wrong request method: %v, requires POST", r.Method)
	}
	decoder := json.NewDecoder(r.Body)
	var b struct {
		Name  string `json:"name"`
		Token int64  `json:"token"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	r.Body.Close()

	p := &monitoringpb.Point{
		Interval: &monitoringpb.TimeInterval{
			EndTime: ptypes.TimestampNow(),
		},
		Value: &monitoringpb.TypedValue{
			Value: &monitoringpb.TypedValue_Int64Value{
				Int64Value: b.Token,
			},
		},
	}

	if err := mtClient.CreateTimeSeries(r.Context(), &monitoringpb.CreateTimeSeriesRequest{
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

	_, err := fmt.Fprint(w, "OK")
	return err
}

func exceptionHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != http.MethodPost {
		return fmt.Errorf("wrong request method: %v, requires POST", r.Method)
	}
	decoder := json.NewDecoder(r.Body)
	var b struct {
		Token int64 `json:"token"`
	}
	if err := decoder.Decode(&b); err != nil {
		return fmt.Errorf("decode request body: %v", err)
	}
	r.Body.Close()

	errClient.ReportSync(r.Context(), errorreporting.Entry{
		Error: errors.New(strconv.FormatInt(b.Token, 10)),
	})
	_, err := fmt.Fprint(w, "OK")
	return err
}

func customHandler(w http.ResponseWriter, r *http.Request) error {
	var tests = []struct {
		Name    string `json:"name,omitempty"`
		Path    string `json:"path,omitempty"`
		Timeout int    `json:"timeout,omitempty"`
	}{
		{
			Name: "Version",
			Path: "/version",
		},
		{
			Name: "Lookup Host",
			Path: "/lookup_host",
		},
		{
			Name: "TimeZone",
			Path: "/tzinfo",
		},
		{
			Name: "Ping Foo",
			Path: "/ping_foo",
		},
	}
	return json.NewEncoder(w).Encode(tests)
}

func pingFooHandler(w http.ResponseWriter, r *http.Request) error {
	_, err := fmt.Fprint(w, foo.Ping())
	return err
}

func environmentHandler(w http.ResponseWriter, r *http.Request) error {
	if os.Getenv(envFlex) != "" || os.Getenv(envVM) != "" {
		fmt.Fprint(w, "GAE")
	} else {
		fmt.Fprint(w, "GKE")
	}
	return nil
}
