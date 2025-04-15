import 'dart:io';
import 'dart:typed_data';
import 'package:bloc_test/constants/strings.dart';
import 'package:bloc_test/presentation_layer/Screens/LoginPage.dart';
import 'package:bloc_test/presentation_layer/Screens/WebSocketPage.dart';
import 'package:bloc_test/presentation_layer/Screens/WorkshopsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  Uint8List? _webImage;
  final picker = ImagePicker();
  final Color primaryColor = Color(0xFF1A237E);
  final Color accentColor = Color(0xFF536DFE);
  bool _isUploading = false;
  int _page = 3;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Future<void> _uploadImageToBackend() async {
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _image == null)) {
      print("Aucune image sélectionnée");
      return;
    }

    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse('$baseUrl/file/upload');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Accept'] = 'application/json';

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
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      print("Envoi de la requête...");
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print("Réponse: ${response.statusCode} - $responseBody");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Photo enregistrée avec succès!");
      } else {
        print("Erreur serveur: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Erreur réseau: $e\n$stackTrace");
      print("Erreur lors de l'envoi de la photo");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        if (kIsWeb) {
          pickedFile.readAsBytes().then((bytes) {
            setState(() => _webImage = bytes);
            _uploadImageToBackend();
          });
        } else {
          _image = File(pickedFile.path);
          _uploadImageToBackend();
        }
      });
    } catch (e) {
      print("Erreur lors de la sélection de l'image: ${e.toString()}");
    }
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildProfileImage(),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ],
      );
    } else if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!,
          width: 150, height: 150, fit: BoxFit.cover);
    } else if (!kIsWeb && _image != null) {
      return Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover);
    }
    return Icon(Icons.person, size: 150, color: Colors.grey);
  }

  Widget _buildProfileImage() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    } else if (!kIsWeb && _image != null) {
      return Image.file(_image!, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 60,
              ),
              _buildProfileCard(),
              _buildOptionsCard(),
              SizedBox(height: 30),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        items: <Widget>[
          Image.asset(
            "assets/images/maison.png",
            width: 25,
            height: 25,
            color: Colors.white,
          ),
          Image.asset(
            "assets/images/commentaire-alt.png",
            width: 25,
            height: 25,
            color: Colors.white,
          ),
          Image.asset(
            "assets/images/applications.png",
            width: 25,
            height: 25,
            color: Colors.white,
          ),
          Image.asset(
            "assets/images/utilisateur (2).png",
            width: 25,
            height: 25,
            color: Colors.white,
          ),
        ],
        color: const Color(0xFF1A3A5F),
        height: 55,
        buttonBackgroundColor: const Color(0xFF1A3A5F),
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _page = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkshopsScreen(),
              ),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WebSocketPage(),
              ),
            );
          }
        },
        letIndexChange: (index) => true,
      ),
    );
  }

  Widget _buildProfileCard() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildImagePreview(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: primaryColor,
                  onPressed: _isUploading ? null : _pickImage,
                  child: Icon(Icons.edit, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Yasmin Othmen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'yasminothmen33@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard() {
    final List<Map<String, dynamic>> options = [
      {
        'icon': Icons.settings,
        'title': 'Paramètres',
        'isLogout': false,
        'onTap': () {}
      },
      {
        'icon': Icons.info_outline,
        'title': 'Informations',
        'isLogout': false,
        'onTap': () {}
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Changer mot de passe',
        'isLogout': false,
        'onTap': _showChangePasswordDialog
      },
      {
        'icon': Icons.exit_to_app,
        'title': 'Déconnexion',
        'isLogout': true,
        'onTap': _showLogoutDialog
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: options
            .map((option) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: option['onTap'],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              child: Icon(
                                option['icon'],
                                color: option['isLogout']
                                    ? Colors.red[400]
                                    : primaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option['title'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: option['isLogout']
                                      ? Colors.red[400]
                                      : Colors.black87,
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
                ))
            .toList(),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              child: Text('Annuler', style: TextStyle(color: primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  print("Erreur de déconnexion: $e");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Mot de passe actuel'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuler', style: TextStyle(color: primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Enregistrer', style: TextStyle(color: primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
