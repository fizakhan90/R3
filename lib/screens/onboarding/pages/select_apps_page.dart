// lib/screens/onboarding/pages/select_apps_page.dart
import 'package:flutter/material.dart';
import 'package:r3/services/usage_service.dart';

class SelectAppsPage extends StatefulWidget {
  final Function(String, bool) onAppSelected;
  final Set<String> selectedApps;

  const SelectAppsPage({
    super.key,
    required this.onAppSelected,
    required this.selectedApps,
  });

  @override
  _SelectAppsPageState createState() => _SelectAppsPageState();
}

class _SelectAppsPageState extends State<SelectAppsPage> {
  // We create an instance of our "bridge" to talk to the native code.
  final UsageService _usageService = UsageService();
  Future<List<AppInfo>>? _appsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching the apps as soon as the widget is created.
    _appsFuture = _usageService.getInstalledApps();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Which apps are your biggest distractions?",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "R3 will help you pause before you open them.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            // FutureBuilder is perfect for this. It shows a loading spinner
            // while waiting for the apps, and then shows the list.
            child: FutureBuilder<List<AppInfo>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                // While loading:
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // If there was an error:
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Could not load apps.\nPlease grant permissions and restart.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                // When data is ready:
                final apps = snapshot.data!;
                apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                return ListView.builder(
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isSelected = widget.selectedApps.contains(app.packageName);
                    return CheckboxListTile(
                      activeColor: Colors.deepPurple,
                      secondary: app.icon != null
                          ? Image.memory(app.icon!, width: 40, height: 40)
                          : const Icon(Icons.android, size: 40, color: Colors.white38),
                      title: Text(app.name, style: const TextStyle(color: Colors.white)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        if (value != null) {
                          // This calls the function in onboarding_screen.dart
                          // to update the list of selected apps.
                          widget.onAppSelected(app.packageName, value);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}