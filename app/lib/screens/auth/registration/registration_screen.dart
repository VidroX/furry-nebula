import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/extensions/string_extension.dart';
import 'package:furry_nebula/models/user/user_registration_role.dart';
import 'package:furry_nebula/router/router.gr.dart';
import 'package:furry_nebula/screens/auth/state/auth_bloc.dart';
import 'package:furry_nebula/screens/auth/widgets/auth_header.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/validators/api_error_validator.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_datepicker_field.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_form_field.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_logo.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_notification.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_password_field.dart';

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
  final _bloc = injector.get<AuthBloc>();
  final _formKey = GlobalKey<FormState>();

  static const _emailFieldName = 'email';
  static const _passwordFieldName = 'password';
  static const _firstNameFieldName = 'firstname';
  static const _lastNameFieldName = 'lastname';
  static const _aboutFieldName = 'about';
  static const _birthDayFieldName = 'birthday';

  String? _email;
  String? _password;
  String? _firstName;
  String? _lastName;
  String? _about;
  DateTime? _birthday;

  bool get isFilled => _email != null && _password != null;

  @override
  Widget build(BuildContext context) => ScreenLayout(
    scrollable: true,
    child: BlocBuilder<AuthBloc, AuthState>(
      bloc: _bloc,
      builder: (context, state) => Form(
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
              title: widget.isShelterRep
                  ? context
                  .translate(Translations.authShelterRepresentativeSignUp)
                  : context.translate(Translations.authSignUp).tryCapitalize,
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
            NebulaPasswordField(
              autovalidateMode: AutovalidateMode.always,
              label: context.translate(Translations.authEnterPassword),
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
            const SizedBox(height: 12),
            NebulaFormField(
              autovalidateMode: AutovalidateMode.always,
              label: context.translate(Translations.authEnterFirstName),
              validator: ApiErrorValidator(
                validationErrors: state.validationErrors,
                fieldName: _firstNameFieldName,
              ).validate,
              onChanged: (value) {
                _bloc.add(const AuthEvent.clearValidationErrors(
                  field: _firstNameFieldName,
                ),);
                setState(() => _firstName = value);
              },
            ),
            const SizedBox(height: 12),
            NebulaFormField(
              autovalidateMode: AutovalidateMode.always,
              label: context.translate(Translations.authEnterLastName),
              validator: ApiErrorValidator(
                validationErrors: state.validationErrors,
                fieldName: _lastNameFieldName,
              ).validate,
              onChanged: (value) {
                _bloc.add(const AuthEvent.clearValidationErrors(
                  field: _lastNameFieldName,
                ),);
                setState(() => _lastName = value);
              },
            ),
            const SizedBox(height: 12),
            NebulaDatePickerField(
              autovalidateMode: AutovalidateMode.always,
              label: context.translate(Translations.authProvideBirthday),
              validator: ApiErrorValidator(
                validationErrors: state.validationErrors,
                fieldName: _birthDayFieldName,
              ).validate,
              onDateSelected: (date) {
                _bloc.add(const AuthEvent.clearValidationErrors(
                  field: _birthDayFieldName,
                ),);
                setState(() => _birthday = date);
              },
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 12),
            NebulaFormField(
              autovalidateMode: AutovalidateMode.always,
              label: context
                  .translate(Translations.authProvideInfoAboutYourself),
              validator: ApiErrorValidator(
                validationErrors: state.validationErrors,
                fieldName: _aboutFieldName,
              ).validate,
              maxLines: 3,
              onChanged: (value) {
                _bloc.add(const AuthEvent.clearValidationErrors(
                  field: _aboutFieldName,
                ),);
                setState(() => _about = value);
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: NebulaButton(
                loading: state.isLoading,
                text: context.translate(Translations.authSignUp),
                onPress: () => _onSignUpPressed(state),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  void _onSignUpPressed(AuthState state) {
    FocusScope.of(context).unfocus();

    _bloc.add(
      AuthEvent.register(
        email: _email ?? '',
        password: _password ?? '',
        firstName: _firstName ?? '',
        lastName: _lastName ?? '',
        about: _about ?? '',
        birthDay: _birthday ?? DateTime.now(),
        role: widget.isShelterRep
            ? UserRegistrationRole.shelter
            : UserRegistrationRole.user,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                widget.isShelterRep
                    ? Translations.authSuccessfulShelterRepRegistration
                    : Translations.authSuccessfulRegistration,
              ),
            ),
          );

          context.replaceRoute(const HomeRoute());
        },
        onError: (e) {
          _formKey.currentState?.validate();

          context.showApiError(e);
        },
      ),
    );
  }
}
