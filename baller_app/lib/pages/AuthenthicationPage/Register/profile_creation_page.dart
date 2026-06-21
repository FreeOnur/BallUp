import 'dart:developer' as developer;

import 'package:baller_app/auth/auth_service.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/pages/Home/main_page.dart';
import 'package:baller_app/repositories/profile_repository.dart';
import 'package:baller_app/repositories/repository_provider.dart';
import 'package:baller_app/widgets/profile_creation/avatar.dart';
import 'package:baller_app/widgets/text_fields/drop_down_field_custom.dart';
import 'package:baller_app/widgets/text_fields/text_form_field_custom';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({
    super.key,
    this.onProfileComplete,
    this.authService,
    this.profileRepository,
  });

  final VoidCallback? onProfileComplete;
  final AuthService? authService;
  final ProfileRepository? profileRepository;

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final formkey = GlobalKey<FormState>();
  String? imageUrl;
  late final AuthService _authService;
  late final ProfileRepository _profiles;

  final usernameController = TextEditingController();
  int? selectedAge;
  int? location;
  final levelController = TextEditingController();
  final genderController = TextEditingController();
  int? selectedGender;
  int? selectedLevel;

  void createProfile() async {
    final username = usernameController.text.trim();
    final gender = genderController.text;
    switch (gender) {
      case 'Male':
        selectedGender = 0;
        break;
      case 'Female':
        selectedGender = 1;
        break;
      case 'Other':
        selectedGender = 2;
        break;
      case 'Prefer not to say':
        selectedGender = 3;
        break;
    }

    switch (levelController.text) {
      case 'Beginner':
        selectedLevel = 0;
        break;
      case 'Intermediate':
        selectedLevel = 1;
        break;
      case 'Advanced':
        selectedLevel = 2;
        break;
      case 'Pro':
        selectedLevel = 3;
        break;
    }

    try {
      await _authService.createProfile(
        username: username,
        avatarURL: imageUrl,
        age: selectedAge,
        location: location,
        gender: selectedGender,
        skillLevel: selectedLevel,
      );
      if (mounted) {
        if (widget.onProfileComplete != null) {
          widget.onProfileComplete!();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating profile: $e')));
      }
    }
  }
  Future<void> _loadExistingProfile() async {
    try {
      final profile = await _profiles.getMyProfile();
      if (!mounted || profile == null) return;

      final loadedImageUrl = profile['avatar_url'];
      final loadedUsername = profile['username'];
      setState(() {
        if (loadedImageUrl is String && loadedImageUrl.isNotEmpty) {
          imageUrl = loadedImageUrl;
        }
        if (loadedUsername is String &&
            loadedUsername.trim().isNotEmpty &&
            usernameController.text.isEmpty) {
          usernameController.text = loadedUsername;
        }
      });
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load existing profile during onboarding',
        name: 'ProfileCreationPage',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _profiles = widget.profileRepository ?? RepositoryProvider.profiles;
    _loadExistingProfile();
  }

  @override
  void dispose() {
    usernameController.dispose();
    levelController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    final fieldSize = screenwidth * 0.9;
    final createProfileSize = fieldSize * 0.92;
    final dropDownSize = fieldSize * 0.3;
    final dropDownLevelSize = fieldSize * 0.35;
    final dropDownGenderSize = fieldSize * 0.41;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenheight * 0.2),
            if (AppConfig.useLegacySupabase)
              Avatar(
                imageUrl: imageUrl,
                onUpload: (uploadedImageUrl) async {
                  try {
                    await _profiles.updateAvatarUrl(uploadedImageUrl);
                    if (mounted) {
                      setState(() {
                        imageUrl = uploadedImageUrl;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating avatar: $e')),
                      );
                    }
                  }
                },
              )
            else
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            Form(
              key: formkey,
              child: Column(
                children: [
                  TextFormFieldCustom(
                    screenwidth: screenwidth,
                    usernameController: usernameController,
                    labelTextCustom: 'Username',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: dropDownSize,
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: const TextStyle(fontSize: 20),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(231, 85, 39, 100),
                              ),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromRGBO(231, 85, 39, 100),
                              fontSize: 20,
                            ),
                          ),
                          dropdownColor: const Color.fromARGB(255, 39, 39, 39),
                          initialValue: selectedAge,
                          items: [
                            for (int age = 0; age <= 100; age++)
                              DropdownMenuItem<int>(
                                value: age,
                                child: Opacity(
                                  opacity: 1.0,
                                  child: Text(
                                    age.toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                          onChanged: (value) => setState(() {
                            selectedAge = value;
                          }),
                          validator: (value) =>
                              value == null ? 'Please select your age' : null,
                        ),
                      ),
                      SizedBox(width: screenwidth * 0.15),
                      SizedBox(
                        width: screenwidth * 0.4,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: 'Zip Code',
                            labelStyle: const TextStyle(fontSize: 20),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(231, 85, 39, 100),
                              ),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromRGBO(231, 85, 39, 100),
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Zip Code';
                            }
                            return null;
                          },
                          onChanged: (value) => setState(() {
                            location = int.tryParse(value);
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenheight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropDownFieldCustom(
                        width: dropDownLevelSize,
                        labelTextCustom: 'Level',
                        items: const [
                          'Beginner',
                          'Intermediate',
                          'Advanced',
                          'Pro',
                        ],
                        controller: levelController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your level';
                          }
                          return null;
                        },
                      ),
                      SizedBox(width: screenwidth * 0.14),
                      DropDownFieldCustom(
                        items: const [
                          'Male',
                          'Female',
                          'Other',
                          'Prefer not to say',
                        ],
                        labelTextCustom: 'Gender',
                        width: dropDownGenderSize,
                        controller: genderController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select';
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: screenheight * 0.05),
                  SizedBox(
                    width: createProfileSize,
                    height: screenheight * 0.07,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (formkey.currentState!.validate()) {
                          createProfile();
                        }
                      },
                      child: Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenheight * 0.03,
                          ),
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
    );
  }
}
