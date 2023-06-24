import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AccommodationsScreen extends StatefulWidget {
  static const routePath = 'accommodations';

  const AccommodationsScreen({super.key});

  @override
  State<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends State<AccommodationsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
