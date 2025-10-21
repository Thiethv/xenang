// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_cast

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_forklift/services/connect_supabase.dart';

class CheckPage extends StatefulWidget {
  final String factory;
  const CheckPage({super.key, required this.factory});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  final TextEditingController _ngayNhapController = TextEditingController();
  final TextEditingController _viTriController = TextEditingController();

  final connectSupabase = ConnectSupabase();
  List<Map<String, dynamic>> matchingDocs = [];

  @override
  void dispose() {
    _ngayNhapController.dispose();
    _viTriController.dispose();
    super.dispose();
  }

  void seachLocationDate() async {
    String location = _viTriController.text.trim();
    String dateStr = _ngayNhapController.text.trim();
    dateStr = dateStr.isNotEmpty ? convertDateFormat(dateStr) : dateStr;
    try {
      List<Map<String, dynamic>>? docs =
          await connectSupabase.checkLocationDate(
              location.isNotEmpty ? location : null,
              dateStr.isNotEmpty ? dateStr : null,
              widget.factory);
      setState(() {
        matchingDocs = docs!;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy dữ liệu')),
      );
      return;
    }
  }

  String convertDateFormat(String inputDate) {
    try {
      DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(inputDate);

      String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

      return formattedDate;
    } catch (e) {
      print("Error parsing date: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _ngayNhapController,
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: 'Ngày nhập',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)))),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: _viTriController,
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        hintText: 'Vị trí',
                        hintStyle:
                            TextStyle(color: Colors.grey.withOpacity(0.5))),
                    onChanged: (value) {
                      _viTriController.value = _viTriController.value.copyWith(
                          text: value.toUpperCase(),
                          selection: TextSelection.fromPosition(
                              TextPosition(offset: value.length)));
                    },
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: seachLocationDate,
                child: const Text(
                  'TÌM KIẾM',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            const SizedBox(
              height: 15,
            ),
            const Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Text(
                      'VỊ TRÍ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueGrey),
                      textAlign: TextAlign.center,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      'THÙNG',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueGrey),
                      textAlign: TextAlign.center,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      'XE NÂNG',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueGrey),
                      textAlign: TextAlign.center,
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      'NGÀY/GIỜ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.blueGrey),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: matchingDocs.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      itemCount: matchingDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            matchingDocs[index] as Map<String, dynamic>;
                        String location = data['LOCATION'] ?? '';
                        int carton = data['UCC'] ?? 0;
                        String driver = data['DRIVER'] ?? '';
                        String date = data['DATE'] ?? '';

                        if (date.isNotEmpty) {
                          DateTime dateTime = DateTime.parse(date);
                          date = DateFormat('dd-MM HH:mm:ss').format(dateTime);
                        }

                        return Column(
                          children: [
                            SizedBox(
                              height: 30,
                              child: ListTile(
                                  title: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          location,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          carton.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          driver,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                        )),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                          date,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                        )),
                                  ],
                                ),
                              )),
                            ),
                            const Divider(
                              thickness: 1,
                              color: Colors.grey,
                            )
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
