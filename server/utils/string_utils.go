package utils

import "strings"

type UtilString string

func (str UtilString) IsEmpty() bool {
	return len(strings.TrimSpace(string(str))) < 1
}
