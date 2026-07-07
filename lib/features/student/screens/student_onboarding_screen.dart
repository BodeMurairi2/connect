import 'package:flutter/material.dart';
import 'package:connect/features/onboarding/components/onboarding_header.dart';

class StudentOnboardingScreen extends StatelessWidget {
  const StudentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: OnboardingHeader(currentStep: 2, totalSteps: 3, onSkip: () {}),
        ),
      ),
    );
  }
}
