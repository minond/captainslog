import * as React from "react"
import { useEffect, useReducer, useState } from "react"
import * as ReactDOM from "react-dom"

// TODO implement cachedExecuteQuery
// import { cachedExecuteQuery } from "./remote"
const cachedExecuteQuery = (query: string): Promise<QueryResults> =>
  new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest()
    xhr.open("POST", "/query/execute")
    xhr.setRequestHeader("Content-Type", "application/json")
    xhr.setRequestHeader("Accept", "application/json")
    xhr.send(JSON.stringify({query}))
    xhr.onload = () => resolve(JSON.parse(xhr.responseText))
    xhr.onerror = () => reject(new Error(`query execution request error: ${xhr.responseText}`))
  })

import {
  Input,
  Output,
  OutputType,
  QueryResult,
  QueryResults,
  Report,
  Variable,
} from "./definitions"

import { IncompleteOutput } from "./report_builder/outputs/incomplete"
import { Definition, LookupOutput, parseOutputType } from "./report_builder/outputs/output"
import { valueOf } from "./report_builder/outputs/utils"

const dummy = {
  label: "Weight Trends",
  outputs: [
    {
      id: Math.random().toString(),
      label: "Min",
      width: "150px",
      query:
        "select min(cast(weight as float))\n" +
        "from workouts\n" +
        "where exercise ilike '{{Exercise}}'\n" +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      id: Math.random().toString(),
      label: "Max",
      width: "150px",
      query:
        "select max(cast(weight as float))\n" +
        "from workouts\n" +
        "where exercise ilike '{{Exercise}}'\n" +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      id: Math.random().toString(),
      label: "Count",
      width: "150px",
      query:
        "select count(1)\n" +
        "from workouts\n" +
        "where exercise ilike '{{Exercise}}'\n" +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      id: Math.random().toString(),
      label: "Weight Trends",
      width: "100%",
      query:
        "select cast(_collected_at as integer) as x,\n  cast(weight as float) as y\n" +
        "from workouts\n" +
        "where exercise ilike '{{Exercise}}'\n" +
        "and weight is not null\n" +
        "order by _collected_at asc",
      type: OutputType.ChartOutput,
    },
    {
      id: Math.random().toString(),
      label: "Last 20 Entries",
      width: "100%",
      query:
        "select exercise, cast(weight as float) as weight,\n  to_timestamp(cast(_collected_at as integer)) as date\n" +
        "from workouts\n" +
        "where exercise ilike '{{Exercise}}'\n" +
        "and weight is not null\n" +
        "order by _collected_at desc\n" +
        "limit 20",
      type: OutputType.TableOutput,
    },
  ],
  variables: [
    {
      defaultValue: "Squats",
      id: Math.random().toString(),
      label: "Exercise",
      query:
        "select distinct exercise\n" +
        "from workouts\n" +
        "where exercise is not null\n" +
        "and weight is not null\n" +
        "order by exercise",
    }
  ],
}

const valuesOf = (res: QueryResults): string[] =>
  !res.results ? [] : res.results.map((row) => {
    const val = valueOf(row[0])
    return val !== undefined ? val.toString() : "undefined"
  })

const getInputForMergeField = (field: string, inputs: Input[]): Input | null => {
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

const getCleanMergeFields = (query: string): string[] =>
  getMergeFields(query).map(cleanMergeField)

const mergeFields = (query: string, inputs: Input[]): string => {
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

const isReadyToExecute = (query: string, inputs: Input[]): boolean => {
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

type VariableInputsProps = {
  variables: Variable[]
  inputs: Input[]
  onSelect: (val: string, v: Variable) => void
}

const VariablesForm = ({ variables, inputs, onSelect }: VariableInputsProps) => {
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

type EditFormProps = {
  output: Output,
  onSave: (output: Output) => void
  onCancel: () => void
}

const EditForm = ({ output, onSave, onCancel }: EditFormProps) => {
  const [type, setType] = useState<OutputType>(output.type)
  const [label, setLabel] = useState<string>(output.label)
  const [query, setQuery] = useState<string>(output.query)
  const [width, setWidth] = useState<string>(output.width)

  const updated = { ...output, type, label, query, width }

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
              <span>Type</span>
              <select value={type} onChange={(ev) => setType(parseOutputType(ev.target.value))}>
                <option value={OutputType.TableOutput} label="Table" />
                <option value={OutputType.ChartOutput} label="Chart" />
                <option value={OutputType.ValueOutput} label="Value" />
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

type OutputReducerSetOutputsAction = { kind: "setOutputs", outputs: Output[] }
type OutputReducerSetResultsAction = { kind: "setResults", output: Output, results: QueryResults }
type OutputReducerUpdateDefinitionAction = { kind: "updateDefinition", output: Output }
type OutputReducerIsLoadingAction = { kind: "isLoading", output: Output }
type OutputReducerAction
  = OutputReducerSetOutputsAction
  | OutputReducerSetResultsAction
  | OutputReducerUpdateDefinitionAction
  | OutputReducerIsLoadingAction
type OutputReducer = (outputs: Output[], action: OutputReducerAction) => Output[]
const outputReducer: OutputReducer = (outputs, action) => {
  switch (action.kind) {
    case "setOutputs":
      return action.outputs

    case "setResults": {
      const { output, results } = action
      return outputs.map((o) =>
        o.id !== output.id ? o : { ...o, results })
    }

    case "isLoading": {
      const { output } = action
      return outputs.map((o) =>
        o.id !== output.id ? o : { ...o, reload: false })
    }

    case "updateDefinition": {
      const { output } = action
      return outputs.map((o) =>
        o.id !== output.id ? o : {
          ...o,
          reload: o.query !== output.query,
          type: output.type,
          label: output.label,
          query: output.query,
          width: output.width,
        })
    }
  }
}

type InputReducerChangeHandledAction = { kind: "changeHandled", input: Input }
type InputReducerSetInputAction = { kind: "setInput", input: Input }
type InputReducerAction = InputReducerChangeHandledAction | InputReducerSetInputAction
type InputReducer = (inputs: Input[], action: InputReducerAction) => Input[]
const inputReducer: InputReducer = (inputs, action) => {
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
type VariableReducerAction = VariableReducerSetVariablesAction | VariableReducerSetOptionsAction
type VariableReducer = (variables: Variable[], action: VariableReducerAction) => Variable[]
const variableReducer: VariableReducer = (variables, action) => {
  switch (action.kind) {
    case "setVariables":
      return action.variables

    case "setOptions":
      const { variable, options } = action
      return variables.map((v) =>
        v.id !== variable.id ? v : { ...v, options })
  }
}

const loadReportSettings = (
  report: Report,
  dispatchVariable: (_: VariableReducerAction) => void,
  dispatchInput: (_: InputReducerAction) => void,
  dispatchOutput: (_: OutputReducerAction) => void,
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
    cachedExecuteQuery(variable.query).then((res) => {
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
  dispatchInput: (_: InputReducerAction) => void,
  dispatchOutput: (_: OutputReducerAction) => void,
) => {
  outputs.map((output) => {
    if (!isReadyToExecute(output.query, inputs)) {
      return
    }

    const queryInputs = getCleanMergeFields(output.query)
      .reduce((acc, field) => {
        const input = getInputForMergeField(field, inputs)
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

    cachedExecuteQuery(mergeFields(output.query, inputs)).then((results) =>
      dispatchOutput({ kind: "setResults", output, results }))
  })
}

type OutputsProps = {
  outputs: Output[]
  onEdit: (output: Output) => void
}

const Outputs = ({ outputs, onEdit: onEditOutput }: OutputsProps) =>
  <>
  {outputs.map((output, i) => {
    const definition = output
    const results = output.results
    const onEdit = (_: Definition) => onEditOutput(output)
    const props = { definition, onEdit }
    const elem = !results ?
      <IncompleteOutput {...props} /> :
      <LookupOutput {...props} results={results} />

    return <span key={i} className="report-output">{elem}</span>
  })}
  </>

export const ReportView = (props: {}) => {
  const [report, setReport] = useState<Report | null>(dummy)
  const [variables, dispatchVariable] = useReducer(variableReducer, [], (i) => i)
  const [inputs, dispatchInput] = useReducer(inputReducer, [], (i) => i)
  const [outputs, dispatchOutput] = useReducer(outputReducer, [], (i) => i)

  const [editing, setEditing] = useState<Output | null>(null)

  const setInput = (value: string, variable: Variable) =>
    dispatchInput({ kind: "setInput", input: { value, variable } })

  const saveOutputDefinition = (output: Output) => {
    setEditing(null)
    dispatchOutput({ kind: "updateDefinition", output })
  }

  const editForm = editing &&
    <EditForm
      output={editing}
      onSave={saveOutputDefinition}
      onCancel={() => setEditing(null)}
    />

  useEffect(() => {
    if (report) {
      loadReportSettings(report, dispatchVariable, dispatchInput, dispatchOutput)
    }
  }, [report])

  loadReportData(inputs, outputs, dispatchInput, dispatchOutput)

  return <div className="report">
    <h1>{report ? report.label : " "}</h1>
    {editForm}
    <VariablesForm variables={variables} inputs={inputs} onSelect={setInput} />
    <Outputs outputs={outputs} onEdit={(output) => setEditing(output)} />
  </div>
}

ReactDOM.render(<ReportView />, document.getElementById("report-builder-mount"))
