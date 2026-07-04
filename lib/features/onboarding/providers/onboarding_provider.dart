import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/error/result.dart';
import '../../../core/providers/app_providers.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/repositories/repositories.dart';

part 'onboarding_provider.g.dart';

// ── Onboarding state ──────────────────────────────────────

class OnboardingState {
  const OnboardingState({
    this.nickname = '',
    this.selectedAvatar = '🚀',
    this.selectedYearGroup = 'Year 4',
    this.selectedSubjects = const ['Maths', 'English', 'Science', 'Spelling'],
    this.isLoading = false,
    this.error,
  });

  final String nickname;
  final String selectedAvatar;
  final String selectedYearGroup;
  final List<String> selectedSubjects;
  final bool isLoading;
  final String? error;

  OnboardingState copyWith({
    String? nickname,
    String? selectedAvatar,
    String? selectedYearGroup,
    List<String>? selectedSubjects,
    bool? isLoading,
    String? error,
  }) =>
      OnboardingState(
        nickname: nickname ?? this.nickname,
        selectedAvatar: selectedAvatar ?? this.selectedAvatar,
        selectedYearGroup: selectedYearGroup ?? this.selectedYearGroup,
        selectedSubjects: selectedSubjects ?? this.selectedSubjects,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Notifier ──────────────────────────────────────────────

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void setNickname(String value) =>
      state = state.copyWith(nickname: value.trim());

  void setAvatar(String emoji) =>
      state = state.copyWith(selectedAvatar: emoji);

  void setYearGroup(String year) =>
      state = state.copyWith(selectedYearGroup: year);

  void toggleSubject(String subject) {
    final current = List<String>.from(state.selectedSubjects);
    if (current.contains(subject)) {
      current.remove(subject);
    } else {
      current.add(subject);
    }
    state = state.copyWith(selectedSubjects: current);
  }

  /// Saves the child profile and marks onboarding complete.
  Future<bool> finishSetup() async {
    if (state.nickname.isEmpty) {
      state = state.copyWith(error: 'Please enter a nickname');
      return false;
    }
    if (state.selectedSubjects.isEmpty) {
      state = state.copyWith(error: 'Please select at least one subject');
      return false;
    }

    state = state.copyWith(isLoading: true);

    final repo = ref.read(childrenRepositoryProvider);
    final child = ChildEntity(
      id: const Uuid().v4(),
      nickname: state.nickname,
      avatar: state.selectedAvatar,
      yearGroup: state.selectedYearGroup,
      subjects: state.selectedSubjects,
      createdAt: DateTime.now(),
    );

    final result = await repo.create(child);

    return result.when(
      success: (_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyOnboardingDone, true);
        await prefs.setString(AppConstants.keySelectedChildId, child.id);
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error.message);
        return false;
      },
    );
  }
}

// ── PIN provider ──────────────────────────────────────────

@riverpod
class ParentPinNotifier extends _$ParentPinNotifier {
  @override
  ({String pin, bool isConfirming, bool hasError, bool isLoading}) build() =>
      (pin: '', isConfirming: false, hasError: false, isLoading: false);

  void tapDigit(String digit) {
    if (state.pin.length >= 4) return;
    state = (
      pin: state.pin + digit,
      isConfirming: state.isConfirming,
      hasError: false,
      isLoading: state.isLoading,
    );
  }

  void backspace() {
    if (state.pin.isEmpty) return;
    state = (
      pin: state.pin.substring(0, state.pin.length - 1),
      isConfirming: state.isConfirming,
      hasError: false,
      isLoading: state.isLoading,
    );
  }

  /// Returns true if PIN entry is complete and we should navigate.
  Future<bool> onPinComplete(String firstPin) async {
    if (!state.isConfirming) {
      // First entry done — move to confirmation step
      state = (pin: '', isConfirming: true, hasError: false, isLoading: false);
      return false;
    }

    // Confirmation step
    if (state.pin != firstPin) {
      state = (pin: '', isConfirming: false, hasError: true, isLoading: false);
      return false;
    }

    // PINs match — save it
    state = (pin: state.pin, isConfirming: true, hasError: false, isLoading: true);
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.setPin(state.pin);

    result.when(
      success: (_) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyParentPinSet, true);
      },
      failure: (_) {},
    );

    return result.isSuccess;
  }

  void reset() => state = (pin: '', isConfirming: false, hasError: false, isLoading: false);
}
