package utils

import "strings"

func IsEmpty(str string) bool {
	return len(strings.TrimSpace(str)) < 1
}
