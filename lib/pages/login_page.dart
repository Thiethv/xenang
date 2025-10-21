// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../services/connect_supabase.dart';
import '../utils/dialog_login.dart';
import 'fristpage.dart';
import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPass = TextEditingController();

  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerPassOld = TextEditingController();
  TextEditingController controllerPassNew = TextEditingController();

  final connectSupabase = ConnectSupabase();
  bool _isLoading = false;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String username = controllerName.text.trim();
      String password = controllerPass.text.trim();
      String hashedInputPassword = _hashPassword(password);

      try {
        Map<String, dynamic>? userData =
            await connectSupabase.getUser(username);

        if (userData != null) {
          String dbHashedPassword = userData['password'];
          String role = userData['role'] ?? 'user';
          String factory = userData['factory'] ?? '';

          if (dbHashedPassword == hashedInputPassword) {
            // Đăng nhập thành công, xóa dữ liệu trên form
            controllerName.clear();
            controllerPass.clear();

            // **CẬP NHẬT:** Tất cả user sau khi đăng nhập đều vào Fristpage.
            // Truyền thêm `role` để Fristpage quyết định giao diện.
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Fristpage(
                  username: username,
                  factory: factory,
                  role: role, // Truyền vai trò của người dùng
                ),
              ),
            );
          } else {
            _showErrorSnackBar('Tên đăng nhập hoặc mật khẩu không đúng');
          }
        } else {
          _showErrorSnackBar('Tên đăng nhập hoặc mật khẩu không đúng');
        }
      } catch (e) {
        _showErrorSnackBar('Đã xảy ra lỗi: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _changePasswordDialog() {
    // Reset controllers
    controllerUser.clear();
    controllerPassOld.clear();
    controllerPassNew.clear();

    showDialog(
        context: context,
        builder: (context) {
          return DialogLogin(
              controllerUser: controllerUser,
              controllerPassOld: controllerPassOld,
              controllerPassNew: controllerPassNew,
              onSave: _performPasswordChange,
              onCancel: () => Navigator.of(context).pop());
        });
  }

  void _performPasswordChange() async {
    String username = controllerUser.text.trim();
    String oldPassword = controllerPassOld.text.trim();
    String newPassword = controllerPassNew.text.trim();

    if (username.isEmpty || oldPassword.isEmpty || newPassword.isEmpty) {
      // Tạm thời chỉ đóng dialog, có thể hiển thị lỗi trong dialog sau
      return;
    }

    final hashedOldPassword = _hashPassword(oldPassword);
    final hashedNewPassword = _hashPassword(newPassword);

    try {
      final userData = await connectSupabase.getUser(username);
      if (userData != null && userData['password'] == hashedOldPassword) {
        await connectSupabase.updatePassWord(username, hashedNewPassword);
        Navigator.of(context).pop(); // Đóng dialog
        _scaffoldKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công!')),
        );
      } else {
        // Không đóng dialog, để người dùng thử lại
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tên đăng nhập hoặc mật khẩu cũ không đúng')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldKey,
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'APP XE NÂNG',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: controllerName,
                    decoration: const InputDecoration(
                      labelText: 'Tên đăng nhập',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controllerPass,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _login,
                            child: const Text('ĐĂNG NHẬP',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: _changePasswordDialog,
                    child: const Text("Đổi mật khẩu"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
