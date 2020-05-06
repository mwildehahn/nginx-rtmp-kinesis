package main

import (
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	err := http.ListenAndServe(":8090", nil)
	if err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
