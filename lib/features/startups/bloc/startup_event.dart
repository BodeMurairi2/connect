abstract class StartupEvent {}

class LoadDashboard extends StartupEvent {}

class LoadApplicants extends StartupEvent {}

class UpdateApplicantStatus extends StartupEvent {
  final Map<String, dynamic> app;
  final String newStatus;
  UpdateApplicantStatus({required this.app, required this.newStatus});
}
