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
    var filter = client.from(table).select();
    if (query != null) {
      query.forEach((key, value) {
        filter = filter.eq(key, value);
      });
    }
    // Apply ordering and limit via transform builder
    if (orderBy != null) {
      final sorted = filter.order(orderBy, ascending: ascending);
      if (limit != null) {
        return List<Map<String, dynamic>>.from(await sorted.limit(limit));
      }
      return List<Map<String, dynamic>>.from(await sorted);
    }
    if (limit != null) {
      return List<Map<String, dynamic>>.from(await filter.limit(limit));
    }
    return List<Map<String, dynamic>>.from(await filter);
  }

  /// Paginated query using Supabase range (offset-based pagination).
  /// Returns records starting at [offset] with up to [limit] results.
  Future<List<Map<String, dynamic>>> getAllPaginated(
    String table, {
    Map<String, dynamic>? query,
    String? orderBy,
    bool ascending = true,
    int limit = 20,
    int offset = 0,
  }) async {
    var queryBuilder = client.from(table).select();
    if (query != null) {
      query.forEach((key, value) {
        queryBuilder = queryBuilder.eq(key, value);
      });
    }
    // Build the full query chain before awaiting
    dynamic chain = queryBuilder;
    if (orderBy != null) {
      chain = chain.order(orderBy, ascending: ascending);
    }
    // Supabase range is inclusive on both ends, so end = offset + limit - 1
    final end = offset + limit - 1;
    final result = await chain.range(offset, end);
    return List<Map<String, dynamic>>.from(result);
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

  Future<Map<String, dynamic>> upsert(
    String table,
    Map<String, dynamic> data, {
    String onConflict = 'id',
  }) async {
    _log.i('Upserting into $table (onConflict: $onConflict)');
    return await client
        .from(table)
        .upsert(data, onConflict: onConflict)
        .select()
        .single();
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
    // Generate a unique channel name to avoid collisions when multiple
    // subscriptions to the same table exist (e.g., rides + rides for driver)
    final suffix = filterColumn != null && filterValue != null
        ? '_${filterColumn}_$filterValue'
        : '';
    final channelName = 'public:$table$suffix_${DateTime.now().millisecondsSinceEpoch}';
    _log.i('Subscribing to $table via channel $channelName');
    final channel = client.channel(channelName);
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

  /// Upload a file to a **public** bucket and return the public URL.
  Future<String> uploadFile(
    String bucket,
    String path,
    List<int> bytes,
  ) async {
    final uint8List = Uint8List.fromList(bytes);
    await client.storage.from(bucket).uploadBinary(path, uint8List);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Upload a file to a **private** bucket and return the **storage path**.
  /// The path can be stored in the DB. Use [getSignedUrl] to get a
  /// time-limited URL when you need to display the file.
  Future<String> uploadPrivateFile(
    String bucket,
    String path,
    List<int> bytes,
  ) async {
    final uint8List = Uint8List.fromList(bytes);
    await client.storage.from(bucket).uploadBinary(path, uint8List);
    return path;
  }

  /// Get a signed URL for a file in a private bucket.
  /// [expiresIn] is the signed URL validity in seconds (default 1 hour).
  Future<String> getSignedUrl(
    String bucket,
    String path, {
    int expiresIn = 3600,
  }) async {
    return client.storage.from(bucket).createSignedUrl(path, expiresIn);
  }

  Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }
}
