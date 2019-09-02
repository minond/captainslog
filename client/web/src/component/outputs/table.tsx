import * as React from "react"

import { QueryResult, QueryResults } from "../../definitions"
import { Definition } from "./output"

import { isBool, isString, isFloat64, isInt64, isNumber, stringValueOf } from "./utils"

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

export const TableOutput = (props: TableOutputProps) =>
  <div className="output table-output">
    {props.definition ?
      <div className="output-label" title={props.definition.query}>{props.definition.label}</div> :
      null}
    <table className="table-output-table">
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
              <td key={vidx} className={classOf(val)}>{stringValueOf(val)}</td>)}
          </tr>)}
      </tbody>
    </table>
  </div>
