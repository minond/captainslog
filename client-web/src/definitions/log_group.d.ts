export type LogGroup = {
  guid?: string
  log?: {
    guid?: string
    text?: string
    data?: Map<string, string>
    createdOn?: number
    createdBy?: string
    updatedOn?: number
    updatedBy?: string
    deletedOn?: number
    deletedBy?: string
  }[]
  createdOn?: number
  createdBy?: string
  updatedOn?: number
  updatedBy?: string
}
