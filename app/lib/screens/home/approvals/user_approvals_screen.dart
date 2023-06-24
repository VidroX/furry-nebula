import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UserApprovalsScreen extends StatefulWidget {
  static const routePath = 'approvals/user';

  const UserApprovalsScreen({super.key});

  @override
  State<UserApprovalsScreen> createState() => _UserApprovalsScreenState();
}

class _UserApprovalsScreenState extends State<UserApprovalsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
