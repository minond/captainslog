export type Entry = {
  guid: string
  text: string
  timestamp: number
  data?: Map<string, string>
}

export type EntryCreateRequest = {
  guid: string
  text: string
  timestamp: number
  book_guid: string
}

export type EntryCreateResponse = {
  guid: string
  entry: Entry
}
