import 'package:camera/camera.dart';

List<CameraDescription>? cameras;
Future<List<CameraDescription>>? future;

Future<List<CameraDescription>> globalAvailableCameras() async {
  if (cameras != null) return cameras!;
  if (future != null) return future!;

  final f = availableCameras();
  future = f;
  cameras = await f;
  future = null;
  return cameras!;
}
