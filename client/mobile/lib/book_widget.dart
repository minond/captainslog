import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'book_model.dart';
import 'entry_model.dart';
import 'entry_widget.dart';

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
                  return BookWidget(this.books[i], this.entries, (book) {
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
    return GestureDetector(
      onTap: () {
        onTap(book);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          book.name,
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
