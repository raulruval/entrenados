import 'package:flutter/material.dart';

circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 15.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue[300]),
    ),
  );
}

linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.blue[300]),
    ),
  );
}
