import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../features/auth/auth_repository.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_in_view_model.dart';
import '../features/forms/catch_check_form_screen.dart';
import '../features/forms/inspection_form_screen.dart';
import '../features/forms/violation_form_screen.dart';
import '../features/home/home_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const signIn = '/sign-in';
  static const home = '/home';
  static const inspectionForm = '/forms/inspection';
  static const violationForm = '/forms/violation';
  static const catchCheckForm = '/forms/catch-check';

  static final Map<String, WidgetBuilder> routes = {
    // Each screen gets its own ViewModel; the ViewModel gets the repository it needs
    // With TEST_USER set, Sign In is skipped and the app opens straight on Home
    signIn: (context) => skipSignIn
        ? const HomeShell()
        : ChangeNotifierProvider(
            create: (context) => SignInViewModel(context.read<AuthRepository>()),
            child: const SignInScreen(),
          ),
    home: (_) => const HomeShell(),
    inspectionForm: (_) => const InspectionFormScreen(),
    violationForm: (_) => const ViolationFormScreen(),
    catchCheckForm: (_) => const CatchCheckFormScreen(),
  };
}
