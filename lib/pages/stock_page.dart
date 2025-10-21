import 'package:flutter/material.dart';
import 'package:supabase_forklift/services/connect_supabase.dart';

class StockPage extends StatefulWidget {
  final String factory; // **Cập nhật: Thêm factory**
  const StockPage({super.key, required this.factory});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final connectSupabase = ConnectSupabase();
  List<String> _dropdownDocno = [];
  String? _selectedDocno;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            // **Cập nhật: Truyền factory vào stream**
            stream: connectSupabase.streamDocno(widget.factory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Không có dữ liệu SRN.'));
              }

              _dropdownDocno = snapshot.data!
                  .map((doc) => doc['doc_no'].toString())
                  .toSet()
                  .toList();
              // An check to ensure the selected value is still valid
              if (_selectedDocno != null &&
                  !_dropdownDocno.contains(_selectedDocno)) {
                _selectedDocno = null;
              }

              return Container(
                width: 350,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text(
                    'Chọn số SRN',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
                  value: _selectedDocno,
                  items: _dropdownDocno.map((String item) {
                    return DropdownMenuItem<String>(
                        value: item, child: Text(item));
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDocno = newValue;
                    });
                  },
                ),
              );
            },
          ),
          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'LẤY HẾT',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'LỌC HÀNG',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _selectedDocno == null
                      ? const Center(child: Text('Vui lòng chọn SRN'))
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          stream: connectSupabase.streamDataStock(
                              "layhet", _selectedDocno!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Không có dữ liệu.'));
                            }
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data =
                                    snapshot.data![index];
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        '${data['LOCATION'] ?? ''}     ${data['CARTON'] ?? ''}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                ),
                const VerticalDivider(
                  thickness: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: _selectedDocno == null
                      ? const Center(child: Text('Vui lòng chọn SRN'))
                      : StreamBuilder<List<Map<String, dynamic>>>(
                          stream: connectSupabase.streamDataStock(
                              "loc", _selectedDocno!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Không có dữ liệu.'));
                            }
                            return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data =
                                    snapshot.data![index];
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        '${data['LOCATION'] ?? ''}     ${data['CARTON'] ?? ''}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                      height: 1,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
