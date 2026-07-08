import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onSkip;
  const OnboardingHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onSkip != null)
          Row(
            children: [
              Spacer(),
              TextButton(onPressed: onSkip, child: Text("Skip")),
            ],
          ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              "Step $currentStep of $totalSteps",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Spacer(),
            Text(
              "${((currentStep / totalSteps) * 100).round()}%",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                color: Colors.grey[200],
              ),
              FractionallySizedBox(
                widthFactor: currentStep / totalSteps,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
