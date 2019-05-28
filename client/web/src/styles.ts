import { CSSProperties } from "aphrodite"

export const mainColor = "black"
export const fadeColor = "#96ccff"
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
  height: "25px",
  border: "0",
  borderBottom: "1px solid black",
}

export const button: CSSProperties = {
  ...normalText,
  backgroundColor: "white",
  border: "1px solid black",
  fontSize: ".8rem",
  height: "29px",
  lineHeight: 1,
  marginLeft: "4px",
  verticalAlign: "top",
}

export const textAreaField: CSSProperties = {
  ...normalText,
  border: "0",
  borderBottom: `1px solid black`,
  boxSizing: "border-box",
  margin: 0,
  outline: 0,
  padding: "10px 0",
}
