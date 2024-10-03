import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shelter_partner/view_models/auth_view_model.dart';
import 'package:shelter_partner/views/auth/login_or_signup.dart';
import 'package:shelter_partner/views/pages/main_page.dart';


class AuthPage extends ConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final authState = ref.watch(authViewModelProvider);

    // Handle error state with toast and reset state
    if (authState.status == AuthStatus.error) {
      Future.microtask(() {
        Fluttertoast.showToast(
          msg: authState.errorMessage ?? 'An unknown error occurred',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        authViewModel.resetState();
      });

      return const LoginOrSignup(); // The page is already managed by Riverpod
    }

    return Scaffold(
      body: authState.status == AuthStatus.loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(authState.loadingMessage ?? "Loading..."),
                ],
              ),
            )
          : authState.status == AuthStatus.authenticated
              ? MainPage(appUser: authState.user!)
              : const LoginOrSignup(), // Persisting the page through Riverpod
    );
  }
}


enum AuthPageType { login, signup, forgotPassword }

class AuthPageNotifier extends StateNotifier<AuthPageType> {
  AuthPageNotifier() : super(AuthPageType.login);

  // Update the current page
  void setPage(AuthPageType pageType) {
    state = pageType;
  }
}

// Provide the AuthPageNotifier using Riverpod
final authPageProvider = StateNotifierProvider<AuthPageNotifier, AuthPageType>(
  (ref) => AuthPageNotifier(),
);