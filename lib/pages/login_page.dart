// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:forklift_ios/pages/fristpage.dart';
import 'package:forklift_ios/services/connect_supabase.dart';
import 'package:forklift_ios/utils/dialog_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPass = TextEditingController();

  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerPassOld = TextEditingController();
  TextEditingController controllerPassNew = TextEditingController();

  final connectSupabase = ConnectSupabase();

  void navigateToReceiptPage(String username){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => Fristpage(username: username)),
    );
  }

  void login() async {
    String username = controllerName.text;
    String password = controllerPass.text;

    List<Map<String, dynamic>> userData = await connectSupabase.checkLogin(username, password);

    if (userData.isNotEmpty) {
      navigateToReceiptPage(username);
      controllerName.text = '';
      controllerPass.text = '';
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên đăng nhập hoặc mật khẩu không đúng')),
      );
    }
  }

  void changePassWord() {
    showDialog(
      context: context, 
      builder: (context) {
        return DialogLogin(
          controllerUser: controllerUser, 
          controllerPassOld: controllerPassOld, 
          controllerPassNew: controllerPassNew, 
          onSave: () async {
            String username = controllerUser.text;
            String password = controllerPassOld.text;

            List<Map<String, dynamic>> userData = await connectSupabase.checkLogin(username, password);

            if (userData.isNotEmpty) {

                connectSupabase.updatePassWord(controllerUser.text, controllerPassOld.text, controllerPassNew.text);
                controllerUser.text = '';
                controllerPassOld.text = '';
                controllerPassNew.text = '';
                Navigator.of(context).pop();
            }
            else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tên đăng nhập hoặc mật khẩu không đúng')),
            );
          }
            
          }, 
          onCancel: () => Navigator.of(context).pop()
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50,),
            Text(
              'XE NÂNG',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue[300]),
              textAlign: TextAlign.center,
              
            ),
            const SizedBox(height: 20,),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: TextField(
                controller: controllerName,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'Tên đăng nhập',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5))
                ),
              ),
            ),
            const SizedBox(height: 10,),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: TextField(
                controller: controllerPass,
                obscureText: true,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  hintText: 'Mật khẩu',
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5))
                ),
              ),
            ),
            const SizedBox(height: 50,),
        
            ElevatedButton(
              onPressed: login, 
              child: const Text('ĐĂNG NHẬP', style: TextStyle(fontWeight: FontWeight.bold),)
            ),
            const SizedBox(height: 15,),
        
            TextButton.icon(
              onPressed: changePassWord, 
              label: const Text("Đổi mật khẩu", style: TextStyle(fontSize: 12, color: Colors.black38),)
            )
          ],
        ),
      ),
    );
  }
}