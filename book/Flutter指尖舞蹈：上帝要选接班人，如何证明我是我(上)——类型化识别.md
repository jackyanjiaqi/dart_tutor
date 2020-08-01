#Flutter指尖舞蹈：上帝要选接班人，如何证明我是我(上)——类型化识别⚠️

> 上帝要选接班人了，他要找的是一个跟自己类型一样的人：
>
> 一个幸福的人，一个健康活泼的人，一个心灵手巧的人，一个努力奋斗实现价值的人；
>
> 可是所有的人看起来都一样，这可犯了愁。

如题，在本期指尖舞蹈系列的开头先介绍一下 **“我—是—谁—？”**

##我是谁？

我的全名叫闫佳奇，大家一般call我英文名杰克，是一名住在北京的年轻人、会唱会跳偶尔写写小说、设计一下游戏偶尔再客串个美工、运营，当然我的职业是一名工程师，再具体一点可以说是大前端工程师。什么是大前端工程师？就是前端啦！那什么是前端呢？额。。。(三脸懵逼中)。

当然我还有很多属性，比如我的学籍、工号、花名、英文名、曾用名等等，在人群中你可以通过任何单一甚至组合的方式来识别我，比如在头马俱乐部中有不止一个杰克，你可以说我是那个会写小说又偶尔客串运营的工程师杰克，然而在 Flutter/Dart 中识别一个对象的方式有很多种，比如 class mixin，它们都可以通过  `who is who` 这种句式来判断，把以上信息翻译成 `Dart` 代码就是如下效果：

```dart
/// 一名住在大城市里的年轻人
class Youth{
	String city="BeiJing";
}
```

因为有很多名字，所以照例我们把不同种类的名字设置成 mixin

```dart
/// 英文名
mixin EngName{
	String get english_name;
}
/// 花名
mixin NickName{
	String get nick;
}
/// 中文名
mixin FullName{
	String get fullname;
}
```

实际上这么多名字我们可以融合成一个叫 Name 的mixin

```dart
/// 管你是啥名的名
mixin Name {
  String get workid;
  String get englishName;
  String get nickName;
  String get fullName;
}
```

针对我是谁这样的一个问题，通过观察自然人的回答逻辑就能反推我们应该设置在代码中的结构，那么主语的部分就是只能单继承的class，因为不能既是年轻人又是老年人，以及我们的主要职业只能是一种(劳动合同规定不允许有多个全职)，其他所有具有多义并列的描述我们统统放到mixin中去进行多态化扩展。

```dart
/// 只要不能赚钱就放在这里吧
mixin Capability{
	bool cook = false;
	bool design = true;
	bool sing = true;
	bool dance = true;
	bool shoot = false;
}
/// 能赚钱的职业
class Employee extends Youth with Name, Capability{
  /// 主要职业用来消耗时间赚钱,一般业余时间每天有8小时,996职业除外
	Duration timespare;
  int earnedmoney;
}
```

事实上单纯地表述我是谁本不用这么麻烦，我们可以把所有属性放在一个class里，如下：

```dart
class YANJIAQI{
	String city="BeiJing";
	String workid;
  String englishName;
  String nickName;
  String fullName;
  bool cook = false;
	bool design = true;
	bool sing = true;
	bool dance = true;
	bool shoot = false;
  bool write = true;
}
```

虽然我们可以这样使用所有属性来描述一个人，但是机器并不知道每个值具体是什么，能干什么用，从而推断出我是谁？那么为什么费这么大劲要让机器知道我是谁呢？

> 类型越多、我们用类型定义类的种类越多，机器就能代替我们做更多。

对比 javascript，这是带有强类型机制的语言最大的特色，用类型来进行 `复杂性管理` ， 通过编译器检查来避免人的管理负担，从而构建复杂的应用程序。

> 毕竟人人都喜欢语法自动补全和出错提示，这是编程提效的一大利器啊 ～

## 我能干什么？

那么要这么多属性用来识别我有什么作用呢？答案显而易见，我们需要在判断类型之后执行相应的方法调用，也就是我是谁之后的问题：我能干什么。这里我们把几个属性对应到我们想要类型帮我们完成的事情，并设计对应方法的签名：

* 名字——被识别，recognized
* 兴趣/能力——加入社交，addToSocial
* 职业——财务/时间分配——生计，live

```dart
mixin Name{
	...
	/// 可以从各种名字中去比较和识别
	bool recognized(String name){
		if(workid == name || englishName == name || nickName == name || fullName == name){
			return true;
		}
		return false;
	}
}

mixin Capability{
	...
	/// 这个函数会根据你的时间/金钱分配程度+你的能力值进行社交圈子的选择，返回你能加入的圈子列表
	List<String> addToSocial();
}

class Employee extends Youth with Name, Capability{
  ...
  /// 通过维持生计获得产出,时间 金钱 或者两者都有
  dynamic live();
}

```

因为逻辑简单，我们直接把recognized方法实现了，然而另外两个方法我们暂时未实现。

> 注意：因为强类型语言只能使用确定的一种类型作为返回值，我们可以通过`typedef` 进行复杂类型的定义，然而即便如此也不能返回可能的多种情况(像TypeScript使用|符号)，那么遇到返回多种数据格式的可能性时我们使用dynamic关键字也就是缺省的写法，此时我们也放弃了类型检查这项利器。

最后在完成我们的定义之后，描述我是谁，我能干什么的问题都解决了，自觉同样**幸福、健康活泼、心灵手巧并努力奋斗实现价值**的我来到上帝面前后遇到的盛况是这样的:

```dart
/// 伪代码
void main(){
	God()
    /// all the same
    /// class Employee extends Youth with Name, Capability
    ..selecting([Employee(),Employee(),Employee(),Employee(),Employee(),Employee(),..]) 		
    ..selecting([Employee(),Employee(),Employee(),Employee(),Employee(),Employee(),..]) 				..selecting([Employee(),Employee(),Employee(),Employee(),Employee(),Employee(),..]) 				..selecting([Employee(),Employee(),Employee(),Employee(),Employee(),Employee(),..]) 				..selecting([Employee(),Employee(),Employee(),Employee(),Employee(),Employee(),..]) 				..selecting([Employee(),Employee(),Employee(),Employee(),Employee(),Employee(),..]) 		
		///				....500000000000000000 Employees still waiting to be selet
    ..hasNoPatience()
    ..failedAll();
}
```

那么到此为止，上帝挑选接班人这项工作就这样夭折了，虽然使用了多种类型扩展结构但是上帝(编译器)视角下的类依然是千篇一律毫无辨识度的，所有人给上帝的第一印象都是*Employee*，之后是*class Employee extends Youth with Name,Capability* 再然后是全部基本类型为bool int String以及属性名字相同的签名。什么？多样化要程序运行起来？上帝失去了耐心。

> 注意：使用类型就要在静态类型检查阶段发现问题而不是运行阶段发现问题，这会节省很多调试时间。

## 类型化改造

上帝不想来到人间海选，他随机选择一些有个性的名字，识别他们、判断他们、最后选出合适的人成为接班人，可能有一些运气成分，但是筛选的条件是苛刻的，一次不行就两次，两次不行就三次。而能够提高识别效率的工具就是我们常说的`类型`。

因为mixin不能被继承，我们选择 class 来将形如 xxxname 这个属性族进行一层类型化封装：

```dart
class BaseName {
  final String name;
  const BaseName(this.name);
  bool recognized(String name) {
    return this.name == name;
  }
}
```
具体类型不进行过多设计，只进行类型化封装
```dart
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
```

再将类型化信息重新植入mixin 起名Names，这样更加语义化。

```dart
mixin Names {
  /// 按照经验我们只在mixin中做函数定义
  List<BaseName> get names;
	
  bool recognized(BaseName bn) {
    return names.any((item) => item.recognized(bn.name));
  }
}
```

接下来我们处理更加复杂一些的Capability类型。

## 上帝想要什么？

> 问："上帝究竟想要什么？他如何判断一个人是否可以接班？"
>
> 答："上帝想要的人是一个活得明白的人"

怎么理解这句话呢？你得首先问问你自己是活着呢？还是在享受生活呢？

为此我们重新设计一下基本类型 Youth，认为你是来大城市打拼的青年，而城市本身在未进行类型化的时候我们只需要知道城市的最底生活成本是多少，比如房租水电每日三餐，你可以获得一份全职工作从而从 Youth(待业青年)一跃为 Employee(工薪阶层)，但是可能你得先从兴趣爱好中选择若干充实你的时间，同时赚取费用满足最低生活标准。所以将 `timespare` 和 `live` 移到基类中，并把city属性修改后得到新的 BaseYouth定义：

```dart
class BaseYouth {
  /// 可分配时间
  final Duration timespare;

  /// 城市生存开销
  final int cityspent;
  const BaseYouth(
      {this.timespare = const Duration(hours: 16), this.cityspent = 100});

  /// 依然不知道具体实现，目的是检测可以活在这个城市里的最低标准
  live() {}
}
```

> 我们依然不知道live的具体签名应该是如何的，不过可以暂时放下，让其他部分的实现逐步清晰化这个函数的作用。

跟名字的类型化一样，紧接着我们对兴趣爱好这个具有社交概念的基本模型入手：

```dart
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
}
```

我们看到经过我们的解读，上帝想要一个幸福指数高、健康指数高、技巧指数高和能额外挣钱的四高青年。

我们根据常识试着对几种类型的兴趣爱好进行参数化配置：

```dart
/// 自己做饭健康，还能够省钱(相当于赚钱)
class Cooking extends BaseSocial {
  const Cooking() : super(health: 70, skill: 20, extramoney: 30, happiness: 35);
}
/// 跳舞很费体力，但是需要支付较高的场地和教学费用，幸福指数较高，时间占用较高
class Dancing extends BaseSocial {
  const Dancing()
      : super(
            timespend: const Duration(hours: 4),
            health: 250,
            skill: 50,
            extramoney: -100,
            happiness: 200);
}
/// 唱歌属于全民运动，在家也能唱，但是可能会扰民
class Singing extends BaseSocial {
  const Singing()
      : super(health: 50, skill: 50, extramoney: -20, happiness: 100);
}
/// 会写代码更会做设计，真的是再学了一门手艺还能额外赚点外快，需要消耗点健康来学习
class Designing extends BaseSocial {
  const Designing()
      : super(skill: 250, extramoney: 100, happiness: 150, health: -50);
}
/// 射击真真土豪运动，装备场地都不菲，只要赚得多就能很幸福
class Shooting extends BaseSocial {
  const Shooting()
      : super(health: 200, skill: 300, extramoney: -200, happiness: 250);
}
/// 为数不多能赚点外快的兴趣，只是熬夜写文有些伤身，用作品说话也是很满足的
class Writing extends BaseSocial {
  const Writing() : super(health: -70, extramoney: 30, happiness: 100);
}
```

与名字的类型化不同，兴趣爱好具有了典型的参数异化特征。	

```dart
mixin Capabilities on BaseYouth {
  List<BaseSocial> get capabilities;

  /// 根据给定的能力范围获得可选的兴趣方向 可重复
  List<BaseSocial> addToSocial() {
    /// TODO
    /// 算法解析：
    /// 1.以月为单位对已经存在的能力进行筛选获得列表返回，(外部调用，对所有返回值进行四项结算)
    /// 2.包含live方法调用迭代30次，对金钱单位结果进行累加，不对时间进行累加。
    /// 3.包含多个解时，有每日最优策略和月度最优策略，根据上半月选择每日最优和下半月选择月度最优
  }
}
```

同样把 BaseSocial 并入 Capabilities ，之后我们就完成了兴趣爱好的类型化设定。只是我们没有对函数进行具体的实现。这里列出TODO: 以示待加入实现代码的槽位

> 注意：在代码重构和建设中设置未添加实现的代码槽位是非常重要的，罗马也非一天建成。这样不仅保持了结构完整性也能泾渭分明地划分出代码块，避免陷入逻辑混淆。

```dart
/// 最后我们对Employee进行更名和组装
class EmployeeKind extends BaseYouth with Names, Capabilities {
  final int earnedmoney;
  final List<BaseName> names;
  final List<BaseSocial> capabilities;
  EmployeeKind(
      {int cityspent,
      this.capabilities,
      this.names,
      Duration timespare = const Duration(hours: 8),
      this.earnedmoney = 300})
      : super(timespare: timespare, cityspent: cityspent);
}
```

最后我们对Employee进行更名和组装，组装包含继承新的基类BaseYouth，混入Names 和 Capabilities，初始化参数列表设置。

> 注意：奇怪的是我们不能将此处的构造函数设置成const(其他可以)，给出的理由是

为了方便输出，我们将返回结果包装一层打印：

```dart
mixin Names{
	...
	/// 可以从各种名字中去比较和识别
  bool recognized(BaseName bn) {
  	return printWrapped(...)
  }
}

printWrapped(everything) {
  print(everything);
  return everything;
}
```

最后我们类型化后的实例具有了明显的类型特征，不同的类也有了较大的类型差异。

```dart
void main(){
  EmployeeKind(
      names: [
        Nickname("果酱V"),
        Workid("F117007"),
        Fullname("闫佳奇"),
        Englishname("杰克")
      ],
      capabilities: [Singing(), Dancing(), Writting(), Designing()],
      earnedmoney: 800,
      timespare: Duration(hours:8),
    )
      ..recognized(Nickname("闫佳奇")) /// 预期为false，实际为true
      ..recognized(Workid("果酱V")) /// 预期为false， 实际为true
      ..recognized(Englishname("杰克")) /// 预期为true，实际为true		
      ..recognized(Englishname("杰瑞")) /// 预期为false，实际为false
      ;
}
控制台:
true
true
true
false
```

注意，实际上编译器看不到引号里面传参的信息，但这已经比先前好很多了，上帝视角下知道你有一个全名、英文名、花名和工作编号，另外你的兴趣是唱歌跳舞写作和设计，这都是从类型体现出来的。

然而最后我们发现控制台输出跟我们的预想不太一致，因为我们只进行了值的比较，没有关注到类型一致，修改一下recognized的算法:

```dart
mixin Names {
  List<BaseName> get names;

  /// 可以从各种名字中去比较和识别
  bool recognized(BaseName bn) {
    return printWrapped(names.any((item) =>
    /// 添加了类型比较
        item.runtimeType == bn.runtimeType && item.recognized(bn.name)));
  }
}
...
控制台:
false
false
true
false
```

## 类型化识别

可以说类型识别是面向对象设计语言都有的特征，有类就有类型化识别，在dart中他们是 `is` 关键字，runtimeType变量(Type类型)，最后再加上hashCode这个对象实例的唯一标识，形成了从继承关系、到类型、再到对象“证明我是我”的递进逻辑。以下列举了java 和 javascript 等价的类型识别方式，以方便对比学习。

|类目| dart | java | javascript |
| ---- | ---- | ---- | ---------- |
| 判断类型归属 | 关键字 is | 关键字 instanceof | 关键字 instanceof |
| 获得运行时类型 | .runtimeType | .class | 关键字 typeof |
| 类类型 | Type | Class | Object (prototype) |

在接下来的中篇中我们引入 dart 超强的 **泛型** 概念，并将目前构建出的《上帝要选接班人》场景进一步优化，关注我的专栏[《程序员跨界之美》](https://zhuanlan.zhihu.com/c_1256368460256694272)，敬请期待吧 ～

## 附录

演示代码已上传到[github](https://github.com/jackyanjiaqi/dart_tutor)，欢迎下载学习。

