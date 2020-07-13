# Flutter指尖舞蹈：这个杀手不太冷——场景式学习Dart的多态和继承
刻意练习的第二节课我们来看看Flutter(Dart)里面涉及的继承和多态。
看过很多文章都无法准确理解Flutter中没有接口却又到处充斥着的隐形的接口概念，翻看Flutter源码发现组织解构跟Java代码也有显著区别，这和Flutter善用组合思想不无关系的，一旦代码规模庞大我们依然要依靠这些概念来管理代码，此处概念涉及的关键字还不少：

`class`、`extends`、`abstract`、`implements`、`mixin`、`with`、`on`、`super`、`this`
# 基础概念
## 概念1: 继承用extends 接口用implements
类继承的概念我们在C++、Java等面向对象的语言都学习过多次了，我们做个简单的复习。
```
// 抽象类有未实现的函数，只能被继承不能实例化
abstract class Father{
    doSomething();
}
// 子类继承父类并可以被实例化
class Child extends Father{
    @override
    doSomthing()=>print('I am the child');
}
```
    
相应地`super`调用父类的同名函数，`this`调用成员变量(存在同名时)指代自己，然而 Dart 中没有 `interface` 却独有的`implements`可以额外把`class`、`mixin` 的声明信息来复用，不论实现与否都统一看成是接口，巧妙就在于不设定重复概念，然而也着实让人容易混淆。

## 概念2: 可实例化内核class 华丽的衣裳mixin
class 可实例化意味着可以有构造函数，可以为空构造函数，则子类也可以默认为空构造函数，而 mixin 不可以，mixin只能通过与class 搭配使用`with`来混入。这是 class 和 mixin 最本质的区别。

所以对于没有内核的`mixin`中不能用`this`关键字，也不能用`super`而`on`刚好用来在定义的时候指定内核，但也仅仅是以接口的方式取得其声明信息供其调用，可以使用指定内核的公开变量和公开函数。

## 概念3: 重要的事说三遍**mixin的覆盖顺序**

使用 `mixin` 可以有两种方式，`implements` 和 `with`，作为`implements`时是完全当作接口来使用的，其实现总在内核class中，然而一旦使用`with`且`mixin`中还有内核的同名声明实现，则会造成强烈的覆盖隐患，该隐患极难排查，为此我们必须清楚其同名定义的覆盖顺序。

为此我们定义如下A B C D。
```
mixin C {
  String a = "this is C";
  log() {
    print('log called in C');
    print(a);
  }
}

mixin B {
  String a;
  log() {
    print('log called in B');
    a = "this is B";
    print(a);
  }
}

class D {
  String a;
  log() {
    print("this is log in D");
    print(a);
  }
}

class A extends D with C, B {
  String a = "this is A";
   log() {
     print("this is log in A");
     print(a);
   }
}
```
可以看到class A继承自class D，混入了C 和 B。他们都同时定义变量a和打印函数log并打印a
```
main() {
  A().log();
}
控制台输出：
log called in A
this is A
```
接着依次注释ABCD内声明和实现，调换A、D，B，C获得覆盖顺序如下：

> A->B->C->D

然而隐藏的坑点还没有结束，当修改class A只有部分成员变量的定义时，B中的隐式getter函数被A覆盖，这就导致了虽然B中的函数被调用，但是打印的值依然是A中的。
```
class A extends D with C, B {
  get a => "this is A";
  // log() {
  //   print("this is log in A");
  //   print(a);
  // }
}
...
控制台输出:
log called in B
this is A
```
即便B在很近的地方重新赋了值
```
...
mixin B {
  String a;
  log() {
    print('log called in B');
    a = "this is B";
    print(a);
...
```
其实C和D都是类似的情况，我们避开被覆盖的函数分别为其增加一个能被调用的函数logC 和logD来查看a的引用关系。
```
mixin C {
  ...
  logC() {
    print('logC called in C');
    print(a);
  }
}
class D {
  ...
  logD() {
    print("logD called in D");
    print(a);
  }
}
void main(){
    A()
    ..log()
    ..logC()
    ..logD();
}
控制台结果：
log called in B
this is A
logC called in C
this is A
logD called in D
this is A
```
其结果是一样的，那么如何在不修改A的情况下才能让B打印自身的值呢？
像我们对待D一样对待A，引入一个空的Amask
```
class Amask extends A with C, B {}
main(){
    Amask()
        ..log()
        ..logC()
        ..logD();
}
控制台：
log called in B
this is B
logC called in C
this is B
logD called in D
this is B
```
哈哈 是不是发现这时候才是B为所欲为的时候了。

实际上 mixin 提供了在子类和父类夹层中变更覆盖逻辑的机制，而又可以不受限制地在其孙子类和爷爷类继续累加，真可谓是千层饼干都不为过，但是你以为样例中的A很霸道么，A其实是持有的自己的状态，而B的本意也是使用A的状态，要不然B为什么不自己成为class呢？

而C仅仅是因为顺序问题，排在更后面就解决了，最憋屈的就是D了，自己的状态不能用，子类A继承之后竟然直接打印出了B，喂，我也是曾经的老大呀，太看不起我了吧。对于核心能力是管理自身状态的class来说这是不能忍受的。

所以综上，mixin 的使用切记 切记 切记：
```
不要在mixin里面定义和赋值变量，它会导致具有正统继承关系的变量定义变乱。

如果在实现的函数里需要引用混入的class变量，优先设置关键字on，或者避免被使用场景限制设置
set a;
get a;
这样的存取器定义，好处是如果混入的class没有定义的时候会提示增加其定义。
```
实际上混入这种特性正是对传统接口多态的继承。它对比接口多态具有更加灵活的组合策略。因为mixin中不仅仅有接口还有实现。

实际上在java时代笔者喜欢贯彻另一种组合思想，那就是父类的实现尽量原子化拆分到小函数，这些函数不对外提供调用但是对子类开放重载和组合调用，所以他们往往是protected，达成的效果是子类的实现可以看成是一种新的组合，非常灵活和易于理解。

然而这样的方式会导致父类(基类)成为各种实现的底层引擎，也丧失了其作为简单类型的灵活性。而 Dart中 `mixin` 关键字提供了一种更加灵活的方式，让你的组合不仅仅局限于同一个体系，例如Flutter中我们见了很多自成一派的 Mixin，他们往往跟UI无关，却不能独立运行，又具有可插拔配置简单的特性。
# 场景式练习
下面我们来用杀手不太冷这个小游戏场景来作为讲解，故事背景采用同名电影。
## 基础设定
设定Human(人类)为抽象基类，定义了基础体力值 *power* 来影响人类行为，因为人在休息时具有恢复行为，所以在基类中直接定义其实现：一次恢复增加5点体力。。
```
abstract class Human {
  /// 体力值
  int power;
  Human(this.power);

  /// 消耗体力值与他人互动，产生影响值
  int act([List<Human> others]);

  /// 休息补充体力，因为仅关注自身，对周围的影响值为0
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
```
里昂是精英杀手擅长单点突破，小女孩儿是新晋杀手，初始杀伤力低但成长性很好，贩毒黑警一方则使用范围杀伤。我们直接使用mixin来分离攻击伤害这个行为命名为**mixin XxxxDamage** 进行如下定义:
```
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
```
根据最小影响原则，我们没有使用on Human在 SharpDamage上。
## 塑造角色
### 1.女主-从接口建立起一个完整的成长型杀手
继承关系如下

> class SharpKiller with SharpDamage implements Human;

```
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
```
从接口创建class的好处是可以利用编辑器快速生成模版，知道抽象父类、Mixin都有哪些需要子类实现，坏处是即便是像本例中使用了Human但是却不能使用其实现过的restore函数。

### 2.精英杀手--不同方式的对比
#### 2.1 成长型大叔——隐藏的剧情，隐藏了继承
电影中没有交代里昂是如何成为顶级杀手的，但是不难看出男主对女主的感情有对自己际遇怜惜的影子，那么我们就以第一种方式，从成长型杀手继承。
```
/// 从普通杀手成长起来的精英杀手，具有普通杀手的能力以及精英杀手的数值。
class SeniorSharpBladeKiller extends SharpKiller with BladeDamage {
    SeniorSharpBladeKiller(int power) : super(power);
}
```
可以发现系统发现所有的方法都有现成的实现，通过混入 BladeDamage 达到快速组合出一个精英杀手所需数值和行为的目的。
此时BladeDamage里的length和powerloss固定数值代替原来SharpKiller中的成长型定义并生效。
#### 2.2 天生强者——写在基因里的，抹都抹不掉
另一种构建方式是从Human基类去继承，并赋予mixin来实现杀手能力，就好像剧情中设定的一样，不需要解释，因为强到发指，所以
> 这个杀手不太冷

```
class BladeKiller extends Human with SharpDamage, BladeDamage {
  BladeKiller(int power) : super(power);
  @override
  int act([List<Human> others]) {
    // TODO: implement act
    throw UnimplementedError();
  }
}
```
这里重点强调一下BladeDamage 的顺位相比于 SharpDamage 更靠后，所以后者覆盖前者的定义。
然而这里对调两者不会产生实际的意义，因为即便SharpDamage 在前也仅仅是全部声明，并不覆盖BladeDamage中的全部实现。
补充完 **BladeKiller** 的实现如下：
```
/// 天才型精英杀手，直接通过Mixin获得能力
class BladeKiller extends Human with SharpDamage, BladeDamage {
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
```
#### 2.3 明目张胆的群攻AOE
电影里黑警的手段是黑白通吃，搜查，逮捕，私闯民宅，只为逮到你，所以游戏里没有设置成固定的伤害方式，但是iterator.any函数定义了AOE的厉害之处，只要打中一个就算是打中了，电影中里昂大叔和小女孩儿组成了团队，一方被困另一方不会不管不顾，所以也才有了杀手不太冷的标题。

于是游戏中我们前两个类少写代码的经验最大化复用基础类Human，并赋予其群攻的Mixin，继承关系如下：
> class Bomber extends Human with RangeDamage {

根据RangeDamage的定义要求我们需要设置length，从构造函数获得。

```
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
```

### 3. 构建游戏
接下来我们来完成main函数以及游戏场景的搭建，两班人马一个精英杀手+成长型杀手团体，一个纯粹的AOE团体。
```
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
控制台结果如下:


第一场战斗
Bomber恢复体力5:防御0
SeniorSharpBladeKiller造成击杀
Bomber被击杀！！！
SeniorSharpBladeKiller恢复体力4:防御2
Bomber造成击杀
SeniorSharpBladeKiller被击杀！！！



第二场战斗
Bomber恢复体力5:防御0
SharpKiller造成击杀
Bomber被击杀！！！
SharpKiller恢复体力4:防御2
Bomber造成击杀
SharpKiller被击杀！！！



第三场战斗
Bomber恢复体力5:防御0
BladeKiller造成击杀
Bomber被击杀！！！
BladeKiller恢复体力5:防御0
Bomber造成击杀
BladeKiller被击杀！！！

```
大功告成，可见把部分功能放在Mixin中确实更加灵活，尤其是 `SeniorSharpBladeKiller` 的构造堪称典范，简直就是修改继承对象+重新排列混入对象列表，就可以制造一个新的类型，当然如果全部用mixin来实现组合也有弊端，那就是在Mixin中的函数被覆盖改写更加困难形成新特性，极为困难。

最后你可以理解我们把曾经使用接口的场景没有改变，反而是笔者先前乐用的父类小函数被抽离出类成为新的关键词mixin，掌握好mixin容易犯错的覆盖关系后，就可以愉快地重构啦！！！
