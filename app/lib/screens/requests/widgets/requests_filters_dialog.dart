import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_filters.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_checkbox.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_link.dart';

class RequestsFilterDialog extends StatefulWidget {
  final UserRequestsFilters currentFilters;

  const RequestsFilterDialog({
    this.currentFilters = const UserRequestsFilters(),
    super.key,
  });

  @override
  State<RequestsFilterDialog> createState() => _RequestsFilterDialogState();
}

class _RequestsFilterDialogState extends State<RequestsFilterDialog> {
  final _bloc = injector.get<UserBloc>();
  final _formKey = GlobalKey<FormState>();

  late UserRequestsFilters _filters = widget.currentFilters;

  @override
  Widget build(BuildContext context) => BlocBuilder<UserBloc, UserState>(
    bloc: _bloc,
    builder: (context, state) => Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.hasRole(UserRole.shelter))
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: NebulaCheckbox(
                title: context.translate(Translations.userRequestShowOwnRequests),
                value: _filters.showOwnRequests,
                onChanged: _onShowOwnRequestsChanged,
              ),
            ),
          NebulaCheckbox(
            title: context.translate(Translations.userRequestShowApproved),
            value: _filters.isApproved,
            onChanged: _onIsApprovedChanged,
          ),
          const SizedBox(height: 12),
          NebulaCheckbox(
            title: context.translate(Translations.userRequestShowReviewed),
            value: _filters.isReviewed,
            onChanged: _onIsReviewedChanged,
          ),
          const SizedBox(height: 16),
          NebulaLink(
            text: context.translate(Translations.clearFilters),
            onTap: _clearFilters,
          ),
          const SizedBox(height: 12),
          NebulaButton.fill(
            text:context.translate(Translations.apply),
            onPress: _apply,
          ),
        ],
      ),
    ),
  );

  void _clearFilters() {
    setState(() {
      _filters = const UserRequestsFilters();
    });
  }

  void _onIsApprovedChanged(bool? newState) {
    setState(() {
      _filters = _filters.copyWith(
        isApproved: newState,
      );
    });
  }

  void _onIsReviewedChanged(bool? newState) {
    setState(() {
      _filters = _filters.copyWith(
        isReviewed: newState,
      );
    });
  }

  void _onShowOwnRequestsChanged(bool? newState) {
    setState(() {
      _filters = _filters.copyWith(
        showOwnRequests: newState,
      );
    });
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.popRoute<UserRequestsFilters>(_filters);
  }
}
