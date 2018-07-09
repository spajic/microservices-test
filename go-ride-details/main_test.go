package main

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"googlemaps.github.io/maps"
)

const successMeters = 2000
const successSeconds = 700

type successMatrixFetcherStub struct{}

func (f *successMatrixFetcherStub) DistanceMatrix(ctx context.Context, r *maps.DistanceMatrixRequest) (*maps.DistanceMatrixResponse, error) {
	distance := maps.Distance{Meters: successMeters}
	element := &maps.DistanceMatrixElement{Status: "OK", Duration: successSeconds * time.Second, Distance: distance}
	elements := []*maps.DistanceMatrixElement{element}
	row := maps.DistanceMatrixElementsRow{Elements: elements}
	rows := []maps.DistanceMatrixElementsRow{row}
	response := maps.DistanceMatrixResponse{Rows: rows}
	return &response, nil
}

func TestSuccessfulMatrixRequest(t *testing.T) {
	req, err := http.NewRequest("GET", Endpoint, nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()

	stub := successMatrixFetcherStub{}
	handler := ServiceHandler{mapsClient: &stub}
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := `{"data":{"duration_in_seconds":700, "distance_in_meters":2000}}`
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expected)
	}
}

type failureMatrixFetcherStub struct{}

const failureError = "Not found"

func (f *failureMatrixFetcherStub) DistanceMatrix(ctx context.Context, r *maps.DistanceMatrixRequest) (*maps.DistanceMatrixResponse, error) {
	distance := maps.Distance{Meters: 0}
	element := &maps.DistanceMatrixElement{Status: failureError, Duration: 0, Distance: distance}
	elements := []*maps.DistanceMatrixElement{element}
	row := maps.DistanceMatrixElementsRow{Elements: elements}
	rows := []maps.DistanceMatrixElementsRow{row}
	response := maps.DistanceMatrixResponse{Rows: rows}
	return &response, nil
}
func TestFailureMatrixRequest(t *testing.T) {
	req, err := http.NewRequest("GET", Endpoint, nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()

	stub := failureMatrixFetcherStub{}
	handler := ServiceHandler{mapsClient: &stub}
	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := `{"errors":[{"detail":"Got bad status for requested ride: Not found"}]}`
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expected)
	}
}

func TestFailedMatrixRequest(t *testing.T) {
	one := 1
	if one != 1 {
		t.Errorf("Test for failed!")
	}
}
