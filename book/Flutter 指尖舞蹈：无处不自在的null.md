#Flutter指尖舞蹈：静若处子/动若脱兔——无处不在的null

使用Dart编程很让人欣喜的一点是摆脱了javascript里的undefined定义束缚，因为往往一个Object 有undefined、null以及自身类型多种状态，非常苦恼，然而Dart把未定义的变量都统一赋值成null也着实让人头疼，因为不知道什么时候，编译器的隐式赋值就覆盖了你的某一处显示赋值，无可奈何地在各种继承关系中寻找蛛丝马迹。今天我们就来彻彻底底地扒一扒。

## 1. 静若处子：静态变量、常量、构造函数初始化列表

几乎所有编程语言都有`static`、 `const`、 `final` 这样的关键字，被这些关键字定义的值意味着在程序正式运行之前，有固定的内存分配，你可以随时通过固定寻址来找到他们。这就好比在国企事业单位领固定工资和福利的公务员，是社会运行的基础。

而在这些值的初始化方式上Dart为我们提供了一种承接于构造函数声明体之后基于冒号和逗号的语法

```dart
class A{
	A(参数列表): 表达式1, 表达式2, super(参数列表){
		构造函数体
	}
}
```

我们称之为`构造函数初始化列表`。[Dart中文网](https://www.dartcn.com/guides/language/language-tour#构造函数)并没有给出更多的初始化列表定义，但是我们可以用结下来的指尖舞蹈来强化理解。

在构造函数初始化列表中我们可以在调用父类初始化列表之前为成员变量赋值，注意：

* 不可以为静态成员变量赋值

  > Fields initialized in a constructor can't be static.

* 不可以使用类的非静态成员赋值

  > Only static members can be accessed in initializers.

* 可以使用静态成员变量、静态成员方法，函数、常量对象、字面量、参数列表的形参赋值

这是因为该过程在执行构造函数之前，还没有从类的内存静态区向动态区过度，普通的成员变量和方法，正是构造的初始化过程的最终目标，不能反过来为自己服务。如果把对象的生产过程比作工厂出货，那就是先要制造机器（编译器)、购买原料(常量)、找到生产原型模具(类Type)，再依葫芦画瓢按照生产流程(构造函数流程)生产实例。不能用产品反过来再生产产品。

关于静态变量常量的概念可以参考[Dart中文网](https://www.dartcn.com/guides/language/language-tour#变量)，

关于构造函数初始化列表，是Dart把这个编译器隐藏动作拿出来让用户进行可配置化了，相比于传统java的构造函数调用顺序其实是反过来的。用一个伪代码表示则是这样的：

```DART
class A{
	构造函数A入口参数: 参数初始化列表A{
		构造函数体A
	}	
}
class B extends A{
	构造函数B入口参数: 参数初始化列表B,超类初始化列表B{
		构造函数体B
	}
}

以默认的空构造函数为例，执行一个B()编译器的实际动作为：

静态区：构造函数B入口参数 -> 参数初始化列表B ->超类初始化列表B -> 构造函数A入口参数 ->参数初始化列表A
 | 
 V
动态区：构造函数体A -> 构造函数体B
```

一进一出方向相反。但然这部分内容蛮多的，但是官方文档寥寥几句并不清晰，那么本期借助讨论的无处不在的null来强化类型实例化从构造函数开始做了哪些事，以及在继承关系下如何执行。

##2. 动若脱兔：无处不在的null

先看平面级别(没有继承关系)的例子：

```dart
class Simple1 {
  int example;
  Simple1({this.example});
  printExample() {
    print(example);
  }
}

main(){
	Simple1().printExample();
}

控制台:
null
```

这个例子我们看到声明并默认赋值给example为null，而通过可选参数传进来的example通过this.语法糖绑定到example成员变量上，main函数中调用时未传参则默认为null，那么经过两次赋值之后打印example为null.



接下来为了强化记忆我们展开语法糖，在声明阶段和传参时分别传入初始值和默认参数对比验证一下，是不是这个流程。

```dart
/// 声明并初始化并绑定构造函数参数列表
class Simple2 {
  int example = 5;
  Simple2({example}) : this.example = example;
  printExample() {
    print(example);
  }
}
/// 仅传入构造函数默认参数
class Simple3 {
  int example;
  Simple3({example = 5});
  printExample() {
    print(example);
  }
}

/// 传入构造函数默认参数并绑定构造函数参数列表
class Simple4 {
  int example;
  Simple4({example = 5}) : this.example = example;
  printExample() {
    print(example);
  }
}

main(){
	Simple2().printExample();
  Simple3().printExample();
  Simple4().printExample();
}
控制台:
null
null
5
```

* Simple2 声明时的赋值被构造函数隐式传null所覆盖
* Simple3 声明时默认赋值为 `null`，虽然传参为 `null`取了默认参数5 但是没有进行绑定，注意此处的example仅仅是构造函数形参，并不是成员变量。
* Simple4 把Simple3的绑定在初始化列表中补齐，可见 <span style="color:red">使用默认参数搭配this.进行数据绑定是以可选参数为构造形参的最佳实践。</span>

##3. 类继承关系下的成员变量初始化覆盖关系

根据上面总结的最佳实践原则我们开始套一层继承关系，并通过super关键字来进行超类的构造器调用：

```dart
abstract class A {
  int example;
  A({this.example});
  printExample();
}

class B extends A {
  int example = 5;
  B({this.example}) : super(example: example);
  @override
  printExample() {
    print(example);
  }
}
```

B 和 A 是继承关系的两个类，且都有example的定义和构造函数赋值，A不能实例化，在没有额外的初始化参数传递的情况下会通过子类的可选参数未被调用默认传null的规则所覆盖，然而我们此处向B添加了声明赋值，想要打印出5，我们来看看结果如何：

```dart
控制台：
null
```

没错了，这里打印出了null，这是为什么呢？应该说这和上例中Simple2的结果一致，原因也是一致的，被构造函数默认形参null给覆盖了，我们再来看两组对比实验：

```dart
class C extends A {
  int example;

  /// 此处定义默认参数有效
  C({this.example = 5}) : super(example: example);
  @override
  printExample() {
    print(example);
  }
}

class D extends A {
  int example;
  /// 此处为父函数截流未生效
  D({this.example}) : super(example: example ?? 5);
  @override
  printExample() {
    print(example);
  }
}
main(){
	C().printExample();
	D().printExample();
}

控制台:
5
null
```

* class C，可见在可选参数列表中加入默认参数是有效的提供默认值的方式之一。然而这只对隐式传null 有用。
* class D，为什么我在父类的参数列表中传了为null则赋值为5，却仍旧打印为null呢？因为此处可以把class D看成是没有继承关系的Simple1，为什么我们接下来看一个对比。

> ?? 运算符的作用是使得表达式的左值为空时返回右值

## 4. 显式传null

之所以null的状态有很多，是因为结合了函数可选参数可传可不传的特性，这时候javascript中undefined的表意作用就更加清晰。

我们为B、C、D 添加显式传null的对比测试用例：

```dart
main(){
  B(example: null).printExample();
  C(example: null).printExample();
  D(example: null).printExample();
}

控制台：
null
null
null
```

毫无疑问，用户有明确的指向，class C的默认传参被忽略。其他与隐式传null情况相同。

##5. 消失的 ??

既然理解了默认传参的用法，我们来重点探究一下super()里定义的 ?? 为什么消失了。来看另一组对照：

```dart
class B1 extends A {
  int _a = 5;
  @override
  set example(int a) {
    /// 在构造函数参数列表中不论隐式还是显式null都没有调用
    print('set example $a');
    _a = a;
  }

  @override
  get example {
    ///
    print('get example');
    return _a;
  }

  B1({example}) : super(example: example);
  @override
  printExample() {
    print(example);
    print(example = 8);
  }
}

class C1 extends A {
  C1({example = 5}) : super(example: example);
  @override
  printExample() {
    print(example);
  }
}

class D1 extends A {
  /// ?? 针对隐式和显示null都有效
  D1({example}) : super(example: example ?? 5);
  @override
  printExample() {
    print(example);
  }
}
```

上一篇在[Flutter指尖舞蹈：这个杀手不太冷——场景式学习Dart的多态和继承](https://zhuanlan.zhihu.com/p/159244600) 中我们得出结论，子类的同名变量定义可以拆解成set get函数对父类中相同的变量定义进行了覆盖，那么我们这次也用等量替换的思路来看看set和get函数里是否都进行了打印。

同时我们在C1和D1中将覆盖定义完全去掉，仅仅向子类传递example初值。

```dart
main(){
	B1().printExample();
  C1().printExample();
  D1().printExample();
  print('-----------------');
  B1(example: null).printExample();
  C1(example: null).printExample();
  D1(example: null).printExample();
}

控制台：
get example
5
5
5
-----------------
get example
5
null
5
```

* 重要的时刻来了，我们发现在B1中用 set get 函数代替变量定义成功让父类的example定义显示出了默认值5，而预想中的set example并没有因为覆盖关系被调用，而C1 和 D1通过去掉子类的变量重载定义也让默认值得以显示。

* 那么就剩下一种最为可能的情况了，想想也是正确的，在开篇的第1节中我们说过了`不可以使用类的非静态成员赋值` 这包括所有成员函数，也包含set get存取器函数。

  子类和父类各自有一个相同的example定义，并分别被赋予了null 和 5，然而不论在父类或子类的打印函数中example的引用都受到了子类的重载，我们说int example就是隐形的set example 和 get example所以你到处找不到父类的真实变量值，此时笔者想到了不常用的super关键字，将打印函数替换为

  
  



```dart
class D extends A {
  /// 此处定义赋初值无效
  int example;
  D({this.example}) : super(example: example ?? 5);
  @override
  printExample() {
    print(example);
  }
}

main(){
  D().printExample();
  print('-----------------');
  D(example: null).printExample();
}

控制台：
null
5
-----------------
null
5
```



 无论显式隐式传递null 都会影响所有子类，却因为有??的作用不能够影响父类，但是同时访问父类只能通过super来规避覆盖效果，如果不能通过子类完全代替父类而去跨层级关系调用被原本覆盖掉的值是违背OOP 中里氏代换原则的，这在我们的代码中也是不经常使用的。

## 6. 在多个层级关系中使用变量覆盖的最佳实践

不要在子类中重复定义父类定义过的变量，除非有父类必须实现的抽象方法，当需要从构造函数传递参数时，仅仅开放参数列表并作为传递者向下传递，并在其他地方以相同的语意来进行引用，且在要求非空的条件下设置@required 和默认参数。



如果不得不修改，定义私有变量，并使用存取器根据数据边界情况判断适用子类还是父类的取值。

```dart
class M {
  int a;
  M(this.a);
  acceptUseAnotherA() => a > 5000;
}

class N extends M {
  int _a;
  int get a {
    if (acceptUseAnotherA())
      return _a;
    else
      return super.a;
  }

  N(int a)
      : _a = a,
        super(a);
}
```

当然大多数情况并不需要这么麻烦地进行变量多版本管理。(有点像github了哈)

## 7. 声明式UI -->const 构造函数

下面来聊聊为什么不用传统的构造函数初始化呢？因为如果仅仅是给变量赋值在函数体内由父向子地传递就好了，但是声明式UI 利用了构造函数的参数列表成为UI的描述。这跟jsx的xml声明没有本质区别，在对应翻译成js之后也是这种构造函数嵌套的写法。

> Dart 利用语言特性就直接省去了翻译的过程。

但既然声明就要满足声明的条件，像常量一样在构造函数参数列表中传递自身。对于相同的输入总能输出相同的值，或者说就是同一个值，跟一串字符代表的描述是相同的效果。

那么我们就会看到当你为之前的构造函数添加const 关键字之后，带有函数体的代码会报错：

> Const constructors can't have a body.
>
>  Try removing either the 'const' keyword or the body.

对应地，成员变量必须为final类型，在构造函数初始化列表中进行一次性装配。

之后我们就可以愉快地使用各种以s为结尾的集合类型常量Widget来构建我们的UI了。

否则 你就只能使用基于简单类型的常量、enum、静态变量来书写一种非精确的UI描述，再通过比如Android中的XML转化体系来映射到基于对象的传统UI的构建体系上，以及纯粹的手写代码，比如:

![IOS命令式UI](https://pic2.zhimg.com/80/v2-498d97adb3434212e003957cc73fd139_1440w.jpg)



## 8. 与普通构造函数的区别是什么？

```dart
class Location {
  final int x;
  final int y;
  const Location(this.x, this.y);
}

main() {
  const Location gate = const Location(400, 200);
  const Location tower = const Location(500, 200);
  const Location tube = const Location(400, 200);

  //false – different values results on a new object
  /// 哈希值不同 是不同的对象
  print(gate == tower);

  //true – same class & values results in the same reference
  /// 哈希值相同 是同一个对象
  print(gate == tube);

  Location runway = new Location(400, 200);
  Location tarmac = new Location(500, 200);
  Location field = new Location(400, 200);
  print(runway == tarmac); //false – new keyword results on a new object
  print(runway == field); //false – new keyword results on a new object
}
```

引用一段[Object Structures in Dart][https://www.peachpit.com/articles/article.aspx?p=2468332&seqNum=5] 的代码来解释最不为过了，只要不被new修饰，gate 和 tube是同一个值，这为声明式编程提供了有力的数据驱动保证。

与静态常量最大的区别是可以通过常量构造函数的参数列表来无限扩展常量可枚举的可能性。由用户发挥空间去书写而非编译器去根据某种规则进行转译或注入。

与普通构造函数的区别是可以作为常量在其他UI的构造函数中出现，成为描述整体UI的一部分，使得即便返回了一个超级大的，嵌套复杂的Widget树依然可以作为一个常量参与Flutter引擎的UI重绘。

## 9.  总结

经过这一章的刻意训练，我也基本上查阅资料，书写案例，不单单从别人的代码中去看，去听，而是亲自挖掘可供自己借鉴的，对已经稍显庞大的视频软件APP工程规模进行合理架构。

* const Constructor体系适合做无限扩展可能性的[文本类型处理系统][]，代替枚举值和基于基本类型的静态类。
* 对反复使用相同定义覆盖父类的情况进行梳理和重构，确保不再出现莫名其妙的null覆盖问题。

* 对Flutter之所以选用Dart有了框架层面更深的认识。

[文本类型处理系统][文本类型处理系统: 基于用户输入或者函数产出的文本进行格式识别、分类和提供针对性的处理方法]



最后欢迎关注我的个人专栏[程序员跨界之美][https://zhuanlan.zhihu.com/c_1256368460256694272]

Flutter指尖系列的上一篇[Flutter指尖舞蹈：这个杀手不太冷——场景式学习Dart的多态和继承](https://zhuanlan.zhihu.com/p/159244600)

指尖系列练习 [github地址][https://github.com/jackyanjiaqi/dart_tutor]