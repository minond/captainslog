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
    var entries = new List<Entry>();
    var params = {
      "book": book.guid,
      "at": new DateTime.now().millisecondsSinceEpoch.toString(),
    };

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
