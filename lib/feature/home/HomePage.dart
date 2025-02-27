import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_one_ict/feature/login/LoginPage.dart';
import 'package:task_one_ict/model/user.dart';
import 'package:task_one_ict/widget/custom_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? latitude;
  String? longitude;
  String? errorMessage;
  bool isLoading = false;
  late User user;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// Load user information from shared preferences
  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User(
      id: prefs.getInt('id') ?? 0,
      username: prefs.getString('username') ?? '',
      email: prefs.getString('email') ?? '',
      firstName: prefs.getString('firstName') ?? '',
      lastName: prefs.getString('lastName') ?? '',
      image: prefs.getString('image') ?? '',
      accessToken: prefs.getString('accessToken') ?? '',
    );
    setState(() {});
  }

  /// Get current location with loading state management
  Future<void> getCurrentLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _checkLocationPermission();

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Check location permission and request if necessary
  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      await Permission.location.request();
    }
    if (status.isRestricted || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  /// Log out user
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Get Current Location",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          const SizedBox(width: 10), // Add space before the icon
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // Calls the logout function
          ),
          const SizedBox(width: 10), // Add space after the icon
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildUserInfo(),
            const SizedBox(height: 40),

            /// Custom button to get location
            CustomElevatedButton(
              onPressed:() {isLoading ? null : getCurrentLocation();},
              text: "Get Current Location",
              backgroundColor: Colors.green,
              textColor: Colors.white,
              borderColor: Colors.grey,
            ),

            const SizedBox(height: 20),

            /// Loading Indicator
            if (isLoading) const CircularProgressIndicator(),

            /// Display latitude, longitude, or error message
            if (!isLoading) _buildLocationInfo(),
          ],
        ),
      ),
    );
  }

  /// User info display widget
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user.image.isNotEmpty) Image.network(user.image),
        Text('Welcome ${user.firstName} ${user.lastName}'),
        Text('Username: ${user.username}'),
        Text('Email: ${user.email}'),
      ],
    );
  }

  /// Display location or error message
  Widget _buildLocationInfo() {
    if (latitude != null && longitude != null) {
      return Column(
        children: [
          Text("Latitude: $latitude"),
          Text("Longitude: $longitude"),
        ],
      );
    } else if (errorMessage != null) {
      return Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      );
    }
    return const SizedBox(); // Empty widget if nothing to show
  }
}

