package log

import "regexp"

func (x *Extractor) Process(text string) (map[string]string, error) {
	var data map[string]string
	reg, err := regexp.Compile(x.Match)
	if err != nil {
		return nil, err
	}

	matches := reg.FindStringSubmatch(text)
	if len(matches) > 1 {
		data = make(map[string]string)
		data[x.Label] = matches[1]
	}

	return data, nil
}
