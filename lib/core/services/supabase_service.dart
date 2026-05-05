import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();
  static SupabaseClient get client => Supabase.instance.client;
  static final _log = Logger();

  // Auth
  Future<void> signInWithOtp(String phone) async {
    _log.i('Sending OTP to $phone');
    await client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp(String phone, String token) async {
    _log.i('Verifying OTP for $phone');
    return await client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  User? get currentUser => client.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  Session? get currentSession => client.auth.currentSession;

  Future<void> signOut() async {
    await client.auth.signOut();
    _log.i('User signed out');
  }

  // Generic CRUD
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    Map<String, dynamic>? query,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    PostgrestFilterBuilder<PostgrestList> select = client.from(table).select();
    if (query != null) {
      query.forEach((key, value) {
        select = select.eq(key, value);
      });
    }
    if (orderBy != null) {
      select = select.order(orderBy, ascending: ascending);
    }
    if (limit != null) {
      select = select.limit(limit);
    }
    return List<Map<String, dynamic>>.from(await select);
  }

  Future<Map<String, dynamic>> getById(String table, String id) async {
    return await client.from(table).select().eq('id', id).single();
  }

  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    _log.i('Inserting into $table');
    return await client.from(table).insert(data).select().single();
  }

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    _log.i('Updating $table/$id');
    return await client.from(table).update(data).eq('id', id).select().single();
  }

  Future<void> delete(String table, String id) async {
    _log.i('Deleting from $table/$id');
    await client.from(table).delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    required String column,
    required dynamic value,
  }) async {
    final response = await client.from(table).select().eq(column, value);
    return List<Map<String, dynamic>>.from(response);
  }

  // Realtime
  RealtimeChannel subscribeToTable(
    String table, {
    String? filterColumn,
    String? filterValue,
    required void Function(PostgresChangePayload) onChange,
  }) {
    _log.i('Subscribing to $table');
    final channel = client.channel('public:$table');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: table,
      filter: filterColumn != null && filterValue != null
          ? PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: filterColumn,
              value: filterValue,
            )
          : null,
      callback: onChange,
    );
    channel.subscribe();
    return channel;
  }

  void unsubscribe(RealtimeChannel channel) {
    client.removeChannel(channel);
  }

  // Storage
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> bytes,
  ) async {
    final uint8List = Uint8List.fromList(bytes);
    await client.storage.from(bucket).uploadBinary(path, uint8List);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }
}
