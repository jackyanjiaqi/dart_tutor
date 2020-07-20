/// 本练习针对类继承关系下的变量覆盖
class Simple1 {
  int example;
  Simple1({this.example});
  printExample() {
    print(example);
  }
}

class Simple2 {
  int example = 5;
  Simple2({example}) : this.example = example;
  printExample() {
    print(example);
  }
}

class Simple3 {
  int example;
  Simple3({example = 5});
  printExample() {
    print(example);
  }
}

class Simple4 {
  int example;
  Simple4({example = 5}) : this.example = example;
  printExample() {
    print(example);
  }
}

abstract class A {
  int example;
  A({this.example});
  printExample();
}

class B extends A {
  /// 此处定义赋初值无效 被后续构造函数默认参数赋值=null 所覆盖
  int example = 5;
  B({this.example}) : super(example: example);
  @override
  printExample() {
    print(example);
  }
}

class C extends A {
  int example;

  /// 此处定义默认参数有效，当example为隐式null时用5来代替，显式null不代替
  C({this.example = 5}) : super(example: example);
  @override
  printExample() {
    print(example);
  }
}

class D extends A {
  /// 此处定义赋初值无效
  int example;
  D({this.example}) : super(example: example ?? 5);
  @override
  printExample() {
    print(example);
  }
}

class D2 extends A {
  /// 此处定义赋初值无效
  int example;
  D2({this.example}) : super(example: example ?? 5);
  @override
  printExample() {
    print(example);
    print(super.example);
  }
}

class B1 extends A {
  int _a = 5;
  @override
  set example(int a) {
    /// 在构造器中不论隐式还是显式null都没有调用
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
    // print(example = 8);
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

main() {
  Simple1().printExample();
  Simple2().printExample();
  Simple3().printExample();
  Simple4().printExample();
  print('-----------------');
  B().printExample();
  C().printExample();
  D().printExample();
  print('-----------------');
  B(example: null).printExample();
  C(example: null).printExample();
  D(example: null).printExample();
  print('-----------------');
  B1().printExample();
  C1().printExample();
  D1().printExample();
  print('-----------------');
  B1(example: null).printExample();
  C1(example: null).printExample();
  D1(example: null).printExample();
  print('-----------------');
  D2().printExample();
  D2(example: null).printExample();
}
