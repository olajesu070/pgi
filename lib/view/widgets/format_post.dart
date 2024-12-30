import 'package:flutter/material.dart';

List<Widget> formatPost(String message) {
  List<Widget> formattedWidgets = [];
  
  // Split the message into lines (split by newline)
  List<String> lines = message.split('\n');

  for (String line in lines) {
    if (line.contains('[QUOTE]')) {
      // Handling [QUOTE]
      formattedWidgets.add(
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            // borderLeft: BorderSide(color: Colors.blue, width: 4),
          ),
          child: Text(
            line.replaceAll('[QUOTE]', '').trim(),
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey),
          ),
        ),
      );
    } else if (line.contains('[USER]')) {
      // Handling [USER]
      formattedWidgets.add(
        Text(
          line.replaceAll('[USER]', '').trim(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    } else if (line.contains('[LIST]')) {
      // Handling [LIST]
      List<String> listItems = line.replaceAll('[LIST]', '').split('[*]');
      formattedWidgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: listItems
              .where((item) => item.isNotEmpty)
              .map((item) => Row(
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.blue),
                      SizedBox(width: 5),
                      Expanded(child: Text(item.trim())),
                    ],
                  ))
              .toList(),
        ),
      );
    } else {
      // Normal line
      formattedWidgets.add(
        Text(line.trim(), style: TextStyle(fontSize: 14)),
      );
    }
  }

  return formattedWidgets;
}
