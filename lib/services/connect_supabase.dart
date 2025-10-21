// ignore_for_file: avoid_print, unused_import

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_forklift/main.dart';

class ConnectSupabase {
  // Lấy dữ liệu từ supbase
  Stream<List<Map<String, dynamic>>> streamDataReceipt(String factory) {
    return supabase
        .from("receipt")
        .stream(primaryKey: ['id'])
        .eq('factory', factory)
        .order("id", ascending: true);
  }

  Stream<List<Map<String, dynamic>>> streamDocno(String factory) {
    return supabase
        .from("repack")
        .stream(primaryKey: ['id']).eq("factory", factory);
  }

  Stream<List<Map<String, dynamic>>> streamDataStock(
      String table, String docno) {
    return supabase
        .from(table)
        .stream(primaryKey: ['id'])
        .eq("DOC_NO", docno)
        .order("LOCATION", ascending: true);
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      // **SỬA LỖI:** Dùng .maybeSingle() thay vì .single()
      // .maybeSingle() sẽ trả về null nếu không tìm thấy, thay vì ném ra lỗi.
      final response = await supabase
          .from("account")
          .select()
          .eq('username', username)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Lỗi không xác định khi lấy user: $e');
      return null;
    }
  }

  Future<void> updatePassWord(String user, String newHashedPassword) async {
    try {
      await supabase
          .from('account')
          .update({'password': newHashedPassword}).match({'username': user});
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateReceipt(String driver, String selectValue, String newDate,
      int carton, int id) async {
    try {
      await supabase
          .from('receipt')
          .update({'DRIVER': driver, 'DATE': newDate}).match({
        'LOCATION': selectValue,
        'UCC': carton,
        'DRIVER': 'NOTVALUE',
        'id': id
      });
    } catch (e) {
      print("Error updating receipt: $e");
    }
  }

  Future<void> deleteReceipt(int id) async {
    try {
      await supabase.from('receipt').delete().match({'id': id});
    } catch (e) {
      print("Error deleting receipt: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> checkLocationDate(
      String? location, String? checkDate, String factory) async {
    try {
      String? startDate = checkDate != null && checkDate.isNotEmpty
          ? "$checkDate 00:00:00"
          : null;
      String? endDate = checkDate != null && checkDate.isNotEmpty
          ? "$checkDate 23:59:59"
          : null;

      var query = supabase.from('receipt').select().eq('factory', factory);

      if (location != null && location.isNotEmpty) {
        query = query.eq('LOCATION', location);
      }
      if (startDate != null && endDate != null) {
        query = query.gte('DATE', startDate).lte('DATE', endDate);
      }

      final result = await query;
      return result;
    } catch (e) {
      print("Error fetching data: $e");
      return [];
    }
  }

  // --- Chức năng quản lý người dùng ---

  Stream<List<Map<String, dynamic>>> getUsersStream(String factory) {
    return supabase
        .from('account')
        .stream(primaryKey: ['id'])
        .eq('factory', factory)
        .order('username', ascending: true);
  }

  Future<void> addUser(String username, String hashedPassword, String factory,
      String role) async {
    // **CẬP NHẬT:** Kiểm tra xem username đã tồn tại chưa trước khi thêm.
    final existingUser = await getUser(username);
    if (existingUser != null) {
      // Ném ra một lỗi cụ thể để UI có thể bắt và hiển thị.
      throw 'Tên đăng nhập "$username" đã tồn tại.';
    }

    // Nếu chưa tồn tại, tiến hành thêm mới.
    await supabase.from('account').insert({
      'username': username,
      'password': hashedPassword,
      'factory': factory,
      'role': role,
    });
  }

  Future<void> updateUser(int id, String username, String? hashedPassword,
      String factory, String role) async {
    final updates = {
      'username': username,
      'factory': factory,
      'role': role,
    };
    if (hashedPassword != null && hashedPassword.isNotEmpty) {
      updates['password'] = hashedPassword;
    }
    await supabase.from('account').update(updates).eq('id', id);
  }

  Future<void> deleteUser(int id) async {
    await supabase.from('account').delete().eq('id', id);
  }
}
