import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR Code Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter QR Code Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
  }

  Future _link(String? url) async {
    if (url != null) {
      return await launch(url);
    } else {
      throw 'null';
    }
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = StrutStyle( fontSize: 15, height: 2 );
    const buttonStyle = TextStyle( fontSize: 20 );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _buildQrView(context)),
            Expanded(
                child: Column(children: <Widget>[
                  if (result != null)
                    Column(children: <Widget>[
                      Text('Format : ${result?.format}', strutStyle: textStyle ),
                      TextButton(
                          onPressed: () => _link(result?.code),
                          child: Text('${result?.code}', style: TextStyle( fontSize: 15 ))),
                    ])
                  else
                    Column(children: <Widget>[
                      Text('nil', strutStyle: textStyle),
                      Text('nil', strutStyle: textStyle),
                    ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () async => await controller?.resumeCamera(),
                          child: Text('resume', style: buttonStyle),
                        ),
                        ElevatedButton(
                          onPressed: () async => await controller?.pauseCamera(),
                          child: Text('pause', style: buttonStyle),
                        )
                      ])
                ]))
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        cutOutSize: 500,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
