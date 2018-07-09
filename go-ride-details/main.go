package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"googlemaps.github.io/maps"
)

// Endpoint is service endpoint
const Endpoint = "/ride_details_by_coords"
const apiKeyEnvVariableName = "GOOGLE_MAPS_API_KEY"
const portEnvVariableName = "RIDE_DETAILS_PORT"
const defaultPort = "8080"
const fromParamName = "from"
const toParamName = "to"

func main() {
	apiKey := os.Getenv(apiKeyEnvVariableName)
	checkAPIKey(apiKey)

	port := os.Getenv(portEnvVariableName)
	if port == "" {
		port = defaultPort
	}

	http.Handle(Endpoint, &ServiceHandler{mapsClient: createMapsClient(apiKey)})
	log.Printf("go-ride-details is serving %s on port %s\n", Endpoint, port)
	http.ListenAndServe(":"+port, nil)
}

func checkAPIKey(apiKey string) {
	if apiKey == "" {
		log.Printf("Provide %s env-variable, please!\n", apiKeyEnvVariableName)
		os.Exit(1)
	}
}

func createMapsClient(apiKey string) *maps.Client {
	c, err := maps.NewClient(maps.WithAPIKey(apiKey))
	if err != nil {
		log.Printf("Fatal error on creating Maps Client: %s\n", err)
		os.Exit(1)
	}
	return c
}

type matrixFetcher interface {
	DistanceMatrix(ctx context.Context, r *maps.DistanceMatrixRequest) (*maps.DistanceMatrixResponse, error)
}

// ServiceHandler is service handler
type ServiceHandler struct {
	mapsClient matrixFetcher
}

func (h *ServiceHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	from := r.FormValue(fromParamName)
	to := r.FormValue(toParamName)
	log.Printf("from: %s, to: %s\n", from, to)

	matrixRequest := &maps.DistanceMatrixRequest{
		Origins:      []string{from},
		Destinations: []string{to},
	}
	resp, err := h.mapsClient.DistanceMatrix(context.Background(), matrixRequest)
	if err != nil {
		sendErrorResponse(&w, "Error on fetching distanceMatrix: "+err.Error())
		return
	}
	rideDetails := resp.Rows[0].Elements[0]
	status := rideDetails.Status
	if status != "OK" {
		sendErrorResponse(&w, "Got bad status for requested ride: "+status)
		return
	}
	sendSuccessResponse(&w, rideDetails)
}

func sendSuccessResponse(w *http.ResponseWriter, rideDetails *maps.DistanceMatrixElement) {
	seconds := int(rideDetails.Duration.Seconds())
	meters := rideDetails.Distance.Meters
	fmt.Fprintf(*w, "{\"data\":{\"duration_in_seconds\":%d, \"distance_in_meters\":%d}}", seconds, meters)
}

func sendErrorResponse(w *http.ResponseWriter, message string) {
	fmt.Fprintf(*w, "{\"errors\":[{\"detail\":\"%s\"}]}", message)
}
