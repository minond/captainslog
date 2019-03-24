export type Log = {
  guid?: string
  text?: string
  data?: Map<string, string>
  createdOn?: number
  createdBy?: string
  updatedOn?: number
  updatedBy?: string
  deletedOn?: number
  deletedBy?: string
}

export type LogCreateRequest = {
  guid?: string
  text?: string
  createdOn?: number
  updatedOn?: number
}

export type LogCreateResponse = {
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
  }
}
