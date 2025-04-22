import 'dart:io';
import 'dart:typed_data';
import '../../constants/BackendUrl.dart';
import '../../model/user.dart';
import 'LoginPage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  static const _primaryColor = Color(0xFF1A237E);
  static const _profileImageSize = 120.0;
  static const _editButtonSize = 40.0;
  static const _editIconSize = 20.0;

  File? _localImage;
  Uint8List? _webImage;
  bool _isUploading = false;
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        return Scaffold(
          backgroundColor: Colors.grey[300],
          body: _buildProfileContent(user),
        );
      },
    );
  }

  Widget _buildProfileContent(AppUser? user) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 60),
            _ProfileCard(
              user: user,
              imagePreview: _buildImagePreview(),
              onEditPressed: _isUploading ? null : _pickImage,
              isUploading: _isUploading,
            ),
            _buildOptionsCard(),
            const SizedBox(height: 30),
          ]),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildProfileImage(),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
        ],
      );
    }

    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    }

    if (!kIsWeb && _localImage != null) {
      return Image.file(
        _localImage!,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
      );
    }

    return const Icon(
      Icons.person,
      size: 150,
      color: Colors.grey,
    );
  }

  Widget _buildProfileImage() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    }

    if (!kIsWeb && _localImage != null) {
      return Image.file(_localImage!, fit: BoxFit.cover);
    }

    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.person,  color: Colors.grey),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        if (kIsWeb) {
          pickedFile.readAsBytes().then((bytes) {
            setState(() => _webImage = bytes);
            _uploadImageToBackend();
          });
        } else {
          _localImage = File(pickedFile.path);
          _uploadImageToBackend();
        }
      });
    } catch (e) {
      debugPrint("Erreur lors de la sélection de l'image: ${e.toString()}");
    }
  }

  Future<void> _uploadImageToBackend() async {
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _localImage == null)) {
      debugPrint("Aucune image sélectionnée");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/file/upload'),
      )..headers['Accept'] = 'application/json';

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          _webImage!,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _localImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint("Photo enregistrée avec succès!");
      } else {
        debugPrint("Erreur serveur: ${response.statusCode} - $responseBody");
      }
    } catch (e, stackTrace) {
      debugPrint("Erreur réseau: $e\n$stackTrace");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildOptionsCard() {
    final options = [
      _ProfileOption(
        icon: IconlyLight.setting,
        title: 'Paramètres',
        onTap: () {},
      ),
      _ProfileOption(
        icon: IconlyLight.info_circle,
        title: 'Informations',
        onTap: () {},
      ),
      _ProfileOption(
        icon: IconlyLight.lock,
        title: 'Changer mot de passe',
        onTap: _showChangePasswordDialog,
      ),
      _ProfileOption(
        icon: IconlyLight.logout,
        title: 'Déconnexion',
        isLogout: true,
        onTap: _showLogoutDialog,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: options.map((option) => _buildOptionItem(option)).toList(),
      ),
    );
  }

  Widget _buildOptionItem(_ProfileOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: option.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    option.icon,
                    color: option.isLogout ? Colors.red[400] : _primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: option.isLogout ? Colors.red[400] : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: _primaryColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onPressed: _performLogout,
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Erreur de déconnexion: $e");
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Changer le mot de passe'),
        content: const _ChangePasswordForm(),
        actions: [
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: _primaryColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Enregistrer', style: TextStyle(color: _primaryColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AppUser? user;
  final Widget imagePreview;
  final VoidCallback? onEditPressed;
  final bool isUploading;

  const _ProfileCard({
    required this.user,
    required this.imagePreview,
    this.onEditPressed,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              _buildProfileImageContainer(),
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildEditButton(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildProfileImageContainer() {
    return Container(
      width: ProfilePageState._profileImageSize,
      height: ProfilePageState._profileImageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ProfilePageState._primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: imagePreview),
    );
  }

  Widget _buildEditButton() {
    return Container(
      width: ProfilePageState._editButtonSize,
      height: ProfilePageState._editButtonSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ProfilePageState._primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.edit,
          size: ProfilePageState._editIconSize,
          color: Colors.white,
        ),
        onPressed: onEditPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          user != null ? "${user!.firstname} ${user!.lastname}" : "Utilisateur",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user?.email ?? "Email non disponible",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ProfileOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });
}

class _ChangePasswordForm extends StatelessWidget {
  const _ChangePasswordForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const TextField(
          decoration: InputDecoration(labelText: 'Mot de passe actuel'),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(labelText: 'Confirmer le nouveau mot de passe'),
          obscureText: true,
        ),
      ],
    );
  }
}