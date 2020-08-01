class Youth {
  String city = "BeiJing";
}

mixin EngName {
  String englishName;
}

mixin NickName {
  String nickName;
}

mixin FullName {
  String fullName;
}

mixin Name {
  String workid;
  String englishName;
  String nickName;
  String fullName;
  bool recognized(String name) {
    if (workid == name ||
        englishName == name ||
        nickName == name ||
        fullName == name) {
      return true;
    }
    return false;
  }
}

mixin Capability {
  bool cook = false;
  bool design = true;
  bool sing = true;
  bool dance = true;
  bool shoot = false;
  bool write = true;
}

class Employee extends Youth with Name, Capability {
  Duration timespend;
  int earnedmoney;
}
