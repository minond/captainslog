import * as React from "react"
import { FunctionComponent } from "react"

import { Output, OutputType, QueryResult, QueryResults } from "../../definitions"

import { ChartOutput } from "./chart"
import { TableOutput } from "./table"
import { ValueOutput } from "./value"

export const parseOutputType = (x: string) => {
  switch (x) {
    case "1": return OutputType.TableOutput
    case "2": return OutputType.ChartOutput
    case "3": return OutputType.ValueOutput
    default:  return OutputType.InvalidOutput
  }
}

export type Definition = {
  type: OutputType
  label: string
  query: string
  width: string
}

type OutputWrapperProps = {
  definition: Definition
  outputName: string
  onEdit?: (def: Definition) => void
  loading?: boolean
}

const outputClassName = (props: { loading?: boolean, outputName: string }): string =>
  `output ${props.outputName}-output ${props.loading ? "output-loading" : ""}`

const outputStyle = ({ definition }: { definition: Definition }) =>
  ({width: definition ? definition.width : "100%"})

export const OutputWrapper: FunctionComponent<OutputWrapperProps> = (props) =>
  <div className={outputClassName(props)} style={outputStyle(props)}>
    <Header definition={props.definition} onEdit={props.onEdit} />
    <div className="output-content">{props.children}</div>
  </div>

type LookupOutputProps = {
  definition: Definition
  results: QueryResults
  onEdit?: (def: Definition) => void
  loading?: boolean
}

export const LookupOutput = (props: LookupOutputProps) => {
  switch (props.definition.type) {
    case OutputType.TableOutput:
      return <OutputWrapper {...props} outputName="table">
        <TableOutput {...props} />
      </OutputWrapper>

    case OutputType.ChartOutput:
      return <OutputWrapper {...props} outputName="chart">
        <ChartOutput {...props} />
      </OutputWrapper>

    case OutputType.ValueOutput:
      return <OutputWrapper {...props} outputName="value">
        <ValueOutput {...props} />
      </OutputWrapper>

    case OutputType.InvalidOutput:
    default:
      return null
  }
}

type HeaderProps = {
  definition: Definition
  onEdit?: (def: Definition) => void
}

export const Header = ({ definition, onEdit }: HeaderProps) =>
  <div className="output-header">
    <div className="output-label" title={definition.query}>
      {definition.label}
    </div>
    {onEdit ?
      <div className="output-edit" onClick={() => onEdit(definition)}>
        [edit]
      </div> :
      null}
  </div>
