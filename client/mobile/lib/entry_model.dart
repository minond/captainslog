import 'remote.dart';

import 'book_model.dart';

class Entry {
  final String text;
  final String guid;

  Entry({this.guid, this.text});

  @override
  String toString() {
    return "<Entry guid=\"$guid\" />";
  }

  static Future<List<Entry>> findFor(Book book) async {
    var sec = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var params = {"book": book.guid, "at": sec.toString()};
    var entries = new List<Entry>();

    try {
      var response = await apiGet(resource: Resource.ENTRIES, params: params);
      if (response == null) {
        print("did not get any entries back");
        return entries;
      }

      var rawData = response as Map<String, dynamic>;
      var rawBooks = rawData["entries"] as List;
      rawBooks.forEach((item) {
        entries.add(Entry(
          guid: item["guid"],
          text: item["text"],
        ));
      });
    } catch (err) {
      print("error retrieving and decoding books:");
      print(err);
    }

    return entries;
  }
}
