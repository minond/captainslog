import * as React from "react"
import { FunctionComponent, useEffect, useReducer, useState } from "react"
import * as ReactDOM from "react-dom"

import {
  Input,
  Output,
  OutputKind,
  QueryResult,
  QueryResults,
  Report,
  Variable,
} from "./definitions"

import { scalar, valueOf, valuesOf } from "./report_builder/outputs/utils"

namespace Network {
  export const cachedExecuteQuery = (query: string): Promise<QueryResults> =>
    new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open("POST", "/query/execute")
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Accept", "application/json")
      xhr.onload = () => resolve(JSON.parse(xhr.responseText))
      xhr.onerror = () => reject(new Error(`query execution request error: ${xhr.responseText}`))
      xhr.send(JSON.stringify({query}))
    })

  export const loadReports = (): Promise<Report[]> =>
    new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open("GET", "/reports")
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Accept", "application/json")
      xhr.onload = () => resolve(JSON.parse(xhr.responseText))
      xhr.onerror = () => reject(new Error(`request error: ${xhr.responseText}`))
      xhr.send()
    })
}

namespace Query {
  export const getInputForMergeField = (field: string, inputs: Input[]): Input | null => {
    for (let i = 0, len = inputs.length; i < len; i++) {
      if (inputs[i].variable.label === field) {
        return inputs[i]
      }
    }
    return null
  }

  const cleanMergeField = (field: string): string =>
    field.replace(/^{{/, "").replace(/}}$/, "")

  const getMergeFields = (query: string): string[] =>
    query.match(/{{.+?}}/g) || []

  export const getCleanMergeFields = (query: string): string[] =>
    getMergeFields(query).map(cleanMergeField)

  export const mergeFields = (query: string, inputs: Input[]): string => {
    const fields = getMergeFields(query)
    const selected = inputs.reduce((acc, input) => {
      acc[input.variable.label] = input.value
      return acc
    }, {} as { [index: string]: string })

    for (let i = 0, len = fields.length; i < len; i++) {
      query = query.replace(new RegExp(fields[i], "g"),
        selected[cleanMergeField(fields[i])])
    }

    return query
  }

  export const isReadyToExecute = (query: string, inputs: Input[]): boolean => {
    const fields = getCleanMergeFields(query)
    const selected = inputs.reduce((acc, input) => {
      acc[input.variable.label] = true
      return acc
    }, {} as { [index: string]: boolean })

    for (let i = 0, len = fields.length; i < len; i++) {
      if (!selected[fields[i]]) {
        return false
      }
    }

    return true
  }
}

namespace Variables {
  type InputsProps = {
    variables: Variable[]
    inputs: Input[]
    onSelect: (val: string, v: Variable) => void
  }

  export const Form = ({ variables, inputs, onSelect }: InputsProps) => {
    const variableFields = variables.map((variable) => {
      const val = inputs.reduce((def, input) =>
        input.variable.id === variable.id ? input.value : def, variable.defaultValue)

      return <div title={variable.query} key={variable.label} className="report-variable-field">
        <label>
          <span>{variable.label}</span>
          <select value={val} onChange={(ev) => onSelect(ev.target.value, variable)}>
            <option key="blank" value="" label="Select a value" />
            {!variable.options ? null : variable.options.map((option, i) =>
              <option key={i + option} value={option} label={option}>{option}</option>)}
          </select>
        </label>
      </div>
    })

    return <div className="report-variable-fields">
      {variableFields}
    </div>
  }
}

namespace Editor {
  type FormProps = {
    output: Output,
    onSave: (output: Output) => void
    onCancel: () => void
  }

  export const Form = ({ output, onSave, onCancel }: FormProps) => {
    const [kind, setKind] = useState<OutputKind>(output.kind)
    const [label, setLabel] = useState<string>(output.label)
    const [query, setQuery] = useState<string>(output.query)
    const [width, setWidth] = useState<string>(output.width)

    const updated = { ...output, kind, label, query, width }

    return <div className="report-edit-form">
      <table>
        <tbody>
          <tr>
            <td>
              <label className="report-edit-form-label">
                <span>Label</span>
                <input value={label} onChange={(ev) => setLabel(ev.target.value)} />
              </label>
              <label className="report-edit-form-label">
                <span>Width</span>
                <input value={width} onChange={(ev) => setWidth(ev.target.value)} />
              </label>
              <label className="report-edit-form-label">
                <span>Kind</span>
                <select value={kind} onChange={(ev) => setKind(ev.target.value as OutputKind)}>
                  <option value={OutputKind.TableOutput} label="Table" />
                  <option value={OutputKind.ChartOutput} label="Chart" />
                  <option value={OutputKind.ValueOutput} label="Value" />
                </select>
              </label>
            </td>
            <td>
              <label className="report-edit-form-label">
                <span>Query</span>
                <textarea value={query} onChange={(ev) => setQuery(ev.target.value)} />
              </label>
            </td>
          </tr>
          <tr>
            <td colSpan={2} className="report-edit-form-actions">
              <button onClick={onCancel}>Cancel</button>
              <button onClick={() => onSave(updated)}>Save</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  }
}

import { ChartRawOutput } from "./report_builder/outputs/chart"
import { TableRawOutput } from "./report_builder/outputs/table"
// import { ValueRawOutput } from "./report_builder/outputs/value"

import { ChartOutput } from "./report_builder/outputs/chart"
import { TableOutput } from "./report_builder/outputs/table"
// import { ValueOutput } from "./report_builder/outputs/value"

namespace Outputs {
  export type Definition = {
    kind: OutputKind
    label: string
    query: string
    width: string
  }

  type ViewProps = {
    outputs: Output[]
    onEdit: (output: Output) => void
  }

  export const View = ({ outputs, onEdit: onEditOutput }: ViewProps) =>
    <>
    {outputs.map((output, i) => {
      const definition = output
      const results = output.results
      const loading = output.loading
      const onEdit = (_: Definition) => onEditOutput(output)
      const props = { definition, onEdit, loading }
      const elem = !results ?
        <IncompleteOutput {...props} /> :
        <LookupOutput {...props} results={results} />

      return <span key={i} className="report-output">{elem}</span>
    })}
    </>

  type IncompleteOutputProps = {
    definition: Definition
    loading?: boolean
    onEdit?: (def: Definition) => void
  }

  const IncompleteOutput = (props: IncompleteOutputProps) => {
    switch (props.definition.kind) {
      case OutputKind.TableOutput:
        return <OutputWrapper {...props} outputName="table">
          <TableRawOutput />
        </OutputWrapper>

      case OutputKind.ChartOutput:
        return <OutputWrapper {...props} outputName="chart">
          <ChartRawOutput />
        </OutputWrapper>

      case OutputKind.ValueOutput:
        return <OutputWrapper {...props} outputName="value">
          <ValueRawOutput />
        </OutputWrapper>

      case OutputKind.InvalidOutput:
      default:
        return null
    }
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

  const OutputWrapper: FunctionComponent<OutputWrapperProps> = (props) =>
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

  const LookupOutput = (props: LookupOutputProps) => {
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

  const DEFAULT_VALUE = "N/A"

  const getValue = (res: QueryResults) =>
    res.results && res.results[0] ? valueOf(res.results[0][0]) : undefined

  type ValueOutputProps = {
    results: QueryResults
  }

  export const ValueOutput = ({ results }: ValueOutputProps) =>
    <ValueRawOutput raw={getValue(results)} />

  type ValueRawOutputProps = {
    raw?: scalar
  }

  export const ValueRawOutput = ({ raw }: ValueRawOutputProps) =>
    <div className="value-output-wrapper">
      <span className="value-output-value">{raw || DEFAULT_VALUE}</span>
    </div>
}

namespace Reducer {
  type OutputReducerSetOutputsAction = { kind: "setOutputs", outputs: Output[] }
  type OutputReducerSetResultsAction = { kind: "setResults", output: Output, results: QueryResults }
  type OutputReducerUpdateDefinitionAction = { kind: "updateDefinition", output: Output }
  type OutputReducerIsLoadingAction = { kind: "isLoading", output: Output }
  export type OutputReducerAction
    = OutputReducerSetOutputsAction
    | OutputReducerSetResultsAction
    | OutputReducerUpdateDefinitionAction
    | OutputReducerIsLoadingAction
  export type OutputReducer = (outputs: Output[], action: OutputReducerAction) => Output[]
  export const outputReducer: OutputReducer = (outputs, action) => {
    switch (action.kind) {
      case "setOutputs":
        return action.outputs

      case "setResults": {
        const { output, results } = action
        return outputs.map((o) =>
          o.id !== output.id ? o : { ...o, results, loading: false })
      }

      case "isLoading": {
        const { output } = action
        return outputs.map((o) =>
          o.id !== output.id ? o : { ...o, loading: true, reload: false })
      }

      case "updateDefinition": {
        const { output } = action
        return outputs.map((o) =>
          o.id !== output.id ? o : {
            ...o,
            loading: false,
            reload: o.query !== output.query,
            kind: output.kind,
            label: output.label,
            query: output.query,
            width: output.width,
          })
      }
    }
  }

  type InputReducerChangeHandledAction = { kind: "changeHandled", input: Input }
  type InputReducerSetInputAction = { kind: "setInput", input: Input }
  export type InputReducerAction = InputReducerChangeHandledAction | InputReducerSetInputAction
  export type InputReducer = (inputs: Input[], action: InputReducerAction) => Input[]
  export const inputReducer: InputReducer = (inputs, action) => {
    switch (action.kind) {
      case "changeHandled":
        return inputs.map((i) =>
          i.variable.id !== action.input.variable.id ? i :
            { ...i, changeHandled: true })

      case "setInput":
        const newInputs = inputs
          .filter((i) => i.variable.id !== action.input.variable.id)
        newInputs.push(action.input)
        return newInputs
    }
  }

  type VariableReducerSetVariablesAction = { kind: "setVariables", variables: Variable[] }
  type VariableReducerSetOptionsAction = { kind: "setOptions", variable: Variable, options: string[] }
  export type VariableReducerAction = VariableReducerSetVariablesAction | VariableReducerSetOptionsAction
  export type VariableReducer = (variables: Variable[], action: VariableReducerAction) => Variable[]
  export const variableReducer: VariableReducer = (variables, action) => {
    switch (action.kind) {
      case "setVariables":
        return action.variables

      case "setOptions":
        const { variable, options } = action
        return variables.map((v) =>
          v.id !== variable.id ? v : { ...v, options })
    }
  }
}

namespace Report {
  const loadReportSettings = (
    report: Report,
    dispatchVariable: (_: Reducer.VariableReducerAction) => void,
    dispatchInput: (_: Reducer.InputReducerAction) => void,
    dispatchOutput: (_: Reducer.OutputReducerAction) => void,
  ) => {
    dispatchOutput({
      kind: "setOutputs",
      outputs: report.outputs,
    })

    dispatchVariable({
      kind: "setVariables",
      variables: report.variables
    })

    report.variables.map((variable) =>
      Network.cachedExecuteQuery(variable.query).then((res) => {
        const options = valuesOf(res)
        dispatchVariable({ kind: "setOptions", options, variable })

        if (!!variable.defaultValue && options.indexOf(variable.defaultValue) !== -1) {
          const value = variable.defaultValue
          const input = { variable, value }
          dispatchInput({ kind: "setInput", input })
        }
      }))
  }

  const loadReportData = (
    inputs: Input[],
    outputs: Output[],
    dispatchInput: (_: Reducer.InputReducerAction) => void,
    dispatchOutput: (_: Reducer.OutputReducerAction) => void,
  ) => {
    outputs.map((output) => {
      if (!Query.isReadyToExecute(output.query, inputs)) {
        return
      }

      const queryInputs = Query.getCleanMergeFields(output.query)
        .reduce((acc, field) => {
          const input = Query.getInputForMergeField(field, inputs)
          if (input) {
            acc.push(input)
          }
          return acc
        }, [] as Input[])

      const shouldLoad = queryInputs.reduce((doIt, input) =>
        !input.changeHandled || doIt, false)

      if (!shouldLoad && !output.reload) {
        return
      }

      dispatchOutput({ kind: "isLoading", output })

      queryInputs.map((input) =>
        dispatchInput({ kind: "changeHandled", input }))

      Network.cachedExecuteQuery(Query.mergeFields(output.query, inputs)).then((results) =>
        dispatchOutput({ kind: "setResults", output, results }))
    })
  }

  export const View = (props: {}) => {
    const [report, setReport] = useState<Report | null>(null)
    const [variables, dispatchVariable] = useReducer(Reducer.variableReducer, [], (i) => i)
    const [inputs, dispatchInput] = useReducer(Reducer.inputReducer, [], (i) => i)
    const [outputs, dispatchOutput] = useReducer(Reducer.outputReducer, [], (i) => i)

    const [editing, setEditing] = useState<Output | null>(null)

    const setInput = (value: string, variable: Variable) =>
      dispatchInput({ kind: "setInput", input: { value, variable } })

    const saveOutputDefinition = (output: Output) => {
      setEditing(null)
      dispatchOutput({ kind: "updateDefinition", output })
    }

    const editForm = editing &&
      <Editor.Form
        output={editing}
        onSave={saveOutputDefinition}
        onCancel={() => setEditing(null)}
      />

    useEffect(() => {
      if (report) {
        loadReportSettings(report, dispatchVariable, dispatchInput, dispatchOutput)
      } else {
        Network.loadReports().then((reports) => setReport(reports[0] || {
          label: "",
          variables: [],
          outputs: []
        }))
      }
    }, [report])

    loadReportData(inputs, outputs, dispatchInput, dispatchOutput)

    return <>
      <h1>{report ? report.label : " "}</h1>
      {editForm}
      <Variables.Form variables={variables} inputs={inputs} onSelect={setInput} />
      <Outputs.View outputs={outputs} onEdit={(output) => setEditing(output)} />
    </>
  }
}

ReactDOM.render(<Report.View />, document.querySelector(".content-view"))
