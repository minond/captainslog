export type UnsyncedLog = Pick<Log, "guid" | "text" | "createdOn" | "updatedOn">

export type Log = {
  guid: string
  text: string
  data: Map<string, string>
  createdOn: number
  createdBy: string
  updatedOn: number
  updatedBy: string
  deletedOn?: number
  deletedBy?: string
}
