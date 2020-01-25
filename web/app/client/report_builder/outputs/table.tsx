import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"
import { Definition, Header } from "./output"

import {
  NO_RESULTS,
  isBool,
  isFloat64,
  isInt64,
  isNumber,
  isString,
  isTime,
  stringValueOf,
} from "./utils"

const classOf = (val: QueryResult): string =>
  !val.Valid ? "table-output-type-null" :
    isString(val) ? "table-output-type-string" :
    isNumber(val) ? "table-output-type-number" :
    isBool(val) ? "table-output-type-boolean" :
    isTime(val) ? "table-output-type-timestamp" :
    "table-output-type-unknown"

type TableOutputProps = {
  definition?: Definition
  results: QueryResults
  onEdit?: (def: Definition) => void
}

export const TableOutput = (props: TableOutputProps) =>
  <TableRawOutput {...props} />

type TableRawOutputProps = {
  definition?: Definition
  results?: QueryResults
  onEdit?: (def: Definition) => void
}

export const TableRawOutput = ({ definition, results, onEdit }: TableRawOutputProps) =>
  <div className="output table-output" style={{width: definition ? definition.width : "100%"}}>
    {definition ?
      <Header definition={definition} onEdit={onEdit} /> :
      null}
    {results && results.data && results.data.length ?
      <table className="table-output-table">
        <thead>
          <tr>
            {results.cols.map((col, i) =>
              <td key={col + i}>{col}</td>)}
          </tr>
        </thead>
        <tbody>
          {results.data && results.data.map((row, ridx) =>
            <tr key={ridx}>
              {row.map((val, vidx) =>
                <td key={vidx} className={classOf(val)}>{stringValueOf(val)}</td>)}
            </tr>)}
        </tbody>
      </table> :
      <div className="output-no-data">{NO_RESULTS}</div>}
  </div>
