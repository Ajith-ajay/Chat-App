import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
  final picker = ImagePicker();
  TextEditingController _nameController = TextEditingController();

  // Pick image from gallery
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _auth.currentUser?.displayName ?? '';
  }

  void signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/avatar_placeholder.png')
                            as ImageProvider,
                    backgroundColor: Colors.grey[200],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: buildEditIcon(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Email Display
            ListTile(
              leading: Icon(Icons.email),
              title: Text(user?.email ?? "No email"),
            ),

            // UID Display
            ListTile(
              leading: Icon(Icons.perm_identity),
              title: Text("UID"),
              subtitle: Text(user?.uid ?? ""),
            ),

            const SizedBox(height: 10),

            // Editable Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton.icon(
              onPressed: () async {
                await user?.updateDisplayName(_nameController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Profile updated")),
                );
              },
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              label: Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: Size(double.infinity, 50),
              ),
            ),

            const SizedBox(height: 30),

            // Sign Out
            TextButton.icon(
              onPressed: signOut,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text("Sign Out", style: TextStyle(color: Colors.red)),
            )
          ],
        ),
      ),
    );
  }

  Widget buildEditIcon() => GestureDetector(
        onTap: pickImage,
        child: CircleAvatar(
          backgroundColor: Colors.deepPurple,
          radius: 18,
          child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
        ),
      );
}
