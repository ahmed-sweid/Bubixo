import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:en_bubixo/core/constants/error_content.dart';
import 'package:en_bubixo/features/auth/data/auth_session.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/error/exceptions.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/network/network_info.dart';
import 'package:en_bubixo/shared/service_locator.dart';

/// Sahte kapı: hiçbir ağ çağrısı yapmaz, yalnız `isReady` ve sorgu kaydını taşır.
class _FakeBackend implements SupabaseBackend {
  _FakeBackend({this.isReady = false});

  @override
  final bool isReady;
  final List<TableQuery> queries = <TableQuery>[];

  @override
  SupabaseClient get client =>
      throw StateError('Bu test client istemez: $queries');

  @override
  Future<List<Map<String, dynamic>>> rows(TableQuery query) async {
    queries.add(query);
    return <Map<String, dynamic>>[
      <String, dynamic>{'id': 1},
      <String, dynamic>{'id': 2},
    ];
  }

  @override
  Future<Map<String, dynamic>?> row(TableQuery query) async {
    final result = await rows(query.copyWith(limit: 1));
    return result.isEmpty ? null : result.first;
  }

  @override
  Future<void> insert(String table, Map<String, dynamic> values) async {}

  @override
  Future<void> upsert(
    String table,
    Map<String, dynamic> values, {
    required String onConflict,
    bool ignoreDuplicates = false,
  }) async {}

  @override
  Future<void> update(
      String table, Map<String, dynamic> values, Map<String, Object> where) async {}

  @override
  Future<void> delete(String table, Map<String, Object> where) async {}

  @override
  Future<dynamic> rpc(String name, [Map<String, dynamic>? params]) async => null;
}

void main() {
  group('failureFrom', () {
    test('benzersizlik ihlali kayıt akışında e-posta mesajına döner', () {
      final failure = failureFrom(
        const BackendException(message: 'duplicate key', code: '23505'),
      );

      expect(failure, isA<ConflictFailure>());
      expect(failure.errorMessage, ErrorContent.emailAlreadyRegistered);
    });

    test('aynı kod içerik tablosunda jenerik çakışma olarak kalır', () {
      final failure = failureFrom(
        const BackendException(
          message: 'duplicate key',
          code: '23505',
          table: 'story_sentences',
        ),
      );

      expect(failure.errorMessage, ErrorContent.conflict);
    });

    test('RLS reddi yetki hatası olur, sunucu hatası değil', () {
      final failure = failureFrom(
        const BackendException(message: 'denied', code: '42501'),
      );

      expect(failure, isA<PermissionFailure>());
      expect(failure.errorMessage, ErrorContent.forbidden);
    });

    test('geçersiz oturum açma bilgileri doğru metni taşır', () {
      final failure = failureFrom(
        const BackendException(message: 'Invalid Login', code: 'invalid_credentials'),
      );

      expect(failure, isA<AuthFailure>());
      expect(failure.errorMessage, ErrorContent.invalidCredentials);
    });

    test('5xx ve bağlantı sınıfı meşgul mesajına düşer', () {
      expect(
        failureFrom(const BackendException(message: 'boom', code: '503'))
            .errorMessage,
        ErrorContent.serverBusy,
      );
      expect(
        failureFrom(const BackendException(message: 'down', code: '08006'))
            .errorMessage,
        ErrorContent.serverBusy,
      );
    });

    test('bilinmeyen hata kullanıcıya teknik metin sızdırmaz', () {
      final failure = failureFromUnknown(StateError('internale bak'));

      expect(failure, isA<UnexpectedFailure>());
      expect(failure.errorMessage, ErrorContent.generic);
      expect(failure.errorMessage, isNot(contains('internale')));
    });
  });

  group('SupabaseBackend', () {
    test('client yoksa kapı hazır sayılmaz ve okuma girişte durur', () async {
      final backend = SupabaseBackendImpl();

      expect(backend.isReady, isFalse);
      expect(() => backend.client, throwsA(isA<StateError>()));
      await expectLater(
        backend.rows(const TableQuery('levels')),
        throwsA(isA<StateError>()),
      );
    });

    test('filtresiz güncelleme ve silme reddedilir', () async {
      final backend = SupabaseBackendImpl();

      await expectLater(
        backend.update('levels', <String, dynamic>{'title': 'x'}, {}),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        backend.delete('levels', {}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('copyWith yalnızca istenen alanı değiştirir', () {
      const TableQuery query = TableQuery(
        'lessons',
        columns: 'id, title',
        eq: <String, Object>{'level_id': 3},
        orderColumn: 'order_index',
        limit: 20,
      );

      final TableQuery paged = query.copyWith(limit: 1, offset: 40);

      expect(paged.limit, 1);
      expect(paged.offset, 40);
      expect(paged.table, 'lessons');
      expect(paged.columns, 'id, title');
      expect(paged.eq, query.eq);
      expect(paged.orderColumn, 'order_index');
    });

    test('tek satır isteği limit 1 ile kopyalanır', () async {
      final backend = _FakeBackend(isReady: true);

      final single = await backend.row(
        const TableQuery('levels', columns: 'id', limit: 20),
      );

      expect(single, <String, dynamic>{'id': 1});
      expect(backend.queries, hasLength(1));
      expect(backend.queries.single.limit, 1);
    });
  });

  group('AuthSession', () {
    test('Supabase başlatılmamışsa oturum dinlenmez ve patlamaz', () async {
      final session = AuthSession(_FakeBackend());

      expect(session.isAuthenticated, isFalse);
      expect(session.userId, isNull);

      session.dispose();
      await Future<void>.delayed(Duration.zero);
    });

    test('initDependencies anahtarsız çalışırsa hiçbir bileşen hazır olmaz',
        () async {
      await initDependencies();
      addTearDown(sl.reset);

      expect(sl<SupabaseBackend>().isReady, isFalse);
      expect(sl<AuthSession>().isAuthenticated, isFalse);
      expect(sl<NetworkInfo>(), isA<NetworkInfo>());
    });
  });
}
