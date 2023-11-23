import 'dart:convert';

import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

Future<FlutterBarcodeSdk> initBarcodeSDK() async {
  final barcodeReader = FlutterBarcodeSdk();
  // Get 30-day FREEE trial license from https://www.dynamsoft.com/customer/license/trialLicense?product=dbr
  await barcodeReader.setLicense(
      'DLS2eyJoYW5kc2hha2VDb2RlIjoiMTAyNDAzMjAzLVRYbE5iMkpwYkdWUWNtOXFYMlJpY2ciLCJtYWluU2VydmVyVVJMIjoiaHR0cHM6Ly9tZGxzLmR5bmFtc29mdG9ubGluZS5jb20iLCJvcmdhbml6YXRpb25JRCI6IjEwMjQwMzIwMyIsInN0YW5kYnlTZXJ2ZXJVUkwiOiJodHRwczovL3NkbHMuZHluYW1zb2Z0b25saW5lLmNvbSIsImNoZWNrQ29kZSI6Mzg3NTM2NzEzfQ==');
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

FlutterBarcodeSdk? barcodeReader;
Future<FlutterBarcodeSdk>? future;

Future<FlutterBarcodeSdk> globalInitBarcodeSDK() async {
  if (barcodeReader != null) return barcodeReader!;
  if (future != null) return future!;

  final f = initBarcodeSDK();
  future = f;
  barcodeReader = await f;
  future = null;

  return barcodeReader!;
}
