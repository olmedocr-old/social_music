class Session {
  String adminName;

  Session(this.adminName);

  Map<String, dynamic> toMap(){
      return {
        "adminName": adminName,
        "nextSongs": [
          {
            "test":"test"
          },
        ],
        "nowPlaying": [
          {
            "test":"test"
          },
        ],
      };
  }
}