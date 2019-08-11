import * as React from "react"
import { useEffect, useState, KeyboardEvent } from "react"

import {
  cachedExecuteQuery,
  cachedGetSavedQueries,
  createSavedQuery,
  updateSavedQuery,
} from "./remote"

import {
  QueryExecuteRequest,
  QueryResult,
  QueryResults,
  SavedQuery,
} from "./definitions"

const KEY_ENTER = 13
const MIN_ROWS = 5
const MAX_ROWS = 20

const { max, min } = Math

const rowCount = (val: string): number =>
  min(MAX_ROWS, max(MIN_ROWS, val.split("\n").length + 1))

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
      {res.data && res.data.map((row, ridx) =>
        <tr key={ridx}>
          {row.map((val, vidx) =>
            <td key={vidx} className={classOf(val)}>{valueOf(val)}</td>)}
        </tr>)}
    </tbody>
  </table>

const generateSavedQueryOptions = (queries: SavedQuery[]) =>
  [
    <option key="blank" value="" label="Select a saved query" />
  ].concat(
    queries.map((query) =>
      <option key={query.guid} value={query.guid} label={query.label} />))

type Message = {
  ok: boolean
  message: string
}

export const Query = (props: {}) => {
  const [message, setMessage] = useState<Message | null>(null)
  const [query, setQuery] = useState<string>("")
  const [rows, setRows] = useState<number>(rowCount(query))
  const [results, setResults] = useState<QueryResults | null>(null)
  const [savedQueries, setSavedQueries] = useState<SavedQuery[]>([])
  const [savedQuery, setSavedQuery] = useState<SavedQuery | null>(null)

  useEffect(() => {
    fetchSavedQueries()
  }, [])

  const fetchSavedQueries = () => {
    cachedGetSavedQueries().then(setSavedQueries)
  }

  const loadSavedQuery = (guid: string) => {
    let query = savedQueries.find((query) => query.guid === guid)
    if (!query) {
      setSavedQuery(null)
      return
    }

    setSavedQuery(query)
    updateQuery(query.content)
  }

  const saveQuery = () => {
    // Update
    if (savedQuery) {
      let update = Object.assign({}, savedQuery, { content: query })
      updateSavedQuery(update).then(fetchSavedQueries)
      return
    }

    // Create
    let label = prompt("Query label")
    if (!label) {
      return
    }

    createSavedQuery({ label, content: query })
      .then(fetchSavedQueries)
  }

  const executeQuery = () => {
    setMessage(null)

    if (!query) {
      setResults(null)
      return
    }

    const startTime = Date.now()
    cachedExecuteQuery(query)
      .then((res) => {
        const elapsedTime = Date.now() - startTime
        setResults(res)
        setMessage({
          ok: true,
          message: `(${res.data ? res.data.length : 0} rows) (${elapsedTime}ms)`,
        })
      })
      .catch((err) => {
        setResults(null)
        setMessage({ ok: false, message: "Error executing query" })
      })
  }

  const updateQuery = (query: string) => {
    setQuery(query)
    setRows(rowCount(query))
  }

  const textareaKeyPress = (ev: KeyboardEvent<HTMLTextAreaElement>) => {
    if (ev.charCode === KEY_ENTER && ev.shiftKey) {
      executeQuery()
      ev.preventDefault()
    }
  }

  const saveBtnLabel = savedQuery ? "Update query" : "Save query"
  const messageSublass = message && message.ok ? "query-message-ok" : "query-message-error"
  const messageClass = `query-message ${messageSublass}`

  const savedQuerySelect =
    <select onChange={(ev) => loadSavedQuery(ev.target.value)}>
      {generateSavedQueryOptions(savedQueries)}
    </select>

  return <div className="query">
    <textarea
      className="query-textarea"
      rows={rows}
      onChange={(ev) => updateQuery(ev.target.value)}
      onKeyPress={textareaKeyPress}
      placeholder="Execute query"
      value={query}
    />
    <input type="button" value="Execute" onClick={executeQuery} />
    <input type="button" value={saveBtnLabel} onClick={saveQuery} />
    {!!savedQueries.length && savedQuerySelect}
    {message && <div className={messageClass}>{message.message}</div>}
    {results && resultsTable(results)}
  </div>
}
