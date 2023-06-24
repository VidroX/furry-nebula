import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/extensions/string_extension.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/auth/state/auth_bloc.dart';
import 'package:furry_nebula/screens/auth/widgets/auth_header.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/validators/api_error_validator.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/ui/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula_form_field.dart';
import 'package:furry_nebula/widgets/ui/nebula_logo.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routePath = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _bloc = injector.get<AuthBloc>();
  final _formKey = GlobalKey<FormState>();

  static const _emailFieldName = 'email';
  static const _passwordFieldName = 'password';

  String? _email;
  String? _password;

  bool get isFilled => _email != null && _password != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ScreenLayout(
    scrollable: true,
    child: BlocBuilder<AuthBloc, AuthState>(
      bloc: _bloc,
      builder: (context, state) => Padding(
        padding: const EdgeInsets.only(top: 64),
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: NebulaLogo(),
              ),
              const SizedBox(height: 24),
              AuthHeader(
                title: context.translate(Translations.authSignIn).tryCapitalize,
              ),
              const SizedBox(height: 12),
              NebulaFormField(
                autovalidateMode: AutovalidateMode.always,
                label: context.translate(Translations.authEnterEmail),
                validator: ApiErrorValidator(
                  validationErrors: state.validationErrors,
                  fieldName: _emailFieldName,
                ).validate,
                onChanged: (value) {
                  _bloc.add(const AuthEvent.clearValidationErrors(
                    field: _emailFieldName,
                  ),);
                  setState(() => _email = value);
                },
              ),
              const SizedBox(height: 12),
              NebulaFormField(
                autovalidateMode: AutovalidateMode.always,
                label: context.translate(Translations.authEnterPassword),
                obscureText: true,
                validator: ApiErrorValidator(
                  validationErrors: state.validationErrors,
                  fieldName: _passwordFieldName,
                ).validate,
                onChanged: (value) {
                  _bloc.add(const AuthEvent.clearValidationErrors(
                    field: _passwordFieldName,
                  ),);
                  setState(() => _password = value);
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: NebulaButton(
                  loading: state.isLoading,
                  text: context.translate(Translations.authSignIn),
                  onPress: () => _onLoginPressed(state),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  void _onLoginPressed(AuthState state) {
    _bloc.add(
      AuthEvent.login(
        email: _email ?? '',
        password: _password ?? '',
        onSuccess: () => context.replaceRoute(const HomeRoute()),
        onError: (e) {
          _formKey.currentState?.validate();

          if (e is RequestFailedException) {
            Fluttertoast.showToast(msg: context.translate(e.message));
          }
        },
      ),
    );
  }
}
