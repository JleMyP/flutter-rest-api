import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger_flutter/logger_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

import '../models/imported_resource.dart';
import '../repos/imported_resources.dart';
import '../repos/user.dart';
import '../utils/dialogs.dart';
import '../utils/paginators.dart';


class SelectedScreenStore with ChangeNotifier {
  int _screen = 0;

  int get screen => _screen;
  set screen(int val) {
    _screen = val;
    notifyListeners();
  }
}


class HomePage extends StatelessWidget {
  final _sideMenuKey = GlobalKey<SideMenuState>();
  final _bodyKey = GlobalKey<BodyState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _exit(context),
      child: ChangeNotifierProvider<SelectedScreenStore>(
        create: (context) => SelectedScreenStore(),
        child: SideMenu(
          background: Theme.of(context).dialogBackgroundColor,
          key: _sideMenuKey,
          type: SideMenuType.slideNRotate,
          menu: LeftMenu(),
          child: Scaffold(
            appBar: AppBar(
              title: Text('Дом'),
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  final _state = _sideMenuKey.currentState;

                  if (_state.isOpened) {
                    _state.closeSideMenu();
                  } else {
                    _state.openSideMenu();
                  }
                },
              ),
            ),
            body: SafeArea(
              child: Body(_bodyKey),
            ),
            bottomNavigationBar: ConvexBottomBar(), // BottomBar(),
            floatingActionButton: FloatingButton(),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            // TODO: не рендерить консольку в release mode или по флагам
            endDrawer: LogConsole(dark: true, showCloseButton: true),
          ),
        ),
      ),
    );
  }

  _exit(BuildContext context) async {
    return await showConfirmDialog(context, 'Выйти?', null);
  }
}


class LeftMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserRepo>().currentUser;
    var theme = Theme.of(context);

    return ListView(
      children: [
        GestureDetector(
          onTap: () => _profile(context),
          child: UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.transparent),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.primaryColor,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.backgroundColor,
              ),
            ),
            accountName: Text(user.shortName),
            accountEmail: Text(user.email ?? ''),
          ),
        ),
        ListTile(
          leading: Icon(Icons.help_outline),
          title: Text('О программе'),
          onTap: () => _about(context),
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Выход'),
          onTap: () => _logout(context),
        ),
      ],
    );
  }

  _profile(BuildContext context) {
    Navigator.of(context).pushNamed('/profile');
  }

  _about(BuildContext context) {
    Navigator.of(context).pushNamed('/about');
  }

  _logout(BuildContext context) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove('auth:login');
    sharedPreferences.remove('auth:password');
    sharedPreferences.remove('auth:autoLogin');
    context.read<UserRepo>().logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}


class Body extends StatefulWidget {
  Body(Key key): super(key: key);

  @override
  BodyState createState() => BodyState();
}


class BodyState extends State<Body> {
  int _prevScreen;
  LimitOffsetPaginator<ImportedResourceRepo, ImportedResource> paginator;

  @override
  Widget build(BuildContext context) {
    var repo = context.watch<ImportedResourceRepo>();
    var screen = context.watch<SelectedScreenStore>().screen;

    if (repo != paginator?.repo) {
      if (paginator == null) {
        paginator = LimitOffsetPaginator.withRepo(repo);
      } else {
        paginator.setRepo(repo);
      }
    }

    if (screen != _prevScreen) {
      _changeScreen(screen);
      return Center(child: CircularProgressIndicator());
    }

    if (paginator.isEnd && paginator.items.isEmpty) {
      return Center(child: Text('ниче нету...'));
    }

    return RefreshIndicator(
      child: ListView.separated(
        itemCount: paginator.items.length + (paginator.isEnd ? 0 : 1),
        itemBuilder: _buildListItem,
        separatorBuilder: (context, index) => Divider(),
        shrinkWrap: true,
      ),
      onRefresh: _refresh,
    );
  }

  Widget _buildListItem(BuildContext context, int index) {
    if (index == paginator.items.length && !paginator.isEnd) {
      if (paginator.loadingIsFailed) {
        return Padding(
          padding: EdgeInsets.only(bottom: 15, top: 10),
          child: Column(
            children: [
              Text('Шот не удалось...'),
              RaisedButton(
                child: Text('Повторить'),
                onPressed: () {
                  paginator.loadingIsFailed = false;
                  setState(() {});
                },
              )
            ],
          ),
        );
      }

      _fetchNext();
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 15, top: 10),
          child: CircularProgressIndicator(),
        ),
      );
    }

    var item = paginator.items[index];
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      child: ListTile(
        // leading: Text((index + 1).toString()),
        title: Text(item.name),
        trailing: IconButton(
          icon: Icon(Icons.do_not_disturb_on),
          onPressed: () {},
        ),
        onTap: () {},
      ),
      actions: [
        IconSlideAction(
          caption: 'Создать \nресурс',
          color: Colors.green,
          icon: Icons.add,
          onTap: () {},
        ),
        IconSlideAction(
          caption: 'Изменить',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {},
        ),
        IconSlideAction(
          caption: 'Удалить',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {},
        ),
      ],
    );
  }

  _changeScreen(int index) async {
    if (index == 0) {
      paginator.setParams(null);
    } else if (index == 1) {
      paginator.setParams({'is_ignored': true});
    } else if (index == 2) {
      paginator.setParams({'is_ignored': false});
    } else {
      return;
    }

    _prevScreen = index;
    await _fetchNext();
  }

  _fetchNext() async {
    await paginator.fetchNext();
    setState(() {});
  }

  Future _refresh() async {
    await _changeScreen(_prevScreen);
  }
}


class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var iconColor = Theme.of(context).primaryColor;
    var screen = context.watch<SelectedScreenStore>();

    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      selectedItemColor: iconColor,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Все'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Игнор'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Не игнор'),
      ],
      currentIndex: screen.screen,
      onTap: (index) => _onItemTapped(screen, index),
    );
  }

  _onItemTapped(SelectedScreenStore screen, int newIndex) {
    if (screen.screen == newIndex) {
      return;
    }
    screen.screen = newIndex;
  }
}


class ConvexBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var screen = context.watch<SelectedScreenStore>();

    return ConvexAppBar(
      style: TabStyle.reactCircle,
      backgroundColor: theme.primaryColor,
      color: theme.backgroundColor,
      items: [
        TabItem(icon: Icons.home, title: 'Все'),
        TabItem(icon: Icons.map, title: 'Игнор'),
        TabItem(icon: Icons.add, title: 'Не игнор'),
      ],
      onTap: (i) => _onItemTapped(screen, i),
    );
  }

  _onItemTapped(SelectedScreenStore screen, int newIndex) {
    if (screen.screen == newIndex) {
      return;
    }
    screen.screen = newIndex;
  }
}


class FloatingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {},
    );
  }
}
