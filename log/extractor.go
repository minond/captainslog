package log

import "regexp"

type Extractor struct {
	Label  string
	Match  string
	Regexp *regexp.Regexp
}

func NewExtractor(label, match string) (Extractor, error) {
	x := Extractor{Label: label, Match: match}
	reg, err := regexp.Compile(x.Match)
	if err != nil {
		return x, err
	}

	x.Regexp = reg
	return x, nil
}

func (x *Extractor) Process(text string) (map[string]string, error) {
	var data map[string]string
	matches := x.Regexp.FindStringSubmatch(text)
	if len(matches) > 1 {
		data = make(map[string]string)
		data[x.Label] = matches[1]
	}
	return data, nil
}
