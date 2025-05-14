import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:io_expense_data/services/api_service.dart';

class PickFile extends StatefulWidget {
  final Function(String filePath) onFileSelected;

  const PickFile({super.key, required this.onFileSelected});

  @override
  _PickFileState createState() => _PickFileState();
}

class _PickFileState extends State<PickFile> {
  ApiService apiService = ApiService();
  late List<CameraDescription> cameras;
  CameraController? controller;
  List<File> uploadedImages = [];
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.isNotEmpty) {
        controller = CameraController(cameras[0], ResolutionPreset.high);
        controller!.initialize().then((_) {
          if (!mounted) return;
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      setState(() {
        uploadedImages.insert(0, _photo!);
      });
      widget.onFileSelected(pickedFile.path);
      print('Image path: ${pickedFile.path}');
    } else {
      print('No image selected.');
    }
  }

  Future<void> imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      setState(() {
        uploadedImages.insert(0, _photo!);
      });
      widget.onFileSelected(pickedFile.path);
      print('Image path: ${pickedFile.path}');
    } else {
      print('No image selected.');
    }
  }

  void deleteImage(int index) {
    setState(() {
      uploadedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        _showPicker(context);
      },
      icon: const Icon(Icons.attachment, color: Colors.black54),
      label: const Text('Attachment'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  imgFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
