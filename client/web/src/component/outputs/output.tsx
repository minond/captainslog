import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"

import { ChartOutput } from "./chart"
import { TableOutput } from "./table"
import { ValueOutput } from "./value"

export enum OutputType {
  InvalidOutput,
  TableOutput,
  ChartOutput,
  ValueOutput,
}

export type Definition = {
  type: OutputType
  label: string
  query: string
}

type OutputProps = {
  results: QueryResults
  definition: Definition
}

export const LookupOutput = (props: OutputProps) => {
  switch (props.definition.type) {
    case OutputType.TableOutput:
      return <TableOutput definition={props.definition} results={props.results} />

    case OutputType.ChartOutput:
      return <ChartOutput definition={props.definition} results={props.results} />

    case OutputType.ValueOutput:
      return <ValueOutput definition={props.definition} results={props.results} />

    case OutputType.InvalidOutput:
    default:
      return null
  }
}
