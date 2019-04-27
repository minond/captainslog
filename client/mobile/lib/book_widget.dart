import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'book_model.dart';
import 'entry_model.dart';

class BooksWidget extends StatefulWidget {
  BooksWidget({Key key}) : super(key: key);

  @override
  BooksWidgetState createState() => BooksWidgetState();
}

class BooksWidgetState extends State<BooksWidget> {
  List<Book> books;
  List<Entry> entries;
  String activeBookGuid;
  bool loading;

  void refreshBooks() async {
    this.setState(() {
      loading = true;
    });

    var _books = await Book.find();
    this.setState(() {
      books = _books;
      loading = false;
    });
  }

  void activateBook(Book book) async {
    this.setState(() {
      activeBookGuid = book.guid;
    });

    var _entries = await Entry.findFor(book);
    this.setState(() {
      entries = _entries;
    });
  }

  @override
  void initState() {
    refreshBooks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Books"),
          trailing: CupertinoButton(
            child: Icon(Icons.refresh),
            onPressed: refreshBooks,
          ),
        ),
        child: loading == true
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : ListView.builder(
                itemCount: books != null ? books.length : 0,
                itemBuilder: (context, i) {
                  return BookWidget(
                      this.books[i],
                      this.books[i].guid == this.activeBookGuid
                          ? this.entries
                          : null, (book) {
                    activateBook(book);
                  });
                }));
  }
}

class BookWidget extends StatelessWidget {
  final Book book;
  final List<Entry> entries;
  final void Function(Book) onTap;

  BookWidget(this.book, this.entries, this.onTap);

  @override
  Widget build(BuildContext context) {
    var header = Container(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          onTap(book);
        },
        child: Text(
          book.name,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    var rows = <Widget>[header];

    if (entries != null) {
      for (var i = 0; i < entries.length; i++) {
        rows.add(
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              entries[i].text,
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
