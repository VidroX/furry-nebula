import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SheltersScreen extends StatefulWidget {
  static const routePath = 'shelters';

  const SheltersScreen({super.key});

  @override
  State<SheltersScreen> createState() => _SheltersScreenState();
}

class _SheltersScreenState extends State<SheltersScreen> {
  @override
  Widget build(BuildContext context) => const AutoRouter();
}
