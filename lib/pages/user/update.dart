// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letters/auth/auth_service.dart';
import 'package:letters/components/custom/custom_button.dart';
import 'package:letters/components/custom/custom_textfield.dart';
import 'package:letters/models/user.dart';
import 'package:letters/pages/home.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  File? _image;
  final picker = ImagePicker();
  final _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Future<User?> getUser() async {
    return await _authService.getUserInfo();
  }

  late final Future user;

  @override
  void initState() {
    super.initState();
    user = getUser();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile!.path.isNotEmpty) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      _image = File("");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: const Text("Update User"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 16),
          width: width,
          height: height,
          child: FutureBuilder(
            future: user,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              } else if (snapshot.hasData) {
                final data = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                        onTap: getImage,
                        child: CircleAvatar(
                          radius: height / 11.25,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          backgroundImage: _image == null
                              ? Image.network(data.imgUrl).image
                              : Image.file(_image!, fit: BoxFit.fill).image,
                        )),
                    SizedBox(height: height / 20),
                    CustomTextField(
                      placeholderText: data.name ?? "",
                      hintText: "Name",
                      icon: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      isPass: false,
                      controller: _nameController,
                    ),
                    SizedBox(height: height / 30),
                    CustomTextField(
                      placeholderText: data.bio ?? "",
                      hintText: "Bio",
                      isPass: false,
                      controller: _bioController,
                      icon: Icon(
                        Icons.pending,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    SizedBox(height: height / 40),
                    Text(
                      "*To update email, please contact the dev",
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: height / 15),
                    CustomButton(
                      buttonText: "Update",
                      btn_color: const Color(0xff463f3a),
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.grey.shade900,
                          duration: const Duration(seconds: 2),
                          content: const Row(
                            children: <Widget>[
                              CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                              Text("  Updating Profile...")
                            ],
                          ),
                        ));
                        await _authService.updateUser(
                            data.id,
                            _nameController.text.isEmpty
                                ? data.name
                                : _nameController.text.trimRight(),
                            _bioController.text.isEmpty
                                ? data.bio.toString().isEmpty
                                    ? ""
                                    : data.bio
                                : _bioController.text.trimRight(),
                            _image == null ? data.imgUrl : _image!.path);

                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const HomePage()));
                      },
                    )
                  ],
                );
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
