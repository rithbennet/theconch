import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'viewmodels/culinary_oracle_viewmodel.dart';
import 'package:geolocator/geolocator.dart';
import '../api_service.dart';

class CulinaryOracleScreen extends StatefulWidget {
  @override
  _CulinaryOracleScreenState createState() => _CulinaryOracleScreenState();
}

class _CulinaryOracleScreenState extends State<CulinaryOracleScreen> {
  bool _isLoading = false;

  Future<void> _handleLocationAndFindFood() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled. Please enable them.');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(
            'Location permission denied. Cannot find nearby food options.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
          'Location permission permanently denied. Please enable it in your device settings.',
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      // Call API with coordinates
      await ApiService.findFood(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      _showSnackBar('Location found! Finding food recommendations...');
    } catch (e) {
      _showSnackBar('Failed to get location: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 3)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Culinary Oracle')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Discover magical food recommendations based on your location!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLocationAndFindFood,
              child:
                  _isLoading
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Finding Location...'),
                        ],
                      )
                      : Text('Find Food'),
            ),
          ],
        ),
      ),
    );
  }
}
