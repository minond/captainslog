import * as React from "react";
import * as ReactDOM from "react-dom";

import { Logbook } from "./components/Logbook";
import { Entry } from "./definitions/entry";

const fake = (text: string): Entry => ({
  guid: Math.random().toString(),
  text: text,
  data: new Map(),
  timestamp: Date.now(),
})

const entries = [
  fake("Bench press, 3x10@65"),
  fake("Squats, 2min"),
  fake("Squats, 3x10@45"),
  fake("Running, 30min"),
]

ReactDOM.render(
  <Logbook guid="2be8e6ec-2668-4a7c-bdca-3d213f724c82" name="Workouts" entries={entries} />,
  document.getElementById("body"))
