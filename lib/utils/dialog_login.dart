// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class DialogLogin extends StatefulWidget {
  final controllerUser;
  final controllerPassOld;
  final controllerPassNew;

  VoidCallback onSave;
  VoidCallback onCancel;

  DialogLogin({
    super.key,
    required this.controllerUser,
    required this.controllerPassOld,
    required this.controllerPassNew,
    required this.onSave,
    required this.onCancel
  });

  @override
  State<DialogLogin> createState() => _DialogLoginState();
}

class _DialogLoginState extends State<DialogLogin> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 300,
        // width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Đổi mật khẩu",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: Colors.blue),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: widget.controllerUser,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: "Tên đăng nhập",
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5)
                )
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: widget.controllerPassOld,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: "Mật khẩu",
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5)
                )
              ),
            ),
            const SizedBox(height: 10,),
            TextField(
              controller: widget.controllerPassNew,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(),
                hintText: "Mật khẩu mới",
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5)
                )
              ),
            ),
            const SizedBox(height: 15,),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onSave, 
                    child: const Text("Thay đổi")
                  )
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.onCancel, 
                    child: const Text("Bỏ qua")
                  )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}