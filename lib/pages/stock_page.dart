import 'package:flutter/material.dart';
import 'package:supabase_forklift/services/connect_supabase.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

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
          const SizedBox(height: 15,),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: connectSupabase.streamDocno(),
            builder: (context, snapshot){
              if(!snapshot.hasData){
                return const Center(child: CircularProgressIndicator(),);
              }

              _dropdownDocno = snapshot.data!.map((doc) => doc['DOC_NO'].toString()).toSet().toList();

              return Container(
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Chọn số SRN',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
                  value: _selectedDocno,
                  items: _dropdownDocno.map((String item){
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item)
                    );
                  }).toList(),
                  onChanged: (String? newValue){
                    setState(() {
                      _selectedDocno = newValue;
                    });
                  },
                ),
              );
            },
            
          ),

          const SizedBox(height: 15,),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('LẤY HẾT',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
            
                Text('LỌC HÀNG',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _selectedDocno == null 
                    ? const SizedBox.shrink()
                    : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: connectSupabase.streamDataStock("layhet",_selectedDocno!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ListView(
                            children: snapshot.data!.map((doc) {
                              Map<String, dynamic> data = doc;
                              return Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: ListTile(
                                        title: Text(
                                          '${data['LOCATION'] ?? ''}     ${data['CARTON'] ?? ''}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                    )
                                  ],
                                );
                            }).toList(),
                          );
                        },
                    ),
                ),
                const VerticalDivider(
                  thickness: 1, // Độ dày của đường kẻ
                  color: Colors.grey, // Màu của đường kẻ
                ),
                Expanded(
                  child: _selectedDocno == null 
                    ? const SizedBox.shrink()
                    : StreamBuilder<List<Map<String, dynamic>>>(
                        stream: connectSupabase.streamDataStock("loc",_selectedDocno!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ListView(
                            children: snapshot.data!.map((doc) {
                              Map<String, dynamic> data = doc;
                              return Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      child: ListTile(
                                        title: Text(
                                          '${data['LOCATION'] ?? ''}     ${data['CARTON'] ?? ''}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 1,
                                      color: Colors.grey,
                                    )
                                  ],
                                );
                            }).toList(),
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