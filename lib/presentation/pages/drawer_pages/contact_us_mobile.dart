import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/network/api_paths.dart';
import 'package:volt/providers/authentication_provider.dart';
import 'package:volt/services/network_service.dart';
import 'package:volt/presentation/components/ui/app_widgets.dart';
import 'package:volt/presentation/components/controls/text_input.dart';
import 'package:volt/presentation/pages/drawer_pages/contact_us_success_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/content_provider.dart';
import '../../../services/logging_service.dart';

bool validateEmail(String email) {
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  String? nameError;
  String? phoneError;
  String? emailError;
  String? subjectError;
  String? messageError;
  bool isSubmitting = false;

  final List<PlatformFile> _selectedImages = [];

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only add up to 2 images.")),
      );
      return;
    }

    try {
      // Android Photo Picker / iOS File Picker — no permissions needed
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (!_selectedImages.any((x) => x.path == file.path)) {
          setState(() => _selectedImages.add(file));
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("contact_us_mobile");
    LoggingService().setCrashlyticsScreen("contact_us_mobile");
    final authenticationProvider =
    Provider.of<AuthenticationProvider>(context, listen: false);
    final user = authenticationProvider.getUser();
    if (user != null) {
      nameController.text = user.username ?? "";
      phoneController.text = user.contactNumber ?? "";
      emailController.text = user.email ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentProvider =
    Provider.of<ContentProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.colorBackground,
      appBar: AppBar(
        title: const Text("Contact Us"),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextInput(
                  controller: nameController,
                  hintText: "Name",
                  obscureText: false,
                  isLast: false,
                  errorText: nameError,
                ),
                const SizedBox(height: 25),
                TextInput(
                  controller: phoneController,
                  hintText: "Phone Number",
                  obscureText: false,
                  isLast: false,
                  errorText: phoneError,
                  textInputType: TextInputType.phone,
                ),
                const SizedBox(height: 25),
                TextInput(
                  controller: emailController,
                  hintText: "Email (optional)",
                  obscureText: false,
                  isLast: false,
                  errorText: emailError,
                  textInputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 25),
                TextInput(
                  controller: subjectController,
                  hintText: "Subject",
                  obscureText: false,
                  isLast: false,
                  errorText: subjectError,
                ),
                const SizedBox(height: 25),
                TextInput(
                  controller: messageController,
                  hintText: "Message",
                  obscureText: false,
                  minLines: 5,
                  isLast: true,
                  errorText: messageError,
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: _selectedImages
                          .map((file) => Stack(
                        children: [
                          Image.file(
                            File(file.path!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedImages
                                      .remove(file)),
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 40,
                        width: 200,
                        alignment: Alignment.center,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.colorSurface,
                          border: Border.all(color: AppColors.colorInputBorder),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_file, color: Colors.white),
                            SizedBox(width: 3),
                            Text("Add Screenshots",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: "Submit Message",
                  isLoading: isSubmitting,
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  onPressed: () async {
                    if (isSubmitting) return;
                    nameError = phoneError = emailError = subjectError = messageError = null;

                    if (nameController.text.isEmpty) {
                      setState(() => nameError = "Please Enter Your Name");
                      return;
                    }
                    if (phoneController.text.isEmpty) {
                      setState(() => phoneError = "Please Enter Your Phone Number");
                      return;
                    }
                    if (emailController.text.isNotEmpty && !validateEmail(emailController.text)) {
                      setState(() => emailError = "Please Enter A Valid Email");
                      return;
                    }
                    if (subjectController.text.isEmpty) {
                      setState(() => subjectError = "Please Enter a Subject");
                      return;
                    }
                    if (messageController.text.isEmpty) {
                      setState(() => messageError = "Please Enter A Message");
                      return;
                    }
                    if (nameController.text.length > 100) {
                      setState(() => nameError = "Max Length: 100 Characters");
                      return;
                    }
                    if (phoneController.text.length > 15 ||
                        phoneController.text.length < 10) {
                      setState(() => phoneError = "Invalid Phone Number");
                      return;
                    }
                    if (emailController.text.length > 100) {
                      setState(() => emailError = "Max Length: 100 Characters");
                      return;
                    }
                    if (subjectController.text.length > 200) {
                      setState(() => subjectError = "Max Length: 200 Characters");
                      return;
                    }
                    if (messageController.text.length > 1000) {
                      setState(() => messageError = "Max Length: 1,000 Characters");
                      return;
                    }

                    setState(() => isSubmitting = true);

                    final Map<String, dynamic> requestData = {
                      "name": nameController.text,
                      "phone_number": phoneController.text,
                      "subject": subjectController.text,
                      "message": messageController.text,
                    };
                    
                    if (emailController.text.isNotEmpty) {
                      requestData["email"] = emailController.text;
                    }

                    NetworkService().post(
                      APIPath.contactUs,
                      requestData,
                      (data) {
                        setState(() => isSubmitting = false);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContactUsSuccessPage(),
                          ),
                        );
                      },
                      (error) => setState(() => isSubmitting = false),
                      () {},
                      files: _selectedImages
                          .map((f) => File(f.path!))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 25),
                if (contentProvider.getSupportPhoneNumber().isNotEmpty)
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse(
                              "tel:${contentProvider.getSupportPhoneNumber()}");
                          if (await canLaunchUrl(url)) await launchUrl(url);
                        },
                        child: Text(
                          contentProvider.getSupportPhoneNumber(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.colorPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (contentProvider.getSupportTiming().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            contentProvider.getSupportTiming(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                if (contentProvider.getSupportEmail().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: contentProvider.getSupportEmail(),
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                      child: Text(
                        contentProvider.getSupportEmail(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.colorPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
