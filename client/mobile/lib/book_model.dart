import 'remote.dart';

class Book {
  final String name;
  final String guid;

  Book({this.name, this.guid});

  @override
  String toString() {
    return "<Book guid=\"$guid\" name=\"$name\" />";
  }

  static Future<List<Book>> find() async {
    var books = new List<Book>();

    try {
      var response = await apiGet(Resource.BOOKS);
      if (response == null) {
        print("did not get any books back");
        return books;
      }

      var rawData = response as Map<String, dynamic>;
      var rawBooks = rawData["books"] as List;
      rawBooks.forEach((item) {
        books.add(Book(
          guid: item["guid"],
          name: item["name"],
        ));
      });
    } catch (err) {
      print("error retrieving and decoding books:");
      print(err);
    }

    return books;
  }
}