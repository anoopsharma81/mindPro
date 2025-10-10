import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../profile/profile_model.dart';
import '../profile/profile_repository.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Profile repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

/// Current user profile provider
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile();
});

/// Selected year notifier
class SelectedYearNotifier extends Notifier<String> {
  @override
  String build() {
    return DateTime.now().year.toString();
  }
  
  void setYear(String year) {
    state = year;
  }
}

/// Selected year provider (defaults to current year)
/// UI should update this when profile loads with profile.defaultYear
final selectedYearProvider = NotifierProvider<SelectedYearNotifier, String>(
  SelectedYearNotifier.new,
);

/// Year config provider for selected year
final currentYearConfigProvider = FutureProvider<YearConfig?>((ref) async {
  final year = ref.watch(selectedYearProvider);
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getYearConfig(year);
});

/// Available years provider
final availableYearsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final years = await repository.listYears();
  
  // Always include current year if not present
  final currentYear = DateTime.now().year.toString();
  if (!years.contains(currentYear)) {
    return [currentYear, ...years]..sort((a, b) => b.compareTo(a));
  }
  
  return years..sort((a, b) => b.compareTo(a));
});


