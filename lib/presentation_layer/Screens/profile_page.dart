import 'dart:io';
import 'package:bloc_test/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../model/user.dart';
import 'LoginPage.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  static const _primaryColor = Color(0xFF1A237E);

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
          body: Column(children: [
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
        );
      },
    );
  }

  Widget _buildImagePreview() {
    final authState = context.read<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

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
      return Image.memory(_webImage!,
          width: 150, height: 150, fit: BoxFit.cover);
    }

    if (!kIsWeb && _localImage != null) {
      return Image.file(_localImage!,
          width: 150, height: 150, fit: BoxFit.cover);
    }

    // Afficher l'image du backend si elle existe
    if (user?.email != null) {
      return FutureBuilder<Uint8List?>(
        future: ApiService.getProfileImage(user!.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              );
            }
          }
          return _buildDefaultAvatar();
        },
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
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
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }

  Future<Response?> _uploadImageToServer(
      Uint8List bytes, String filename, String email) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
        'email': email,
      });

      return await ApiService.instance.post(
        '/file/save-image-to-db',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } catch (e) {
      debugPrint('Erreur upload: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isUploading = true);

      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      Uint8List bytes;
      String filename;

      if (kIsWeb) {
        bytes = await pickedFile.readAsBytes();
        filename = pickedFile.name;
        setState(() => _webImage = bytes);
      } else {
        _localImage = File(pickedFile.path);
        bytes = await _localImage!.readAsBytes();
        filename = _localImage!.path.split('/').last;
      }

// Récupérer l'utilisateur courant
      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final email = authState.user.email;
      // Envoyer l'image au backend
      final response = await _uploadImageToServer(
        bytes,
        filename,
        email,
      );

      if (response != null) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image de profil mise à jour')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${response.data}')),
          );
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de l'envoi de l'image: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi de l\'image')),
      );
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
            child:
                const Text('Annuler', style: TextStyle(color: _primaryColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: _performLogout,
            child:
                const Text('Déconnexion', style: TextStyle(color: Colors.red)),
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
            child:
                const Text('Annuler', style: TextStyle(color: _primaryColor)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Enregistrer',
                style: TextStyle(color: _primaryColor)),
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
      width: 120.0,
      height: 120.0,
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
      width: 40.0,
      height: 40.0,
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
          size: 20,
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
          decoration:
              InputDecoration(labelText: 'Confirmer le nouveau mot de passe'),
          obscureText: true,
        ),
      ],
    );
  }
}
