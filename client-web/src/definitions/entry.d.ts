// Code generated by protoc-gen-typescript-definitions. DO NOT EDIT.
// source: entry.proto

export type Entry = {
  guid?: string
  text?: string
  data?: Map<string, string>
}

export type EntryCreateRequest = {
  guid?: string
  text?: string
}

export type EntryCreateResponse = {
  guid?: string
  entry?: {
    guid?: string
    text?: string
    data?: Map<string, string>
  }
}
