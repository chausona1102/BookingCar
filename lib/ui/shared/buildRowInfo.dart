import 'package:flutter/material.dart';

Widget buildRowInfo(String title, String info) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Expanded(
        flex: 3,
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: Colors.black38,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      Expanded(
        flex: 7,
        child: Text(
          info,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    ],
  );
}
