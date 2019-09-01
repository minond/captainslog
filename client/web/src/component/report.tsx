import * as React from "react"
import { useEffect, useReducer, useState } from "react"

import { QueryResult, QueryResults } from "../definitions"
import { cachedExecuteQuery } from "../remote"

import { Output, OutputType } from "./outputs/output"

const dummy = {
  label: "Weight Trends",
  outputs: [
    {
      label: "Weight Trends",
      query:
        "select weight " +
        "from workouts " +
        "where exercise ilike '{{Exercise}}' " +
        "and weight is not null " +
        "order by created_at desc",
      type: OutputType.TableOutput,
    }
  ],
  variables: [
    {
      label: "Exercise",
      query:
        "select distinct exercise " +
        "from workouts " +
        "where exercise is not null " +
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
}

type Input = {
  variable: Variable
  input: string
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

const VariableInputs = (props: VariableInputsProps) => {
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

type InputReducerSetInputAction = { kind: "setInput", input: Input }
type InputReducerAction = InputReducerSetInputAction
type InputReducer = (inputs: Input[], action: InputReducerAction) => Input[]
const inputReducer: InputReducer = (inputs, action) => {
  switch (action.kind) {
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

const reportLoader = (report: Report, dispatchVariable: (_: VariableReducerAction) => void) => {
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

export const Report = (props: {}) => {
  const [report, setReport] = useState<Report | null>(dummy)

  const [variables, dispatchVariable] =
    useReducer<VariableReducer, Variable[]>(variableReducer, dummy.variables.slice(0), (i) => i)

  const [inputs, dispatchInput] =
    useReducer<InputReducer, Input[]>(inputReducer, [], (i) => i)

  useEffect(() => {
    if (report) {
      reportLoader(report, dispatchVariable)
    }
  }, [report])

  return <div>
    <VariableInputs
      variables={variables}
      onSelect={(input, variable) =>
        dispatchInput({ kind: "setInput", input: { input, variable } })}
    />

    {isReadyToExecute(dummy.outputs[0].query, inputs) ? mergeFields(dummy.outputs[0].query, inputs) : "..."}
  </div>
}
