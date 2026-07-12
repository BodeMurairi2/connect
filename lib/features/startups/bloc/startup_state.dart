abstract class StartupState {}

class StartupInitial extends StartupState {}

class StartupLoading extends StartupState {}

// Single loaded state shared by Dashboard and Applicants tabs.
// applications is null until LoadApplicants is dispatched.
class StartupLoaded extends StartupState {
  final Map<String, dynamic>? startup;
  final List<Map<String, dynamic>> opportunities;
  final List<Map<String, dynamic>>? applications;
  final bool applicantsLoading;
  final String? statusUpdateError;

  StartupLoaded({
    this.startup,
    required this.opportunities,
    this.applications,
    this.applicantsLoading = false,
    this.statusUpdateError,
  });

  StartupLoaded copyWith({
    Map<String, dynamic>? startup,
    List<Map<String, dynamic>>? opportunities,
    List<Map<String, dynamic>>? applications,
    bool? applicantsLoading,
    String? statusUpdateError,
  }) {
    return StartupLoaded(
      startup: startup ?? this.startup,
      opportunities: opportunities ?? this.opportunities,
      applications: applications ?? this.applications,
      applicantsLoading: applicantsLoading ?? this.applicantsLoading,
      statusUpdateError: statusUpdateError,
    );
  }
}

class StartupError extends StartupState {
  final String message;
  StartupError(this.message);
}
