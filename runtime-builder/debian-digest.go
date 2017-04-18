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

// Command debian-digest fetches the latest debian8 image and parse the digest of it.
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os/exec"
)

type image struct {
	Digest string
	Tags   []string
}

func main() {
	cmd := exec.Command("gcloud", "beta", "container", "images", "list-tags",
		"--filter=TAGS=latest", "--format=json", "gcr.io/google_appengine/debian8")
	var out []byte
	var err error
	if out, err = cmd.Output(); err != nil {
		log.Fatal(err)
	}
	var imgs []image
	if err := json.Unmarshal(out, &imgs); err != nil {
		log.Fatal(err)
	}
	// We should get exactly one item from the command above.
	fmt.Print(imgs[0].Digest)
}
