import * as React from "react"

import { Definition } from "./output"
import { OutputType } from "../../definitions"

import { ChartRawOutput } from "./chart"
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
      return <ChartRawOutput definition={definition} />

    case OutputType.ValueOutput:
      return <ValueRawOutput definition={definition} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
