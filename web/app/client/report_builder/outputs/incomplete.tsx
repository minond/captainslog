import * as React from "react"

import { Definition } from "./output"
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
      return <TableRawOutput {...props} />

    case OutputType.ChartOutput:
      return <ChartRawOutput {...props} />

    case OutputType.ValueOutput:
      return <ValueRawOutput {...props} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
