package log

func merge(a, b map[string]string) map[string]string {
	if b == nil {
		return a
	}
	for k, v := range b {
		a[k] = v
	}
	return a
}

func Process(l Log, xs []Extractor) (Log, error) {
	for _, x := range xs {
		data, err := x.Process(l.Text)
		if err != nil {
			return l, err
		}

		l.Data = merge(l.Data, data)
	}

	return l, nil
}
