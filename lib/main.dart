import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/auth_repository.dart';

void main() {
  // One shared copy of each service for the whole app; screens get them with context.read<...>()
  final tokens = TokenStorage();
  final api = ApiClient(baseUrl: apiBaseUrl, tokens: tokens);

  runApp(
    MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokens),
        Provider<ApiClient>.value(value: api),
        Provider<AuthRepository>(create: (_) => AuthRepository(api: api, tokens: tokens)),
      ],
      child: const VesperApp(),
    ),
  );
}
