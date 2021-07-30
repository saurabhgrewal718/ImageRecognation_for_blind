import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:introduction_screen/introduction_screen.dart';

void main() {
  runApp(MyApp());
}

const String ssd = "SSD MobileNet";

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define the default brightness and colors.
        primaryColor: Colors.black,
        accentColor: Colors.yellow),
      home: OnBoardingPage(),
    );
  }
}

enum TtsState { playing, stopped, paused, continued }

class OnBoardingPage extends StatefulWidget {

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TfliteHome()),
    );
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/images/img2.gif',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      globalHeader: Align(
        alignment: Alignment.topRight,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, right: 16),
            child: _buildImage('images/img5.gif', 100),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          child: const Text(
            'Let\s go right away!',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,color: Colors.black),
          ),
          style: ElevatedButton.styleFrom(primary: Colors.yellow),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "What's this app?",
          body:
              "Hello my name is Saurabh Grewal And this app is giving you the third eye,Let your camera see the things around you and then Speaks it Loud to you!",
          image: _buildImage('images/img2.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "How its Made?",
          body:
              "A ML model is trained on the TensorFlow Lite whose size is 4mb...it works on device(without internet) and predicts whos around you! Flutter is used to make the Android App :)",
          image: _buildImage('images/img4.gif'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "How to use It?",
          body:
              "Just Upload/Click the image you want to check! and the ML model tells you what's in Front of you :)",
          image: _buildImage('images/img3.gif'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      skip: const Text('Skip',style: TextStyle(color:Colors.black),),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(color:Colors.black,fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12.0)
          : const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}


class TfliteHome extends StatefulWidget {
  @override
  _TfliteHomeState createState() => _TfliteHomeState();
}

class _TfliteHomeState extends State<TfliteHome> {
  late File _image;

  late FlutterTts flutterTts;
  late String engine;
  double volume = 1;
  double pitch = 1.0;
  double rate = 0.7;
  List tes = [];
  List tes1 = [];

  
  TtsState ttsState = TtsState.stopped;

  Future _speak(List tes1) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    // print('point11111111111111111111111111111111111');
    // print(tes1);
    if (tes1 != null) {
      if (tes1.isNotEmpty) {
        if(tes1.length>1){
            await flutterTts.awaitSpeakCompletion(true);
            await flutterTts.speak('i see a' + tes1[0] + ' and a ' + tes1[1]);
        }else{
            await flutterTts.awaitSpeakCompletion(true);
            await flutterTts.speak('i see a' + tes1[0]);
        }
        
      }
    }
  }

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  late double _imageWidth;
  late double _imageHeight;
  bool _busy = false;

  late List _recognitions;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  loadModel() async {
    Tflite.close();
    try {
      await Tflite.loadModel(
          model: "assets/tflite/ssd_mobilenet.tflite",
          labels: "assets/tflite/ssd_mobilenet.txt",
        );
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  selectFromImagePicker() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  selectFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(image);
  }

  predictImage(File image) async {
    if (image == null) return;
      await ssdMobileNet(image);

    FileImage(image)
        .resolve(ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
          setState(() {
            _imageWidth = info.image.width.toDouble();
            _imageHeight = info.image.height.toDouble();
          });
        })));

    setState(() {
      _image = image;
      _busy = false;
    });
  }


  ssdMobileNet(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path, numResultsPerClass: 1);
    _recognitions = recognitions!;
    // print(_recognitions);
    if(_recognitions[0]["confidenceInClass"]>0.5 && _recognitions[1]["confidenceInClass"]>0.5){
        tes= [];
        // print(tes);
        // print(_recognitions[0]["confidenceInClass"].toString() +' , '+ _recognitions[1]["confidenceInClass"].toString());
        for (var i=0; i<3; i++) {
            if(!tes.contains(_recognitions[i]["detectedClass"])){
              tes.insert(i,_recognitions[i]["detectedClass"]);
              // print('point 2222222222');
              // print(tes);
            }
        }
        setState(() {
          tes1 = tes;
          _speak(tes1);
        });
        
    }else{
      tes= [];
      tes.insert(0,_recognitions[0]["detectedClass"]);
      setState(() {
          tes1 = tes;
          _speak(tes1);
      });
    }
  }


  List<Widget> renderBoxes(Size screen) {
    if (_recognitions == null) return [];
    if (_imageWidth == null || _imageHeight == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageHeight * screen.width;

    Color blue = Colors.red;

    return _recognitions.map((re) {
      return Positioned(
        left: re["rect"]["x"] * factorX,
        top: re["rect"]["y"] * factorY,
        width: re["rect"]["w"] * factorX,
        height: re["rect"]["h"] * factorY,
        child: ((re["confidenceInClass"] > 0.50))? Container(
          decoration: BoxDecoration(
              border: Border.all(
            color: blue,
            width: 3,
          )),
          child: Text(
            "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = blue,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ) : Container()
     );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Center(child: Container(
        padding: EdgeInsets.only(top:80),
        child: Text("No Image Selected, Pick an Image",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.black)
            )
          )
        ) : Image.file(_image),
    ));

    stackChildren.addAll(renderBoxes(size));   

    if (_busy) {
      stackChildren.add(Center(
        child: CircularProgressIndicator(),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Help Me See!",style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold,color: Colors.black)),
        backgroundColor: Colors.yellow,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.yellow),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:10),
            child: FloatingActionButton.extended (
                icon: Icon(Icons.image),
                label: Text('Upload',style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,color: Colors.black)),
                backgroundColor: Colors.yellow,
                tooltip: "Upload from Gallary",
                onPressed: selectFromImagePicker,
              ),
          ),
          // SizedBox(
          //   height: 10,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:10),
            child: FloatingActionButton.extended (
                icon: Icon(Icons.camera),
                label: Text('Click',style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,color: Colors.black)),
                backgroundColor: Colors.yellow,
                tooltip: "Pick Image from Camera",
                onPressed: selectFromCamera,
              ),
          ),
        ]
      ),
      body: Stack(
        children: stackChildren,
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}




