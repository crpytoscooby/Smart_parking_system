import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
//import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter_tts/flutter_tts.dart';




void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking System')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('Tap to check slot'),
        ),
      ),
    );
  }
}

class MyTextToSpeechClass {
  late FlutterTts flutterTts;
  String? _newVoiceText;

  Future _speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(2.0);
    await flutterTts.setVolume(2.0);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(_newVoiceText!);
    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }



  }

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  String? apiResponseData;

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  /*if (result != null)
                    Text(
                        'Available Parking Blocks:\n ${apiResponseData}', style: TextStyle(fontSize: 30)),
                    SizedBox(height: 20),
                    Image.network(
                      'https://github.com/crpytoscooby/parking/blob/main/Layout%20example%202.png', // Replace with the actual image URL
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  else
                    const Text('Scan a code'),*/

                  if (result != null)
                    Column(
                      children: [
                        Text('Available Parking Blocks:\n $apiResponseData', style: TextStyle(fontSize: 30)),
                        SizedBox(height: 10),
                        // Image.network(
                        //   'https://drive.google.com/file/d/1mXGanMtjASTxa4wWSq-S2M2zUw5OPkRQ/view?usp=sharing',
                        //   width: 200,
                        //   height: 200,
                        //   fit: BoxFit.cover,
                        // ),
                        Image.asset('assets/layout.png')
                      ],
                    )
                  else
                    const Text('Scan a code'),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        alignment:Alignment.centerLeft,
                        child: ElevatedButton(
                            onPressed: () async {
                              await book1();
                              fetchData();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Block-p1');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await book2();
                              fetchData();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Block-p2');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await book3();
                              fetchData();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Block-p3');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await book4();
                              fetchData();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Block-p4');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');

                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            final pdf = generateReceipt('Parking Lot A', 'ABC123', 20.0);
                            final bytes = await pdf.save();
                            final dir = await getApplicationDocumentsDirectory();
                            final file = File('${dir.path}/receipt.pdf');
                            await file.writeAsBytes(bytes);
                          },
                          child: const Text('Get Receipt',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            /*speak('Hello, World!');*/
                            String apiResponse = 'Available Parking Blocks $apiResponseData'; // Replace with your actual API response retrieval logic
                            speak(apiResponse);
                          },
                          child: const Text('Speak',
                                style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text('Resume',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),

                        Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                        },
                          child: const Text('Pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }



  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://a9da-183-87-227-65.ngrok-free.app/export-data'));

    if (response.statusCode == 200) {
      // handle successful response
      final data = response.body;
      setState(() {
        // set the response data to a variable to be displayed in the UI
        apiResponseData = data;
      });
    } else {
      // handle error response
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> book1() async {
    final response = await http.get(Uri.parse('https://a9da-183-87-227-65.ngrok-free.app/book1'));

    if (response.statusCode == 200) {
      // handle successful response
      final data = response.body;
      setState(() {
        // set the response data to a variable to be displayed in the UI
        apiResponseData = data;
      });
    } else {
      // handle error response
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> book2() async {
    final response = await http.get(Uri.parse('https://a9da-183-87-227-65.ngrok-free.app/book2'));
    if (response.statusCode == 200) {
      // handle successful response
      final data = response.body;
      setState(() {
        // set the response data to a variable to be displayed in the UI
        apiResponseData = data;
      });
    } else {
      // handle error response
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> book3() async {
    final response = await http.get(Uri.parse('https://a9da-183-87-227-65.ngrok-free.app/book3'));

    if (response.statusCode == 200) {
      // handle successful response
      final data = response.body;
      setState(() {
        // set the response data to a variable to be displayed in the UI
        apiResponseData = data;
      });
    } else {
      // handle error response
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> book4() async {
    final response = await http.get(Uri.parse('https://a9da-183-87-227-65.ngrok-free.app/book4'));

    if (response.statusCode == 200) {
      // handle successful response
      final data = response.body;
      setState(() {
        // set the response data to a variable to be displayed in the UI
        apiResponseData = data;
      });
    } else {
      // handle error response
      throw Exception('Failed to fetch data');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchData();
  }



  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 390 ||
            MediaQuery.of(context).size.height < 390)
        ? 200.0
        : 200.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.lightBlueAccent,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
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

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  getApplicationDocumentsDirectory() {}
}

pw.Document generateReceipt(String parkingLotName, String vehicleNumber, double amount) {
  final pdf = pw.Document();

  pdf.addPage(pw.Page(
    build: (context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Parking Receipt',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 24),
          pw.Text('Parking Lot: $parkingLotName',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 12),
          pw.Text('Vehicle Number: $vehicleNumber',
              style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 12),
          pw.Text('Amount Paid: $amount',
              style: pw.TextStyle(fontSize: 16)),
        ],
      );
    },
  ));

  return pdf;
}

class ReceiptPage extends StatefulWidget {
  final String filePath;

  ReceiptPage({required this.filePath});

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : PDFView(
          filePath: widget.filePath,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          onRender: (_pages) {
            setState(() {
              _isLoading = false;
            });
          },
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
        ),
      ),
    );
  }
}



