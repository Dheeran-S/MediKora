import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../navigation_menu.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const NavigationMenu();
        }

        return LoginScreen(
          onLoginSuccess: () {
            // This will trigger a rebuild and show the NavigationMenu
          },
        );
      },
    );
  }
}
