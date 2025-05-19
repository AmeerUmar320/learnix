//main.dart
import 'dart:io';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- Add this for SystemNavigator
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_chat_app/blocs/task/task_bloc.dart';
import 'package:group_chat_app/repositories/task_repository.dart';
import 'package:group_chat_app/screens/tasks_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/profile_picture_page.dart';
import 'screens/home_page.dart';
import 'screens/select_members_page.dart';
import 'screens/create_task_page.dart';
import 'screens/group_details_screen.dart';
import 'repositories/auth_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/group/group_bloc.dart';
import 'repositories/group_repository.dart';
import 'screens/group_info_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('loggedIn') ?? false;
  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(AuthRepository()),
        ),
        BlocProvider(
          create: (context) => GroupBloc(GroupRepository()),
        ),
        BlocProvider(
          create: (context) => TaskBloc(TaskRepository()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Learnix',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0E1213),
          primaryColor: const Color(0xFFB5FB67),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFB5FB67),
            secondary: const Color(0xFFB5FB67),
          ),
        ),
        initialRoute: loggedIn ? '/home' : '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/profile_picture': (context) => const ProfilePicturePage(),
          '/home': (context) => const MyHomePage(),
          '/select_members': (context) => const SelectMembersPage(),
          '/create_task': (context) => const CreateTaskPage(),
          '/group_details': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
            return GroupDetailsScreen(
              group: args!['group'],
            );
          },
          '/group_info': (context) => const GroupInfoPage(selectedUsers: []),
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;
  String? _userName;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _profilePictureUrl = prefs.getString('profilePictureUrl');
    });
  }

  final List<Map<String, String>> _notifications = [
    { 'title': 'New Assignment Posted', 'time': '2h ago' },
    { 'title': 'Group "Flutter Devs" invited you', 'time': '5h ago' },
    { 'title': 'Task "Write Lab Report" due soon', 'time': '1d ago' },
  ];

  IconData get _centerIcon =>
      _selectedPage == 0 ? Icons.group_add : Icons.assignment_add;

  void _onTap(int i) {
    switch (i) {
      case 0:
        setState(() => _selectedPage = 0);
        break;
      case 1:
        if (_selectedPage == 0) {
          Navigator.pushNamed(context, '/select_members');
        } else {
          Navigator.pushNamed(context, '/create_task');
        }
        break;
      case 2:
        setState(() => _selectedPage = 1);
        break;
    }
  }

  void _showNotificationsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0E1213),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          children: _notifications.map((notif) {
            return ListTile(
              title: Text(notif['title']!, style: const TextStyle(color: Colors.white)),
              subtitle: Text(notif['time']!, style: const TextStyle(color: Colors.white54)),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('profilePictureUrl');
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF22282a),
        title: const Text('Exit App', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to exit?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit', style: TextStyle(color: Color(0xFFB5FB67))),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      // Exit app using SystemNavigator.pop (works for Android, Windows, etc)
      await Future.delayed(const Duration(milliseconds: 150));
      SystemNavigator.pop();
      // Optionally, for Android, you can also use: exit(0);
      // exit(0);
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    const circleBg = Color(0xFFB5FB67);
    const iconColor = Color(0xFF0E1213);
    const inactiveColor = Color.fromARGB(255, 105, 112, 114);
    const navBg = Color(0xFF212D2D);
    const appBarBg = Color(0xFF0E1213);

    final leftColor = _selectedPage == 0 ? circleBg : inactiveColor;
    final rightColor = _selectedPage == 1 ? circleBg : inactiveColor;

    final circleSize = 60.0;
    final navHeight = 60.0;
    final screenW = MediaQuery.of(context).size.width;

    String? profilePicUrl = _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
        ? 'http://192.168.100.28:5241${_profilePictureUrl!}'
        : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Scaffold(
            extendBody: true,
            appBar: AppBar(
              backgroundColor: appBarBg,
              elevation: 0,
              toolbarHeight: 80,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: profilePicUrl != null
                      ? NetworkImage(profilePicUrl)
                      : const AssetImage('assets/profile (7).jpg') as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName != null && _userName!.isNotEmpty ? 'Hey, $_userName' : 'Hey!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(77, 118, 131, 131),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none),
                    color: Colors.white,
                    onPressed: _showNotificationsPopup,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(77, 131, 118, 118),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    color: Colors.white,
                    tooltip: 'Logout',
                    onPressed: _logout,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: CircleNavBar(
              color: navBg,
              padding: EdgeInsets.zero,
              activeIndex: 1,
              height: navHeight,
              circleWidth: circleSize,
              circleColor: circleBg,
              shadowColor: Colors.black26,
              elevation: 8,
              onTap: _onTap,
              tabCurve: Curves.easeInOutBack,
              iconCurve: Curves.elasticOut,
              inactiveIcons: [
                Icon(
                  _selectedPage == 0 ? Icons.home : Icons.home_outlined,
                  size: 28,
                  color: leftColor,
                ),
                Icon(_centerIcon, size: 28, color: iconColor),
                Icon(
                  _selectedPage == 1 ? Icons.assignment : Icons.assignment_outlined,
                  size: 28,
                  color: rightColor,
                ),
              ],
              activeIcons: [
                Icon(
                  _selectedPage == 0 ? Icons.home : Icons.home_outlined,
                  size: 28,
                  color: leftColor,
                ),
                Icon(_centerIcon, size: 28, color: iconColor),
                Icon(
                  _selectedPage == 1 ? Icons.assignment : Icons.assignment_outlined,
                  size: 28,
                  color: rightColor,
                ),
              ],
            ),
            body: IndexedStack(
              index: _selectedPage,
              children: const [
                HomePage(),
                TasksPage(),
              ],
            ),
          ),
          Positioned(
            bottom: navHeight - (circleSize / 2),
            left: (screenW / 2) - (circleSize / 2),
            width: circleSize,
            height: circleSize,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _onTap(1),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
