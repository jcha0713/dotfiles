package main

import (
	"reflect"
	"testing"
)

func TestSplitLines(t *testing.T) {
	got := splitLines("Rust\r\nGo\n")
	want := []string{"Rust", "Go"}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("splitLines() = %#v, want %#v", got, want)
	}
}

func TestFilterExcluded(t *testing.T) {
	got := filterExcluded([]string{"Rust", "Go", "Common Lisp"}, map[string]bool{
		"rust":        true,
		"common lisp": true,
	})
	want := []string{"Go"}
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("filterExcluded() = %#v, want %#v", got, want)
	}
}
