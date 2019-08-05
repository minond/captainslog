import * as React from "react"
import { useState, KeyboardEvent } from "react"

import { cachedExecuteQuery } from "./remote"
import { QueryExecuteRequest, QueryResults, QueryResult } from "./definitions"

const KEY_ENTER = 13

type QueryViewProps = {
  bookGuid: string
}

const rowCount = (val: string): number =>
  val.split("\n").length

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

const classOf = (val: QueryResult): string =>
  !val.Valid ? "query-res-type-null" :
    isString(val) ? "query-res-type-string" :
    isNumber(val) ? "query-res-type-number" :
    isBool(val) ? "query-res-type-boolean" :
    "query-res-type-unknown"

const resultsTable = (res: QueryResults) =>
  <table className="query-results">
    <thead>
      <tr>
        {res.cols.map((col, i) =>
          <td key={col + i}>{col}</td>)}
      </tr>
    </thead>
    <tbody>
      {res.data.map((row, ridx) =>
        <tr key={ridx}>
          {row.map((val, vidx) =>
            <td key={vidx} className={classOf(val)}>{valueOf(val)}</td>)}
        </tr>)}
    </tbody>
  </table>

const SAMPLE_QUERY = `select distinct exercise,
  max(cast(weight as float))
from workouts
where exercise is not null
group by exercise`

const _ = `select exercise, count(1) as count
from workouts
group by exercise
order by count desc
limit 20`

export const QueryView = (props: QueryViewProps) => {
  const [query, setQuery] = useState<string>(SAMPLE_QUERY)
  const [rows, setRows] = useState<number>(rowCount(query))
  const [results, setResults] = useState<QueryResults | null>(null)

  const execute = () =>
    query ? cachedExecuteQuery(query).then(setResults) :
      setResults(null)

  const updateQuery = (query: string) => {
    setQuery(query)
    setRows(rowCount(query))
  }

  const textareaKeyPress = (ev: KeyboardEvent<HTMLTextAreaElement>) => {
    if (ev.charCode === KEY_ENTER && ev.shiftKey) {
      execute()
      ev.preventDefault()
    }
  }

  return <div className="query">
    <textarea
      className="query-textarea"
      rows={rows}
      onChange={(ev) => updateQuery(ev.target.value)}
      onKeyPress={textareaKeyPress}
      defaultValue={SAMPLE_QUERY}
    />
    <input type="button" value="Execute" onClick={execute} />
    {results && resultsTable(results)}
  </div>
}
