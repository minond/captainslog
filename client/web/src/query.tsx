import * as React from "react"
import { useState } from "react"

import { cachedExecuteQuery } from "./remote"
import { QueryExecuteRequest, QueryResults } from "./definitions"

type QueryViewProps = {
  bookGuid: string
}

const resultsTable = (res: QueryResults) =>
  <table>
    <thead>
      <tr>
        {res.cols.map((col, i) =>
          <td key={col + i}>{col}</td>)}
      </tr>
    </thead>
  </table>

const SAMPLE_QUERY = `select distinct exercise,
  max(cast(weight as float))
from workouts
group by exercise`

export const QueryView = (props: QueryViewProps) => {
  const [query, setQuery] = useState<string>(SAMPLE_QUERY)
  const [results, setResults] = useState<QueryResults | null>(null)

  const execute = () =>
    cachedExecuteQuery(query).then(setResults)

  return <div className="query">
    <textarea
      className="query-textarea"
      rows={5}
      onChange={(e) => setQuery(e.target.value)}
      value={SAMPLE_QUERY}
    />
    <input type="button" value="Execute" onClick={execute} />
    {results && resultsTable(results)}
  </div>
}
