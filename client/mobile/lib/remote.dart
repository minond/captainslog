import 'dart:convert';

import 'package:http/http.dart' as http;

enum Resource { BOOKS, ENTRIES }

const _base = "http://localhost/";

const _uris = {
  Resource.BOOKS: _base + "api/book",
  Resource.ENTRIES: _base + "api/entry"
};

String _params(Map<String, String> params) {
  if (params == null || params.isEmpty) {
    return "";
  }

  return params.keys.fold(StringBuffer("?"), (StringBuffer buff, k) {
    buff.write("$k=${params[k]}&");
    return buff;
  }).toString();
}

Future apiGet({Resource resource, Map<String, String> params}) async {
  try {
    var url = _uris[resource] + _params(params);
    print("making GET $url");
    var res = await http.get(url, headers: {
      "Accept": "application/json",
    });

    print("decoding response");
    return json.decode(res.body);
  } catch (err) {
    print("error fetching data:");
    print(err);
  }
}
