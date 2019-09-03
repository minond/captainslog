import * as React from "react"

import { QueryResults } from "../../definitions"
import { Definition } from "./output"
import { scalar } from "./utils"

import { valueOf } from "./utils"

const DEFAULT_VALUE = "N/A"

const getValue = (res: QueryResults) =>
  res.data && res.data[0] ? valueOf(res.data[0][0]) : undefined

type ValueOutputProps = {
  results: QueryResults
  definition: Definition
}

export const ValueOutput = (props: ValueOutputProps) =>
  <ValueRawOutput
    definition={props.definition}
    raw={getValue(props.results)}
  />

type ValueProps = {
  definition: Definition
  raw?: scalar
}

export const ValueRawOutput = (props: ValueProps) =>
  <div className="output value-output">
    <div className="value-output-wrapper">
      <div className="output-label" title={props.definition.query}>
        {props.definition.label}
      </div>
      <span className="value-output-value">{props.raw || DEFAULT_VALUE}</span>
    </div>
  </div>
