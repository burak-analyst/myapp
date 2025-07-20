import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'pages/dashboard_page.dart';
import 'pages/objectives_page.dart';
import 'pages/vision_page.dart';
import 'pages/info_page.dart';
import 'pages/settings_page.dart';

// --- Splash video widget (can be moved to its own file if you want) ---
class SplashVideoScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashVideoScreen({super.key, required this.onFinish});

  @override
  State<SplashVideoScreen> createState() => _SplashVideoScreenState();
}

class _SplashVideoScreenState extends State<SplashVideoScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/splash_intro.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.setVolume(1.0);
    _controller.setLooping(false);
    _controller.addListener(_checkVideoEnd);
  }

  void _checkVideoEnd() {
    if (_controller.value.position >= _controller.value.duration) {
      widget.onFinish();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_checkVideoEnd);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller.value.isInitialized
          ? GestureDetector(
              onTap: widget.onFinish, // tap to skip
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  Positioned(
                    top: 44,
                    right: 20,
                    child: SafeArea(
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                        onPressed: widget.onFinish,
                        tooltip: 'Skip intro',
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

// --- Main app ---

void main() {
  runApp(const LifeMaxxApp());
}

class LifeMaxxApp extends StatelessWidget {
  const LifeMaxxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeMaxx',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const SplashVideoLauncher(),
    );
  }
}

class SplashVideoLauncher extends StatefulWidget {
  const SplashVideoLauncher({super.key});
  @override
  State<SplashVideoLauncher> createState() => _SplashVideoLauncherState();
}

class _SplashVideoLauncherState extends State<SplashVideoLauncher> {
  bool _splashDone = false;
  @override
  Widget build(BuildContext context) {
    return _splashDone
        ? const MainNavigationPage()
        : SplashVideoScreen(onFinish: () {
            setState(() {
              _splashDone = true;
            });
          });
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ObjectivesPage(),
    DashboardPage(),
    VisionPage(),
    InfoPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.flag), label: 'Objectives'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.bolt), label: 'Vision'),
          NavigationDestination(icon: Icon(Icons.info_outline), label: 'Info'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
