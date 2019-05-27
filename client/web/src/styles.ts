import { CSSProperties } from "aphrodite"

export const mainColor = "#0031FE"
export const accentColor = "#c3c3c3"
export const contrastColor = "white"

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

export const normalText = {
  fontSize: "1em",
  lineHeight: 1,
}

export const largeText = {
  fontSize: "1.25em",
  lineHeight: 1,
}

export const largerText = {
  fontSize: "1.75em",
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
  ...normalText,
  border: "1px solid #c3c3c3",
}

export const textAreaField: CSSProperties = {
  ...normalText,
  border: "0",
  borderBottom: `1px solid ${accentColor}`,
  boxSizing: "border-box",
  margin: 0,
  outline: 0,
  padding: "10px 0",
}
