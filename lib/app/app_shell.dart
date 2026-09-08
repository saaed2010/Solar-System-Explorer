import 'package:flutter/material.dart';

import '../screens/comparison_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/solar_system_screen.dart';
import '../screens/stars_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _wideLayoutBreakpoint = 960.0;
  int _selectedIndex = 0;

  Widget get _screen => switch (_selectedIndex) {
    0 => const SolarSystemScreen(key: ValueKey('solar-system-screen')),
    1 => const ExploreScreen(key: ValueKey('explore-screen')),
    2 => const StarsScreen(key: ValueKey('stars-screen')),
    _ => const ComparisonScreen(key: ValueKey('comparison-screen')),
  };

  void _select(int index) => setState(() => _selectedIndex = index);

  Widget _animatedScreen(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.99, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: _screen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _wideLayoutBreakpoint) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                SafeArea(
                  child: NavigationRail(
                    key: const Key('main-navigation-rail'),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _select,
                    labelType: NavigationRailLabelType.all,
                    groupAlignment: -0.45,
                    minWidth: 88,
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.blur_circular_outlined),
                        selectedIcon: Icon(Icons.blur_circular),
                        label: Text('System'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.travel_explore_outlined),
                        selectedIcon: Icon(Icons.travel_explore),
                        label: Text('Explore'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.auto_awesome_outlined),
                        selectedIcon: Icon(Icons.auto_awesome),
                        label: Text('Stars'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.straighten_outlined),
                        selectedIcon: Icon(Icons.straighten),
                        label: Text('Compare'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _animatedScreen(context)),
              ],
            ),
          );
        }
        return Scaffold(
          extendBody: false,
          body: _animatedScreen(context),
          bottomNavigationBar: NavigationBar(
            key: const Key('main-navigation'),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _select,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.blur_circular_outlined),
                selectedIcon: Icon(Icons.blur_circular),
                label: 'System',
              ),
              NavigationDestination(
                icon: Icon(Icons.travel_explore_outlined),
                selectedIcon: Icon(Icons.travel_explore),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Stars',
              ),
              NavigationDestination(
                icon: Icon(Icons.straighten_outlined),
                selectedIcon: Icon(Icons.straighten),
                label: 'Compare',
              ),
            ],
          ),
        );
      },
    );
  }
}
