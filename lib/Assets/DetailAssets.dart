import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/AssetsModel.dart';
import '../Navbar/Home.dart';
import 'VendorAssetsDetail.dart';
import 'CustomerAssetsDetail.dart';

class AssetsDetail extends StatefulWidget {
  final Assets assets;

  const AssetsDetail({Key? key, required this.assets}) : super(key: key);

  @override
  State<AssetsDetail> createState() => _AssetsDetailState();
}

class _AssetsDetailState extends State<AssetsDetail> {
  FilePickerResult? result;
  PlatformFile? pickedfile;
  bool isLoadingFile = false;
  File? fileToDisplay;

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<void> uploadFile(File file) async {
    final url = Uri.parse("https://misqot.repit.tech/api/assets/update/" +
        widget.assets.id.toString());
    final request = http.MultipartRequest('POST', url);

    final headers = await getHeaders();
    request.headers.addAll(headers);
    // Kompresi gambar sebelum mengupload
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      file.readAsBytesSync(),
      minHeight: 1920, // Sesuaikan dengan kebutuhan
      minWidth: 1080, // Sesuaikan dengan kebutuhan
      quality: 80, // Sesuaikan dengan kebutuhan
      rotate: 0, // Rotasi gambar jika diperlukan
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        compressedBytes,
        filename: file.path.split('/').last,
      ),
    );

    try {
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        print('File uploaded successfully');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
      } else {
        print('File upload failed');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void pickFile() async {
    try {
      setState(() {
        isLoadingFile = true;
      });

      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        pickedfile = result!.files.first;
        fileToDisplay = File(pickedfile!.path.toString());

        // Periksa ukuran file sebelum kompresi
        if (fileToDisplay!.lengthSync() > 500 * 1024) {
          // Ukuran file di atas 500KB, tampilkan pesan kesalahan
          setState(() {
            isLoadingFile = false;
          });

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Ukuran file melebihi batas 500KB."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          return;
        }
        // Upload file ke API Laravel
        await uploadFile(fileToDisplay!);
      }

      setState(() {
        isLoadingFile = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Customer'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          child: Column(
            children: [
              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: InstaImageViewer(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(
                            image: NetworkImage(
                                "https://misqot.repit.tech/storage/assets-image/${widget.assets.image}"),
                            fit: BoxFit.fitWidth,
                          )),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickFile,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blue),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(widget.assets.namaAset,
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(widget.assets.location,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              /// Vendor
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VendorAssetsDetail(assets: widget.assets),
                      ),
                    );
                  },
                  child: ProfileCustomerWidget(
                      title: widget.assets.vendor.name,
                      icon: Icons.wifi_tethering)),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerAssetsDetail(assets: widget.assets),
                      ),
                    );
                  },
                  child: ProfileCustomerWidget(
                      title: widget.assets.customer.customersName,
                      icon: Icons.people)),
              const Divider(),
              const SizedBox(height: 10),
              ProfileCustomerWidget(
                  title: widget.assets.serialAssets, icon: Icons.numbers),
              ProfileCustomerWidget(
                  title: widget.assets.serialNumber, icon: Icons.numbers),
              ProfileCustomerWidget(
                  title: widget.assets.dateBuyed, icon: Icons.date_range),
              ProfileCustomerWidget(
                  title: widget.assets.price, icon: Icons.wallet),
              ProfileCustomerWidget(
                  title: widget.assets.description, icon: Icons.description),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCustomerWidget extends StatelessWidget {
  const ProfileCustomerWidget({
    Key? key,
    required this.title,
    required this.icon,
    this.endIcon = true,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
      title: Text(title,
          style:
              Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
    );
  }
}
