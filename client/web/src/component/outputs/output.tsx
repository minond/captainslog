import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"

import { TableOutput } from "./table"

export enum OutputType {
  InvalidOutput,
  TableOutput,
  LineGraphOutput,
}

type OutputProps = {
  type: OutputType
  results: QueryResults
}

export const Output = (props: OutputProps) => {
  switch (props.type) {
    case OutputType.TableOutput:
      return <TableOutput results={props.results} />

    default:
      return null
  }
}
