import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int lowQuantity;
  late int daysBeforeExpiry;

  @override
  void initState() {
    super.initState();
    lowQuantity = 0;
    daysBeforeExpiry = 1;
    loadLowQuantity();
    loadDaysBeforeExpiry();
  }

  Future<void> loadLowQuantity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lowQuantity = prefs.getInt('lowQuantity') ?? 0;
    });
  }

  Future<void> saveLowQuantity(int newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lowQuantity', newValue);
    setState(() {
      lowQuantity = newValue;
    });
  }

  Future<void> loadDaysBeforeExpiry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      daysBeforeExpiry = prefs.getInt('daysBeforeExpiry') ?? 1;
    });
  }

  Future<void> saveDaysBeforeExpiry(int newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daysBeforeExpiry', newValue);
    setState(() {
      daysBeforeExpiry = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(255, 244, 235, 1),
          appBar: AppBar(
            title: Text(languageProvider.translate('settings.title')),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      languageProvider.translate('settings.language'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromRGBO(158, 66, 0, 1),
                      ),
                    ),
                    const Divider(color: Color.fromRGBO(158, 66, 0, 0.5)),
                    const SizedBox(height: 16),
                    _buildLanguageSelector(languageProvider),
                    const SizedBox(height: 30),
                    Text(
                      languageProvider.translate('settings.notifications'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color.fromRGBO(158, 66, 0, 1),
                      ),
                    ),
                    const Divider(color: Color.fromRGBO(158, 66, 0, 0.5)),
                    const SizedBox(height: 16),
                    Text(
                      languageProvider.translate('settings.quantity_to_notify'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color.fromRGBO(158, 66, 0, 1),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(225, 95, 0, 1),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (lowQuantity > 1) lowQuantity--;
                                saveLowQuantity(lowQuantity);
                              });
                            },
                          ),
                          Text(
                            '$lowQuantity',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                lowQuantity++;
                                saveLowQuantity(lowQuantity);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      languageProvider.translate('settings.days_before_expiry'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color.fromRGBO(158, 66, 0, 1),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(225, 95, 0, 1),
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (daysBeforeExpiry > 1) daysBeforeExpiry--;
                                saveDaysBeforeExpiry(daysBeforeExpiry);
                              });
                            },
                          ),
                          Text(
                            '$daysBeforeExpiry',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                daysBeforeExpiry++;
                                saveDaysBeforeExpiry(daysBeforeExpiry);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ]),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(158, 66, 0, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.translate('settings.select_language'),
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color.fromRGBO(158, 66, 0, 1),
            ),
          ),
          const SizedBox(height: 12),
          ...languageProvider.getSupportedLanguages().map((language) {
            return RadioListTile<String>(
              title: Text(language['name']!),
              value: language['code']!,
              groupValue: languageProvider.currentLanguage,
              activeColor: const Color.fromRGBO(158, 66, 0, 1),
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
