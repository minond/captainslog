import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'book_model.dart';

void main() => runApp(CaptainsLog());

class CaptainsLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Captain\'s Log',
      home: Books(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Books extends StatefulWidget {
  Books({Key key}) : super(key: key);

  @override
  BooksState createState() => BooksState();
}

class BooksState extends State<Books> {
  List<Book> books;
  bool loading;

  void refresh() async {
    this.setState(() {
      loading = true;
    });

    var _books = await Book.find();
    this.setState(() {
      books = _books;
      loading = false;
    });
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Books"),
          trailing: CupertinoButton(
            child: Icon(Icons.refresh),
            onPressed: refresh,
          ),
        ),
        child: loading == true
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : ListView.builder(
                itemCount: books != null ? books.length : 0,
                itemBuilder: (context, i) {
                  final book = this.books[i];
                  return Container(
                    child: Text(
                      book.name,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ));
  }
}
