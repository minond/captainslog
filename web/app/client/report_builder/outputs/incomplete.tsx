import * as React from "react"

import { Definition, OutputWrapper } from "./output"
import { OutputType } from "../../definitions"

import { ChartRawOutput } from "./chart"
import { TableRawOutput } from "./table"
import { ValueRawOutput } from "./value"

type IncompleteOutputProps = {
  definition: Definition
  onEdit?: (def: Definition) => void
}

export const IncompleteOutput = (props: IncompleteOutputProps) => {
  switch (props.definition.type) {
    case OutputType.TableOutput:
      return <OutputWrapper {...props} outputName="table">
        <TableRawOutput />
      </OutputWrapper>

    case OutputType.ChartOutput:
      return <OutputWrapper {...props} outputName="chart">
        <ChartRawOutput />
      </OutputWrapper>

    case OutputType.ValueOutput:
      return <OutputWrapper {...props} outputName="value">
        <ValueRawOutput />
      </OutputWrapper>

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
