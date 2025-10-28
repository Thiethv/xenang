// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../services/connect_supabase.dart';

class ReceiptPage extends StatefulWidget {
  final String username;
  final String factory;

  const ReceiptPage({
    super.key,
    required this.username,
    required this.factory,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final connectSupabase = ConnectSupabase();
  // **SỬA LỖI:** Chuyển stream thành biến có thể thay đổi để làm mới thủ công
  late Stream<List<Map<String, dynamic>>> _receiptStream;

  @override
  void initState() {
    super.initState();
    // Khởi tạo stream lần đầu
    _receiptStream = connectSupabase.streamDataReceipt();
  }

  // **SỬA LỖI:** Hàm để làm mới stream và cập nhật UI
  void _refreshData() {
    setState(() {
      _receiptStream = connectSupabase.streamDataReceipt();
    });
  }

  void confirmLocation(int id) async {
    final newDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    try {
      await connectSupabase.updateReceipt(widget.username, newDate, id);

      _refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Xác nhận thành công!'),
            backgroundColor: Colors.green),
      );
      // Real-time hoạt động tốt cho update, không cần refresh thủ công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Lỗi khi xác nhận: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void deleteLocation(int id) async {
    try {
      await connectSupabase.deleteReceipt(id);

      // **SỬA LỖI:** Gọi hàm làm mới thủ công sau khi xóa
      // Đây là giải pháp tạm thời nếu real-time không hoạt động cho việc xóa
      _refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Xóa thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'VỊ TRÍ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Kho_Style',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'THÙNG',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _receiptStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có hàng chờ nhập.'));
                }

                final noteList = snapshot.data!
                    .where((doc) => doc['factory'] == widget.factory)
                    .toList();

                if (noteList.isEmpty) {
                  return const Center(child: Text('Không có hàng chờ nhập.'));
                }

                return ListView.builder(
                  itemCount: noteList.length,
                  itemBuilder: (context, index) {
                    final document = noteList[index];

                    final int id = document['id'] ?? 0;
                    final String location = document['LOCATION'] ?? '';
                    String style = document['STYLE_NO'] ?? '';
                    final int carton = document['UCC'] ?? 0;
                    final String store = document['STORE'] ?? '';

                    if (style.length > 4) {
                      style = style.substring(style.length - 4);
                    }
                    final String poSty = '$store-$style';

                    return Slidable(
                      key: ValueKey(id),
                      endActionPane:
                          ActionPane(motion: const StretchMotion(), children: [
                        SlidableAction(
                          onPressed: (context) => confirmLocation(id),
                          icon: Icons.check,
                          backgroundColor: Colors.green.shade300,
                          borderRadius: BorderRadius.circular(10),
                          label: 'Xác nhận',
                        ),
                        SlidableAction(
                          onPressed: (context) => deleteLocation(id),
                          icon: Icons.delete,
                          backgroundColor: Colors.red.shade300,
                          borderRadius: BorderRadius.circular(10),
                          label: 'Xóa',
                        )
                      ]),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    location,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                    textAlign: TextAlign.center,
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    poSty,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                    textAlign: TextAlign.center,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    carton.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
