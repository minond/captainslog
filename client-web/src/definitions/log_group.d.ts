
// Code generated by protoc-gen-typescript-definitions. DO NOT EDIT.
// source: log_group.proto

export type LogGroup = {
  guid?: string
  log?: Array<{
    guid?: string
    text?: string
    data?: Map<string, string>
    createdOn?: number
    createdBy?: string
    updatedOn?: number
    updatedBy?: string
    deletedOn?: number
    deletedBy?: string
  }>
  createdOn?: number
  createdBy?: string
  updatedOn?: number
  updatedBy?: string
}
