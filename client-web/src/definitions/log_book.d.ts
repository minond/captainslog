export type LogBook = {
  guid?: string
  name?: string
  grouping?: number
  extractor?: Array<{
    guid?: string
    label?: string
    match?: string
  }>
  group?: Array<{
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
  }>
}
