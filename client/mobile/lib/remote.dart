import 'dart:convert';

import 'package:http/http.dart' as http;

enum Resource {
  BOOKS
}

const uris = {
  Resource.BOOKS: "http://localhost/api/book",
};

Future apiGet(Resource resource) async {
  try {
    print("making GET ${uris[resource]}");
    var res = await http.get(uris[resource], headers: {
      "Accept": "application/json",
    });

    print("decoding response");
    return json.decode(res.body);
  } catch (err) {
    print("error fetching data:");
    print(err);
  }
}