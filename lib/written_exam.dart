
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WrittenAnswerScreen extends StatefulWidget {
  final String mainQuestionAnswerTitle;

  WrittenAnswerScreen({required this.mainQuestionAnswerTitle});

  @override
  _WrittenAnswerScreenState createState() => _WrittenAnswerScreenState();
}

class _WrittenAnswerScreenState extends State<WrittenAnswerScreen> {
  List<String> questionNames = ['Ka', 'Kha', 'Ga', 'Gha'];
  List<List<ImageItem>> rowItems = [];

  void addItem(int rowIndex) {
    pickImageFromGallery(rowIndex);
  }

  Future<void> pickImageFromGallery(int rowIndex) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        rowItems[rowIndex].insert(0, ImageItem(image: File(image.path)));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < questionNames.length; i++) {
      rowItems.add([]);
    }
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
                            children: const [
                              Icon(
                                Icons.add_outlined,
                                color: Colors.black,
                              ),
                              Text(
                                "Add question",
                                style: TextStyle(
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
              child: ListView.builder(
                itemCount: rowItems.length,
                itemBuilder: (context, rowIndex) {
                  final questionName = questionNames[rowIndex];
                  final items = rowItems[rowIndex];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        child: GridView.builder(
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageItem extends StatelessWidget {
  final File image;

  ImageItem({required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.file(
      image,
      fit: BoxFit.cover,
    );
  }
}
