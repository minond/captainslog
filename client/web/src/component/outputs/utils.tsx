import { QueryResult, QueryResults } from "../../definitions"

export const isBool = (val: QueryResult): boolean => "Bool" in val
export const isString = (val: QueryResult): boolean => "String" in val
export const isFloat64 = (val: QueryResult): boolean => "Float64" in val
export const isInt64 = (val: QueryResult): boolean => "Int64" in val
export const isNumber = (val: QueryResult): boolean => isFloat64(val) || isInt64(val)

type scalar = string | number | boolean | undefined
export const valueOf = (val: QueryResult): scalar =>
  !val.Valid ? undefined :
    isString(val) ? val.String :
    isFloat64(val) ? val.Float64 :
    isInt64(val) ? val.Int64 :
    isBool(val) ? val.Bool :
    undefined

type dict = { [index: string]: scalar }
export const flattenResultsHash = (results: QueryResults): dict[] =>
  !results.data ? [] : results.data.map((row) =>
    results.cols.reduce((acc, col, i) => {
      acc[col] = valueOf(row[i])
      return acc
    }, {} as dict))
