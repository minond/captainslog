import * as React from "react"
import { KeyboardEvent, useEffect, useState } from "react"

import {
  cachedExecuteQuery,
  cachedGetSavedQueries,
  cachedGetSchema,
  createSavedQuery,
  updateSavedQuery,
} from "../remote"

import {
  QueryExecuteRequest,
  QueryResult,
  QueryResults,
  SavedQuery,
  Schema,
  SchemaBook,
  SchemaField,
  SchemaFieldType,
} from "../definitions"

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

const saveQuery = (query: string, savedQuery: SavedQuery | null) => {
  // Update
  if (savedQuery) {
    return updateSavedQuery(Object.assign({}, savedQuery, { content: query }))
  }

  // Create
  const label = prompt("Query label")
  if (!label) {
    return new Promise((_, rej) => rej())
  }

  return createSavedQuery({ label, content: query })
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

  const fetchSavedQueries = () =>
    cachedGetSavedQueries().then(setSavedQueries)

  const saveQueryClickHandler = () =>
    saveQuery(query, savedQuery).then(fetchSavedQueries)

  const loadSavedQueryHandler = (guid: string) => {
    const matchedQuery = savedQueries.find((q) => q.guid === guid)
    if (!matchedQuery) {
      setSavedQuery(null)
      return
    }

    setSavedQuery(matchedQuery)
    updateQuery(matchedQuery.content)
    executeQuery(matchedQuery.content)
  }

  const executeQuery = (queryToExecute = query) => {
    setMessage(null)

    if (!queryToExecute) {
      setResults(null)
      return
    }

    const startTime = Date.now()
    cachedExecuteQuery(queryToExecute)
      .then((res) => {
        const elapsedTime = Date.now() - startTime
        setResults(res)
        setMessage({
          message: `${res.data ? res.data.length : 0} row(s) (${elapsedTime}ms)`,
          ok: true,
        })
      })
      .catch((err) => {
        setResults(null)
        setMessage({ ok: false, message: "Error executing query" })
      })
  }

  const updateQuery = (newQuery: string) => {
    setQuery(newQuery)
    setRows(rowCount(newQuery))
  }

  const textareaKeyPressHandler = (ev: KeyboardEvent<HTMLTextAreaElement>) => {
    if (ev.charCode === KEY_ENTER && ev.shiftKey) {
      executeQuery()
      ev.preventDefault()
    }
  }

  const saveBtnLabel = savedQuery ? "Update query" : "Save query"
  const messageSublass = message && message.ok ? "query-message-ok" : "query-message-error"
  const messageClass = `query-message ${messageSublass}`

  const savedQuerySelect =
    <select onChange={(ev) => loadSavedQueryHandler(ev.target.value)}>
      {generateSavedQueryOptions(savedQueries)}
    </select>

  const textarea =
    <textarea
      className="query-textarea"
      rows={rows}
      onChange={(ev) => updateQuery(ev.target.value)}
      onKeyPress={textareaKeyPressHandler}
      placeholder="Execute query"
      value={query}
    />

  return <div className="query">
    <div className="w100">
      {textarea}
      <input type="button" value="Execute" onClick={() => executeQuery()} />
      <input type="button" value={saveBtnLabel} onClick={saveQueryClickHandler} />
      {!!savedQueries.length && savedQuerySelect}
      {results && resultsTable(results)}
      {message && <div className={messageClass}>{message.message}</div>}
    </div>
    <div>
      <SchemaView />
    </div>
  </div>
}

const fieldTypeNames = {
  [SchemaFieldType.String]: "String",
  [SchemaFieldType.Number]: "Number",
  [SchemaFieldType.Boolean]: "Boolean",
}

const fieldTypeName = (ty: SchemaFieldType) =>
  fieldTypeNames[ty]

const SchemaFieldView = (props: { field: SchemaField }) => {
  const tyName = fieldTypeName(props.field.type)
  return <div className="schema-field">
    <span className={`schema-field-type ${tyName.toLowerCase()}`}>{tyName}</span>
    <span className="schema-field-name">{props.field.name}</span>
  </div>
}

const SchemaBookView = (props: { book: SchemaBook }) =>
  <div className="schema-book">
    <div className="schema-book-name">{props.book.name}</div>
    {props.book.fields.map((field, j) =>
      <SchemaFieldView key={field.name + j} field={field} />)}
  </div>

const SchemaView = () => {
  const [schema, setSchema] = useState<Schema | null>(null)

  useEffect(() => {
    cachedGetSchema().then(setSchema)
  }, [])

  const byBook = !schema ? null :
    schema.books.map((book, i) =>
      <SchemaBookView key={book.name + i} book={book} />)

  return <div className="schema">{byBook}</div>
}
