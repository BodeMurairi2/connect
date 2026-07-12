import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/repositories/application_repository.dart';
import 'package:connect/repositories/notification_repository.dart';
import 'package:connect/repositories/startup_repository.dart';
import 'startup_event.dart';
import 'startup_state.dart';

class StartupBloc extends Bloc<StartupEvent, StartupState> {
  StartupBloc() : super(StartupInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<LoadApplicants>(_onLoadApplicants);
    on<UpdateApplicantStatus>(_onUpdateApplicantStatus);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<StartupState> emit,
  ) async {
    emit(StartupLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final repo = StartupRepository();
      final results = await Future.wait([
        repo.getStartupProfile(uid),
        repo.getStartupOpportunities(uid),
      ]);
      emit(StartupLoaded(
        startup: results[0] as Map<String, dynamic>?,
        opportunities:
            (results[1] as List).cast<Map<String, dynamic>>(),
      ));
    } catch (e) {
      emit(StartupError(e.toString()));
    }
  }

  Future<void> _onLoadApplicants(
    LoadApplicants event,
    Emitter<StartupState> emit,
  ) async {
    final current = state is StartupLoaded ? state as StartupLoaded : null;
    if (current != null) {
      emit(current.copyWith(applicantsLoading: true));
    }
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final apps =
          await ApplicationRepository().getApplicationsForStartup(uid);
      if (state is StartupLoaded) {
        emit((state as StartupLoaded).copyWith(
          applications: apps,
          applicantsLoading: false,
        ));
      } else {
        emit(StartupLoaded(
          startup: null,
          opportunities: [],
          applications: apps,
        ));
      }
    } catch (e) {
      emit(StartupError(e.toString()));
    }
  }

  Future<void> _onUpdateApplicantStatus(
    UpdateApplicantStatus event,
    Emitter<StartupState> emit,
  ) async {
    if (state is! StartupLoaded) return;
    final current = state as StartupLoaded;
    final id = event.app['id'] as String;
    try {
      await ApplicationRepository().updateApplicationStatus(id, event.newStatus);
      NotificationRepository().sendStatusUpdateNotification(
        studentEmail: event.app['studentEmail'] as String? ?? '',
        studentName: event.app['studentName'] as String? ?? '',
        opportunityTitle: event.app['opportunityTitle'] as String? ?? '',
        startupName: event.app['startupName'] as String? ?? '',
        newStatus: event.newStatus,
      );
      final updatedApps = current.applications?.map((a) {
        return a['id'] == id ? {...a, 'status': event.newStatus} : a;
      }).toList();
      emit(current.copyWith(applications: updatedApps));
    } catch (e) {
      emit(current.copyWith(statusUpdateError: e.toString()));
    }
  }
}
