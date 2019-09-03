import * as React from "react"

import { Definition, OutputType } from "./output"
import { ValueRawOutput } from "./value"

type IncompleteOutputProps = {
  definition: Definition
}

export const IncompleteOutput = (props: IncompleteOutputProps) => {
  switch (props.definition.type) {
    case OutputType.TableOutput:
      return <div>table</div>

    case OutputType.ChartOutput:
      return <div>chart</div>

    case OutputType.ValueOutput:
      return <ValueRawOutput definition={props.definition} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
