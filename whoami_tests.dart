import 'whoami_part2.dart';

/// 测试用，非教学演示内容
///
class NameTest with Names {
  final List<BaseName> names;
  NameTest({this.names});
}

class CapabilityTest extends BaseYouth with Capabilities {
  final List<BaseSocial> capabilities;
  CapabilityTest({this.capabilities});
}

class CapabilityNameTest extends BaseYouth with Capabilities, Names {
  final int earnedmoney;
  final List<BaseSocial> capabilities;
  final List<BaseName> names;
  CapabilityNameTest(
      {cityspent,
      timespare = const Duration(hours: 8),
      this.names,
      this.capabilities,
      this.earnedmoney = 300})
      : super(timespare: timespare, cityspent: cityspent);
}

void main() {
  BaseYouth().live();
  Nickname('Jack').recognized('Jack');
  Fullname('闫佳奇').recognized('闫');
  Workid('F117911').recognized('F117911');
  Englishname('JackYan').recognized('Ja Y');
  print('——————————————');
  NameTest(names: [
    Nickname('Jack'),
    Fullname('闫佳奇'),
    Workid('F117911'),
    Englishname('JackYan')
  ])
    ..recognized(Nickname('Jack'))
    ..recognized(Nickname('JackYan'))
    ..recognized(Workid('F117910'));
  print('——————————————');
  Cooking().debug();
  Singing().debug();
  Dancing().debug();
  Shooting().debug();
  Writing().debug();
  Designing().debug();
  CapabilityTest(capabilities: [Singing(), Dancing(), Writing(), Designing()])
      .live();
  CapabilityNameTest(names: [
    Nickname('Jack'),
    Fullname('闫佳奇'),
    Workid('F117911'),
    Englishname('JackYan')
  ], capabilities: [
    Singing(),
    Dancing(),
    Writing(),
    Designing()
  ], earnedmoney: 800);
}
