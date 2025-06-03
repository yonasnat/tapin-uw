import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

// profile screen for viewing and editing user profile data
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //theme colors
  static const _uwPurple = Color(0xFF7D3CFF);
  static const _beige = Color(0xFFF5D598);
  static const _white = Color(0xFFFFFFFF);
  static const _black = Color(0xFF000000);

  // stating variables
  String name = '';
  String bio = '';
  String? profilePicUrl;
  List<String> interests = [];
  List<String> postUrls = [];
  bool loading = true;
  bool uploading = false;

  //controller for the bio text field
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  //fetches user profile data from Firestore
  Future<void> fetchProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          name = data['name'] ?? data['displayName'] ?? 'Unnamed';
          bio = data['bio'] ?? '';
          profilePicUrl = data['profilePicUrl'];
          interests = List<String>.from(data['interests'] ?? []);
          postUrls = List<String>.from(data['posts'] ?? []);
          _bioController.text = bio;
          loading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => loading = false);
      _showErrorSnackBar('Failed to load profile data');
    }
  }

  //updates user's bio in Firestore
  Future<void> updateBio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'bio': _bioController.text.trim(),
      });

      setState(() {
        bio = _bioController.text.trim();
      });

      _showSuccessSnackBar('Bio updated successfully');
    } catch (e) {
      print('Error updating bio: $e');
      _showErrorSnackBar('Failed to update bio');
    }
  }

  //upload profile picture
  Future<void> uploadProfilePicture() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    setState(() => uploading = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => uploading = false);
        return;
      }

      Uint8List bytes = await picked.readAsBytes();
      String fileName = kIsWeb ? picked.name : path.basename(picked.path);
      String extension = path.extension(fileName).toLowerCase();

      if (extension == '.heic') {
        _showErrorSnackBar('HEIC images are not supported in web. Please use JPG or PNG.');
        setState(() => uploading = false);
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'profile_$timestamp$extension';
      final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

      final ref = FirebaseStorage.instance.ref().child('users/${user.uid}/$uniqueFileName');
      final uploadTask = ref.putData(bytes, SettableMetadata(contentType: mimeType));

      uploadTask.snapshotEvents.listen((snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      await uploadTask;
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'profilePicUrl': url});

      setState(() {
        profilePicUrl = url;
        uploading = false;
      });

      _showSuccessSnackBar('Profile picture updated successfully');
      print("Profile picture uploaded: $url");
    } catch (e) {
      setState(() => uploading = false);
      print('Error uploading profile picture: $e');
      _showErrorSnackBar('Failed to upload profile picture: ${e.toString()}');
    }
  }

  //upload new post
  Future<void> uploadPost() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    setState(() => uploading = true);

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) {
        setState(() => uploading = false);
        return;
      }

      Uint8List bytes = await picked.readAsBytes();
      String fileName = kIsWeb ? picked.name : path.basename(picked.path);
      String extension = path.extension(fileName).toLowerCase();

      if (extension == '.heic') {
        _showErrorSnackBar('HEIC images are not supported in web. Please use JPG or PNG.');
        setState(() => uploading = false);
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = 'post_$timestamp$extension';
      final mimeType = lookupMimeType(fileName) ?? 'image/jpeg';

      final ref = FirebaseStorage.instance.ref().child('users/${user.uid}/posts/$uniqueFileName');
      final uploadTask = ref.putData(bytes, SettableMetadata(contentType: mimeType));

      uploadTask.snapshotEvents.listen((snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Post upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      await uploadTask;
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'posts': FieldValue.arrayUnion([url]),
      });

      setState(() {
        postUrls.add(url);
        uploading = false;
      });

      _showSuccessSnackBar('Post uploaded successfully');
      print("Post uploaded: $url");
    } catch (e) {
      setState(() => uploading = false);
      print('Error uploading post: $e');
      _showErrorSnackBar('Failed to upload post: ${e.toString()}');
    }
  }

  //snackbars
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
  
//UI components
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage: profilePicUrl != null && profilePicUrl!.isNotEmpty
              ? NetworkImage(profilePicUrl!)
              : null,
          child: profilePicUrl == null || profilePicUrl!.isEmpty
              ? const Icon(Icons.person, size: 60, color: _uwPurple)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _white),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: uploading ? null : uploadProfilePicture,
          style: ElevatedButton.styleFrom(
            backgroundColor: _beige,
            foregroundColor: _black,
          ),
          child: Text(uploading ? "Uploading..." : "Change Profile Picture"),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bio:", style: TextStyle(color: _white, fontSize: 18)),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          style: const TextStyle(color: _white),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Write something about yourself...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            onPressed: updateBio,
            style: ElevatedButton.styleFrom(
              backgroundColor: _beige,
              foregroundColor: _black,
            ),
            child: const Text("Save Bio"),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Interests:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _white)),
        const SizedBox(height: 8),
        interests.isEmpty
            ? const Text("No interests added", style: TextStyle(color: _white))
            : Wrap(
                spacing: 8,
                children: interests
                    .map((i) => Chip(
                          label: Text(i),
                          backgroundColor: _beige,
                          labelStyle: const TextStyle(color: _black),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Posts:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _white)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: uploading ? null : uploadPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: uploading ? Colors.grey : _beige,
          ),
          child: Text(uploading ? "Uploading..." : "Upload Post", style: const TextStyle(color: _black)),
        ),
        const SizedBox(height: 10),
        postUrls.isEmpty
            ? const Text("No posts yet", style: TextStyle(color: Colors.white70))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: postUrls.length,
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    postUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
                    loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
      ],
    );
  }

  //main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _uwPurple,
      appBar: AppBar(
        backgroundColor: _beige,
        title: const Text("Profile", style: TextStyle(color: _black)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildBioSection(),
                  const SizedBox(height: 24),
                  _buildInterestsSection(),
                  const SizedBox(height: 24),
                  _buildPostsSection(),
                ],
              ),
            ),
    );
  }
}





