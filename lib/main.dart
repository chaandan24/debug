import 'package:flutter/material.dart';

// A placeholder for your WordFormScreen
class GenericFormScreen extends StatelessWidget {
  final String title;
  const GenericFormScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Content')),
    );
  }
}

// Your app_navigator.dart, simplified to remove dependencies
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});
  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _pushPage(Widget page) {
    // This is the critical navigation call
    _navigatorKeys[_selectedIndex].currentState?.push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          _buildOffstageNavigator(0, const Center(child: Text('Home Page'))),
          _buildOffstageNavigator(1, const Center(child: Text('Search Page'))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: AnimatedFloatingActionButton(onPushPage: _pushPage),
    );
  }

  Widget _buildOffstageNavigator(int index, Widget initialRoute) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        initialRoute: '/',
        onGenerateInitialRoutes: (navigator, initialRouteName) {
          return [MaterialPageRoute(builder: (context) => initialRoute)];
        },
      ),
    );
  }
}

// Your floating_action_button.dart, simplified to remove dependencies
class AnimatedFloatingActionButton extends StatefulWidget {
  final Function(Widget page) onPushPage;
  const AnimatedFloatingActionButton({super.key, required this.onPushPage});
  @override
  State<AnimatedFloatingActionButton> createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleFab() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        Transform.translate(
          offset: Offset.lerp(
            Offset.zero,
            const Offset(-15, -70),
            _animationController.value,
          )!,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              toggleFab();
              widget.onPushPage(const GenericFormScreen(title: "Add Word"));
            },
            child: const Icon(Icons.book),
          ),
        ),
        FloatingActionButton(
          onPressed: toggleFab,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }
}

// Main App Entry Point
void main() async {
  await Future.delayed(const Duration(seconds: 30));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AppNavigator());
  }
}
