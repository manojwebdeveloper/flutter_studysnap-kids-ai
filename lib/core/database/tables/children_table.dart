// ─────────────────────────────────────────────────────────
// children_table.dart
// ─────────────────────────────────────────────────────────
import 'package:drift/drift.dart';

/// Stores each child profile created by the parent.
class ChildrenTable extends Table {
  @override
  String get tableName => 'children';

  /// UUID primary key.
  TextColumn get id       => text()();
  TextColumn get nickname => text()();
  TextColumn get avatar   => text()(); // emoji string
  TextColumn get yearGroup => text()(); // e.g. 'Year 4'
  TextColumn get subjects  => text()(); // JSON array of subject labels
  IntColumn  get xp        => integer().withDefault(const Constant(0))();
  IntColumn  get stars     => integer().withDefault(const Constant(0))();
  IntColumn  get streak    => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  DateTimeColumn get createdAt     => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
