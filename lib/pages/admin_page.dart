// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/connect_supabase.dart';
import 'login_page.dart'; // **SỬA LỖI:** Thêm dòng import này

class AdminPage extends StatefulWidget {
  final String adminFactory;
  const AdminPage({super.key, required this.adminFactory});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final ConnectSupabase _connectSupabase = ConnectSupabase();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user?['username']);
    final passwordController = TextEditingController();
    final factoryController =
        TextEditingController(text: user?['factory'] ?? widget.adminFactory);
    String currentRole = user?['role'] ?? 'user';
    final bool isEditing = user != null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Chỉnh sửa người dùng' : 'Thêm người dùng'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration:
                        const InputDecoration(labelText: 'Tên đăng nhập'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên đăng nhập';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        labelText: isEditing
                            ? 'Mật khẩu mới (để trống nếu không đổi)'
                            : 'Mật khẩu'),
                    obscureText: true,
                    validator: (value) {
                      if (!isEditing && (value == null || value.isEmpty)) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: factoryController,
                    decoration: const InputDecoration(labelText: 'Factory'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập factory';
                      }
                      return null;
                    },
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return DropdownButtonFormField<String>(
                        value: currentRole,
                        decoration: const InputDecoration(labelText: 'Vai trò'),
                        items: ['user', 'admin'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            currentRole = newValue!;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();
                    final factory = factoryController.text.trim();
                    final role = currentRole;

                    if (isEditing) {
                      // Update user
                      await _connectSupabase.updateUser(
                        user['id'],
                        username,
                        password.isNotEmpty ? _hashPassword(password) : null,
                        factory,
                        role,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Cập nhật thành công!')));
                    } else {
                      // Add new user
                      await _connectSupabase.addUser(
                        username,
                        _hashPassword(password),
                        factory,
                        role,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Thêm người dùng thành công!')));
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: ${e.toString()}')));
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int id, String username) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa người dùng "$username"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      await _connectSupabase.deleteUser(id);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xóa thành công!')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}')));
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Xóa')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý người dùng (${widget.adminFactory})'),
        // **SỬA LỖI:** Xóa nút logout ở đây vì nó đã có ở Fristpage
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _connectSupabase.getUsersStream(widget.adminFactory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(user['username']),
                  subtitle: Text('Vai trò: ${user['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserDialog(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(user['id'], user['username']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
