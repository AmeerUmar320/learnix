// lib/main.dart
import 'package:flutter/material.dart';

// ─── Firebase Initialization ──────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ─── Services & Auth ────────────────────────────────────────────────────
import 'package:group_chat_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─── Screens ────────────────────────────────────────────────────────────
import 'package:group_chat_app/screens/login_screen.dart';
import 'package:group_chat_app/screens/signup_screen.dart';
import 'package:group_chat_app/screens/profile_picture_page.dart';
import 'package:group_chat_app/screens/home_page.dart';
import 'package:group_chat_app/screens/select_members_page.dart';
import 'package:group_chat_app/screens/create_task_page.dart';
import 'package:group_chat_app/screens/group_details_screen.dart';
import 'package:group_chat_app/screens/tasks_page.dart';

// ─── Bottom Nav Bar ─────────────────────────────────────────────────────
import 'package:circle_nav_bar/circle_nav_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E1213),
        primaryColor: const Color(0xFFB5FB67),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFB5FB67),
          secondary: Color(0xFFB5FB67),
        ),
      ),

      // ─── Global auth-gate ───────────────────────────────────────────────
      home: StreamBuilder<User?>(
        stream: AuthService().authState,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // if logged in, go to your bottom-nav home, otherwise login
          return snapshot.hasData ? const MyHomePage() : const LoginScreen();
        },
      ),

      // ─── Named routes (for any pushNamed usage) ─────────────────────────
      routes: {
        '/signup': (ctx) => const SignupScreen(),
        '/profile_picture': (ctx) => const ProfilePicturePage(),
        '/home': (ctx) => const MyHomePage(),
        '/select_members': (ctx) => const SelectMembersPage(),
        '/create_task': (ctx) => const CreateTaskPage(groupId: '' /* overwritten by push args */),
        '/group_details': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
          return GroupDetailsScreen(
            groupName: args?['groupName'] ?? '',
            subject: args?['subject'] ?? '',
            imageAsset: args?['imageAsset'] ?? 'assets/profiles/profile_7.jpg',
          );
        },
        '/tasks': (ctx) => const TasksPage( /* overwritten by push args */),
      },
    );
  }
}

///
/// Your bottom-nav “shell” that switches between HomePage & TasksPage,
/// and lets you push to SelectMembersPage / CreateTaskPage via the center button.
///
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPage = 0;

  IconData get _centerIcon =>
      _selectedPage == 0 ? Icons.group_add : Icons.assignment_add;

  void _onTap(int i) {
    switch (i) {
      case 0:
        setState(() => _selectedPage = 0);
        break;
      case 1:
        // center button
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

  @override
  Widget build(BuildContext context) {
    const circleBg      = Color(0xFFB5FB67);
    const iconColor     = Color(0xFF0E1213);
    const inactiveColor = Color.fromARGB(255, 105, 112, 114);
    const navBg         = Color(0xFF212D2D);
    const appBarBg      = Color(0xFF0E1213);

    final leftColor  = _selectedPage == 0 ? circleBg : inactiveColor;
    final rightColor = _selectedPage == 1 ? circleBg : inactiveColor;

    const circleSize = 60.0;
    const navHeight  = 60.0;
    final screenW    = MediaQuery.of(context).size.width;

    return Stack(
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
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage('assets/profile (7).jpg'),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hey, Emilyxox',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
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
                margin: const EdgeInsets.only(right: 16),
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(77, 118, 131, 131),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none),
                  color: Colors.white,
                  onPressed: () {},
                ),
              ),
            ],
          ),

          bottomNavigationBar: CircleNavBar(
            color: navBg,
            padding: EdgeInsets.zero,
            activeIndex: _selectedPage == 0 ? 0 : 2,
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
              TasksPage(), // if your TasksPage now requires a groupId
            ],
          ),
        ),

        // full‐circle tap area for the center fab
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
    );
  }
}
