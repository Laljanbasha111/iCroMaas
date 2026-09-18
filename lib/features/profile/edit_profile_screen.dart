import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _dob;
  String? _gender;
  File? _profileImage;
  bool _isLoading = false;
  List<String> _selectedCrops = [];
  final List<String> _availableCrops = [
    'Wheat',
    'Rice',
    'Corn',
    'Soybean',
    'Cotton',
    'Sugarcane',
    'Barley',
    'Oats',
  ];

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).currentUser;

    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _locationController.text = profile.location;
      _farmSizeController.text = profile.farmSize.toString();
      _selectedCrops = List<String>.from(profile.crops);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _farmSizeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _profileImage = File(picked.path));
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final current = profileProvider.currentUser;

      if (current != null) {
        final updatedUser = current.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          farmSize:
          double.tryParse(_farmSizeController.text.trim()) ?? 0,
          crops: _selectedCrops,
        );

        await profileProvider.updateProfile(updatedUser);

        if (_profileImage != null) {
          await profileProvider.uploadProfileImage(_profileImage!);
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _showDiscardDialog() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildCropChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ..._availableCrops.map((crop) {
          final selected = _selectedCrops.contains(crop);
          return FilterChip(
            label: Text(crop),
            selected: selected,
            selectedColor: Colors.green.shade200,
            onSelected: (value) {
              setState(() {
                if (value) {
                  _selectedCrops.add(crop);
                } else {
                  _selectedCrops.remove(crop);
                }
              });
            },
          );
        }),
        ActionChip(
          label: const Text('Add Custom'),
          avatar: const Icon(Icons.add, size: 18),
          onPressed: () async {
            final controller = TextEditingController();
            final custom = await showDialog<String>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Add Custom Crop'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Enter crop name'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                    child: const Text('Add'),
                  ),
                ],
              ),
            );
            if (custom != null && custom.isNotEmpty) {
              setState(() => _selectedCrops.add(custom));
            }
            controller.dispose();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _saveProfile,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF81C784), Color(0xFF388E3C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: InkWell(
                              onTap: _pickProfileImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20, color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Edit Profile Photo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Full Name',
                  icon: Icons.person,
                  controller: _nameController,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Name is required';
                    if (v.trim().length < 3) return 'Name too short';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Email',
                  icon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(v.trim())) return 'Invalid email format';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Phone Number',
                  icon: Icons.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(v)) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Location / Address',
                  icon: Icons.location_on,
                  controller: _locationController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Farm Size (in acres)',
                  icon: Icons.landscape,
                  controller: _farmSizeController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Crop Types',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _buildCropChips(),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Bio / Description',
                  icon: Icons.description,
                  controller: _bioController,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.cake, color: Colors.green),
                  title: const Text('Date of Birth'),
                  subtitle: Text(
                    _dob != null ? DateFormat('MMM d, yyyy').format(_dob!) : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.green),
                    labelText: 'Gender',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final discard = await _showDiscardDialog();
                          if (discard && mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}