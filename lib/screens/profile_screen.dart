import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';
import 'package:app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? user = authService.getCurrentUser();

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F5FF),
          appBar: AppBar(
            title: Text(languageProvider.translate('navigation.profile')),
            backgroundColor: const Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE9D8FD),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF6B46C1),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                Text(
                  user?.email ?? 'No Email',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                _buildProfileItem(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: user?.email ?? 'Not set',
                ),
                const SizedBox(height: 16),
                _buildProfileItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Account Status',
                  subtitle: user?.emailVerified == true ? 'Verified' : 'Unverified',
                  trailing: user?.emailVerified == true
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.error_outline, color: Colors.orange),
                ),
                const SizedBox(height: 16),
                _buildProfileItem(
                  icon: Icons.fingerprint,
                  title: 'User ID',
                  subtitle: user?.uid ?? 'Unknown',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6B46C1)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
