import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../texts/app_texts.dart';

/// Opens a phone call or a map. Shows a message if the device cannot.
Future<void> openUri(
  BuildContext context,
  Uri uri, {
  LaunchMode mode = LaunchMode.platformDefault,
}) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: mode);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t('cannot_open'))));
  }
}

/// tel: link from a phone number like "01700-000001".
Uri phoneUri(String phone) =>
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^0-9+]'), ''));

/// Google Maps search link for a place.
Uri mapsUri(String query) =>
    Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});
