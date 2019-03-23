import * as React from "react";
import * as ReactDOM from "react-dom";

import { Logbook } from "./components/Logbook";
import { Log } from "./definitions/log";

const fake = (text: string): Log => ({
  guid: Math.random().toString(),
  text: text,
  data: new Map(),
  createdOn: Date.now(),
  createdBy: Math.random().toString(),
  updatedOn: Date.now(),
  updatedBy: Math.random().toString(),
})

const logs = [
  fake("Bench press, 3x10@65"),
  fake("Squats, 2min"),
  fake("Squats, 3x10@45"),
  fake("Running, 30min"),
]

ReactDOM.render(
  <Logbook name="Workouts" logs={logs} />,
  document.getElementById("body"))
