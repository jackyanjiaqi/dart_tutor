class BaseYouth {
  /// 可分配时间
  final Duration timespare;

  /// 城市生存开销
  final int cityspent;
  const BaseYouth(
      {this.timespare = const Duration(hours: 16), this.cityspent = 100});

  /// 依然不知道具体实现，目的是检测可以活在这个城市里的最低标准
  live() {
    print(toString());
  }

  @override
  String toString() {
    return 'timespare:${timespare},cityspent:${cityspent}';
  }
}

class BaseName {
  final String name;
  const BaseName(this.name);
  bool recognized(String name) {
    return (this.name == name);
  }
}

class Nickname extends BaseName {
  const Nickname(String name) : super(name);
}

class Fullname extends BaseName {
  const Fullname(String name) : super(name);
}

class Englishname extends BaseName {
  const Englishname(String name) : super(name);
}

class Workid extends BaseName {
  const Workid(String name) : super(name);
}

mixin Names {
  List<BaseName> get names;

  /// 可以从各种名字中去比较和识别
  bool recognized(BaseName bn) {
    return printWrapped(names.any((item) =>
        item.runtimeType == bn.runtimeType && item.recognized(bn.name)));
  }
}

class BaseSocial {
  final Duration timespend;

  /// 考察维度
  /// 一个幸福的人
  final int happiness;

  /// 一个健康活泼的人
  final int health;

  /// 一个心灵手巧的人
  final int skill;

  /// 一个努力奋斗实现价值的人
  final int extramoney;
  const BaseSocial(
      {this.timespend = const Duration(hours: 2),
      this.happiness = 0,
      this.skill = 0,
      this.extramoney = 0,
      this.health = 0});

  @override
  String toString() {
    return 'timespend:$timespend happiness:$happiness skill:$skill extramoney:$extramoney health:$health';
  }

  debug() {
    print(toString());
  }
}

class Cooking extends BaseSocial {
  const Cooking() : super(health: 70, skill: 20, extramoney: 30, happiness: 35);
}

class Dancing extends BaseSocial {
  const Dancing()
      : super(
            timespend: const Duration(hours: 4),
            health: 250,
            skill: 50,
            extramoney: -100,
            happiness: 200);
}

class Singing extends BaseSocial {
  const Singing()
      : super(health: 50, skill: 50, extramoney: -20, happiness: 100);
}

class Designing extends BaseSocial {
  const Designing()
      : super(skill: 250, extramoney: 100, happiness: 150, health: -50);
}

class Shooting extends BaseSocial {
  const Shooting()
      : super(health: 200, skill: 300, extramoney: -200, happiness: 250);
}

class Writing extends BaseSocial {
  const Writing() : super(health: -70, extramoney: 30, happiness: 100);
}

mixin Capabilities on BaseYouth {
  List<BaseSocial> get capabilities;

  /// 根据给定的能力范围获得可选的兴趣方向 可重复
  List<BaseSocial> addToSocial() {
    /// 算法解析：
    /// 1.以月为单位对已经存在的能力进行筛选获得列表返回，(外部调用，对所有返回值进行四项结算)
    /// 2.包含live方法调用迭代30次，对金钱单位结果进行累加，不对时间进行累加。
    /// 3.包含多个解时，有每日最优策略和月度最优策略。
  }
}

class EmployeeKind extends BaseYouth with Capabilities, Names {
  final int earnedmoney;
  final List<BaseName> names;
  final List<BaseSocial> capabilities;
  EmployeeKind(
      {int cityspent,
      this.names,
      this.capabilities,
      Duration timespare = const Duration(hours: 8),
      this.earnedmoney = 300})
      : super(timespare: timespare, cityspent: cityspent);
}

void main() {
  EmployeeKind(names: [
    Nickname("果酱V"),
    Workid("F117007"),
    Fullname("闫佳奇"),
    Englishname("杰克")
  ], capabilities: [
    Singing(),
    Dancing(),
    Writing(),
    Designing()
  ], earnedmoney: 800, timespare: Duration(hours: 8), cityspent: 100)
    ..recognized(const Nickname("闫佳奇"))
    ..recognized(const Workid("果酱V"))
    ..recognized(const Englishname("杰克"))
    ..recognized(const Englishname("杰瑞"));
}

printWrapped(everything) {
  print(everything);
  return everything;
}
