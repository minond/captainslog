import * as React from "react"

import { QueryResults } from "../../definitions"

import { valueOf } from "./utils"

type ValueOutputProps = {
  results: QueryResults
}

const getValue = (res: QueryResults) =>
  res.data && res.data[0] ? valueOf(res.data[0][0]) : "N/A"

export const ValueOutput = (props: ValueOutputProps) =>
  <div className="value-output">{getValue(props.results)}</div>
