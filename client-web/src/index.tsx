import * as React from "react";
import * as ReactDOM from "react-dom";

import { Logbook } from "./components/Logbook";
import { Entry } from "./definitions/entry";

const fake = (text: string): Entry => ({
  guid: Math.random().toString(),
  text: text,
  data: new Map(),
})

const entries = [
  fake("Bench press, 3x10@65"),
  fake("Squats, 2min"),
  fake("Squats, 3x10@45"),
  fake("Running, 30min"),
]

ReactDOM.render(
  <Logbook name="Workouts" entries={entries} />,
  document.getElementById("body"))
