export type Entry = {
  guid: string
  text: string
  created_at: string
  updated_at: string
  data?: Map<string, string>
}

export type EntryCreateRequest = {
  guid: string
  text: string
  created_at: string
  book_guid: string
}

export type EntryCreateResponse = {
  guid: string
  entry: Entry
}
