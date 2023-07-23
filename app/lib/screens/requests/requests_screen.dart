import 'package:animations/animations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/extensions/datetime_extensions.dart';
import 'package:furry_nebula/models/shelter/user_request.dart';
import 'package:furry_nebula/models/shelter/user_request_status.dart';
import 'package:furry_nebula/models/shelter/user_request_type.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/models/user/user_role.dart';
import 'package:furry_nebula/screens/home/state/user_bloc.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_bloc.dart';
import 'package:furry_nebula/screens/requests/state/user_requests_filters.dart';
import 'package:furry_nebula/screens/requests/widgets/request_details.dart';
import 'package:furry_nebula/screens/requests/widgets/requests_filters_dialog.dart';
import 'package:furry_nebula/screens/requests/widgets/user_request_status_chip.dart';
import 'package:furry_nebula/screens/requests/widgets/user_request_type_chip.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/layout/dialog_layout.dart';
import 'package:furry_nebula/widgets/layout/screen_layout.dart';
import 'package:furry_nebula/widgets/not_found.dart';
import 'package:furry_nebula/widgets/ui/loading_barrier.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_api_list.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula/nebula_notification.dart';
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
        builder: (context, state) => LoadingBarrier(
          loading: state.isChangingStatus,
          title: context.translate(Translations.userRequestChangingRequestStatus),
          child: NebulaApiList<UserRequest>(
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
              child: _RequestItemContainer(
                item: item,
                currentUser: userState.user!,
                onApprove: () => _onApprove(item, state.filters),
                onDeny: () => _onDeny(item, state.filters),
                onCancel: () => _onCancel(item, state.filters),
                onReturn: () => _onReturn(item, state.filters),
              ),
            ),
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

  void _onApprove(UserRequest item, UserRequestsFilters currentFilters) {
    context.popRoute();

    _bloc.add(
      UserRequestsEvent.changeRequestStatus(
        requestId: item.id,
        status: UserRequestStatus.approved,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.userRequestRequestApproved,
              ),
            ),
          );

          _fetchUserRequests(rebuildList: true, filters: currentFilters);
        },
        onError: context.showApiError,
      ),
    );
  }

  void _onDeny(UserRequest item, UserRequestsFilters currentFilters) {
    context.popRoute();

    _bloc.add(
      UserRequestsEvent.changeRequestStatus(
        requestId: item.id,
        status: UserRequestStatus.denied,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.userRequestRequestDenied,
              ),
            ),
          );

          _fetchUserRequests(rebuildList: true, filters: currentFilters);
        },
        onError: context.showApiError,
      ),
    );
  }

  void _onCancel(UserRequest item, UserRequestsFilters currentFilters) {
    context.popRoute();

    _bloc.add(
      UserRequestsEvent.cancelRequest(
        requestId: item.id,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.userRequestRequestCancelled,
              ),
            ),
          );

          _fetchUserRequests(rebuildList: true, filters: currentFilters);
        },
        onError: context.showApiError,
      ),
    );
  }

  void _onReturn(UserRequest item, UserRequestsFilters currentFilters) {
    context.popRoute();

    _bloc.add(
      UserRequestsEvent.changeRequestStatus(
        requestId: item.id,
        status: UserRequestStatus.fulfilled,
        onSuccess: () {
          context.showNotification(
            NebulaNotification.primary(
              title: context.translate(Translations.info),
              description: context.translate(
                Translations.userRequestAnimalReturnedSuccessfully,
              ),
            ),
          );

          _fetchUserRequests(rebuildList: true, filters: currentFilters);
        },
        onError: context.showApiError,
      ),
    );
  }
}

class _RequestItemContainer extends StatelessWidget {
  final User currentUser;
  final UserRequest item;
  final VoidCallback? onApprove;
  final VoidCallback? onDeny;
  final VoidCallback? onCancel;
  final VoidCallback? onReturn;

  const _RequestItemContainer({
    required this.item,
    required this.currentUser,
    this.onApprove,
    this.onDeny,
    this.onCancel,
    this.onReturn,
    super.key,
  });

  @override
  Widget build(BuildContext context) => OpenContainer(
    transitionDuration: const Duration(milliseconds: 450),
    closedColor: context.colors.containerColor,
    openColor: context.colors.backgroundColor,
    openBuilder: (context, _) => RequestDetails(
      request: item,
      currentUser: currentUser,
      onApprove: onApprove,
      onDeny: onDeny,
      onCancel: onCancel,
      onReturn: onReturn,
    ),
    closedBuilder: (context, _) => Container(
      decoration: BoxDecoration(
        color: context.colors.containerColor,
      ),
      padding: const EdgeInsetsDirectional.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: NebulaText(
                  item.animal.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography
                      .withFontWeight(FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              UserRequestStatusChip(
                requestStatus: item.requestStatus,
              ),
              const SizedBox(width: 4),
              UserRequestTypeChip(
                requestType: item.requestType,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 14,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    color: context.colors.hint,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              NebulaText(
                item.user.fullName,
                style: context.typography
                    .withColor(context.colors.hint)
                    .withFontSize(AppFontSize.extraSmall),
              ),
            ],
          ),
          if (item.requestType == UserRequestType.accommodation
              && item.fromDate != null
              && item.toDate != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.solidCalendar,
                        color: context.colors.hint,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: item.fromDate!.formatToYearMonthDay,
                        ),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        const TextSpan(text: '—'),
                        const WidgetSpan(child: SizedBox(width: 4)),
                        TextSpan(
                          text: item.toDate!.formatToYearMonthDay,
                        ),
                      ],
                      style: context.typography
                          .withFontSize(AppFontSize.extraSmall)
                          .withColor(context.colors.hint)
                          .toTextStyle(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
