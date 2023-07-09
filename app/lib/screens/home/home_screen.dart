import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/services/injector.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  static const routePath = '/';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => BlocProvider<UserBloc>(
    create: (_) => injector.get<UserBloc>(),
    child: const AutoRouter(),
  );
}
