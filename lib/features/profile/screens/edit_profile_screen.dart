import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
final _formKey = GlobalKey<FormState>();

late TextEditingController _nameController;
late TextEditingController _emailController;
late TextEditingController _phoneController;
late TextEditingController _locationController;
late TextEditingController _farmSizeController;
late TextEditingController _cropController;

String _selectedLanguage = 'en';

bool _initialized = false;

@override
void initState() {
super.initState();

_nameController = TextEditingController();
_emailController = TextEditingController();
_phoneController = TextEditingController();
_locationController = TextEditingController();
_farmSizeController = TextEditingController();
_cropController = TextEditingController();
}

@override
void didChangeDependencies() {
super.didChangeDependencies();

if (_initialized) return;

final provider = Provider.of<ProfileProvider>(context, listen: false);
final user = provider.currentUser;

if (user != null) {
_nameController.text = user.name;
_emailController.text = user.email;
_phoneController.text = user.phone;
_locationController.text = user.location;
_farmSizeController.text = user.farmSize.toString();
_cropController.text = user.crops.join(', ');
_selectedLanguage = user.language;
}

_initialized = true;
}

@override
void dispose() {
_nameController.dispose();
_emailController.dispose();
_phoneController.dispose();
_locationController.dispose();
_farmSizeController.dispose();
_cropController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
final provider = Provider.of<ProfileProvider>(context);
final user = provider.currentUser;

return Scaffold(
appBar: AppBar(
title: const Text("Edit Profile"),
centerTitle: true,
),
body: provider.isUpdating
? const Center(
child: CircularProgressIndicator(),
)
: Form(
key: _formKey,
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
children: [

const SizedBox(height: 10),

GestureDetector(
onTap: () {
_showImagePicker(provider);
},
child: Stack(
children: [
CircleAvatar(
radius: 60,
backgroundImage:
provider.profileImageUrl != null &&
provider.profileImageUrl!.isNotEmpty
? NetworkImage(provider.profileImageUrl!)
: null,
child: provider.profileImageUrl == null ||
provider.profileImageUrl!.isEmpty
? const Icon(
Icons.person,
size: 60,
)
: null,
),

Positioned(
bottom: 0,
right: 0,
child: CircleAvatar(
radius: 18,
backgroundColor: Colors.green,
child: const Icon(
Icons.camera_alt,
color: Colors.white,
size: 18,
),
),
),
],
),
),

const SizedBox(height: 30),

TextFormField(
controller: _nameController,
decoration: const InputDecoration(
labelText: "Full Name",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.person),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return "Please enter your name";
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,
decoration: const InputDecoration(
labelText: "Email",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.email),
),
validator: (value) {
if (value == null || value.isEmpty) {
return "Please enter email";
}

if (!value.contains("@")) {
return "Invalid email";
}

return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: _phoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: "Phone",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.phone),
),
),

const SizedBox(height: 18),

TextFormField(
controller: _locationController,
decoration: const InputDecoration(
labelText: "Location",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.location_on),
),
),

const SizedBox(height: 18),

TextFormField(
controller: _farmSizeController,
keyboardType:
const TextInputType.numberWithOptions(decimal: true),
decoration: const InputDecoration(
labelText: "Farm Size (Acres)",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.landscape),
),
),

const SizedBox(height: 18),

TextFormField(
controller: _cropController,
maxLines: 2,
decoration: const InputDecoration(
labelText: "Crops",
hintText: "Rice, Wheat, Cotton",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.agriculture),
),
),

const SizedBox(height: 18),

DropdownButtonFormField<String>(
value: _selectedLanguage,
decoration: const InputDecoration(
labelText: "Language",
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.language),
),
items: const [
DropdownMenuItem(
value: "en",
child: Text("English"),
),
DropdownMenuItem(
value: "hi",
child: Text("Hindi"),
),
DropdownMenuItem(
value: "te",
child: Text("Telugu"),
),
],
onChanged: (value) {
if (value != null) {
setState(() {
_selectedLanguage = value;
});
}
},
),

const SizedBox(height: 30),
  SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton.icon(
      onPressed: () => _saveProfile(provider, user),
      icon: const Icon(Icons.save),
      label: const Text(
        "Save Changes",
        style: TextStyle(fontSize: 16),
      ),
    ),
  ),

  const SizedBox(height: 20),
],
),
),
),
);
}

Future<void> _showImagePicker(ProfileProvider provider) async {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () async {
                Navigator.pop(context);
                await provider.pickAndUploadImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () async {
                Navigator.pop(context);
                await provider.captureAndUploadImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Remove Photo"),
              onTap: () async {
                Navigator.pop(context);
                await provider.deleteProfileImage();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _saveProfile(
    ProfileProvider provider,
    UserModel? currentUser,
    ) async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User not found."),
      ),
    );
    return;
  }

  final crops = _cropController.text
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  final updatedUser = currentUser.copyWith(
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    phone: _phoneController.text.trim(),
    location: _locationController.text.trim(),
    farmSize:
    double.tryParse(_farmSizeController.text.trim()) ?? 0.0,
    crops: crops,
    language: _selectedLanguage,
    updatedAt: DateTime.now(),
  );

  await provider.updateProfile(updatedUser);

  if (!mounted) return;

  if (provider.error == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully."),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error!),
        backgroundColor: Colors.red,
      ),
    );
  }
}
}