import 'package:flutter/cupertino.dart';

import 'book_widget.dart';

void main() => runApp(CaptainsLog());

class CaptainsLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Captain\'s Log',
      home: BooksWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}
