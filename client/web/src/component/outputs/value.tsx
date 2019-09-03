import * as React from "react"

import { QueryResults } from "../../definitions"
import { Definition } from "./output"
import { scalar } from "./utils"

import { valueOf } from "./utils"

const DEFAULT_VALUE = "N/A"

const getValue = (res: QueryResults) =>
  res.data && res.data[0] ? valueOf(res.data[0][0]) : undefined

type ValueOutputProps = {
  definition: Definition
  results: QueryResults
}

export const ValueOutput = ({ definition, results }: ValueOutputProps) =>
  <ValueRawOutput
    definition={definition}
    raw={getValue(results)}
  />

type ValueProps = {
  definition: Definition
  raw?: scalar
}

export const ValueRawOutput = ({ definition, raw }: ValueProps) =>
  <div className="output value-output">
    <div className="value-output-wrapper">
      <div className="output-label" title={definition.query}>
        {definition.label}
      </div>
      <span className="value-output-value">{raw || DEFAULT_VALUE}</span>
    </div>
  </div>
