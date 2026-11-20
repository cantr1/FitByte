package main

import (
	"encoding/json"
	"fmt"
	"testing"
)

func TestSleepDurationDecoding(t *testing.T) {
	for _, field := range []string{"rem_duration_mins", "light_duration_mins", "deep_duration_mins"} {
		for _, testcase := range []struct {
			name    string
			value   string
			wantErr bool
		}{
			{"zero", "0", false},
			{"minutes", "90", false},
			{"maximum", "2147483647", false},
			{"overflow", "2147483648", true},
			{"wraparound", "4294967296", true},
			{"fraction", "1.5", true},
		} {
			t.Run(field+"/"+testcase.name, func(t *testing.T) {
				var params sleepParameters
				err := json.Unmarshal([]byte(fmt.Sprintf(`{"%s":%s}`, field, testcase.value)), &params)
				if (err != nil) != testcase.wantErr {
					t.Fatalf("decode error = %v, want error = %v", err, testcase.wantErr)
				}
				if !testcase.wantErr && testcase.value == "0" {
					if params.REMDuration == nil && params.LightDuration == nil && params.DeepDuration == nil {
						t.Fatal("explicit zero must remain distinguishable from a missing duration")
					}
				}
			})
		}
	}
}
