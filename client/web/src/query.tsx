import * as React from "react"

type QueryViewProps = {
  bookGuid: string
}

export const QueryView = (props: QueryViewProps) => {
  return <div className="query">
    <textarea className="query-textarea" rows={5} />
    <input type="button" value="Execute" />
  </div>
}
