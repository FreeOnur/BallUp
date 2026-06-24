import 'package:baller_app/auth/auth_service.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/pages/Home/main_page.dart';
import 'package:baller_app/widgets/profile_creation/avatar.dart';
import 'package:baller_app/widgets/text_fields/drop_down_field_custom.dart';
import 'package:baller_app/widgets/text_fields/text_form_field_custom';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key, this.onProfileComplete});

  final VoidCallback? onProfileComplete;

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final formkey = GlobalKey<FormState>();
  String? imageUrl;
  final authService = AuthService();

  final usernameController = TextEditingController();
  int? selectedAge;
  int? location;
  final levelController = TextEditingController();
  final genderController = TextEditingController();
  int? selectedGender;
  int? selectedLevel;

  void createProfile() async {
    final username = usernameController.text;
    final age = selectedAge;
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
      await authService.createProfile(
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
  @override
  void initState() {
    super.initState();
    if (AppConfig.useLegacySupabase) {
      _loadLegacyAvatar();
    }
  }

  Future<void> _loadLegacyAvatar() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final data = await Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();
    if (!mounted) return;
    setState(() {
      imageUrl = data?['avatar_url'] as String?;
    });
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
            // Avatar widget soll hier kommen
            _buildAvatar(),
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

  Widget _buildAvatar() {
    if (!AppConfig.useLegacySupabase) {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: Color.fromRGBO(231, 85, 39, 100),
        child: Icon(Icons.person, size: 40, color: Colors.white),
      );
    }

    return Avatar(
      imageUrl: imageUrl,
      onUpload: (uploadedImageUrl) async {
        setState(() {
          imageUrl = uploadedImageUrl;
        });
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;
        await Supabase.instance.client
            .from('profiles')
            .update({'avatar_url': uploadedImageUrl})
            .eq('id', userId);
      },
    );
  }
}
