import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class CameraCaptureWidget extends StatefulWidget {
  /// Called when the user captures or picks an image.
  /// The parent widget decides what to do with the file (send to API, etc.)
  final void Function(File imageFile) onImageCaptured;

  /// Optional: show a gallery picker button alongside the camera
  final bool showGalleryOption;

  const CameraCaptureWidget({
    super.key,
    required this.onImageCaptured,
    this.showGalleryOption = true,
  });

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget>
    with WidgetsBindingObserver {
  
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;
  int _selectedCameraIndex = 0; // 0 = back camera usually

  @override
  void initState() {
    super.initState();
    // WidgetsBindingObserver lets us pause/resume camera when app backgrounds
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  /// Request permission then set up the camera controller.
  Future<void> _initializeCamera() async {
    // Ask for camera permission at runtime
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _errorMessage = 'Camera permission denied');
      return;
    }

    try {
      // Get all available cameras (front, back, external)
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras found on this device');
        return;
      }

      await _startCamera(_selectedCameraIndex);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to initialize camera: $e');
    }
  }

  /// Creates and initializes a CameraController for the camera at [index].
  Future<void> _startCamera(int cameraIndex) async {
    // Dispose old controller before creating a new one (e.g. when switching cameras)
    await _controller?.dispose();

    final controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.high, // high = good quality without being too large
      enableAudio: false,     // translation app doesn't need audio
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      // initialize() is async — the preview isn't available until this completes
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Camera error: ${e.description}');
      }
    }
  }

  /// Takes a picture and calls the parent's callback with the file.
  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isCapturing) return; // prevent double-tap

    setState(() => _isCapturing = true);

    try {
      // takePicture() saves to a temporary file and returns its path
      final XFile xFile = await _controller!.takePicture();
      final File imageFile = File(xFile.path);
      
      // Notify the parent widget
      widget.onImageCaptured(imageFile);
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Capture failed: ${e.description}')),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  /// Let the user pick from their gallery instead of capturing live.
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90, // 0-100, compress a bit to keep file size reasonable
    );
    if (picked != null) {
      widget.onImageCaptured(File(picked.path));
    }
  }

  /// Switch between front and back camera.
  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitialized = false);
    await _startCamera(_selectedCameraIndex);
  }

  // Pause camera when app goes to background, resume when it comes back.
  // This prevents battery drain and camera conflicts.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(_selectedCameraIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // ── Camera Preview ──────────────────────────────────────────────
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // CameraPreview fills the available space
                // AspectRatio wraps it so it doesn't distort on different devices
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),

                // Overlay: flip camera button (top right)
                if (_cameras.length > 1)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      onPressed: _toggleCamera,
                      icon: const Icon(Icons.flip_camera_ios_rounded),
                      color: Colors.black,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),

                // Overlay: framing guide (helps user center text)
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white54, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Controls ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery picker
            if (widget.showGalleryOption)
              IconButton.outlined(
                color: Colors.white,
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                tooltip: 'Pick from gallery',
              ),

            // Shutter button
            GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _isCapturing ? 60 : 70,
                height: _isCapturing ? 60 : 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCapturing ? Colors.grey : Colors.white,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: _isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
            ),

            // Placeholder to keep shutter centered
            if (widget.showGalleryOption) const SizedBox(width: 48),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeCamera,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}