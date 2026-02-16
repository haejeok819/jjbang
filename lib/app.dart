import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_scaffold.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '주정뱅이',
      theme: AppTheme.light(),
      home: const AppScaffold(),
    );
  }
}