import 'package:flutter/material.dart';
import 'package:supabase_forklift/pages/admin_page.dart';
import 'package:supabase_forklift/pages/check_page.dart';
import 'package:supabase_forklift/pages/login_page.dart';
import 'package:supabase_forklift/pages/receipt_page.dart';
import 'package:supabase_forklift/pages/stock_page.dart';

class Fristpage extends StatefulWidget {
  final String username;
  final String factory;
  final String role; // Thêm role

  const Fristpage({
    super.key,
    required this.username,
    required this.factory,
    required this.role, // Thêm role
  });

  @override
  State<Fristpage> createState() => _FristpageState();
}

class _FristpageState extends State<Fristpage> {
  int _selectedIndex = 0;

  // Khai báo danh sách các trang và các item trên thanh điều hướng
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navBarItems;

  @override
  void initState() {
    super.initState();

    // Khởi tạo danh sách trang mặc định cho 'user'
    _pages = [
      ReceiptPage(username: widget.username, factory: widget.factory),
      StockPage(factory: widget.factory),
      CheckPage(factory: widget.factory),
    ];

    // Khởi tạo danh sách item điều hướng mặc định
    _navBarItems = [
      const BottomNavigationBarItem(
          icon: Icon(Icons.receipt), label: 'Nhập hàng'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.inbox), label: 'Stock hàng'),
      const BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Kiểm tra'),
    ];

    // **CẬP NHẬT:** Nếu là admin, thêm trang và item Quản lý
    if (widget.role == 'admin') {
      _pages.add(AdminPage(adminFactory: widget.factory));
      _navBarItems.add(
        const BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts), label: 'Quản lý'),
      );
    }
  }

  void _navigateBottonBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "APP XE NÂNG (${widget.factory})",
          style: const TextStyle(
              fontSize: 22,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Điều hướng về trang đăng nhập
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottonBar,
        items: _navBarItems,
        // Thêm 2 dòng này để các item luôn hiển thị đúng khi có nhiều hơn 3 mục
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
