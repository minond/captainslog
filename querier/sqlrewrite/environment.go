package sqlrewrite

type Environment map[string]struct{}

func (env Environment) Defined(alias string) bool {
	for v := range env {
		if v == alias {
			return true
		}
	}
	return false
}

func (env Environment) Define(alias string) Environment {
	env[alias] = struct{}{}
	return env
}
