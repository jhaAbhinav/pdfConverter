import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Converter"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return MyPDFList();
                  }),
                );
              },
              child: Text("Show PDF"),
            ),
            MaterialButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return MyApp();
                  }),
                );
              },
              child: Text("Convert Image to PDF"),
            )
          ],
        ),
      ),
    );
  }
}

class MyPDFList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPDFList(); //create state
  }
}

class _MyPDFList extends State<MyPDFList> {
  var files;

  void getFiles() async {
    //asyn function to get list of files
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0]
        .rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm =
        FileManager(root: Directory("/storage/emulated/0/AltroneDrive")); //
    files = await fm.filesTree(
        excludedPaths: ["/storage/emulated/0/Android"],
        extensions: ["pdf"] //optional, to filter files, list only pdf files
        );
    setState(() {}); //update the UI
  }

  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("List of PDF"),
          // backgroundColor: Colors.redAccent
        ),
        body: files == null
            ? Text("Searching Files")
            : ListView.builder(
                //if file/folder list is grabbed, then show here
                itemCount: files?.length ?? 0,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    title: Text(files[index].path.split('/').last),
                    leading: Icon(Icons.picture_as_pdf),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Colors.redAccent,
                    ),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ViewPDF(pathPDF: files[index].path.toString());
                        //open viewPDF page on click
                      }));
                    },
                  ));
                },
              ));
  }
}

class ViewPDF extends StatelessWidget {
  String pathPDF = "";
  ViewPDF({this.pathPDF});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        //view PDF
        appBar: AppBar(
          title: Text("Document"),
          //  backgroundColor: Colors.deepOrangeAccent,
        ),
        path: pathPDF);
  }
}

// class ShowPDF extends StatefulWidget {
//   ShowPDF({Key? key}) : super(key: key);

//   @override
//   _ShowPDFState createState() => _ShowPDFState();
// }

// class _ShowPDFState extends State<ShowPDF> {
//   final FileManagerController controller = FileManagerController();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("List of PDF"),
//       ),
//       body: FileManager(
//         controller: controller,
//         builder: (context, snapshot) {
//           final List<FileSystemEntity> entities = snapshot;
//           print(entities);
//           return ListView.builder(
//             itemCount: entities.length,
//             itemBuilder: (context, index) {
//               return Card(
//                 child: ListTile(
//                   leading: FileManager.isFile(entities[index])
//                       ? Icon(Icons.feed_outlined)
//                       : Icon(Icons.folder),
//                   title: Text(FileManager.basename(entities[index])),
//                   onTap: () {
//                     if (FileManager.isDirectory(entities[index])) {
//                       controller
//                           .openDirectory(entities[index]); // open directory
//                     } else {
//                       // Perform file-related tasks.
//                       print(entities);
//                     }
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final picker = ImagePicker();
  final pdf = pw.Document();
  List<File> _image = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image to PDF"),
        actions: [
          _image.length != 0
              ? IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    createPDF();
                    savePDF();
                  })
              : Container()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _settingModalBottomSheet(context);
        },
      ),
      body: _image.length != 0
          ? ListView.builder(
              itemCount: _image.length,
              itemBuilder: (context, index) => Container(
                  height: 400,
                  width: double.infinity,
                  margin: EdgeInsets.all(8),
                  child: Image.file(
                    _image[index],
                    fit: BoxFit.cover,
                  )),
            )
          : Center(child: Container(child: Text("Add Images"))),
    );
  }

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Camera'),
                    onTap: () {
                      getImageFromGallery(ImageSource.camera);
                      Navigator.pop(context);
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_album),
                  title: new Text('Gallery'),
                  onTap: () {
                    getImageFromGallery(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  getImageFromGallery(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image.add(File(pickedFile.path));
      } else {
        print('No image selected');
      }
    });
  }

  createPDF() async {
    for (var img in _image) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.Container(
              child: pw.Center(
                child: pw.Image(image),
              ),
            );
          }));
    }
  }

  // savePDF() async {
  //   try {
  //     Directory? directory = await getExternalStorageDirectory();
  //     String newPath = "";
  //     List<String> folders = directory!.path.split("/");

  //     for (int x = 1; x < folders.length; x++) {
  //       String folder = folders[x];
  //       if (folder != "Android") {
  //         newPath += "/" + folder;
  //       } else {
  //         break;
  //       }
  //     }

  //     newPath = newPath + "/AltroneDrive";
  //     directory = Directory(newPath);

  //     if (!await directory.exists()) {
  //       directory.create(recursive: true);
  //     }

  //     // final dir = await getExternalStorageDirectory();
  //     final file = File('${directory.path}/filename.pdf');
  //     await file.writeAsBytes(await pdf.save());
  //     print("success");
  //   } catch (e) {
  //     // showPrintedMessage('error', e.toString());
  //   }
  // }

  savePDF() async {
    try {
      if (await Permission.storage.request().isGranted) {
        setState(() {
          // _allowWriteFile = true;
        });
      } else {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.storage,
        ].request();
      }
      Random random = new Random();
      int randomNumber = random.nextInt(10000);
      Directory dir = await getExternalStorageDirectory();
      String newPath = "";
      List<String> folders = dir.path.split("/");

      for (int x = 1; x < folders.length; x++) {
        String folder = folders[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      }
      newPath = newPath + "/AltroneDrive";
      dir = Directory(newPath);
      if (!await dir.exists()) {
        dir.create(recursive: true);
      }

      final file = File('${dir.path}/${randomNumber}.pdf');
      var s = await file.writeAsBytes(await pdf.save()).then((value) {
        setState(() {
          _image = [];
        });
        Fluttertoast.showToast(
            msg: "Save successfully at FileManager/AltroneDrive",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 16.0);
      });
      print(s);
      //showPrintedMessage('success', 'saved to documents');
    } catch (e) {
      print('error' + e.toString());
    }
  }
}
