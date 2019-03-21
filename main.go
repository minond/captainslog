package main

import (
	"fmt"

	"github.com/minond/captainslog/log"
)

func must(x log.Extractor, err error) log.Extractor {
	if err != nil {
		panic(err)
	}
	return x
}

func main() {
	ls := []log.Log{
		log.NewLog("Bench press, 3x10@65"),
		log.NewLog("Squats, 2min"),
		log.NewLog("Squats, 3x10@45"),
		log.NewLog("Running, 30min"),
	}

	xs := []log.Extractor{
		must(log.NewExtractor("exercise", `^(.+),`)),
		must(log.NewExtractor("sets", `,\s{0,}(\d+)\s{0,}x`)),
		must(log.NewExtractor("reps", `x\s{0,}(\d+)\s{0,}@`)),
		must(log.NewExtractor("weight", `@\s{0,}(\d+)$`)),
		must(log.NewExtractor("time", `(\d+\s{0,}(sec|seconds|min|minutes|hour|hours))`)),
	}

	for _, l := range ls {
		fmt.Println(log.Process(l, xs))
	}
}
