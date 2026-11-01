import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/exceptions.dart';

/// Bir PostgREST sorgusunun tarif edilebilir kısmı.
///
/// Amaç: SDK builder tipini veri kaynaklarına yaymamak; böylece kaynaklar
/// sahte `SupabaseBackend` ile test edilebilir.
@immutable
class TableQuery {
  const TableQuery(
    this.table, {
    this.columns = '*',
    this.eq = const <String, Object>{},
    this.gtColumn,
    this.gtValue,
    this.inColumn,
    this.inValues,
    this.orderColumn,
    this.ascending = true,
    this.limit,
    this.offset,
  });

  final String table;

  /// Açık kolon listesi ver; `*` yalnız gerçekten tüm kolon gerekirse.
  final String columns;

  /// Eşitlik filtreleri (`level_id`, `is_published`, …). Null değere izin
  /// verilmez: `is null` ayrı bir sözdizimidir ve sessizce yanlış sonuç üretir.
  final Map<String, Object> eq;

  final String? gtColumn;
  final Object? gtValue;
  final String? inColumn;
  final List<Object>? inValues;

  /// Sıralama kolonu; `order_index` gibi bir indeksle birlikte kullanılır.
  final String? orderColumn;
  final bool ascending;
  final int? limit;

  /// Yalnızca offset istenen yerde kullanılır — listelerde keyset (gtColumn) tercih edilir.
  final int? offset;

  TableQuery copyWith({int? limit, int? offset}) => TableQuery(
        table,
        columns: columns,
        eq: eq,
        gtColumn: gtColumn,
        gtValue: gtValue,
        inColumn: inColumn,
        inValues: inValues,
        orderColumn: orderColumn,
        ascending: ascending,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
      );
}

/// Uygulamanın tek Supabase kapısı.
///
/// SDK tipleri (`PostgrestException`, `AuthException`) bu dosyada doğar ve
/// `BackendException`'a dönüştürülür. Depolama (storage) yardımcıları henüz
/// çağrı yeri yokken eklenmedi — ses/medya fazında buraya gelir.
abstract class SupabaseBackend {
  /// Doğrudan erişim yalnızca kimlik doğrulama akışları içindir
  /// (`client.auth`); satır işlemleri aşağıdaki metotlardan geçer.
  SupabaseClient get client;

  /// `Supabase.initialize()` yapıldı mı? Yapıılmamışsa veri kaynakları istek
  /// atmak yerine boş/`Failure` döner — testler ve yapılandırmasız çalıştırmalar
  /// bu sayede ağa hiç dokunmaz.
  bool get isReady;

  Future<List<Map<String, dynamic>>> rows(TableQuery query);

  Future<Map<String, dynamic>?> row(TableQuery query);

  Future<void> insert(String table, Map<String, dynamic> values);

  /// Composite PK'li ilerleme tabloları için; `onConflict` zorunlu çünkü
  /// çakışma anahtarı olmadan upsert sessizce tam tabloyu etkileyebilir.
  Future<void> upsert(
    String table,
    Map<String, dynamic> values, {
    required String onConflict,
    bool ignoreDuplicates = false,
  });

  Future<void> update(
    String table,
    Map<String, dynamic> values,
    Map<String, Object> where,
  );

  Future<void> delete(String table, Map<String, Object> where);

  Future<dynamic> rpc(String name, [Map<String, dynamic>? params]);
}

class SupabaseBackendImpl implements SupabaseBackend {
  /// `client` null verilirken kapı hazır sayılmaz: testler ve yapılandırmasız
  /// çalıştırmalar bu yolla ağa hiç dokunmaz. `Supabase.instance` doğrudan
  /// okunmaz çünkü başlatılmamış çağrıda assert atar.
  SupabaseBackendImpl([this._client]);

  final SupabaseClient? _client;

  @override
  bool get isReady => _client != null;

  @override
  SupabaseClient get client {
    final client = _client;
    if (client == null) {
      throw StateError(
        'SupabaseBackend client olmadan kullanılamaz; main() içindeki '
        'Supabase.initialize() ve initDependencies(supabase: …) çağrılarını kontrol et.',
      );
    }
    return client;
  }

  @override
  Future<List<Map<String, dynamic>>> rows(TableQuery query) async {
    try {
      var filter = client.from(query.table).select(query.columns);

      for (final entry in query.eq.entries) {
        filter = filter.eq(entry.key, entry.value);
      }
      if (query.gtColumn != null && query.gtValue != null) {
        filter = filter.gt(query.gtColumn!, query.gtValue!);
      }
      if (query.inColumn != null && query.inValues != null) {
        filter = filter.inFilter(query.inColumn!, query.inValues!);
      }

      PostgrestTransformBuilder<PostgrestList> builder = filter;
      if (query.orderColumn != null) {
        builder = builder.order(
          query.orderColumn!,
          ascending: query.ascending,
        );
      }
      if (query.limit != null) {
        builder = builder.limit(query.limit!);
      } else if (query.offset != null) {
        final size = query.limit ?? _defaultPageSize;
        builder = builder.range(query.offset!, query.offset! + size - 1);
      }

      return await builder;
    } on PostgrestException catch (error) {
      throw BackendException.postgrest(error, table: query.table);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on StateError {
      // Başlatma hatası veri hatası değildir; olduğu gibi yukarı çıkar.
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<Map<String, dynamic>?> row(TableQuery query) async {
    final result = await rows(query.copyWith(limit: 1));
    return result.isEmpty ? null : result.first;
  }

  @override
  Future<void> insert(String table, Map<String, dynamic> values) async {
    try {
      await client.from(table).insert(values);
    } on PostgrestException catch (error) {
      throw BackendException.postgrest(error, table: table);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on StateError {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<void> upsert(
    String table,
    Map<String, dynamic> values, {
    required String onConflict,
    bool ignoreDuplicates = false,
  }) async {
    try {
      await client
          .from(table)
          .upsert(values, onConflict: onConflict, ignoreDuplicates: ignoreDuplicates);
    } on PostgrestException catch (error) {
      throw BackendException.postgrest(error, table: table);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on StateError {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<void> update(
    String table,
    Map<String, dynamic> values,
    Map<String, Object> where,
  ) async {
    _requireFilter(table, where);
    try {
      var filter = client.from(table).update(values);
      for (final entry in where.entries) {
        filter = filter.eq(entry.key, entry.value);
      }
      await filter;
    } on PostgrestException catch (error) {
      throw BackendException.postgrest(error, table: table);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on StateError {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<void> delete(String table, Map<String, Object> where) async {
    _requireFilter(table, where);
    try {
      var filter = client.from(table).delete();
      for (final entry in where.entries) {
        filter = filter.eq(entry.key, entry.value);
      }
      await filter;
    } on PostgrestException catch (error) {
      throw BackendException.postgrest(error, table: table);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on StateError {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<dynamic> rpc(String name, [Map<String, dynamic>? params]) async {
    try {
      return await client.rpc(name, params: params ?? <String, dynamic>{});
    } on PostgrestException catch (error) {
      throw BackendException.postgrest(error);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on StateError {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  /// Filtresiz update/delete tüm tabloyu tarar; RLS açık olsa bile kabul
  /// edilmez, çünkü tek bir policy hatası tüm kullanıcı verisini siler.
  void _requireFilter(String table, Map<String, Object> where) {
    if (where.isEmpty) {
      throw ArgumentError.value(where, 'where', '`$table` filtresiz yazılamaz');
    }
  }

  static const int _defaultPageSize = 50;
}
