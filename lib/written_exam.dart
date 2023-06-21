
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'DirectoryHelper.dart';

class WrittenAnswerScreen extends StatefulWidget {
  final String mainQuestionAnswerTitle;

  WrittenAnswerScreen({required this.mainQuestionAnswerTitle});

  @override
  _WrittenAnswerScreenState createState() => _WrittenAnswerScreenState();
}

class _WrittenAnswerScreenState extends State<WrittenAnswerScreen> {
  List<String> questionNames = ['ক', 'খ', 'গ', 'ঘ'];
  int _whichQuestionRunningCounter = 1;
  List<List<ImageItem>> rowItems = [];

  void addItem(int rowIndex) {
    pickImageFromGallery(rowIndex);
  }

  Future<String> createPdf(List<File> imageFiles, {required String subdirectory}) async {
    final pdf = pdfWidgets.Document();

    for (var imageFile in imageFiles) {
      final imageBytes = await imageFile.readAsBytes();
      final image = pdfWidgets.MemoryImage(imageBytes);

      pdf.addPage(
        pdfWidgets.Page(
          build: (pdfWidgets.Context context) => pdfWidgets.Column(
            crossAxisAlignment: pdfWidgets.CrossAxisAlignment.stretch,
            children: [
              pdfWidgets.Expanded(
                child: pdfWidgets.Image(image, fit: pdfWidgets.BoxFit.fill),
              ),
            ],
          ),
        ),
      );
    }

    final output = await DirectoryHelper.getAppDirectory(subdirectory);
    final file = File("${output.path}/example.pdf");
    await file.writeAsBytes(await pdf.save());
    debugPrint("FILE_PATH: ${file.path.toString()}");
    return file.path;
  }

  /// Solved without CROP
  // Future<void> pickImageFromGallery(int rowIndex) async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       rowItems[rowIndex].insert(0, ImageItem(
  //         image: File(image.path),
  //         onDelete: () {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: const Text('Confirm Delete'),
  //                 content: const Text('Are you sure you want to delete this image?'),
  //                 actions: <Widget>[
  //                   TextButton(
  //                     child: const Text('Cancel'),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                   TextButton(
  //                     child: const Text('Delete'),
  //                     onPressed: () {
  //                       setState(() {
  //                         rowItems[rowIndex].removeWhere((item) => item.image.path == image.path);
  //                       });
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                 ],
  //               );
  //             },
  //           );
  //         },
  //       ));
  //     });
  //   }
  // }

  /// Adding the CROPPING functionality:
  Future<void> pickImageFromGallery(int rowIndex) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Create a file instance from the picked image's path.
      File initialImageFile = File(image.path);

      // Open the cropping UI.
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: initialImageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
        ]
      );

      if (croppedFile != null) {
        File convertCroppedFileToFile = File(croppedFile.path);
        setState(() {
          rowItems[rowIndex].insert(0, ImageItem(
            image: convertCroppedFileToFile,
            onDelete: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this image?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          setState(() {
                            rowItems[rowIndex].removeWhere((item) => item.image.path == croppedFile.path);
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ));
        });
      }
    }
  }



  @override
  void initState() {
    super.initState();
    // for (int i = 0; i < questionNames.length; i++) {
    //   rowItems.add([]);
    // }

    rowItems.add([]);
  }

  Widget buildDefaultItem(int rowIndex) {
    return GestureDetector(
      onTap: () {
        addItem(rowIndex);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.grey,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Answer Sheet",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: Container(
                        alignment: Alignment.center,
                        height: 75,
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.mainQuestionAnswerTitle,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        if (rowItems.length < questionNames.length) {
                          if (_whichQuestionRunningCounter < questionNames.length - 1) {
                            _whichQuestionRunningCounter ++;
                          }

                          setState(() {
                            rowItems.add([]);
                          });
                        }
                      },
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_outlined,
                                color: Colors.black,
                              ),
                              Text(
                                "${questionNames[_whichQuestionRunningCounter]} এর উত্তর",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List<Widget>.generate(rowItems.length, (rowIndex) {
                    final questionName = questionNames[rowIndex];
                    final items = rowItems[rowIndex];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 10,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 15, top: 5, bottom: 5, right: 15),
                                child: Text(
                                  questionName,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () async {
                                // Handle PDF generation
                                String pdfPath = await createPdf(rowItems[rowIndex].whereType<ImageItem>().map((item) => item.image).toList(), subdirectory: "WrittenExam");
                                showPdf(pdfPath, "${questionNames[_whichQuestionRunningCounter - 1]} এর উত্তর");
                              },
                              splashColor: Colors.blue, // Set the desired splash color
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 1.5,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 15,
                                    top: 5,
                                    bottom: 5,
                                    right: 15,
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_outlined),
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10
                            ),
                            itemCount: items.length + 1,
                            itemBuilder: (context, index) {
                              if (index == items.length) {
                                return buildDefaultItem(rowIndex);
                              }
                              return items[index];
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showPdf(String pdfPath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: PDFView(
            filePath: pdfPath,
            autoSpacing: false,
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }


}

class ImageItem extends StatelessWidget {
  final File image;
  final VoidCallback onDelete;

  const ImageItem({super.key, required this.image, required this.onDelete});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onLongPress: onDelete,
      onTap: () {
        showDialog(
            context: context, 
            builder: (BuildContext context) => Dialog(
              child: Image.file(image),
            )
        );
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

  }
}
