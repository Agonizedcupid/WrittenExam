import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DirectoryHelper {
  static Future<Directory> getAppDirectory(String subdirectory) async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      print(e.toString());
    }

    // Format the current date
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    final formattedDate = formatter.format(now);

    final newPath = path.join(directory!.path, 'Utkorsho', subdirectory, formattedDate);
    Directory newDirectory = Directory(newPath);

    // If the folder doesn't exist, create it
    if (!await newDirectory.exists()) {
      newDirectory = await newDirectory.create(recursive: true);
    }

    return newDirectory;
  }
}
