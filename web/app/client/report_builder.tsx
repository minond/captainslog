import * as React from "react"
import { FunctionComponent, useEffect, useReducer, useState, useRef } from "react"
import * as ReactDOM from "react-dom"

declare global {
  const REPORT: Definitions.Report
}

namespace Definitions {
  export type Report = {
    label: string
    outputs: Output[]
    variables: Variable[]
  }

  export type Variable = {
    id: string
    label: string
    query: string
    defaultValue?: string
    options?: string[]
  }

  export enum OutputKind {
    InvalidOutput = -1,
    TableOutput = "table",
    ChartOutput = "chart",
    ValueOutput = "value",
  }

  export type Output = {
    id: string
    label: string
    kind: OutputKind
    query: string
    width?: string
    height?: string
    reload?: boolean
    loading?: boolean
    results?: QueryResults
  }

  export type Input = {
    variable: Variable
    value: string
    changeHandled?: boolean
  }

  export type QueryResults = {
    columns: string[]
    results: QueryResult[][] | null
  }

  export type QueryResult = {
    Bool?: boolean
    Float64?: number
    Int64?: number
    String?: string
    Time?: Date
    Valid: boolean
  }
}

namespace Result {
  export const isBool = (val: Definitions.QueryResult): boolean => "Bool" in val
  export const isTime = (val: Definitions.QueryResult): boolean => "Time" in val
  export const isString = (val: Definitions.QueryResult): boolean => "String" in val
  export const isFloat64 = (val: Definitions.QueryResult): boolean => "Float64" in val
  export const isInt64 = (val: Definitions.QueryResult): boolean => "Int64" in val
  export const isNumber = (val: Definitions.QueryResult): boolean => isFloat64(val) || isInt64(val)

  export type scalar = string | number | boolean | Date | undefined
  export const valueOf = (val: Definitions.QueryResult): scalar =>
    !val.Valid ? undefined :
      isString(val) ? val.String :
      isFloat64(val) ? val.Float64 :
      isInt64(val) ? val.Int64 :
      isBool(val) ? val.Bool :
      isTime(val) ? (val.Time ? new Date(val.Time) : undefined) :
      undefined

  export const valuesOf = (res: Definitions.QueryResults): string[] =>
    !res.results ? [] : res.results.map((row) => {
      const val = valueOf(row[0])
      return val !== undefined ? val.toString() : "undefined"
    })

  export const stringValueOf = (val: Definitions.QueryResult): scalar => {
    const inner = valueOf(val)
    if (inner === undefined) {
      return ""
    } else if (inner instanceof Date) {
      return inner.toDateString()
    }

    return inner.toString()
  }

  export const stringOf = (val: Definitions.QueryResult): string => {
    if (!val.Valid) {
      return ""
    } else if (isTime(val) && val.Time) {
      return (new Date(val.Time)).toDateString()
    }

    return (valueOf(val) || "").toString()
  }

  export const numberOf = (val: Definitions.QueryResult): number => {
    if (!val.Valid) {
      return 0
    } else if (isInt64(val) && val.Int64 !== undefined) {
      return val.Int64
    } else if (isFloat64(val) && val.Float64 !== undefined) {
      return val.Float64
    } else if (isTime(val) && val.Time !== undefined) {
      return new Date(val.Time).valueOf()
    } else if (isBool(val) && val.Bool !== undefined) {
      return val.Bool ? 1 : 0
    } else if (isString(val) && val.String !== undefined) {
      return parseFloat(val.String)
    }

    return 0
  }

  type dict = { [index: string]: scalar }
  export const flattenResultsHash = (results: Definitions.QueryResults): dict[] =>
    !results.results ? [] : results.results.map((row) =>
      results.columns.reduce((acc, col, i) => {
        acc[col] = valueOf(row[i])
        return acc
      }, {} as dict))
}

namespace Network {
  export const cachedExecuteQuery = (query: string): Promise<Definitions.QueryResults> =>
    new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open("POST", "/query/execute")
      xhr.setRequestHeader("Content-Type", "application/json")
      xhr.setRequestHeader("Accept", "application/json")
      xhr.onload = () => resolve(JSON.parse(xhr.responseText))
      xhr.onerror = () => reject(new Error(`query execution request error: ${xhr.responseText}`))
      xhr.send(JSON.stringify({query}))
    })
}

namespace Query {
  export const getInputForMergeField = (field: string, inputs: Definitions.Input[]): Definitions.Input | null => {
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

  export const mergeFields = (query: string, inputs: Definitions.Input[]): string => {
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

  export const isReadyToExecute = (query: string, inputs: Definitions.Input[]): boolean => {
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
    variables: Definitions.Variable[]
    inputs: Definitions.Input[]
    onSelect: (val: string, v: Definitions.Variable) => void
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
    output: Definitions.Output,
    onSave: (output: Definitions.Output) => void
    onCancel: () => void
  }

  export const Form = ({ output, onSave, onCancel }: FormProps) => {
    const [kind, setKind] = useState<Definitions.OutputKind>(output.kind)
    const [label, setLabel] = useState<string>(output.label)
    const [query, setQuery] = useState<string>(output.query)
    const [width, setWidth] = useState<string>(output.width || "")
    const [height, setHeight] = useState<string>(output.height || "")

    const updated = { ...output, kind, label, query, width, height }

    return <div className="report-edit-form">
      <label className="report-edit-form-label">
        <span>Kind</span>
        <select value={kind} onChange={(ev) => setKind(ev.target.value as Definitions.OutputKind)}>
          <option value={Definitions.OutputKind.TableOutput} label="Table" />
          <option value={Definitions.OutputKind.ChartOutput} label="Chart" />
          <option value={Definitions.OutputKind.ValueOutput} label="Value" />
        </select>
      </label>
      <label className="report-edit-form-label">
        <span>Label</span>
        <input value={label} onChange={(ev) => setLabel(ev.target.value)} />
      </label>
      <label className="report-edit-form-label">
        <span>Width</span>
        <input value={width} onChange={(ev) => setWidth(ev.target.value)} />
      </label>
      <label className="report-edit-form-label">
        <span>Height</span>
        <input value={height} onChange={(ev) => setHeight(ev.target.value)} />
      </label>
      <label className="report-edit-form-label">
        <span>Query</span>
        <textarea value={query} onChange={(ev) => setQuery(ev.target.value)} />
      </label>

      <div>
        <button onClick={onCancel}>Cancel</button>
        <button onClick={() => onSave(updated)}>Save</button>
      </div>
    </div>
  }
}

namespace Outputs {
  const NO_RESULTS = "No Results"
  const NOT_AVAILABLE = "N/A"

  export type Definition = {
    kind: Definitions.OutputKind
    label: string
    query: string
    width?: string
    height?: string
  }

  type ViewProps = {
    outputs: Definitions.Output[]
    onEdit: (output: Definitions.Output) => void
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
      case Definitions.OutputKind.TableOutput:
        return <OutputWrapper {...props} outputName="table">
          <TableRawOutput />
        </OutputWrapper>

      case Definitions.OutputKind.ChartOutput:
        return <OutputWrapper {...props} outputName="chart">
          <ChartRawOutput />
        </OutputWrapper>

      case Definitions.OutputKind.ValueOutput:
        return <OutputWrapper {...props} outputName="value">
          <ValueRawOutput />
        </OutputWrapper>

      case Definitions.OutputKind.InvalidOutput:
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

  const outputStyle = ({ definition }: { definition: Definition }) => {
    const styles = {} as { [index: string]: string }

    if (definition.width) {
      styles.width = definition.width
    } else {
      styles.width = "100%"
    }

    if (definition.height) {
      styles.height = definition.height
    }

    return styles
  }

  const OutputWrapper: FunctionComponent<OutputWrapperProps> = (props) =>
    <div className={outputClassName(props)} style={outputStyle(props)}>
      <Header definition={props.definition} onEdit={props.onEdit} />
      <div className="output-content">{props.children}</div>
    </div>

  type LookupOutputProps = {
    definition: Definition
    results: Definitions.QueryResults
    onEdit?: (def: Definition) => void
    loading?: boolean
  }

  const LookupOutput = (props: LookupOutputProps) => {
    switch (props.definition.kind) {
      case Definitions.OutputKind.TableOutput:
        return <OutputWrapper {...props} outputName="table">
          <TableOutput {...props} />
        </OutputWrapper>

      case Definitions.OutputKind.ChartOutput:
        return <OutputWrapper {...props} outputName="chart">
          <ChartOutput {...props} />
        </OutputWrapper>

      case Definitions.OutputKind.ValueOutput:
        return <OutputWrapper {...props} outputName="value">
          <ValueOutput {...props} />
        </OutputWrapper>

      case Definitions.OutputKind.InvalidOutput:
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

  const getValue = (res: Definitions.QueryResults) =>
    res.results && res.results[0] ? Result.valueOf(res.results[0][0]) : undefined

  type ValueOutputProps = {
    results: Definitions.QueryResults
  }

  const ValueOutput = ({ results }: ValueOutputProps) =>
    <ValueRawOutput raw={getValue(results)} />

  type ValueRawOutputProps = {
    raw?: Result.scalar
  }

  const ValueRawOutput = ({ raw }: ValueRawOutputProps) =>
    <div className="value-output-wrapper">
      <span className="value-output-value">{raw || NOT_AVAILABLE}</span>
    </div>

  const classOf = (val: Definitions.QueryResult): string =>
    !val.Valid ? "table-output-type-null" :
      Result.isString(val) ? "table-output-type-string" :
      Result.isNumber(val) ? "table-output-type-number" :
      Result.isBool(val) ? "table-output-type-boolean" :
      Result.isTime(val) ? "table-output-type-timestamp" :
      "table-output-type-unknown"

  type TableOutputProps = {
    results: Definitions.QueryResults
  }

  const TableOutput = (props: TableOutputProps) =>
    <TableRawOutput {...props} />

  type TableRawOutputProps = {
    results?: Definitions.QueryResults
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
                <td key={vidx} className={classOf(val)}>{Result.stringValueOf(val)}</td>)}
            </tr>)}
        </tbody>
      </table> :
      <div className="output-no-data">{NO_RESULTS}</div>

  const CHART_ROW_HORIZONTAL_PADDING = 10 // Should always match the left/right margin of the .chart-rows element.
  const CHART_ROW_VERTICAL_PADDING = 10 // Should always match the bottom margin of the last y label element.
  const CHART_ROW_VALUE_BOTTOM_PADDING = CHART_ROW_VERTICAL_PADDING

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
    medX: number
    minX: number
    maxY: number
    medY: number
    minY: number
  }

  const normalizeResults = (results: Definitions.QueryResults): ChartData | undefined => {
    if (!results.results) {
      return
    }

    if (results.columns.length < 2) {
      return
    }

    const datum = results.results.map((cell: Definitions.QueryResult[], i) => {
      return {
        id: Math.random().toString(),
        x: {
          label: Result.stringOf(cell[0]),
          value: Result.numberOf(cell[0]),
        },
        y: Result.numberOf(cell[1]),
      }
    }).sort((a, b) => {
      if (a.x.value > b.x.value) {
        return 1
      } else if (a.x.value < b.x.value) {
        return -1
      }

      return 0
    })

    const xs = datum.map((row) => row.x.value)
    const ys = datum.map((row) => row.y)

    const minX = Math.round(Math.min.apply(Math, xs))
    const maxX = Math.round(Math.max.apply(Math, xs))
    const minY = Math.round(Math.min.apply(Math, ys))
    const maxY = Math.round(Math.max.apply(Math, ys))

    const medX = Math.round((maxX + minX) / 2)
    const medY = Math.round((maxY + minY) / 2)

    const diffX = maxX - minX
    const diffY = maxY - minY

    return { datum, diffX, diffY, minX, medX, maxX, minY, medY, maxY }
  }

  const buildChartLabel = (loc: string, value: string | number) =>
    <div className={`chart-y-label chart-y-label-${loc}`}>
      <span className="chart-y-label-label">{value}</span>
    </div>

  const buildChartRow = (
    containerWidth: number,
    containerHeight: number,
    index: number,
    row: ChartRow,
    chartData: ChartData
  ) => {
    let width
    let height
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

    if (Math.round(row.y) === Math.round(chartData.maxY)) {
      height = containerHeight
    } else if (Math.round(row.y) === Math.round(chartData.minY)) {
      height = CHART_ROW_VALUE_BOTTOM_PADDING
    } else {
      height = (Math.round(row.y) - Math.round(chartData.minY)) /
        (Math.round(chartData.maxY) - Math.round(chartData.minY)) *
        containerHeight
    }

    if (isNaN(height) || !isFinite(height)) {
      height = containerHeight
    }

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
    results: Definitions.QueryResults
  }

  const ChartOutput = (props: ChartOutputProps) =>
    <ChartRawOutput {...props} />

  type ChartRawOutputProps = {
    results?: Definitions.QueryResults
  }

  const ChartRawOutput = ({ results }: ChartRawOutputProps) => {
    const chartContainerRef = useRef(null)
    const [width, setWidth] = useState(0)
    const [height, setHeight] = useState(0)

    const setWidthUsingContainer = () => {
      if (chartContainerRef.current) {
        // XXX need to do `as any` since the compiler is complaining about a
        // possible null value, but why?
        const container = chartContainerRef.current as any
        const { width: containerWidth, height: containerHeight } = container.getBoundingClientRect()
        setWidth(containerWidth - (CHART_ROW_HORIZONTAL_PADDING * 2))
        setHeight(containerHeight - CHART_ROW_VERTICAL_PADDING)
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
        {buildChartLabel("max", chartData.maxY)}
        {chartData.maxY !== chartData.medY ? buildChartLabel("med", chartData.medY) : null}
        {chartData.maxY !== chartData.minY ? buildChartLabel("min", chartData.minY) : null}
        <div className="chart-rows">
          {chartData.datum.map((row, i) => buildChartRow(width, height, i, row, chartData))}
        </div>
      </div>
    </div>
  }
}

namespace Reducer {
  type OutputReducerSetOutputsAction = { kind: "setOutputs", outputs: Definitions.Output[] }
  type OutputReducerSetResultsAction = {
    kind: "setResults",
    output: Definitions.Output,
    results: Definitions.QueryResults,
  }
  type OutputReducerUpdateDefinitionAction = { kind: "updateDefinition", output: Definitions.Output }
  type OutputReducerIsLoadingAction = { kind: "isLoading", output: Definitions.Output }
  export type OutputReducerAction
    = OutputReducerSetOutputsAction
    | OutputReducerSetResultsAction
    | OutputReducerUpdateDefinitionAction
    | OutputReducerIsLoadingAction
  export type OutputReducer = (outputs: Definitions.Output[], action: OutputReducerAction) => Definitions.Output[]
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
            height: output.height,
          })
      }
    }
  }

  type InputReducerChangeHandledAction = { kind: "changeHandled", input: Definitions.Input }
  type InputReducerSetInputAction = { kind: "setInput", input: Definitions.Input }
  export type InputReducerAction = InputReducerChangeHandledAction | InputReducerSetInputAction
  export type InputReducer = (inputs: Definitions.Input[], action: InputReducerAction) => Definitions.Input[]
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

  type VariableReducerSetVariablesAction = { kind: "setVariables", variables: Definitions.Variable[] }
  type VariableReducerSetOptionsAction = { kind: "setOptions", variable: Definitions.Variable, options: string[] }
  export type VariableReducerAction = VariableReducerSetVariablesAction | VariableReducerSetOptionsAction
  export type VariableReducer =
    (variables: Definitions.Variable[], action: VariableReducerAction) => Definitions.Variable[]
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

namespace Reports {
  const loadReportSettings = (
    report: Definitions.Report,
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
        const options = Result.valuesOf(res)
        dispatchVariable({ kind: "setOptions", options, variable })

        if (!!variable.defaultValue && options.indexOf(variable.defaultValue) !== -1) {
          const value = variable.defaultValue
          const input = { variable, value }
          dispatchInput({ kind: "setInput", input })
        }
      }))
  }

  const loadReportData = (
    inputs: Definitions.Input[],
    outputs: Definitions.Output[],
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
        }, [] as Definitions.Input[])

      if (output.loading) {
        return
      }

      const shouldLoad = queryInputs.reduce((doIt, input) =>
        !input.changeHandled || doIt, false)

      if (queryInputs.length && !shouldLoad && !output.reload) {
        return
      }

      if (!queryInputs.length && output.results) {
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
    const report = REPORT

    const [variables, dispatchVariable] = useReducer(Reducer.variableReducer, [], (i) => i)
    const [inputs, dispatchInput] = useReducer(Reducer.inputReducer, [], (i) => i)
    const [outputs, dispatchOutput] = useReducer(Reducer.outputReducer, [], (i) => i)

    const [editing, setEditing] = useState<Definitions.Output | null>(null)

    const setInput = (value: string, variable: Definitions.Variable) =>
      dispatchInput({ kind: "setInput", input: { value, variable } })

    const saveOutputDefinition = (output: Definitions.Output) => {
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
      loadReportSettings(report, dispatchVariable, dispatchInput, dispatchOutput)
    }, [])

    loadReportData(inputs, outputs, dispatchInput, dispatchOutput)

    return <>
      {editForm}
      <Variables.Form variables={variables} inputs={inputs} onSelect={setInput} />
      <Outputs.View outputs={outputs} onEdit={(output) => setEditing(output)} />
    </>
  }
}

ReactDOM.render(<Reports.View />, document.querySelector(".content-view"))
