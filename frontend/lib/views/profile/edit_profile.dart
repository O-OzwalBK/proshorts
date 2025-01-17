import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:pro_shorts/constants.dart';
import 'package:pro_shorts/views/profile/own_profile_screen.dart';
import 'package:pro_shorts/views/widgets/profile/profile_input.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/profile.dart';
import '../../get/profile/get_setup_profile.dart';

class EditProfileOptions extends StatefulWidget {
  const EditProfileOptions({Key? key}) : super(key: key);

  @override
  State<EditProfileOptions> createState() => _EditProfileOptionsState();
}

class _EditProfileOptionsState extends State<EditProfileOptions> {
  late TextEditingController nameController;
  late TextEditingController userNameController;
  late TextEditingController bioController;
  late TextEditingController youtubeURLController;
  late TextEditingController instagramURLController;
  late TextEditingController twitterURLController;
  late TextEditingController portfolioURLController;
  late String tempUsername;
  final _formKey = GlobalKey<FormState>();
  String profilePhoto = "";
  @override
  void initState() {
    // initially username is valid
    setupProfileController.displayError(true);

    nameController =
        TextEditingController(text: MYPROFILE['profileInformation']['name']);
    userNameController = TextEditingController(
        text: MYPROFILE['profileInformation']['username']);
    tempUsername = userNameController.text;
    bioController =
        TextEditingController(text: MYPROFILE['profileInformation']['bio']);
    youtubeURLController = TextEditingController(
        text: MYPROFILE['profileInformation']['youtubeURL']);
    instagramURLController = TextEditingController(
        text: MYPROFILE['profileInformation']['instagramURL']);
    twitterURLController = TextEditingController(
        text: MYPROFILE['profileInformation']['twitterURL']);
    portfolioURLController = TextEditingController(
        text: MYPROFILE['profileInformation']['portfolioURL']);
    profilePhoto =
        "$getProfilePhoto/${MYPROFILE['profileInformation']['profilePhoto']}";
    setupProfileController.displayImage(profilePhoto);
    // TODO: implement initState
    super.initState();
  }

  SetupProfile setupProfile = SetupProfile();

  SetupProfileController setupProfileController =
      Get.put(SetupProfileController());

  Future editProfile() async {
    if (selectedImage != null) {
      profilePhoto = basename(setupProfileController.image.value);
      profilePhoto = "${const Uuid().v1()}$profilePhoto";
      setupProfile
          .deleteProfilePhoto(MYPROFILE['profileInformation']['profilePhoto']);
      setupProfile.uploadProfilePhoto(
          setupProfileController.image.value, profilePhoto);
    } else {
      profilePhoto = MYPROFILE['profileInformation']['profilePhoto'];
    }
    Map<String, dynamic> profile = {
      "profilePhoto": profilePhoto,
      "name": nameController.text.trim().toLowerCase(),
      "username": userNameController.text.trim().toLowerCase(),
      "bio": bioController.text.trim().toLowerCase(),
      "youtubeURL": youtubeURLController.text.trim(),
      "instagramURL": instagramURLController.text.trim(),
      "twitterURL": twitterURLController.text.trim(),
      "portfolioURL": portfolioURLController.text.trim(),
      "email": FirebaseAuth.instance.currentUser!.email
    };
    await setupProfile.editProfile(
        MYPROFILE['profileInformation']['_id'], profile);
    Get.snackbar("Profile", "Profile updated successfully");
    Get.off(() => const OwnProfileScreen());
  }

  XFile? selectedImage;

  Future<bool> checkUserNameExist() async {
    List profiles = await SetupProfile()
        .fetchProfilesByField("username", userNameController.text.trim());
    if (profiles.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool isUserNameValid(String username) {
    // rules
    // 1. username can have alphabets and numbers
    // 2. username can have _ , - and . as special characters
    // 3. minimum length must be 5 and maximum length must be 15

    RegExp forbiddenCharacters = RegExp(r'[^a-zA-Z0-9-._]');

    if (username.length < 5 || username.length > 15) {
      return false;
    }
    if (forbiddenCharacters.hasMatch(username)) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit your profile"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: SizedBox(
              width: 350,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                      onTap: () async {
                        // image_picker for picking image from mobile devices
                        selectedImage = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (selectedImage != null) {
                          setupProfileController
                              .displayImage(selectedImage!.path);
                        } else {
                          Get.snackbar(
                              "Profile Photo", "Please select a profile photo");
                        }
                      },
                      child: Obx(
                        () => CircleAvatar(
                          // showing image using FileImage
                          backgroundImage: selectedImage == null
                              ? NetworkImage(profilePhoto)
                              : FileImage(
                                      File(setupProfileController.image.value))
                                  as ImageProvider<Object>,
                          radius: 50,
                          child: Text(
                            setupProfileController.image.value == ""
                                ? "Choose a photo"
                                : "",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  ProfileInput(
                    controller: nameController,
                    labelText: "Enter your name",
                    prefixIcon: Icons.star,
                    emptyMessage: "Please enter your name",
                    suffixIcon: Icons.person_2_rounded,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(
                    () => TextFormField(
                      controller: userNameController,
                      decoration: InputDecoration(
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        labelText: "Enter username",
                        prefixIcon: const Icon(Icons.star),
                        prefixIconColor: Colors.red,
                        helperText:
                            "Username length {5 - 15} and can have alphabets, numbers, underscore(_), dot(.) and hyphen(-)",
                        suffixIcon: setupProfileController.isUsernameValid.value
                            ? const Icon(FontAwesomeIcons.solidCircleCheck)
                            : const Icon(Icons.error),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a username";
                        }
                        if (!isUserNameValid(value)) {
                          return "Invalid username";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        bool isValid = isUserNameValid(value);
                        setupProfileController.displayError(isValid);
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () async {
                        if (userNameController.text.trim().isNotEmpty &&
                            isUserNameValid(userNameController.text.trim())) {
                          if (tempUsername != userNameController.text.trim()) {
                            bool isUsernameExist = await checkUserNameExist();
                            if (isUsernameExist) {
                              Get.snackbar("Username",
                                  "${userNameController.text.trim()} is not available");
                            } else {
                              Get.snackbar("Username",
                                  "${userNameController.text.trim()} is available");
                            }
                          } else {
                            Get.snackbar("Username",
                                "${userNameController.text.trim()} is available");
                          }
                        }
                      },
                      child: const Text("Check username is available")),
                  const SizedBox(
                    height: 10,
                  ),
                  ProfileInput(
                    controller: bioController,
                    labelText: "Describe about your channel",
                    prefixIcon: Icons.star,
                    emptyMessage: "Please add a bio",
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                   Row(children: [
                    Text(
                      "Add social media link",
                    )
                  ]),
                  const SizedBox(
                    height: 15,
                  ),
                  ProfileInput(
                    controller: youtubeURLController,
                    labelText: "Enter youtube URL",
                    emptyMessage: "Please enter youtube URL",
                    suffixIcon: FontAwesomeIcons.youtube,
                    suffixIconColor: Colors.red,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ProfileInput(
                    controller: instagramURLController,
                    labelText: "Enter instagram URL",
                    emptyMessage: "Please enter instagram URL",
                    suffixIcon: FontAwesomeIcons.instagram,
                    suffixIconColor: Colors.red,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ProfileInput(
                    controller: twitterURLController,
                    labelText: "Enter twitter URL",
                    emptyMessage: "Please enter twitter URL",
                    suffixIcon: FontAwesomeIcons.twitter,
                    suffixIconColor: Colors.blue,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ProfileInput(
                    controller: portfolioURLController,
                    labelText: "Enter your portfolio URL",
                    emptyMessage: "Please enter your portfolio URL",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (tempUsername != userNameController.text.trim()) {
                            bool isUserNameExist = await checkUserNameExist();
                            if (!isUserNameExist) {
                              await editProfile();
                            } else {
                              Get.snackbar(
                                  "Username", "Username already exists");
                            }
                          } else {
                            await editProfile();
                          }
                        }
                      },
                      child: const Text("Update Profile"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
