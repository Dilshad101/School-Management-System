import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:school_management_system/shared/styles/app_styles.dart';

class NavBarScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const NavBarScreen({super.key, required this.navigationShell});

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  // static StatefulNavigationShell? _navShell;

  @override
  Widget build(BuildContext context) {
    // _navShell = navigationShell;

    return Scaffold(
      key: scaffoldKey,
      body: navigationShell,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onItemTapped(index, navigationShell, context),

          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/home.svg'),
              activeIcon: SvgPicture.asset('assets/icons/home_active.svg'),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/feature.svg'),
              activeIcon: SvgPicture.asset('assets/icons/feature_active.svg'),

              label: 'Features',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/chat.svg'),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/profile.svg'),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(
    int index,
    StatefulNavigationShell navigationShell,
    BuildContext context,
  ) {
    // if (index == 1) {
    //   final bloc = context.read<EnquiryBloc>();
    //   final type = bloc.state.type;
    //   bloc.add(GetEnquiries(type: type, reset: true));
    // } else if (index == 2) {
    //   final bloc = context.read<ReportBloc>();
    //   bloc.add(GetReportsEvent());
    // }
    // Use navigationShell.goBranch instead of GoRouter.of(context).go
    navigationShell.goBranch(
      index,
      // Navigate to the initial location if tapping the current tab
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
