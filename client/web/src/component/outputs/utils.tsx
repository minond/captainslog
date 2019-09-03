import { QueryResult, QueryResults } from "../../definitions"

export const isBool = (val: QueryResult): boolean => "Bool" in val
export const isTime = (val: QueryResult): boolean => "Time" in val
export const isString = (val: QueryResult): boolean => "String" in val
export const isFloat64 = (val: QueryResult): boolean => "Float64" in val
export const isInt64 = (val: QueryResult): boolean => "Int64" in val
export const isNumber = (val: QueryResult): boolean => isFloat64(val) || isInt64(val)

export type scalar = string | number | boolean | Date | undefined
export const valueOf = (val: QueryResult): scalar =>
  !val.Valid ? undefined :
    isString(val) ? val.String :
    isFloat64(val) ? val.Float64 :
    isInt64(val) ? val.Int64 :
    isBool(val) ? val.Bool :
    isTime(val) ? (val.Time ? new Date(val.Time) : undefined) :
    undefined

export const stringValueOf = (val: QueryResult): scalar => {
  const inner = valueOf(val)
  return inner === undefined ? "" : inner.toString()
}

type dict = { [index: string]: scalar }
export const flattenResultsHash = (results: QueryResults): dict[] =>
  !results.data ? [] : results.data.map((row) =>
    results.cols.reduce((acc, col, i) => {
      acc[col] = valueOf(row[i])
      return acc
    }, {} as dict))
