import 'package:flutter/material.dart';

import 'book_model.dart';

void main() => runApp(CaptainsLog());

class CaptainsLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Captain\'s Log',
      theme: ThemeData(primarySwatch: Colors.grey),
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
  List<Book> books = new List<Book>();

  void refresh() async {
    var _books = await Book.find();
    this.setState(() {
      books = _books;
    });
  }

  @override
  Widget build(BuildContext context) {
    var booksList = new List<Widget>();
    books.forEach((book) { booksList.add(Text(book.name)); });

    return Scaffold(
      appBar: AppBar(title: Text('Books')),
      body: ListView(children: booksList),
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }
}