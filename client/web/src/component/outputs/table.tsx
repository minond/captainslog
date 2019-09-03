import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"
import { Definition } from "./output"

import { isBool, isString, isFloat64, isInt64, isNumber, stringValueOf } from "./utils"

const DEFAULT_VALUE = "No Results"

const classOf = (val: QueryResult): string =>
  !val.Valid ? "table-output-type-null" :
    isString(val) ? "table-output-type-string" :
    isNumber(val) ? "table-output-type-number" :
    isBool(val) ? "table-output-type-boolean" :
    "table-output-type-unknown"

type TableOutputProps = {
  results: QueryResults
  definition?: Definition
}

export const TableOutput = ({ definition, results }: TableOutputProps) =>
  <TableRawOutput definition={definition} results={results} />

type TableRawOutputProps = {
  results?: QueryResults
  definition?: Definition
}

export const TableRawOutput = ({ definition, results }: TableRawOutputProps) =>
  <div className="output table-output">
    {definition ?
      <div className="output-label" title={definition.query}>{definition.label}</div> :
      null}
    {results ?
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
      <div className="table-output-no-data">{DEFAULT_VALUE}</div>}
  </div>
