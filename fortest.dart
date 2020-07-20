/// mixin练习
main() {
  A()
    ..log()
    ..logC()
    ..logD();
  Amask()
    ..log()
    ..logC()
    ..logD();
}

mixin C {
  String a = "this is C";
  log() {
    print('log called in C');
    print(a);
  }

  logC() {
    print('logC called in C');
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

  logD() {
    print("logD called in D");
    print(a);
  }
}

class A extends D with C, B {
  get a => "this is A";
  // log() {
  //   print("this is log in A");
  //   print(a);
  // }
}

class Amask extends A with C, B {}
