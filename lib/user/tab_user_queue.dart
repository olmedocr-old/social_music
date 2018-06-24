/*
Flexible(
          child: FirebaseAnimatedList(
            query: _nextReference,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              return new SizeTransition(
                  sizeFactor: animation,
                  child: Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          title: Text("$index: ${snapshot.value.toString()}"),
                          subtitle: Text("unnamed"),
                          leading: Image.network(
                            'https://orig00.deviantart.net/e3c6/f/2016/248/3/a/mo___final_song__single__by_musiceverywere-dagl7kw.jpg',
                            width: 64.0,
                          ),
                        ),
                        ButtonTheme.bar(
                          child: new ButtonBar(
                            children: <Widget>[
                              IconButton(
                                icon: new Icon(Icons.favorite_border),
                                onPressed: () {
                                  /* ... */
                                },
                              ),
                              new FlatButton(
                                child: const Text('LISTEN'),
                                onPressed: () {
                                  /* ... */
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          ),



           _nextSubscription = _nextReference.onValue.listen((Event event) {
      setState(() {});
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        print(error);
      });
    });

        _nextReference = widget.database.reference().child("admin-email/next");

 */