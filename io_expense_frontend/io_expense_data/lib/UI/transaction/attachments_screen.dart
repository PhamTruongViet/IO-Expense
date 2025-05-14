import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:io_expense_data/services/api_service.dart';

class AttachmentScreen extends StatefulWidget {
  final String? path;

  const AttachmentScreen({super.key, this.path});

  @override
  _AttachmentScreenState createState() => _AttachmentScreenState();
}

class _AttachmentScreenState extends State<AttachmentScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> uploadedImages = [];
  ApiService apiService = ApiService();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchImageFromPath(widget.path!);
    if (uploadedImages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPicker(this.context);
      });
    }
  }

  Future<void> fetchImageFromPath(String path) async {
    if (path.isEmpty) return;
    setState(() {
      _selectedImage = File(path);
      uploadedImages.insert(0, _selectedImage!);
    });
  }

  Future<void> imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File photo = File(pickedFile.path);
      setState(() {
        _selectedImage = photo;
        uploadedImages.insert(0, photo);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File photo = File(pickedFile.path);
      setState(() {
        _selectedImage = photo;
        uploadedImages.insert(0, photo);
      });
    } else {
      print('No image selected.');
    }
  }

  void deleteImage(int index) async {
    final fileName = basename(uploadedImages[index].path);
    final destination = 'files/$fileName';
    try {
      // Your delete logic here
    } catch (e) {
      print('Error occurred while deleting image: $e');
    }
    setState(() {
      uploadedImages.removeAt(index);
    });
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

  void _saveImage() {
    if (_selectedImage != null) {
      Navigator.of(this.context).pop(_selectedImage!.path);
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attachments'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: uploadedImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImage = uploadedImages[index];
                    });
                  },
                  onLongPress: () {
                    deleteImage(index);
                  },
                  child: Card(
                    elevation: 4,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.file(
                        uploadedImages[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: _clearSelectedImage,
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Stack(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40.0,
                        left: 20.0,
                        right: 20.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveImage,
                                icon: const Icon(Icons.save),
                                label: const Text('Save'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 12.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearSelectedImage,
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                    vertical: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _selectedImage == null
          ? FloatingActionButton(
              onPressed: () {
                _showPicker(context);
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
