import 'package:flutter/material.dart';

import 'package:social_music/admin/tab_admin_settings.dart';

class AdminScreen extends StatefulWidget {
  AdminScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State createState() => AdminScreenState();
}

class AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Sessions", icon: Icon(Icons.settings_ethernet)),
              Tab(text: "Settings", icon: Icon(Icons.settings)),
            ],
          ),
          title: Text(widget.title),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Text('esto es el panel de administracion'),
            ),
            TabAdminSettings(),
          ],
        ),
      ),
    );
  }
}
