import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_bloc.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_filters.dart';
import 'package:furry_nebula/screens/requests/widgets/requests_filters_dialog.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/dialog_layout.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_api_list.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_text.dart';

@RoutePage()
class RequestsScreen extends StatefulWidget {
  static const routePath = 'requests';

  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  var _key = GlobalKey<NebulaApiListState>();
  final _bloc = injector.get<UserRequestsBloc>();

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();

    _bloc.add(UserRequestsEvent.getRequests(
      onSuccess: (_) => _firstLoad = false,
      onError: context.showApiError,
    ),);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScreenLayout(
    padding: EdgeInsets.zero,
    child: BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) => BlocBuilder<UserRequestsBloc, UserRequestsState>(
        bloc: _bloc,
        builder: (context, state) => NebulaApiList<UserRequest>(
          key: _key,
          padding: const EdgeInsets.all(16),
          items: state.userRequests,
          pageInfo: state.pageInfo,
          loading: _firstLoad,
          itemsLoading: _firstLoad || state.isLoading,
          onRefresh: () {
            _fetchUserRequests(rebuildList: true, filters: state.filters);

            return Future<bool>.value(state.isLoading);
          },
          headerBuilder: (context) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                NebulaCircularButton(
                  onPress: () => context.popRoute(),
                  buttonStyle: NebulaCircularButtonStyle.clear(context),
                  child: const FaIcon(
                    FontAwesomeIcons.arrowLeftLong,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NebulaText(
                    context.translate(Translations.userRequestTitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography
                        .withFontWeight(FontWeight.w600)
                        .withFontSize(AppFontSize.extraLarge),
                  ),
                ),
                const SizedBox(width: 12),
                NebulaCircularButton(
                  buttonStyle: NebulaCircularButtonStyle.clear(context),
                  onPress: () => _showFiltersDialog(state.filters),
                  padding: EdgeInsets.zero,
                  child: FaIcon(
                    FontAwesomeIcons.filter,
                    size: 20,
                    color: context.colors.text,
                  ),
                ),
              ],
            ),
          ),
          noItemsBuilder: (context) => NotFound(
            title: userState.hasRole(UserRole.shelter)
                ? state.filters.isEmpty
                  ? context.translate(Translations.userRequestErrorsNoRequests)
                  : context.translate(Translations.userRequestErrorsNoRequestsFiltered)
                : context.translate(Translations.userRequestErrorsNoUserRequests),
            icon: FontAwesomeIcons.solidFaceSadTear,
            onRefreshPress: () =>
                _fetchUserRequests(rebuildList: true, filters: state.filters),
          ),
          onLoadNextPage: _loadNextPage,
          itemBuilder: (context, item, index) => Padding(
            padding: index + 1 < state.userRequests.length
                ? const EdgeInsets.only(bottom: 16)
                : EdgeInsets.zero,
            child: NebulaText(item.animal.name),
          ),
        ),
      ),
    ),
  );

  void _fetchUserRequests({ bool rebuildList = false, UserRequestsFilters? filters }) {
    if (rebuildList) {
      setState(() {
        _key = GlobalKey();
        _firstLoad = true;
      });
    }

    _bloc.add(UserRequestsEvent.getRequests(
      clearFetch: rebuildList,
      filters: filters,
      onSuccess: (_) {
        setState(() {
          _firstLoad = false;
        });
      },
      onError: context.showApiError,
    ),);
  }

  void _loadNextPage() {
    _bloc.add(UserRequestsEvent.nextPage(
      onError: context.showApiError,
    ),);
  }

  Future<void> _showFiltersDialog(UserRequestsFilters currentFilters) async {
    if (!mounted) {
      return;
    }

    final filters = await showNebulaDialog<UserRequestsFilters>(
      context: context,
      title: context.translate(Translations.filters),
      child: RequestsFilterDialog(currentFilters: currentFilters),
    );

    if (!mounted || filters == null) {
      return;
    }

    _fetchUserRequests(rebuildList: true, filters: filters);
  }
}
