import * as React from "react"

import { QueryResults } from "../../definitions"
import { Definition } from "./output"

import { valueOf } from "./utils"

type ValueOutputProps = {
  results: QueryResults
  definition: Definition
}

const getValue = (res: QueryResults) =>
  res.data && res.data[0] ? valueOf(res.data[0][0]) : "N/A"

export const ValueOutput = (props: ValueOutputProps) =>
  <div className="output value-output">
    <div className="value-output-wrapper">
      <div className="output-label" title={props.definition.query}>{props.definition.label}</div>
      <span className="value-output-value">{getValue(props.results)}</span>
    </div>
  </div>
