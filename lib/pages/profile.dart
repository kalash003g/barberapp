import 'package:flutter/material.dart';
import 'package:barberapp/services/auth_service.dart';
import 'package:barberapp/pages/login.dart';
import 'package:barberapp/services/mongodb_service.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilePage({super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? username;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      userEmail = widget.userData!['email'];
      username = widget.userData!['username'];
    } else {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final email = await AuthService.getUserEmail();
      if (email != null) {
        final userData = await MongoDBService.getUserByEmail(email);
        setState(() {
          userEmail = email;
          username = userData?['username'];
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2b1615),
      appBar: AppBar(
        backgroundColor: Color(0xFF2b1615),
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("images/boy.jpg"),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    username ?? 'Guest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            SizedBox(height: 10),
            Text(
              userEmail ?? 'Loading...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.history, color: Colors.white70),
              title: Text('Booking History', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                // TODO: Navigate to booking history
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white70),
              title: Text('Settings', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                // TODO: Navigate to settings
              },
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false,
                  );
                }
              },
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
