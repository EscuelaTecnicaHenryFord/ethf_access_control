import 'dart:convert';

import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

Future<FlutterBarcodeSdk> initBarcodeSDK() async {
  final barcodeReader = FlutterBarcodeSdk();
  // Get 30-day FREEE trial license from https://www.dynamsoft.com/customer/license/trialLicense?product=dbr
  await barcodeReader.setLicense(
      'DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==');
  await barcodeReader.init();
  await barcodeReader.setBarcodeFormats(BarcodeFormat.PDF417);
  // Get all current parameters.
  // Refer to: https://www.dynamsoft.com/barcode-reader/parameters/reference/image-parameter/?ver=latest
  String params = await barcodeReader.getParameters();
  // Convert parameters to a JSON object.
  dynamic obj = json.decode(params);
  // Modify parameters.
  obj['ImageParameter']['DeblurLevel'] = 5;
  // Update the parameters.
  int ret = await barcodeReader.setParameters(json.encode(obj));
  print('Parameter update: $ret');

  return barcodeReader;
}
