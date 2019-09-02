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
  label: string
  query: string
}

type OutputProps = {
  type: OutputType
  results: QueryResults
  definition: Definition
}

export const Output = (props: OutputProps) => {
  switch (props.type) {
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
