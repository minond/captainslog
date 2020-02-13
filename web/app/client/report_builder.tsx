import * as React from "react"
import { FunctionComponent, useEffect, useReducer, useState, useRef } from "react"
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

import {
  NO_RESULTS,
  isBool,
  isFloat64,
  isInt64,
  isNumber,
  isString,
  isTime,
  numberOf,
  scalar,
  stringOf,
  stringValueOf,
  valueOf,
  valuesOf,
} from "./report_builder/outputs/utils"

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

  const Header = ({ definition, onEdit }: HeaderProps) =>
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

  const ValueOutput = ({ results }: ValueOutputProps) =>
    <ValueRawOutput raw={getValue(results)} />

  type ValueRawOutputProps = {
    raw?: scalar
  }

  const ValueRawOutput = ({ raw }: ValueRawOutputProps) =>
    <div className="value-output-wrapper">
      <span className="value-output-value">{raw || DEFAULT_VALUE}</span>
    </div>

  const classOf = (val: QueryResult): string =>
    !val.Valid ? "table-output-type-null" :
      isString(val) ? "table-output-type-string" :
      isNumber(val) ? "table-output-type-number" :
      isBool(val) ? "table-output-type-boolean" :
      isTime(val) ? "table-output-type-timestamp" :
      "table-output-type-unknown"

  type TableOutputProps = {
    results: QueryResults
  }

  const TableOutput = (props: TableOutputProps) =>
    <TableRawOutput {...props} />

  type TableRawOutputProps = {
    results?: QueryResults
  }

  const TableRawOutput = ({ results }: TableRawOutputProps) =>
    results && results.results && results.results.length ?
      <table className="table-output-table">
        <thead>
          <tr>
            {results.columns.map((col, i) =>
              <td key={col + i}>{col}</td>)}
          </tr>
        </thead>
        <tbody>
          {results.results && results.results.map((row, ridx) =>
            <tr key={ridx}>
              {row.map((val, vidx) =>
                <td key={vidx} className={classOf(val)}>{stringValueOf(val)}</td>)}
            </tr>)}
        </tbody>
      </table> :
      <div className="output-no-data">{NO_RESULTS}</div>

  const TIGHT_FIT_CONTAINER_WIDTH_MAX = 400 // A container that is this wide or less is considered to be "small".
  const TIGHT_FIT_DATUM_LENGTH_MIN = 50 // There must be at least this many items before the "tight fit" is used.
  const TIGHT_FIT_BORDER_WIDTH = 1
  const TIGHT_FIT_ITEM_PADDING = 4
  const CONFY_FIT_BORDER_WIDTH = 2
  const CONFY_FIT_ITEM_PADDING = 6

  type ChartRow = {
    id: string
    x: {
      label: string
      value: number
    }
    y: number
  }

  type ChartData = {
    datum: ChartRow[],
    diffX: number
    diffY: number
    maxX: number
    minX: number
    maxY: number
    minY: number
  }

  const normalizeResults = (results: QueryResults): ChartData | undefined => {
    if (!results.results) {
      return
    }

    if (results.columns.length < 2) {
      return
    }

    const datum = results.results.map((cell: QueryResult[], i) => {
      return {
        id: Math.random().toString(),
        x: {
          label: stringOf(cell[0]),
          value: numberOf(cell[0]),
        },
        y: numberOf(cell[1]),
      }
    }).sort((a, b) => {
      if (a.x.value > b.x.value) {
        return 1
      } else if (a.x.value < b.x.value) {
        return -1
      }

      return 0
    })

    const X_PADDING = 10
    const Y_PADDING = X_PADDING

    const xs = datum.map((row) => row.x.value)
    const ys = datum.map((row) => row.y)

    const minX = Math.min.apply(Math, xs) - X_PADDING
    const maxX = Math.max.apply(Math, xs) + X_PADDING
    const minY = Math.min.apply(Math, ys) - Y_PADDING
    const maxY = Math.max.apply(Math, ys) + Y_PADDING

    const diffX = maxX - minX
    const diffY = maxY - minY

    return { datum, diffX, diffY, minX, maxX, minY, maxY }
  }

  const buildChartRow = (containerWidth: number, index: number, row: ChartRow, chartData: ChartData) => {
    let width
    let left
    let borderWidth
    let itemPadding

    const datumLength = chartData.datum.length
    const isSmallView = containerWidth <= TIGHT_FIT_CONTAINER_WIDTH_MAX
    const useTightFit = isSmallView && datumLength >= TIGHT_FIT_DATUM_LENGTH_MIN

    if (useTightFit) {
      borderWidth = TIGHT_FIT_BORDER_WIDTH
      itemPadding = TIGHT_FIT_ITEM_PADDING
    } else {
      borderWidth = CONFY_FIT_BORDER_WIDTH
      itemPadding = CONFY_FIT_ITEM_PADDING
    }

    if (datumLength === 1) {
      width = containerWidth - (borderWidth * 2)
      left = 0
    } else {
      const maxWidth = containerWidth / datumLength
      width = maxWidth - itemPadding
      left = index * maxWidth
    }

    const height = row.y
    const style = { height, width, left, borderWidth }
    const title = `${row.x.label}: ${row.y}`
    return <div
      className="chart-row"
      key={row.id}
      title={title}
      style={style}
    />
  }

  type ChartOutputProps = {
    results: QueryResults
  }

  const ChartOutput = (props: ChartOutputProps) =>
    <ChartRawOutput {...props} />

  type ChartRawOutputProps = {
    results?: QueryResults
  }

  const ChartRawOutput = ({ results }: ChartRawOutputProps) => {
    const chartContainerRef = useRef(null)
    const [width, setWidth] = useState(0)

    const setWidthUsingContainer = () => {
      if (chartContainerRef.current) {
        // XXX need to do `as any` since the compiler is complaining about a
        // possible null value, but why?
        const container = chartContainerRef.current as any
        const { width: containerWidth } = container.getBoundingClientRect()
        setWidth(containerWidth)
      }
    }

    const containerResizeHandler = () => {
      window.addEventListener("resize", setWidthUsingContainer)
      return () => window.removeEventListener("resize", setWidthUsingContainer)
    }

    useEffect(containerResizeHandler)
    useEffect(setWidthUsingContainer, [chartContainerRef.current])

    if (!results || !results.results || !results.results.length) {
      return <div className="output-no-data">{NO_RESULTS}</div>
    }

    const chartData = normalizeResults(results)

    if (!chartData) {
      return <div className="output-no-data">{NO_RESULTS}</div>
    }

    return <div className="chart-output-wrapper">
      <div className="chart-container" ref={chartContainerRef}>
        {chartData.datum.map((row, i) => buildChartRow(width, i, row, chartData))}
      </div>
    </div>
  }
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
