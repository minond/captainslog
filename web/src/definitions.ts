export type UnsyncedEntry = { id: string } & Pick<Entry, "text" | "createdOn">

export type Entry = {
  guid: string
  text: string
  data: Map<string, string>
  createdOn: number
  createdBy: string
  updatedOn: number
  updatedBy: string
  deletedOn: number
  deletedBy: string
}
