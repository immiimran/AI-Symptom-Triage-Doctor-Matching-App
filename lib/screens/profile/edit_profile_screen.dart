import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../app/color.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/photo_service.dart';
import '../../texts/app_texts.dart';
import '../../utils/validators.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_chip.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_sheet.dart';
import '../../widgets/glass_text_field.dart';
import '../../widgets/profile_avatar.dart';

/// Edit name, photo, phone, age, gender and blood group.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final PhotoService _photos = PhotoService();

  String _gender = '';
  String _bloodGroup = '';
  String _originalPhotoFile = '';
  String _photoFile = '';
  String? _photoPath;
  bool _saved = false;
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final profiles = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final profile = profiles.profile;

    _nameController.text = profile.name.isNotEmpty
        ? profile.name
        : auth.userName;
    _phoneController.text = profile.phone;
    _ageController.text = profile.age?.toString() ?? '';
    _gender = profile.gender;
    _bloodGroup = profile.bloodGroup;
    _originalPhotoFile = profile.photoFile;
    _photoFile = profile.photoFile;
    _photoPath = profiles.photoPath;
  }

  /// A photo picked in this session but not saved yet.
  bool get _hasPendingPhoto =>
      _photoFile.isNotEmpty && _photoFile != _originalPhotoFile;

  void _showMessage(String key) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t(key))));
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final file = await _photos.pickAndSave(source);
      if (file == null) return;
      if (_hasPendingPhoto) await _photos.delete(_photoFile);
      final path = await _photos.resolve(file);
      if (!mounted) return;
      setState(() {
        _photoFile = file;
        _photoPath = path;
      });
    } catch (_) {
      if (mounted) _showMessage('photo_failed');
    }
  }

  Future<void> _removePhoto() async {
    if (_hasPendingPhoto) await _photos.delete(_photoFile);
    if (!mounted) return;
    setState(() {
      _photoFile = '';
      _photoPath = null;
    });
  }

  Future<void> _choosePhoto() async {
    final action = await GlassSheet.show<String>(
      context,
      builder: (sheetContext) => Column(
        children: [
          _SheetOption(
            icon: Icons.photo_camera_outlined,
            label: t('take_photo'),
            onTap: () => Navigator.of(sheetContext).pop('camera'),
          ),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: t('choose_gallery'),
            onTap: () => Navigator.of(sheetContext).pop('gallery'),
          ),
          if (_photoFile.isNotEmpty)
            _SheetOption(
              icon: Icons.delete_outline_rounded,
              label: t('remove_photo'),
              color: AppColors.onGlassError,
              onTap: () => Navigator.of(sheetContext).pop('remove'),
            ),
        ],
      ),
    );

    switch (action) {
      case 'camera':
        await _pick(ImageSource.camera);
      case 'gallery':
        await _pick(ImageSource.gallery);
      case 'remove':
        await _removePhoto();
    }
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.age(value);
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return digits.length >= 7 && digits.length <= 15 ? null : t('err_phone');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final auth = context.read<AuthProvider>();
    final profiles = context.read<ProfileProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = _nameController.text.trim();

    await auth.updateName(name);
    await profiles.save(
      UserProfile(
        name: name,
        phone: _phoneController.text.trim(),
        age: int.tryParse(_ageController.text.trim()),
        gender: _gender,
        bloodGroup: _bloodGroup,
        photoFile: _photoFile,
      ),
    );

    // The old photo file is not needed any more.
    if (_originalPhotoFile.isNotEmpty && _originalPhotoFile != _photoFile) {
      await _photos.delete(_originalPhotoFile);
    }
    _saved = true;

    if (!mounted) return;
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t('profile_saved'))));
  }

  @override
  void dispose() {
    // Leaving without saving: remove a photo that was picked but not kept.
    if (!_saved && _hasPendingPhoto) {
      _photos.delete(_photoFile);
    }
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the language changes.
    context.watch<LanguageProvider>();

    final genders = <(String, String)>[
      ('male', t('gender_male')),
      ('female', t('gender_female')),
      ('other', t('gender_other')),
    ];

    return GlassScaffold(
      title: t('edit_profile_title'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Center(
              child: GestureDetector(
                onTap: _choosePhoto,
                child: Stack(
                  children: [
                    ProfileAvatar(
                      name: _nameController.text,
                      photoPath: _photoPath,
                      size: 104,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.glassButtonEnd,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.onGlass,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          size: 16,
                          color: AppColors.onGlass,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _choosePhoto,
                style: TextButton.styleFrom(foregroundColor: AppColors.onGlass),
                child: Text(t('change_photo')),
              ),
            ),
            const SizedBox(height: 12),
            GlassTextField(
              label: t('label_name'),
              controller: _nameController,
              icon: Icons.person_outline_rounded,
              validator: Validators.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            GlassTextField(
              label: t('profile_phone'),
              controller: _phoneController,
              icon: Icons.call_outlined,
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            GlassTextField(
              label: t('profile_age'),
              controller: _ageController,
              icon: Icons.cake_outlined,
              validator: _validateAge,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 20),
            _Label(t('patient_gender')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in genders)
                  GlassChip(
                    label: option.$2,
                    selected: _gender == option.$1,
                    // Tap again to clear.
                    onTap: () => setState(
                      () => _gender = _gender == option.$1 ? '' : option.$1,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _Label(t('profile_blood_group')),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final group in _bloodGroups)
                  GlassChip(
                    label: group,
                    selected: _bloodGroup == group,
                    onTap: () => setState(
                      () => _bloodGroup = _bloodGroup == group ? '' : group,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      bottom: GlassButton(
        label: t('save_changes'),
        isLoading: _saving,
        onPressed: _save,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.onGlass,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.onGlass,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}
