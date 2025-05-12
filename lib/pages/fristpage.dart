// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:forklift_ios/pages/check_page.dart';
import 'package:forklift_ios/pages/receipt_page.dart';
import 'package:forklift_ios/pages/stock_page.dart';

class Fristpage extends StatefulWidget {
  final String username;
  const Fristpage({super.key, required this.username});

  @override
  State<Fristpage> createState() => _FristpageState();
}

class _FristpageState extends State<Fristpage> {
  int _selectedIndex = 0;

  void _navigateBottonBar(int index){
    setState(() {
      _selectedIndex = index;
    });
  }  

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ReceiptPage(username: widget.username),
      const StockPage(),
      const CheckPage()
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "APP XE NÂNG",
          style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottonBar,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Nhập hàng'),

          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Stock hàng'),

          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Kiểm tra')
        ],
      ),
    );
  }
}