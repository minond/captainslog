import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"

import { isBool, isString, isFloat64, isInt64, isNumber, valueOf } from "./utils"

const classOf = (val: QueryResult): string =>
  !val.Valid ? "table-output-type-null" :
    isString(val) ? "table-output-type-string" :
    isNumber(val) ? "table-output-type-number" :
    isBool(val) ? "table-output-type-boolean" :
    "table-output-type-unknown"

type TableOutputProps = {
  results: QueryResults
}

export const TableOutput = (props: TableOutputProps) =>
  <table className="table-output">
    <thead>
      <tr>
        {props.results.cols.map((col, i) =>
          <td key={col + i}>{col}</td>)}
      </tr>
    </thead>
    <tbody>
      {props.results.data && props.results.data.map((row, ridx) =>
        <tr key={ridx}>
          {row.map((val, vidx) =>
            <td key={vidx} className={classOf(val)}>{valueOf(val)}</td>)}
        </tr>)}
    </tbody>
  </table>
