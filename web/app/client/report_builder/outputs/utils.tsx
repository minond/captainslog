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

export const valuesOf = (res: QueryResults): string[] =>
  !res.results ? [] : res.results.map((row) => {
    const val = valueOf(row[0])
    return val !== undefined ? val.toString() : "undefined"
  })

export const stringValueOf = (val: QueryResult): scalar => {
  const inner = valueOf(val)
  if (inner === undefined) {
    return ""
  } else if (inner instanceof Date) {
    return inner.toDateString()
  }

  return inner.toString()
}

export const stringOf = (val: QueryResult): string => {
  if (!val.Valid) {
    return ""
  } else if (isTime(val) && val.Time) {
    return (new Date(val.Time)).toDateString()
  }

  return (valueOf(val) || "").toString()
}

export const numberOf = (val: QueryResult): number => {
  if (!val.Valid) {
    return 0
  } else if (isInt64(val) && val.Int64 !== undefined) {
    return val.Int64
  } else if (isFloat64(val) && val.Float64 !== undefined) {
    return val.Float64
  } else if (isTime(val) && val.Time !== undefined) {
    return new Date(val.Time).valueOf()
  } else if (isBool(val) && val.Bool !== undefined) {
    return val.Bool ? 1 : 0
  } else if (isString(val) && val.String !== undefined) {
    return parseFloat(val.String)
  }

  return 0
}

type dict = { [index: string]: scalar }
export const flattenResultsHash = (results: QueryResults): dict[] =>
  !results.results ? [] : results.results.map((row) =>
    results.columns.reduce((acc, col, i) => {
      acc[col] = valueOf(row[i])
      return acc
    }, {} as dict))
