// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:r3/screens/disruption_hub_screen.dart';
// import 'package:r3/screens/learning_activity_screen.dart'; // ✅ Make sure this exists
// import 'package:r3/services/app_state.dart';
// import 'package:r3/services/usage_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final UsageService _usageService = UsageService();
//   StreamSubscription? _distractionSubscription;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final appState = Provider.of<AppState>(context, listen: false);
//       appState.startMonitoringService();

//       _distractionSubscription =
//           _usageService.distractionStream.listen((packageName) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => const DisruptionHubScreen(),
//         ).then((_) {
//           // After dialog closes, restart monitoring
//           Provider.of<AppState>(context, listen: false).startMonitoringService();
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _distractionSubscription?.cancel();
//     super.dispose();
//   }

//   Widget _buildStatusWidget(String status) {
//     String message;
//     Color color;
//     IconData icon;

//     switch (status) {
//       case "STARTED_SUCCESSFULLY":
//         message = "Monitoring is active. R3 is working in the background.";
//         color = Colors.green;
//         icon = Icons.shield_outlined;
//         break;
//       case "PERMISSION_DENIED":
//         message =
//             "ACTION REQUIRED:\nPlease grant 'Usage Access' permission for R3 to work. Tap here to try opening settings again.";
//         color = Colors.amber;
//         icon = Icons.warning_amber_rounded;
//         break;
//       default:
//         message = "Status: $status";
//         color = Colors.grey;
//         icon = Icons.info_outline;
//     }

//     return GestureDetector(
//       onTap: () {
//         if (status == "PERMISSION_DENIED") {
//           Provider.of<AppState>(context, listen: false).startMonitoringService();
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color, size: 30),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 message,
//                 style: TextStyle(color: color, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppState>(
//       builder: (context, appState, child) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("R3 Dashboard"),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//           ),
//           body: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Spacer(),
//                 const Text(
//                   "Welcome to R3",
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "You have ${appState.distractingApps.length} app(s) marked for interception.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 const SizedBox(height: 20),
//                 _buildStatusWidget(appState.monitoringStatus),
//                 const SizedBox(height: 40),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:r3/screens/disruption_hub_screen.dart';
import 'package:r3/services/app_state.dart';
import 'package:r3/services/usage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UsageService _usageService = UsageService();
  StreamSubscription? _distractionSubscription;

  String? _dailyChallenge;
  int _challengeStreak = 0;
  bool _isChallengeCompletedToday = false;

  final List<String> _challenges = [
    "Stay off Instagram for 30 minutes.",
    "Go outside and take 10 deep breaths.",
    "Call a friend instead of scrolling.",
    "Spend 15 minutes learning something new.",
    "Avoid your top distracting app for 1 hour.",
    "Write down 3 things you're grateful for.",
    "Do 10 jumping jacks or stretch your body.",
    "Read 1 page from a book.",
    "Drink a glass of water mindfully.",
    "Take a walk without your phone.",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.startMonitoringService();

      _distractionSubscription =
          _usageService.distractionStream.listen((packageName) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const DisruptionHubScreen(),
        ).then((_) {
          Provider.of<AppState>(context, listen: false)
              .startMonitoringService();
        });
      });
    });

    _loadDailyChallenge();
  }

  Future<void> _loadDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";

    // Check if already completed today
    final lastCompletedDate = prefs.getString('lastCompletedDate');
    _isChallengeCompletedToday = lastCompletedDate == todayKey;

    // Load streak
    _challengeStreak = prefs.getInt('challengeStreak') ?? 0;

    // Generate consistent challenge using today's date
    final seed = now.year * 10000 + now.month * 100 + now.day;
    _challenges.shuffle(Random(seed));
    _dailyChallenge = _challenges.first;

    setState(() {});
  }

  Future<void> _markChallengeAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = "${now.year}-${now.month}-${now.day}";

    if (_isChallengeCompletedToday) return;

    final lastCompletedDate = prefs.getString('lastCompletedDate');

    if (lastCompletedDate != null) {
      final lastDate = DateTime.parse(lastCompletedDate);
      if (now.difference(lastDate).inDays == 1) {
        _challengeStreak++;
      } else if (now.difference(lastDate).inDays > 1) {
        _challengeStreak = 1; // restart streak
      }
    } else {
      _challengeStreak = 1; // first time
    }

    await prefs.setString('lastCompletedDate', todayKey);
    await prefs.setInt('challengeStreak', _challengeStreak);

    setState(() {
      _isChallengeCompletedToday = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🎉 Challenge completed!")),
    );
  }

  Widget _buildDailyChallengeWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🌟 Daily Challenge",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _dailyChallenge ?? "Stay mindful today!",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isChallengeCompletedToday
                    ? "✅ Completed Today"
                    : "🔄 In Progress",
                style: TextStyle(
                  color: _isChallengeCompletedToday
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
              Text(
                "🔥 Streak: $_challengeStreak day${_challengeStreak == 1 ? '' : 's'}",
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (!_isChallengeCompletedToday)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _markChallengeAsCompleted,
                icon: const Icon(Icons.check, color: Colors.green),
                label: const Text(
                  "Mark Done",
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(String status) {
    String message;
    Color color;
    IconData icon;

    switch (status) {
      case "STARTED_SUCCESSFULLY":
        message = "Monitoring is active. R3 is working in the background.";
        color = Colors.green;
        icon = Icons.shield_outlined;
        break;
      case "PERMISSION_DENIED":
        message =
            "ACTION REQUIRED:\nPlease grant 'Usage Access' permission for R3 to work. Tap here to try opening settings again.";
        color = Colors.amber;
        icon = Icons.warning_amber_rounded;
        break;
      default:
        message = "Status: $status";
        color = Colors.grey;
        icon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () {
        if (status == "PERMISSION_DENIED") {
          Provider.of<AppState>(context, listen: false).startMonitoringService();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _distractionSubscription?.cancel();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Consumer<AppState>(
    builder: (context, appState, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("R3 Dashboard"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome to R3",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "You have ${appState.distractingApps.length} app(s) marked for interception.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              if (_dailyChallenge != null) _buildDailyChallengeWidget(),

              const Spacer(),
              _buildStatusWidget(appState.monitoringStatus),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    },
  );
}
}