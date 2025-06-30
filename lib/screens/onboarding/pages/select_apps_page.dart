// lib/screens/onboarding/pages/select_apps_page.dart
import 'package:flutter/material.dart';
import 'package:r3/screens/learning/learning_theme.dart';
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
  final UsageService _usageService = UsageService();
  Future<List<AppInfo>>? _appsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = _usageService.getInstalledApps();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Which apps are your biggest distractions?",
            // Using a theme style for the main headline
            style: textTheme.titleLarge?.copyWith(
              fontSize: 24, // Slightly larger for emphasis
              color: LearningTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "R3 will help you pause before you open them.",
            // Using a theme style for the sub-headline
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<AppInfo>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                // --- Modern Loading State ---
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: LearningTheme.accent),
                  );
                }
                // --- Modern Error State ---
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: LearningTheme.textSecondary, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          "Could Not Load Apps",
                          style: textTheme.titleLarge?.copyWith(color: LearningTheme.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Please ensure permissions have been granted and restart the app.",
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // --- Data is Ready: Build the List ---
                final apps = snapshot.data!;
                apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 60), // Space for floating button
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    final isSelected = widget.selectedApps.contains(app.packageName);
                    
                    // Using our new custom list tile widget
                    return AppSelectionTile(
                      app: app,
                      isSelected: isSelected,
                      onChanged: (value) => widget.onAppSelected(app.packageName, value),
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

/// A custom, visually appealing widget for each app in the list.
class AppSelectionTile extends StatelessWidget {
  final AppInfo app;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const AppSelectionTile({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? LearningTheme.accent.withOpacity(0.15) : LearningTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? LearningTheme.accent : LearningTheme.surface,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // --- App Icon ---
            app.icon != null
                ? Image.memory(app.icon!, width: 40, height: 40)
                : const Icon(Icons.android, size: 40, color: LearningTheme.textSecondary),
            const SizedBox(width: 16),
            // --- App Name ---
            Expanded(
              child: Text(
                app.name,
                style: const TextStyle(
                  color: LearningTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            // --- Custom Checkbox ---
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? LearningTheme.accent : LearningTheme.card,
                border: Border.all(
                  color: isSelected ? LearningTheme.accent : LearningTheme.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}