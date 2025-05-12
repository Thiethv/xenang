// ignore_for_file: unnecessary_cast, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:forklift_ios/services/connect_supabase.dart';
import 'package:intl/intl.dart';

class ReceiptPage extends StatefulWidget {
  final String username;
  const ReceiptPage({super.key, required this.username});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final connectSupabase = ConnectSupabase();
  String newDate = '';

  void confirmLocation(int id, String selectedLocation, int carton) async {
    newDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await connectSupabase.updateReceipt(widget.username, selectedLocation, newDate, carton, id);
    refreshData();
  }

  void deleteLocation(int id, String selectedLocation, int carton) async {

    await connectSupabase.deleteReceipt(selectedLocation, carton, id);
    refreshData();
  }

  void refreshData() {
    setState(() {
      connectSupabase.streamDataReceipt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 15,),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Text('VỊ TRÍ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Kho_Style',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text('THÙNG',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15,),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: connectSupabase.streamDataReceipt(),
              builder: (context, snapshot) {
                if (!snapshot.hasData){
                  return const Center(child: CircularProgressIndicator(),);
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có hàng nhập.'));
                } else{
                  List<Map<String, dynamic>> noteList = snapshot.data!;
                  return ListView.builder(
                    itemCount: noteList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> document = noteList[index];
                      Map<String, dynamic> data = document;

                      int id = document['id'] ?? 0;
                      String location = data['LOCATION'] ?? '';
                      String style = data['STYLE_NO'] ?? '';
                      int carton = data['UCC'] ?? 0;
                      String store = data['STORE'] ?? '';
                      if (style.length > 4){
                        style = style.substring(style.length-4);
                      }
                      
                      String poSty = '$store-$style';
                                    
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const StretchMotion(), 
                          children: [
                            SlidableAction(
                              onPressed: (context) => confirmLocation(id, location, carton),
                              icon: Icons.check,
                              backgroundColor: Colors.green.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            SlidableAction(
                                onPressed: (context) => deleteLocation(id, location, carton),
                                icon: Icons.delete,
                                backgroundColor: Colors.red.shade300,
                                borderRadius: BorderRadius.circular(10),
                              )
                          ]
                        ),
                        child: Card(              
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      location,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                      textAlign: TextAlign.center,
                                    )
                                  ),
                                  Expanded(
                                    flex: 2,
                                      child: Text(poSty,
                                      style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                      textAlign: TextAlign.center,
                                  )
                                  
                                  ),
                              
                                  Expanded(
                                    flex: 1,
                                      child: Text(carton.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue),
                                      textAlign: TextAlign.center,)
                                  
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                    },
                  );
                }
                
              },            
            )
          ),

        ],
      ),
    );
  }
}