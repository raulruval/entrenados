import 'dart:io';

import 'package:entrenados/widgets/header.dart';
import 'package:entrenados/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DocumentViewPage extends StatefulWidget {
  final String documentUrl;
  DocumentViewPage({@required this.documentUrl, Key key}) : super(key: key);

  @override
  _DocumentViewPageState createState() => _DocumentViewPageState();
}

class _DocumentViewPageState extends State<DocumentViewPage> {
  String _documentUrl = '';
  String _file;
final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _documentUrl = widget.documentUrl;
    loadDocument().then((value) {
      setState(() {
        _file = value;
      });
    });
    super.initState();
  }

  mostrarError(){
    SnackBar snackbar = SnackBar(
          content: Text(
              "Si el contenido no se visualiza correctamente contacta con el creador de la publicación.",),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Future<String> loadDocument() async {
    var response = await http.get(_documentUrl);
    var dir = await getTemporaryDirectory();
    File file = new File(dir.path + "/data.pdf");
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          removeBackButton: false, titleText: 'Visualizador de documento'),
      body: Container(
        child: _file != null ? PDFView(filePath: _file, onError: mostrarError(),) : circularProgress(),
      ),
    );
  }
}
