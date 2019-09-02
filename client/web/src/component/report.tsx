import * as React from "react"
import { useEffect, useReducer, useState } from "react"

import { QueryResult, QueryResults } from "../definitions"
import { cachedExecuteQuery } from "../remote"

import { Definition, Output, OutputType } from "./outputs/output"

const dummy = {
  label: "Weight Trends",
  outputs: [
    {
      label: "Min",
      query:
        "select min(cast(weight as float)) " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      label: "Max",
      query:
        "select max(cast(weight as float)) " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null",
      type: OutputType.ValueOutput,
    },
    {
      label: "Weight Trends",
      query:
        "select cast(created_at as integer) as x, cast(weight as float) as y " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null " +
        "order by created_at asc",
      type: OutputType.ChartOutput,
    },
  ],
  variables: [
    {
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
  label: string
  query: string
  options?: string[]
}

type Output = {
  label: string
  type: OutputType
  query: string
  results?: QueryResults
}

type Input = {
  variable: Variable
  input: string
  changeHandled?: boolean
}

const isBool = (val: QueryResult): boolean => "Bool" in val
const isString = (val: QueryResult): boolean => "String" in val
const isFloat64 = (val: QueryResult): boolean => "Float64" in val
const isInt64 = (val: QueryResult): boolean => "Int64" in val
const isNumber = (val: QueryResult): boolean => isFloat64(val) || isInt64(val)

const valueOf = (val: QueryResult): string | number | boolean | undefined =>
  !val.Valid ? undefined :
    isString(val) ? val.String :
    isFloat64(val) ? val.Float64 :
    isInt64(val) ? val.Int64 :
    isBool(val) ? val.Bool :
    undefined

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
    acc[input.variable.label] = input.input
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

const VariablesForm = (props: VariableInputsProps) => {
  const variableFields = props.variables.map((variable) =>
    <div title={variable.query} key={variable.label} className="report-variable-field">
      <label>
        <span>{variable.label}</span>
        <select onChange={(ev) => props.onSelect(ev.target.value, variable)}>
          <option key="blank" value="" label="Select a value" />
          {!variable.options ? null : variable.options.map((option, i) =>
            <option key={i + option} value={option} label={option}>{option}</option>)}
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
        o.label !== output.label ? o : { ...o, results })
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
        i.variable.label !== action.input.variable.label ? i :
          { ...i, changeHandled: true })

    case "setInput":
      const newInputs = inputs
        .filter((i) => i.variable.label !== action.input.variable.label)
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
        v.label !== variable.label ? v : { ...v, options })
  }
}

const loadReportSettings = (
  report: Report,
  dispatchVariable: (_: VariableReducerAction) => void,
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
    cachedExecuteQuery(variable.query).then((res) =>
      dispatchVariable({
        kind: "setOptions",
        options: valuesOf(res),
        variable,
      })))
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
  label: output.label,
  query: output.query,
})

type OutputsProps = { inputs: Input[], outputs: Output[] }
const Outputs = (props: OutputsProps) =>
  <>
  {props.outputs.map((output, i) => {
    const elem = !output.results ? null :
      <Output type={output.type} definition={outputDefinition(output)} results={output.results} />
    return <div key={i} className="report-output">{elem}</div>
  })}
  </>

export const Report = (props: {}) => {
  const [report, setReport] = useState<Report | null>(dummy)
  const [variables, dispatchVariable] = useReducer(variableReducer, [], (i) => i)
  const [inputs, dispatchInput] = useReducer(inputReducer, [], (i) => i)
  const [outputs, dispatchOutput] = useReducer(outputReducer, [], (i) => i)

  const setInput = (input: string, variable: Variable) =>
    dispatchInput({ kind: "setInput", input: { input, variable } })

  useEffect(() => {
    if (report) {
      loadReportSettings(report, dispatchVariable, dispatchOutput)
    }
  }, [report])

  loadReportData(inputs, outputs, dispatchInput, dispatchOutput)

  return <div>
    <VariablesForm variables={variables} onSelect={setInput} />
    <Outputs inputs={inputs} outputs={outputs} />
  </div>
}
