// ignore_for_file: recursive_getters
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Tabel proyek. Nama kelas (`ProjectRows`) & DataClassName sengaja diberi
/// sufiks Record untuk menghindari bentrok dengan model domain `Project`.
@DataClassName('ProjectRecord')
class ProjectRows extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Index enum `ProjectCategory` (0..2).
  IntColumn get category =>
      integer().check(category.isBetweenValues(0, 2))();

  DateTimeColumn get deadline => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Tabel task per proyek.
@DataClassName('TaskRecord')
class TaskRows extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get projectId =>
      integer().references(ProjectRows, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text().withLength(min: 1, max: 500)();

  /// Index enum `TaskStatus` (0..3).
  IntColumn get status => integer().check(status.isBetweenValues(0, 3))();

  /// Urutan task di dalam kolom kanban.
  IntColumn get position => integer().withDefault(const Constant(0))();

  DateTimeColumn get deadline => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [ProjectRows, TaskRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_connection());

  @override
  int get schemaVersion => 1;

  /// Native: file `omnispace.sqlite` di dokumen aplikasi.
  /// Web: OPFS/IndexedDB via sqlite3.wasm + drift_worker.js di folder web/.
  static DatabaseConnection _connection() {
    return driftDatabase(
      name: 'omnispace',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}