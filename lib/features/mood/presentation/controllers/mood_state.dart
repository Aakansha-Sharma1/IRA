import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/mood_entry.dart';

enum MoodStatus {
  initial,
  loading,
  loaded,
  saving,
  saved,
  empty,
  error,
}

class MoodState extends Equatable {
  final MoodStatus status;
  final List<MoodEntry> entries;
  final MoodEntry? todayEntry;
  final Failure? failure;

  const MoodState({
    this.status = MoodStatus.initial,
    this.entries = const [],
    this.todayEntry,
    this.failure,
  });

  const MoodState.initial() : this(status: MoodStatus.initial);
  const MoodState.loading({List<MoodEntry> entries = const []})
      : this(status: MoodStatus.loading, entries: entries);
  const MoodState.loaded(List<MoodEntry> entries, {MoodEntry? todayEntry})
      : this(status: MoodStatus.loaded, entries: entries, todayEntry: todayEntry);
  const MoodState.saving({List<MoodEntry> entries = const [], MoodEntry? todayEntry})
      : this(status: MoodStatus.saving, entries: entries, todayEntry: todayEntry);
  const MoodState.saved(MoodEntry entry, {List<MoodEntry> entries = const []})
      : this(status: MoodStatus.saved, entries: entries, todayEntry: entry);
  const MoodState.empty() : this(status: MoodStatus.empty);
  const MoodState.error(Failure failure, {List<MoodEntry> entries = const [], MoodEntry? todayEntry})
      : this(status: MoodStatus.error, entries: entries, todayEntry: todayEntry, failure: failure);

  bool get isInitial => status == MoodStatus.initial;
  bool get isLoading => status == MoodStatus.loading;
  bool get isLoaded => status == MoodStatus.loaded;
  bool get isSaving => status == MoodStatus.saving;
  bool get isSaved => status == MoodStatus.saved;
  bool get isEmpty => status == MoodStatus.empty || (status == MoodStatus.loaded && entries.isEmpty);
  bool get isError => status == MoodStatus.error;

  @override
  List<Object?> get props => [status, entries, todayEntry, failure];
}
