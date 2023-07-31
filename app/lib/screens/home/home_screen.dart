import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final _bloc = injector.get<UserBloc>();

  @override
  void initState() {
    FirebaseMessaging.instance.getToken().then((token) {
      log("Received FCM token: $token");
      if (token != null) {
        _bloc.add(UserEvent.updateFCMToken(token: token));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<UserBloc>(
    create: (_) => _bloc,
    child: const AutoRouter(),
  );
}
