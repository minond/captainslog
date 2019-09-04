import * as React from "react"
import { useEffect, useReducer, useState } from "react"

import { QueryResult, QueryResults } from "../definitions"
import { cachedExecuteQuery } from "../remote"

import { IncompleteOutput } from "./outputs/incomplete"
import { Definition, LookupOutput, OutputType } from "./outputs/output"
import { valueOf } from "./outputs/utils"

const dummy = {
  label: "Weight Trends",
  outputs: [
    {
      id: Math.random().toString(),
      label: "Min",
      query:
        "select min(cast(weight as float)) " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      id: Math.random().toString(),
      label: "Max",
      query:
        "select max(cast(weight as float)) " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      id: Math.random().toString(),
      label: "Count",
      query:
        "select count(1) " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      id: Math.random().toString(),
      label: "Weight Trends",
      query:
        "select cast(created_at as integer) as x, cast(weight as float) as y " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null " +
        "order by created_at asc",
      type: OutputType.ChartOutput,
    },
    {
      id: Math.random().toString(),
      label: "Last 20 Entries",
      query:
        "select exercise, cast(weight as float) as weight, to_timestamp(cast(created_at as integer)) as date " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null " +
        "order by created_at desc " +
        "limit 20",
      type: OutputType.TableOutput,
    },
  ],
  variables: [
    {
      defaultInput: "Squats",
      id: Math.random().toString(),
      label: "Exercise",
      query:
        "select distinct exercise " +
        "from workouts " +
        "where exercise is not null " +
        "and weight is not null " +
        "order by exercise",
    }
  ],
}

type Report = {
  label: string
  outputs: Output[]
  variables: Variable[]
}

type Variable = {
  id: string
  label: string
  query: string
  defaultInput?: string
  options?: string[]
}

type Output = {
  id: string
  label: string
  type: OutputType
  query: string
  results?: QueryResults
}

type Input = {
  variable: Variable
  value: string
  changeHandled?: boolean
}

const valuesOf = (res: QueryResults): string[] =>
  !res.data ? [] : res.data.map((row) => {
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
  onSelect: (val: string, v: Variable) => void
}

const VariablesForm = ({ variables, onSelect }: VariableInputsProps) => {
  const variableFields = variables.map((variable) =>
    <div title={variable.query} key={variable.label} className="report-variable-field">
      <label>
        <span>{variable.label}</span>
        <select onChange={(ev) => onSelect(ev.target.value, variable)}>
          <option key="blank" value="" label="Select a value" />
          {!variable.options ? null : variable.options.map((option, i) =>
            <option
              key={i + option}
              selected={!!variable.defaultInput && option === variable.defaultInput}
              value={option}
              label={option}
            >
              {option}
            </option>
          )}
        </select>
      </label>
    </div>)

  return <div className="report-variable-fields">
    {variableFields}
  </div>
}

type OutputReducerSetOutputsAction = { kind: "setOutputs", outputs: Output[] }
type OutputReducerSetResultsAction = { kind: "setResults", output: Output, results: QueryResults }
type OutputReducerAction = OutputReducerSetOutputsAction | OutputReducerSetResultsAction
type OutputReducer = (outputs: Output[], action: OutputReducerAction) => Output[]
const outputReducer: OutputReducer = (outputs, action) => {
  switch (action.kind) {
    case "setOutputs":
      return action.outputs

    case "setResults":
      const { output, results } = action
      return outputs.map((o) =>
        o.id !== output.id ? o : { ...o, results })
      return outputs
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

      if (!!variable.defaultInput && options.indexOf(variable.defaultInput) !== -1) {
        const value = variable.defaultInput
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

    if (!shouldLoad) {
      return
    }

    queryInputs.map((input) =>
      dispatchInput({ kind: "changeHandled", input }))

    cachedExecuteQuery(mergeFields(output.query, inputs)).then((results) =>
      dispatchOutput({ kind: "setResults", output, results }))
  })
}

const outputDefinition = (output: Output): Definition => ({
  type: output.type,
  label: output.label,
  query: output.query,
})

type OutputsProps = { outputs: Output[] }
const Outputs = ({ outputs }: OutputsProps) =>
  <>
  {outputs.map((output, i) => {
    const definition = outputDefinition(output)
    const results = output.results
    const elem = !results ?
      <IncompleteOutput definition={definition} /> :
      <LookupOutput definition={definition} results={results} />

    return <span key={i} className="report-output">{elem}</span>
  })}
  </>

export const Report = (props: {}) => {
  const [report, setReport] = useState<Report | null>(dummy)
  const [variables, dispatchVariable] = useReducer(variableReducer, [], (i) => i)
  const [inputs, dispatchInput] = useReducer(inputReducer, [], (i) => i)
  const [outputs, dispatchOutput] = useReducer(outputReducer, [], (i) => i)

  const setInput = (value: string, variable: Variable) =>
    dispatchInput({ kind: "setInput", input: { value, variable } })

  useEffect(() => {
    if (report) {
      loadReportSettings(report, dispatchVariable, dispatchInput, dispatchOutput)
    }
  }, [report])

  loadReportData(inputs, outputs, dispatchInput, dispatchOutput)

  return <div>
    <h2>{report ? report.label : " "}</h2>
    <VariablesForm variables={variables} onSelect={setInput} />
    <Outputs outputs={outputs} />
  </div>
}
