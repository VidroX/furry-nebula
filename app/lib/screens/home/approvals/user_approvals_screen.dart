import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furry_nebula/extensions/context_extensions.dart';
import 'package:furry_nebula/graphql/exceptions/request_failed_exception.dart';
import 'package:furry_nebula/models/user/user.dart';
import 'package:furry_nebula/screens/home/approvals/state/user_approvals_bloc.dart';
import 'package:furry_nebula/services/injector.dart';
import 'package:furry_nebula/translations.dart';
import 'package:furry_nebula/widgets/ui/nebula_api_list.dart';
import 'package:furry_nebula/widgets/ui/nebula_circular_button.dart';
import 'package:furry_nebula/widgets/ui/nebula_notification.dart';
import 'package:furry_nebula/widgets/ui/nebula_text.dart';
import 'package:furry_nebula/widgets/ui/neumorphic_container.dart';

@RoutePage()
class UserApprovalsScreen extends StatefulWidget {
  static const routePath = 'approvals/user';

  const UserApprovalsScreen({super.key});

  @override
  State<UserApprovalsScreen> createState() => _UserApprovalsScreenState();
}

class _UserApprovalsScreenState extends State<UserApprovalsScreen> {
  final _key = GlobalKey<NebulaApiListState>();
  final _bloc = injector.get<UserApprovalsBloc>();

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();

    _bloc.add(UserApprovalsEvent.getUnapprovedUsers(
      onSuccess: (_) => _firstLoad = false,
      onError: (e) {
        if (e is RequestFailedException) {
          context.showNotification(
            NebulaNotification.error(
              title: context.translate(Translations.error),
              description: context.translate(e.message),
            ),
          );
        }
      },
    ),);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<UserApprovalsBloc, UserApprovalsState>(
    bloc: _bloc,
    builder: (context, state) => NebulaApiList<User>(
      key: _key,
      padding: const EdgeInsets.all(16),
      items: state.userApprovals,
      pageInfo: state.pageInfo,
      itemsLoading: _firstLoad || state.isLoading,
      onItemRemoved: (user, index) =>
          _bloc.add(UserApprovalsEvent.removeUser(userId: user.id)),
      headerBuilder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: NebulaText(
          context.translate(Translations.userApprovalsUsersPendingApproval),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.typography
              .withFontWeight(FontWeight.w600)
              .withFontSize(AppFontSize.extraLarge),
        ),
      ),
      noItemsBuilder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.usersRays,
              size: 128,
              color: context.colors.hint,
            ),
            const SizedBox(height: 32),
            NebulaText(
              context.translate(
                Translations.userApprovalsUsersNoUsersPendingApproval,
              ),
              maxLines: 3,
              textAlign: TextAlign.center,
              style: context.typography
                  .withFontWeight(FontWeight.w500)
                  .withFontSize(AppFontSize.extraNormal)
                  .withColor(context.colors.hint),
            ),
          ],
        ),
      ),
      onLoadNextPage: _loadNextPage,
      itemBuilder: (context, item, index) => Padding(
        padding: index + 1 < state.userApprovals.length
            ? const EdgeInsets.only(bottom: 16)
            : EdgeInsets.zero,
        child: _ApprovalItem(
          user: item,
          pendingApprovalUsers: state.pendingApprovalUsers,
          pendingRejectionUsers: state.pendingRejectionUsers,
          onApprove: (user) => _onUserApprove(user, state.userApprovals),
          onReject: (user) => _onUserReject(user, state.userApprovals),
        ),
      ),
    ),
  );

  void _loadNextPage() {
    _bloc.add(UserApprovalsEvent.nextPage(
      onError: (e) {
        if (e is RequestFailedException) {
          context.showNotification(
            NebulaNotification.error(
              title: context.translate(Translations.error),
              description: context.translate(e.message),
            ),
          );
        }
      },
    ),);
  }

  void _onUserApprove(User user, List<User> userApprovals) {
    _bloc.add(
      UserApprovalsEvent.changeUserStatus(
        user: user,
        isApproved: true,
        onSuccess: () =>
            _key.currentState?.removeItem(userApprovals.indexOf(user)),
      ),
    );
  }

  void _onUserReject(User user, List<User> userApprovals) {
    _bloc.add(
      UserApprovalsEvent.changeUserStatus(
        user: user,
        onSuccess: () =>
            _key.currentState?.removeItem(userApprovals.indexOf(user)),
      ),
    );
  }
}

class _ApprovalItem extends StatelessWidget {
  final User user;
  final List<User> pendingApprovalUsers;
  final List<User> pendingRejectionUsers;
  final Function(User user)? onApprove;
  final Function(User user)? onReject;

  const _ApprovalItem({
    required this.user,
    this.pendingApprovalUsers = const [],
    this.pendingRejectionUsers = const [],
    this.onApprove,
    this.onReject,
    super.key,
  });

  @override
  Widget build(BuildContext context) => NeumorphicContainer(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NebulaText(
                  user.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography
                      .withFontSize(AppFontSize.extraSmall)
                      .withColor(context.colors.hint),
                ),
                const SizedBox(height: 2),
                NebulaText(
                  user.fullName,
                  style: context.typography.withFontWeight(FontWeight.w500),
                ),
                const SizedBox(height: 6),
                NebulaText(
                  context.translate(
                    Translations.userApprovalsUsersWantsToBe,
                    params: {
                      "userType": context.translate(user.role.translationKey),
                    },
                  ),
                  style: context.typography
                      .withFontSize(AppFontSize.small),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              NebulaCircularButton(
                loading: pendingRejectionUsers.contains(user),
                onPress: () => onReject?.call(user),
                buttonStyle: NebulaCircularButtonStyle.outlinedError(context),
                child: FaIcon(
                  FontAwesomeIcons.thumbsDown,
                  size: 18,
                  color: context.colors.error,
                ),
              ),
              const SizedBox(width: 8),
              NebulaCircularButton(
                loading: pendingApprovalUsers.contains(user),
                onPress: () => onApprove?.call(user),
                buttonStyle: NebulaCircularButtonStyle.primary(context),
                child: FaIcon(
                  FontAwesomeIcons.thumbsUp,
                  size: 18,
                  color: context.colors.isLight
                      ? context.colors.text
                      : context.colors.alternativeText,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
