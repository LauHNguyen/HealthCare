// ignore_for_file: prefer_const_constructors
import 'package:client_beta/main.dart';
import 'package:client_beta/screens/TestData.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Login extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['access_token'];
        // Lưu token, điều hướng người dùng đến trang chính hoặc thực hiện các bước tiếp theo.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DataScreen(), // Thay thế bằng widget bạn muốn
          ),
        );
      } else {
        // Hiển thị thông báo lỗi nếu đăng nhập thất bại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(16.0), // Add some padding for better layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to the Login Page!'),
              SizedBox(height: 20),

              // Username Input
              Container(
                width: 300, // Set the width of the TextField
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7), // Rounded corners
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Password Input
              Container(
                width: 300, // Set the width of the TextField
                child: TextField(
                  obscureText: true, // This hides the input text
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7), // Rounded corners
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'), // Changed to 'Login' for clarity
              ),
              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/testdata');
                },
                child: Text('Test Data'), // Changed to 'Login' for clarity
              ),
              SizedBox(height: 10),

              // Optionally, a button for registration
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
