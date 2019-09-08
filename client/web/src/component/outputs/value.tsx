import * as React from "react"

import { QueryResults } from "../../definitions"
import { Definition, Header } from "./output"
import { scalar } from "./utils"

import { valueOf } from "./utils"

const DEFAULT_VALUE = "N/A"

const getValue = (res: QueryResults) =>
  res.data && res.data[0] ? valueOf(res.data[0][0]) : undefined

type ValueOutputProps = {
  definition: Definition
  results: QueryResults
  onEdit?: (def: Definition) => void
}

export const ValueOutput = (props: ValueOutputProps) =>
  <ValueRawOutput {...props} raw={getValue(props.results)} />

type ValueRawOutputProps = {
  definition: Definition
  raw?: scalar
  onEdit?: (def: Definition) => void
}

export const ValueRawOutput = ({ definition, raw, onEdit }: ValueRawOutputProps) =>
  <div className="output value-output" style={{width: definition.width}}>
    <Header definition={definition} onEdit={onEdit} />
    <div className="value-output-wrapper">
      <span className="value-output-value">{raw || DEFAULT_VALUE}</span>
    </div>
  </div>
