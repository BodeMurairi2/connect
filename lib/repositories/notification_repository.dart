import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class NotificationRepository {
  static const _senderEmail = String.fromEnvironment('SMTP_EMAIL');
  static const _appPassword  = String.fromEnvironment('SMTP_PASSWORD');

  Future<void> _send({
    required String to,
    required String subject,
    required String html,
    required String text,
  }) async {
    if (to.isEmpty) return;
    final smtpServer = gmail(_senderEmail, _appPassword);
    final message = Message()
      ..from = Address(_senderEmail, 'AnzaConnect')
      ..recipients.add(to)
      ..subject = subject
      ..html = html
      ..text = text;
    try {
      await send(message, smtpServer);
    } catch (_) {
      // Non-fatal: email failure should never block the user action
    }
  }

  Future<void> sendApplicationConfirmation({
    required String studentEmail,
    required String studentName,
    required String opportunityTitle,
    required String startupName,
  }) async {
    await _send(
      to: studentEmail,
      subject: 'Application Submitted — $opportunityTitle at $startupName',
      html: '<h2>Hi $studentName,</h2>'
          '<p>Your application for <strong>$opportunityTitle</strong> at '
          '<strong>$startupName</strong> has been successfully submitted on AnzaConnect.</p>'
          '<p>You will be notified when the startup reviews your application. Good luck!</p>'
          '<br><p>The AnzaConnect Team</p>',
      text: 'Hi $studentName, your application for $opportunityTitle at $startupName '
          'has been submitted. You will be notified when the startup reviews it. Good luck!',
    );
  }

  Future<void> sendStatusUpdateNotification({
    required String studentEmail,
    required String studentName,
    required String opportunityTitle,
    required String startupName,
    required String newStatus,
  }) async {
    final String subject;
    final String html;
    final String text;

    switch (newStatus) {
      case 'Reviewing':
        subject = 'Application Update — Your Application is Being Reviewed';
        html = '<h2>Hi $studentName,</h2>'
            '<p><strong>$startupName</strong> is now reviewing your application for '
            '<strong>$opportunityTitle</strong>. You may be contacted for an interview soon. '
            'Stay tuned!</p><br><p>The AnzaConnect Team</p>';
        text = 'Hi $studentName, $startupName is now reviewing your application for $opportunityTitle.';
      case 'Accepted':
        subject = 'Congratulations! Application Accepted — $opportunityTitle';
        html = '<h2>Hi $studentName,</h2>'
            '<p>Congratulations! 🎉 <strong>$startupName</strong> has accepted your '
            'application for <strong>$opportunityTitle</strong>. They will be in touch '
            'with next steps very soon.</p><br><p>The AnzaConnect Team</p>';
        text = 'Congratulations $studentName! $startupName has accepted your application for $opportunityTitle.';
      case 'Declined':
        subject = 'Application Update — $opportunityTitle at $startupName';
        html = '<h2>Hi $studentName,</h2>'
            '<p>Thank you for your interest in <strong>$startupName</strong>. Unfortunately, '
            'they have decided not to move forward with your application for '
            '<strong>$opportunityTitle</strong> at this time.</p>'
            '<p>Keep exploring other opportunities on AnzaConnect — the right fit is out there!</p>'
            '<br><p>The AnzaConnect Team</p>';
        text = 'Hi $studentName, $startupName has decided not to move forward with your application for $opportunityTitle.';
      default:
        return;
    }

    await _send(
      to: studentEmail,
      subject: subject,
      html: html,
      text: text,
    );
  }
}
