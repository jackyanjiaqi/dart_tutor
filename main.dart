import 'dart:math';

abstract class Human {
  /// 体力值
  int power;
  Human(this.power);

  /// 消耗体力值与他人互动，产生影响值
  int act([List<Human> others]);

  /// 休息恢复体力，因为仅关注自身，对周围的影响值为0
  int restore() {
    print('${this.runtimeType}恢复体力5:防御0');
    power += 5;
    return 0;
  }

  /// 死亡
  died() {
    print('${this.runtimeType}被击杀！！！');
  }
}

/// 【锋利:普通伤害】
mixin SharpDamage {
  /// 定义伤害
  int get length;

  /// 定义体力损失
  int get powerloss;

  /// 伤害检测，无实现体
  bool testKill(Human item);
}

/// 【刀锋:精英伤害】
mixin BladeDamage on Human {
  /// 高伤害 高消耗，数值固定
  int get length => 15;

  /// 体力损失高，数值固定
  int get powerloss => 10;

  /// 伤害检测，根据对手act的执行结果(相当于回合外防御)结算伤害
  bool testKill(Human item) {
    if (power - powerloss > 0) {
      power -= powerloss;
      if (item.act() < length) {
        print("${this.runtimeType}造成击杀");
        return true;
      }
      print("${this.runtimeType}未造成击杀");
    }
    return false;
  }
}

/// 【范围伤害】
mixin RangeDamage on Human {
  /// 伤害待定，由混入类定义
  int get length;

  /// 体力损失中等
  int get powerloss => 7;

  /// 伤害检测，根据对手act的执行结果(相当于回合外防御)结算伤害
  bool testKill(List<Human> items) {
    if (power - powerloss > 0) {
      power -= powerloss;
      var ret = items.any((item) => item.act() < length);
      if (ret) {
        print("${this.runtimeType}造成击杀");
      } else {
        print("${this.runtimeType}未造成击杀");
      }
      return ret;
    }
    return false;
  }
}

/// 有成长体系的普通杀手
class SharpKiller with SharpDamage implements Human {
  @override
  int power;
  @override
  int get length => level * 3;
  @override
  int get powerloss => level * 2;

  /// 成长等级
  int level = 1;
  SharpKiller(this.power);

  @override
  int act([List<Human> others]) {
    if (others == null) {
      return restore();
    } else {
      var enemy = others[0];
      if (testKill(enemy)) {
        /// 击杀成功 等级提升
        ++level;
        enemy.died();
      }
    }
  }

  /// 恢复数值根据等级来 2、4、6、8..达到3级以上超过其他人
  /// 恢复时具有反击能力，根据等级分别是1、2、3、4、5..
  /// 达到5级以上能躲够避群体伤害
  @override
  int restore() {
    print('${this.runtimeType}恢复体力${level * 2}:防御$level');
    return level;
  }

  /// 根据等级来进行消耗和伤害输出
  /// 输出：3、6、9、12、15... 达到5级等同于精英伤害
  /// 消耗：2、4、6、8、10... 相比于精英的消耗更加灵活
  @override
  bool testKill(Human other) {
    if (power - powerloss > 0) {
      power -= powerloss;
      if (other.act() < length) {
        print("${this.runtimeType}造成击杀");
        return true;
      }
      print("${this.runtimeType}未造成击杀");
    }
    return false;
  }

  @override
  died() {
    print('${this.runtimeType}被击杀！！！');
  }
}

/// 从普通杀手成长起来的精英杀手，具有普通杀手的能力以及精英杀手的数值。
class SeniorSharpBladeKiller extends SharpKiller with BladeDamage {
  SeniorSharpBladeKiller(int power) : super(power);
}

/// 天才型精英杀手，直接通过Mixin获得能力
class BladeKiller extends Human with BladeDamage, SharpDamage {
  BladeKiller(int power) : super(power);
  @override
  int act([List<Human> others]) {
    if (others == null) {
      return restore();
    } else {
      var enemy = others[0];
      if (testKill(enemy)) {
        enemy.died();
      }
    }
  }
}

class Bomber extends Human with RangeDamage {
  int length;
  Bomber(int power, {this.length}) : super(power);
  @override
  int act([List<Human> others]) {
    if (others == null) {
      return restore();
    } else {
      var enemy = others[0];
      if (testKill(others)) {
        enemy.died();
      }
    }
  }
}

void main() {
  var alience = [
    BladeKiller(20),
    SeniorSharpBladeKiller(20),
    SharpKiller(20),
    SharpKiller(20),
    SharpKiller(20)
  ];
  var enemy = [
    Bomber(20, length: 12),
    Bomber(20, length: 10),
    Bomber(20, length: 2),
    Bomber(20, length: 6),
    Bomber(20, length: 4)
  ];
  battle('第一场战斗', alience, enemy);
  battle('第二场战斗', alience, enemy);
  battle('第三场战斗', alience, enemy);

  // var rng = new Random();
  // for (var i = 0; i < 10; i++) {
  //   print(rng.nextInt(100));
  // }
}

/// 回合战斗
/// A选择一名战士面对B行动
/// 之后
/// B选择一名战士面对A行动
void battle(title, List<Human> a, List<Human> b) {
  print('\n$title');
  a
    ..shuffle(Random(Random().nextInt(10000)))
    ..[0].act(b);
  b
    ..shuffle(Random(Random().nextInt(10000)))
    ..[0].act(a);
  print('\n');
}
