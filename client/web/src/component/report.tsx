import * as React from "react"
import { useEffect, useState } from "react"

import { QueryResult, QueryResults } from "../definitions"
import { cachedExecuteQuery } from "../remote"

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
      type: 2,
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

type Variable = {
  label: string
  query: string
  options?: string[]
}

enum OutputType {
  InvalidOutput,
  LineGraphOutput,
}

type Output = {
  label: string
  type: OutputType
  query: string
}

type Selection = {
  variable: Variable
  selection: string
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

const mergeFields = (query: string, selections: Selection[]): string => {
  const fields = getMergeFields(query)
  const selected = selections.reduce((acc, selection) => {
    acc[selection.variable.label] = selection.selection
    return acc
  }, {} as { [index: string]: string })

  for (let i = 0, len = fields.length; i < len; i++) {
    query = query.replace(new RegExp(fields[i], "g"),
      selected[cleanMergeField(fields[i])])
  }

  return query
}

const isReadyToExecute = (query: string, selections: Selection[]): boolean => {
  const fields = getCleanMergeFields(query)
  const selected = selections.reduce((acc, selection) => {
    acc[selection.variable.label] = true
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

export const Report = (props: {}) => {
  // TODO Figure out how array state variables are supposed to be updated.
  const [variables, setVariables] = useState<Variable[]>(dummy.variables.slice(0))
  const [selections, setSelections] = useState<Selection[]>([])

  useEffect(() => {
    // TODO There's gotta be a better way of loading the options into memory.
    variables.map((variable) =>
      cachedExecuteQuery(variable.query).then((res) => {
        variable.options = valuesOf(res)
        setVariables(variables.slice(0))
      }))
  }, [])

  const select = (selection: string, variable: Variable) => {
    const newSelections = selections
      .filter((sel) => sel.variable.label !== variable.label)
    newSelections.push({ selection, variable })
    setSelections(newSelections)
  }

  return <div>
    <VariableInputs variables={variables} onSelect={select} />

    {isReadyToExecute(dummy.outputs[0].query, selections) ? mergeFields(dummy.outputs[0].query, selections) : "..."}
  </div>
}
