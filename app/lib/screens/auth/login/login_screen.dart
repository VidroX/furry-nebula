import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/screens/auth/state/auth_bloc.dart';
import 'package:furry_nebula/services/injector.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routePath = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _bloc = injector.get<AuthBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BlocBuilder<AuthBloc, AuthState>(
      bloc: _bloc,
      builder: (context, state) => Text(state.user?.toString() ?? ''),
    ),
  );
}
