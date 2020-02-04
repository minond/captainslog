import * as React from "react"

import { Definition, OutputWrapper } from "./output"
import { OutputKind } from "../../definitions"

import { ChartRawOutput } from "./chart"
import { TableRawOutput } from "./table"
import { ValueRawOutput } from "./value"

type IncompleteOutputProps = {
  definition: Definition
  loading?: boolean
  onEdit?: (def: Definition) => void
}

export const IncompleteOutput = (props: IncompleteOutputProps) => {
  switch (props.definition.kind) {
    case OutputKind.TableOutput:
      return <OutputWrapper {...props} outputName="table">
        <TableRawOutput />
      </OutputWrapper>

    case OutputKind.ChartOutput:
      return <OutputWrapper {...props} outputName="chart">
        <ChartRawOutput />
      </OutputWrapper>

    case OutputKind.ValueOutput:
      return <OutputWrapper {...props} outputName="value">
        <ValueRawOutput />
      </OutputWrapper>

    case OutputKind.InvalidOutput:
    default:
      return null
  }
}
