package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/GoogleCloudPlatform/golang-docker/hello/vendor/internal"
	"github.com/gorilla/mux"
)

func handle(w http.ResponseWriter, r *http.Request) {
	http.Redirect(w, r, fmt.Sprintf("/%s", internal.Secret), http.StatusFound)
}

func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<html><body>Hello, %s! 세상아 안녕!</body></html>", mux.Vars(r)["who"])
}

func main() {
	r := mux.NewRouter().StrictSlash(true)
	r.HandleFunc("/", handle).Methods("GET")
	r.HandleFunc("/{who}", hello).Methods("GET")

	http.Handle("/", r)
	envPort := os.Getenv("PORT")
	if len(envPort) == 0 {
		envPort = "8080"
	}
	listenOn := fmt.Sprintf(":%s", envPort)
	log.Printf("listening on: %s", listenOn)
	log.Fatal(http.ListenAndServe(listenOn, nil))
}
