import * as React from "react"

import { QueryResults } from "../../definitions"
import { scalar } from "./utils"

import { valueOf } from "./utils"

const DEFAULT_VALUE = "N/A"

const getValue = (res: QueryResults) =>
  res.results && res.results[0] ? valueOf(res.results[0][0]) : undefined

type ValueOutputProps = {
  results: QueryResults
}

export const ValueOutput = ({ results }: ValueOutputProps) =>
  <ValueRawOutput raw={getValue(results)} />

type ValueRawOutputProps = {
  raw?: scalar
}

export const ValueRawOutput = ({ raw }: ValueRawOutputProps) =>
  <div className="value-output-wrapper">
    <span className="value-output-value">{raw || DEFAULT_VALUE}</span>
  </div>
