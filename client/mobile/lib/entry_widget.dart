import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'entry_model.dart';

class EntriesWidget extends StatelessWidget {
  final List<Entry> entries;

  EntriesWidget(this.entries);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold();
  }
}
