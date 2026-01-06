import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F5FF), // light purple background
          appBar: AppBar(
            title: Text(languageProvider.translate('settings.title')),
            backgroundColor: const Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───────── Language Section ─────────
                Text(
                  languageProvider.translate('settings.language'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF4C1D95),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0xFFD6BCFA)),
                const SizedBox(height: 16),
                _buildLanguageSelector(languageProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSelector(LanguageProvider languageProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.translate('settings.select_language'),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF6B46C1),
            ),
          ),
          const SizedBox(height: 12),
          ...languageProvider.getSupportedLanguages().map((language) {
            return RadioListTile<String>(
              title: Text(
                language['name']!,
                style: const TextStyle(fontSize: 15),
              ),
              value: language['code']!,
              groupValue: languageProvider.currentLanguage,
              activeColor: const Color(0xFF6B46C1),
              onChanged: (String? value) async {
                if (value != null) {
                  await languageProvider.changeLanguage(value);
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
