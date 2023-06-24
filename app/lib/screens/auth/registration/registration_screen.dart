import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RegistrationScreen extends StatefulWidget {
  final bool isShelterRep;

  static const routePath = 'register';

  const RegistrationScreen({
    @QueryParam('isShelterRep') this.isShelterRep = false,
    super.key,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
