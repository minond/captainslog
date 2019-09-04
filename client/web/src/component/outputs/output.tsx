import * as React from "react"

import { OutputType, QueryResult, QueryResults } from "../../definitions"

import { ChartOutput } from "./chart"
import { TableOutput } from "./table"
import { ValueOutput } from "./value"

export type Definition = {
  type: OutputType
  label: string
  query: string
}

type OutputProps = {
  definition: Definition
  results: QueryResults
}

export const LookupOutput = ({ definition, results }: OutputProps) => {
  switch (definition.type) {
    case OutputType.TableOutput:
      return <TableOutput definition={definition} results={results} />

    case OutputType.ChartOutput:
      return <ChartOutput definition={definition} results={results} />

    case OutputType.ValueOutput:
      return <ValueOutput definition={definition} results={results} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
