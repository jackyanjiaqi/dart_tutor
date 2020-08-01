mixin B {
  @override
  String toString() {
    print('this is B');
  }
}

mixin O<M> {
  doSomething<M>() {
    print('this is O with type M');
  }
}

abstract class A<T> with B, O<T> {
  T data;
}

class C<T> extends A<T> {}

class C1<T> extends A<String> {
  T data2;
}

class C2 extends A<double> {}

class D1 extends C1<double> {}

class D2 extends C2 {}

main() {
  var c1 = C1();
  var c2 = C2();
  var d1 = D1();
  var d2 = D2();

  print('D1 is O result:${d1 is O}');
  print('D1 is A result:${d1 is A}');
  print('D1 is B result:${d1 is B}');
  print('D1 is C result:${d1 is C}');
  print('D1 is C1 result:${d1 is C1}');

  print('D2 is O result:${d2 is O}');
  print('D2 is A result:${d2 is A}');
  print('D2 is B result:${d2 is B}');
  print('D2 is C result:${d2 is C}');
  print('D2 is C2 result:${d2 is C2}');

  print('C1 is O result:${c1 is O}');
  print('C1 is A result:${c1 is A}');
  print('C1 is B result:${c1 is B}');

  print('C2 is O result:${c2 is O}');
  print('C2 is A result:${c2 is A}');
  print('C2 is B result:${c2 is B}');
}
