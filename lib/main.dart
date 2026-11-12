import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/main_shell/screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KantinQApp());
}

class KantinQApp extends StatelessWidget {
  const KantinQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: AppState.instance,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return Container(
            color: const Color(0xFF181B1F),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        home: const MainShellScreen(),
      ),
    );
  }
}
