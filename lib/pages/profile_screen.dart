import 'package:flutter/material.dart';
import 'package:api_flutter/services/auth_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final user = await AuthService().getProfile();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 60, color: Colors.blue),
            ),
            const SizedBox(height: 16),

            // Username
            Text(
              _user!['name'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(_user!['email'], style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),

            // Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _infoTile("Email", _user!['email']),
                    const Divider(),
                    _infoTile(
                      "Tanggal Daftar",
                      _user!['created_at'].substring(0, 10),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService().logout();
                Navigator.pushReplacementNamed(
                  context,
                  '/',
                ); 
              },
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ],
    );
  }
}
