import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FiltrosFaciale extends StatefulWidget {
  const FiltrosFaciale({super.key});

  @override
  State<FiltrosFaciale> createState() => _FiltrosFacialeState();
}

class _FiltrosFacialeState extends State<FiltrosFaciale> {
  ui.Image? _decodedImage;
  ui.Image? _glassesImage;
  ui.Image? _mustacheImage;
  ui.Image? _capImage;
  List<Face> _faces = [];
  bool _isProcessing = false;
  bool _showGlasses = true;
  bool _showMustache = true;
  bool _showCap = true;
  String _status = 'Selecciona una foto para verla con los filtros.';

  late final FaceDetector _faceDetector;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );
    _loadOverlayAssets();
  }

  Future<void> _loadOverlayAssets() async {
    final glasses = await cargarImagenDeAsset('assets/filtros/glasses.png');
    final mustache = await cargarImagenDeAsset('assets/filtros/bigote.png');
    final cap = await cargarImagenDeAsset('assets/filtros/gorra.png');
    if (!mounted) return;
    setState(() {
      _glassesImage = glasses;
      _mustacheImage = mustache;
      _capImage = cap;
    });
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _pickAndDetect(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    if (!mounted) return;
    setState(() {
      _decodedImage = frame.image;
      _faces = [];
      _status = 'Detectando rostros...';
    });

    await _detectFaces(file);
  }

  Future<void> _detectFaces(File file) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      // Mismo patrón de siempre: archivo -> InputImage -> procesador ->
      // resultado. Aquí el resultado trae, además del cuadro delimitador,
      // los landmarks de cada rostro.
      final inputImage = InputImage.fromFile(file);
      final faces = await _faceDetector.processImage(inputImage);
      if (!mounted) return;
      setState(() {
        _faces = faces;
        _isProcessing = false;
        if (faces.isEmpty) {
          _status =
              'No se detectó ningún rostro. Prueba con una foto de '
              'frente, con buena luz y sin obstrucciones.';
        } else {
          final sinLandmarks = faces
              .where(
                (f) =>
                    f.landmarks[FaceLandmarkType.leftEye] == null ||
                    f.landmarks[FaceLandmarkType.rightEye] == null,
              )
              .length;
          _status =
              '${faces.length} rostro(s) detectado(s).'
              '${sinLandmarks > 0 ? ' $sinLandmarks sin landmarks completos '
                        '(rostro de perfil o parcialmente oculto): el filtro no '
                        'se dibuja ahí.' : ' Activa o desactiva los filtros abajo.'}';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _status = 'Ocurrió un error al detectar rostros: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Detector de rostros',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        if (_decodedImage != null)
          AspectRatio(
            aspectRatio: _decodedImage!.width / _decodedImage!.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: FiltrosFacialesPainter(
                  image: _decodedImage!,
                  faces: _faces,
                  glasses: _showGlasses ? _glassesImage : null,
                  mustache: _showMustache ? _mustacheImage : null,
                  cap: _showCap ? _capImage : null,
                ),
              ),
            ),
          )
        else
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.face_outlined, size: 48, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickAndDetect(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickAndDetect(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Cámara'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Lentes'),
          value: _showGlasses,
          onChanged: _decodedImage == null
              ? null
              : (v) => setState(() => _showGlasses = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Gorra'),
          value: _showCap,
          onChanged: _decodedImage == null
              ? null
              : (v) => setState(() => _showCap = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Bigote'),
          value: _showMustache,
          onChanged: _decodedImage == null
              ? null
              : (v) => setState(() => _showMustache = v),
        ),
        const SizedBox(height: 8),
        Text(_status, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class FiltrosFacialesPainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final ui.Image? glasses;
  final ui.Image? mustache;
  final ui.Image? cap;

  FiltrosFacialesPainter({
    required this.image,
    required this.faces,
    required this.glasses,
    required this.mustache,
    required this.cap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / image.width, size.height / image.height);

    canvas.drawImage(image, Offset.zero, Paint());

    for (final face in faces) {
      pintarFiltrosEnRostro(
        canvas: canvas,
        face: face,
        glasses: glasses,
        mustache: mustache,
        cap: cap,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FiltrosFacialesPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.faces != faces ||
        oldDelegate.glasses != glasses ||
        oldDelegate.mustache != mustache ||
        oldDelegate.cap != cap;
  }
}

Future<ui.Image> cargarImagenDeAsset(String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();
  return frame.image;
}

void pintarFiltrosEnRostro({
  required Canvas canvas,
  required Face face,
  required ui.Image? glasses,
  required ui.Image? mustache,
  required ui.Image? cap,
}) {
  final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
  final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
  final noseBase = face.landmarks[FaceLandmarkType.noseBase]?.position;
  final leftMouth = face.landmarks[FaceLandmarkType.leftMouth]?.position;
  final rightMouth = face.landmarks[FaceLandmarkType.rightMouth]?.position;
  final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth]?.position;

  if (glasses != null && leftEye != null && rightEye != null) {
    _drawBetweenAnchors(
      canvas: canvas,
      overlay: glasses,
      anchorA: Offset(leftEye.x.toDouble(), leftEye.y.toDouble()),
      anchorB: Offset(rightEye.x.toDouble(), rightEye.y.toDouble()),
      widthFactor: 2.3,
    );
  }

  if (mustache != null && leftMouth != null && rightMouth != null) {
    final centerX = (leftMouth.x + rightMouth.x) / 2.0;
    final mouthTopY = bottomMouth != null
        ? bottomMouth.y.toDouble()
        : (leftMouth.y + rightMouth.y) / 2.0;

    final centerY = noseBase != null
        ? (noseBase.y.toDouble() + mouthTopY) / 2.0
        : mouthTopY - 14;
    final angle = math.atan2(
      (rightMouth.y - leftMouth.y).toDouble(),
      (rightMouth.x - leftMouth.x).toDouble(),
    );
    final mouthWidth = (rightMouth.x - leftMouth.x).abs().toDouble();
    _drawAt(
      canvas: canvas,
      overlay: mustache,
      center: Offset(centerX, centerY),
      angle: angle,
      targetWidth: mouthWidth * 1.7,
    );
  }

  if (cap != null) {
    final bounds = face.boundingBox;

    _drawAt(
      canvas: canvas,
      overlay: cap,
      center: Offset(
        bounds.left + bounds.width / 2,
        bounds.top - bounds.height / 2 + bounds.height * 0.08,
      ),
      angle: 0,
      targetWidth: bounds.width * 1.35,
    );
  }
}

void _drawBetweenAnchors({
  required Canvas canvas,
  required ui.Image overlay,
  required Offset anchorA,
  required Offset anchorB,
  required double widthFactor,
}) {
  final center = Offset(
    (anchorA.dx + anchorB.dx) / 2,
    (anchorA.dy + anchorB.dy) / 2,
  );

  final dx = anchorB.dx - anchorA.dx;
  final dy = anchorB.dy - anchorA.dy;
  final distance = math.sqrt(dx * dx + dy * dy);
  final angle = math.atan2(dy, dx);
  _drawAt(
    canvas: canvas,
    overlay: overlay,
    center: center,
    angle: angle,
    targetWidth: distance * widthFactor,
  );
}

void _drawAt({
  required Canvas canvas,
  required ui.Image overlay,
  required Offset center,
  required double angle,
  required double targetWidth,
}) {
  final scaleFactor = targetWidth / overlay.width;
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(angle);
  canvas.scale(scaleFactor);
  canvas.drawImage(
    overlay,
    Offset(-overlay.width / 2, -overlay.height / 2),
    Paint(),
  );
  canvas.restore();
}
