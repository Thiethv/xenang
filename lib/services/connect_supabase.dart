// ignore_for_file: avoid_print

import 'package:forklift_ios/main.dart';

class ConnectSupabase{
  // Lấy dữ liệu từ supbase
  Stream<List<Map<String, dynamic>>> streamDataReceipt () {
    return supabase
          .from("receipt")
          .stream(primaryKey: ['id'])
          .eq("DRIVER", 'NOTVALUE')
          .order("id", ascending: true);
  }

  Stream<List<Map<String, dynamic>>> streamDocno(){
    return supabase
          .from("repack")
          .stream(primaryKey: ['id']);
  }

  Stream<List<Map<String,dynamic>>> streamDataStock(String table, String docno){
    return supabase
          .from(table)
          .stream(primaryKey: ['id'])
          .eq("DOC_NO", docno)
          .order("LOCATION", ascending: true);
  }

  Future<List<Map<String, dynamic>>> checkLogin(String userValue, String passvalue) async{
    try{
      final response = await supabase
                                    .from("account")
                                    .select()
                                    .match({'username': userValue, 'password': passvalue});
      return response;
    }catch(e){
      return [];
    }
  }

  Future<void> updatePassWord (String user, String passOld, String passNew) async {
    try {
      await supabase
        .from('account')
        .update({'password': passNew})
        .match({'username': user, 'password': passOld});
    } catch(e){
      print(e);
    }
  }

  Future<void> updateReceipt(String driver, String selectValue, String newDate, int carton, int id) async {
    try {
      await supabase
        .from('receipt')
        .update({'DRIVER': driver, 'DATE': newDate})
        .match({'LOCATION': selectValue, 'UCC': carton, 'DRIVER': 'NOTVALUE', 'id': id});
      
    } catch (e) {
      print("Error updating receipt: $e");
    }
  }

  Future<void> deleteReceipt (String selectValue, int carton, int id) async {
    try {
      await supabase
        .from('receipt')
        .delete()
        .match({'LOCATION': selectValue, 'UCC': carton, 'DRIVER': 'NOTVALUE', 'id': id});
      
    } catch (e) {
      print("Error updating receipt: $e");
    }
  }

  Future<List<Map<String, dynamic>>?> checkLocationDate(String? location, String? checkDate) async {
    try {
      // Chuyển ngày từ 'yyyy-MM-dd' thành khoảng thời gian
      String startDate = "$checkDate 00:00:00";
      String endDate = "$checkDate 23:59:59";

      // Thực hiện truy vấn
      final result = location != null && checkDate != null
          ? await supabase
              .from('receipt')
              .select()
              .eq('LOCATION', location)
              .gte('DATE', startDate)
              .lte('DATE', endDate)
          : location != null
              ? await supabase.from('receipt').select().eq('LOCATION', location)
              : checkDate != null
                  ? await supabase
                      .from('receipt')
                      .select()
                      .gte('DATE', startDate)
                      .lte('DATE', endDate)
                  : await supabase.from('receipt').select();

      return result;
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

}
