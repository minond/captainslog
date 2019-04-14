import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'book_model.dart';

class BooksWidget extends StatefulWidget {
  BooksWidget({Key key}) : super(key: key);

  @override
  BooksWidgetState createState() => BooksWidgetState();
}

class BooksWidgetState extends State<BooksWidget> {
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
                  return BookWidget(this.books[i]);
                }));
  }
}

class BookWidget extends StatelessWidget {
  final Book book;

  BookWidget(this.book);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Text(
        book.name,
        style: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
