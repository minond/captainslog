import { CSSProperties } from "aphrodite"

export const mainColor = '#0031FE'
export const contrastColor = 'white'

export const link = {
  color: "inherit",
}

export const smallText = {
  fontSize: "0.5em",
  lineHeight: 1,
}

export const mediumText = {
  fontSize: "0.85em",
  lineHeight: 1,
}

export const largeText = {
  fontSize: "1.25em",
  lineHeight: 1,
}

export const mainBackgroundColor = {
  backgroundColor: mainColor,
  color: contrastColor,
}

export const mainTextColor = {
  color: mainColor,
}

export const inputField: CSSProperties = {
  ...mediumText,
  border: "1px solid #c3c3c3",
  boxSizing: "border-box",
  margin: 0,
  padding: "1px 4px 2px 4px",
}

export const textAreaField: CSSProperties = {
  ...mediumText,
  border: "1px solid #c3c3c3",
  boxSizing: "border-box",
  margin: 0,
  padding: "4px",
}
