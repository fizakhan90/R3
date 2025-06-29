// lib/screens/onboarding/pages/select_apps_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:r3/services/app_state.dart';   // Import AppState
import 'package:r3/services/usage_service.dart'; // Import the correct UsageService

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
  // We no longer create an instance here. We will get it from AppState.
  Future<List<AppInfo>>? _appsFuture;

  @override
  void initState() {
    super.initState();
    // Use the AppState's instance of UsageService to fetch the apps.
    // We use addPostFrameCallback to ensure the context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _appsFuture = Provider.of<AppState>(context, listen: false)
            .usageService
            .getInstalledApps();
      });
    });
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
            child: FutureBuilder<List<AppInfo>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                if (_appsFuture == null || snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Could not load apps.\nPlease grant permissions and restart.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                
                final apps = snapshot.data!;
                // The list is already sorted by the service now.

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