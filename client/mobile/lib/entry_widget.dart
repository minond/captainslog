import 'package:flutter/cupertino.dart';

import 'entry_model.dart';

class EntriesWidget extends StatelessWidget {
  final List<Entry> entries;

  EntriesWidget(this.entries);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Text("entry"),
    );
  }
}
