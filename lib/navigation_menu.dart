import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:app/screens/control_center.dart';

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
