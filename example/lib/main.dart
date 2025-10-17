import 'package:flutter/material.dart';
import 'package:connected_button_group/connected_button_group.dart';

void main() {
  runApp(const DemoApp());
}

/// Simple demonstration of the ConnectedButtonGroup widget.
class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  ViewMode _mode = ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectedButtonGroup Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ConnectedButtonGroup Demo'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConnectedButtonGroup<ViewMode>(
                  items: [
                    ConnectedButtonItem(
                      value: ViewMode.list,
                      icon: Icons.view_list,
                      label: 'List',
                      tooltip: 'List view',
                    ),
                    ConnectedButtonItem(
                      value: ViewMode.grid,
                      icon: Icons.grid_view,
                      label: 'Grid',
                      tooltip: 'Grid view',
                    ),
                    ConnectedButtonItem(
                      value: ViewMode.map,
                      icon: Icons.map,
                      label: 'Map',
                      tooltip: 'Map view',
                      isSplit: true,
                      onPrimaryPressed: () {
                        // default map action
                        debugPrint('Primary Map action');
                      },
                      menu: [
                        ConnectedMenuEntry(label: 'Default layer', value: ViewMode.map),
                        ConnectedMenuEntry(label: 'Satellite', value: ViewMode.map),
                        ConnectedMenuEntry(label: 'Terrain', value: ViewMode.map),
                      ],
                    ),
                    ConnectedButtonItem(
                      value: ViewMode.settings,
                      icon: Icons.settings,
                      label: 'More',
                      tooltip: 'More options',
                      menu: [
                        ConnectedMenuEntry(label: 'Profile', value: ViewMode.settings),
                        ConnectedMenuEntry(label: 'Logout', value: ViewMode.settings, destructive: true),
                      ],
                    ),
                  ],
                  value: _mode,
                  onChanged: (mode) {
                    setState(() {
                      _mode = mode;
                    });
                  },
                  onMenuItemSelected: (pair) {
                    debugPrint('Selected ${pair.$2.label} from ${pair.$1}');
                  },
                ),
                const SizedBox(height: 24.0),
                Text('Selected mode: $_mode'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enumeration used for the example demonstrating selection.
enum ViewMode { list, grid, map, settings }