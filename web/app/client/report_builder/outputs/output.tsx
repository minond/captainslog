import * as React from "react"
import { FunctionComponent } from "react"

import { Output, OutputKind, QueryResult, QueryResults } from "../../definitions"

import { ChartOutput } from "./chart"
import { TableOutput } from "./table"
import { ValueOutput } from "./value"

export type Definition = {
  kind: OutputKind
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
  switch (props.definition.kind) {
    case OutputKind.TableOutput:
      return <OutputWrapper {...props} outputName="table">
        <TableOutput {...props} />
      </OutputWrapper>

    case OutputKind.ChartOutput:
      return <OutputWrapper {...props} outputName="chart">
        <ChartOutput {...props} />
      </OutputWrapper>

    case OutputKind.ValueOutput:
      return <OutputWrapper {...props} outputName="value">
        <ValueOutput {...props} />
      </OutputWrapper>

    case OutputKind.InvalidOutput:
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
