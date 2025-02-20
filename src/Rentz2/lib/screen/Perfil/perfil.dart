// profile_screen.dart
import 'package:flutter/material.dart';
import 'services/servicesper.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, String>> _profileData;

  @override
  void initState() {
    super.initState();
    _profileData = ProfileService().getProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Center(
        child: FutureBuilder<Map<String, String>>(
          future: _profileData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error al cargar el perfil');
            } else {
              final data = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(data['image']!),
                  ),
                  SizedBox(height: 16),
                  Text(data['name']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(data['email']!, style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text(data['phone']!, style: TextStyle(fontSize: 18)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
