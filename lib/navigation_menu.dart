import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/health_chat_screen.dart';
import 'package:app/screens/control_center.dart';
import 'services/auth_service.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  NavigationMenuState createState() => NavigationMenuState();
}

class NavigationMenuState extends State<NavigationMenu> {
  void _refreshHomeScreenOnReminderSaved() {
    setState(() {});
  }

  int selectedIndex = 0;

  List<Widget> get screens => [
    HomeScreen(onReminderSaved: _refreshHomeScreenOnReminderSaved),
    const HealthChatScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6B46C1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'MediKora',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Health Companion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF6B46C1)),
              title: const Text('Health Chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6B46C1)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Add profile navigation here
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF6B46C1)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Add settings navigation here
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                try {
                  final auth = Provider.of<AuthService>(context, listen: false);
                  await auth.signOut();
                  // The AuthWrapper will automatically handle the navigation back to login
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF6B46C1)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: kBottomNavigationBarHeight - 4,
            left: (MediaQuery.of(context).size.width - 150) / 2,
            child: MaterialButton(
              onPressed: null,
              elevation: 0,
              highlightElevation: 0,
              color: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Image.asset(
                'assets/icons/kora-transparent1.png',
                width: 120,
                height: 120,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SizedBox(
        height: 83,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(107, 70, 193, 0.1),
                blurRadius: 14,
                offset: Offset(0, -1),
              )
            ],
          ),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selectedIndex == 0
                            ? const Color(0xFF6B46C1)
                            : const Color(0xFFE9D8FD),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/icons/pills_icon_2.png',
                        width: 31,
                        height: 31,
                      ),
                    ),
                    onPressed: () => onItemTapped(0),
                    highlightColor: Colors.transparent,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(15),
                    padding: const EdgeInsets.all(6),
                    color: const Color(0xFF6B46C1),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: const Color(0xFF6B46C1),
                        size: 24,
                      ),
                      onPressed: () {
                        showControlCenter(
                            context, _refreshHomeScreenOnReminderSaved);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
