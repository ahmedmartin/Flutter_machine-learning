import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ml_flutter/home.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
  home: Home(),//MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List ?_outputs;
  File ?_image;
  bool _loading = false;


  List<TextSpan> createTextSpans() {
    final string = """Text seems like it should be so simple, but it really isn't.""";
    final arrayStrings = string.split(" ");
    List<TextSpan> arrayOfTextSpan = [];
    for (int index = 0; index < arrayStrings.length; index++) {
      final text = arrayStrings[index] + " ";
      final span = TextSpan(
          text: text,
          style: TextStyle(color: Colors.black),
          recognizer: TapGestureRecognizer()
            ..onTap = () => print("The word touched is $text")
      );
      arrayOfTextSpan.add(span);
    }
    return arrayOfTextSpan;
  }

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Learning'),
      ),
      body:/*RichText(
        text: TextSpan(children: createTextSpans()),

      ) ,*/
      _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Container() : Image.file(_image!),
            SizedBox(
              height: 20,
            ),
            _outputs != null ? Text("${_outputs![0]["label"]}", style: TextStyle(color: Colors.black,
                fontSize: 20.0, background: Paint()..color = Colors.white,),)
                : Container(),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:pickImage,
        child: Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}