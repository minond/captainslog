import * as React from "react"

import { Definition, OutputType } from "./output"

import { TableRawOutput } from "./table"
import { ValueRawOutput } from "./value"

type IncompleteOutputProps = {
  definition: Definition
}

export const IncompleteOutput = ({ definition }: IncompleteOutputProps) => {
  switch (definition.type) {
    case OutputType.TableOutput:
      return <TableRawOutput definition={definition} />

    case OutputType.ChartOutput:
      return <div>chart</div>

    case OutputType.ValueOutput:
      return <ValueRawOutput definition={definition} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
