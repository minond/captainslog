import { StyleSheet } from "react-native"

export default StyleSheet.create({
  containerWrapper: {
    flex: 1,
    backgroundColor: "#fff",
    display: "flex",
  },
  scrollViewWrapper: {
    marginTop: 70,
    flex: 1,
  },
  viewWrapper: {
    paddingLeft: 30,
    paddingRight: 30,
    paddingTop: 20,
    flex: 1,
  },
  header: {
    fontSize: 36,
    marginBottom: 8,
    fontWeight: "500",
  },
  textInput: {
    borderColor: "gray",
    borderBottomWidth: 1,
    width: "100%",
    fontSize: 20,
    paddingTop: 4,
    paddingBottom: 4,
  },
  inputLabel: {
    paddingTop: 10,
    paddingBottom: 5,
    fontSize: 16,
    fontWeight: "600",
  },
  button: {
    height: 45,
    justifyContent: "center",
    backgroundColor: "lightgray",
    alignItems: "center",
    marginBottom: 20,
  },
  formField: {
    marginTop: 10,
  },
  errorMessage: {
    color: "red",
    fontWeight: "500",
  },
})
