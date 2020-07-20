main() {
  const C1 = "123";
  const C2 = "123";
  var C3 = "123";
  var C4 = "12345";
  var C5 = ["1", "2", "3"].join();
  var copyData = A(5);
  var a = [C1, copyData, "456"];
  var b = a.sublist(0);
  var c = deepCopy(a);
  print(C1.hashCode);
  print(C2.hashCode);
  print(C3.hashCode);
  print(C4.hashCode);
  print(C5.hashCode);
  print(a.hashCode);
  print(b.hashCode);
  print(c.hashCode);
  print(a[0].hashCode);
  print(b[0].hashCode);
  print(c[0].hashCode);
  print(a[1].hashCode);
  print(b[1].hashCode);
  print(c[1].hashCode);
  (a[1] as A).a = 6;
  (b[1] as A).a = 7;
  (c[1] as A).a = 8;
  print((a[1] as A).a);
  print((b[1] as A).a);
  print((c[1] as A).a);
}

class A {
  int a;
  A(this.a);
  factory A.copy(A copyed) {
    return A(copyed.a);
  }
}

deepCopy(list) {
  var ret = [];
  for (var item in list) {
    if (item is A) {
      item = A.copy(item);
    } else if (item is String) {
      item = (item as String).substring(0);
    }
    ret.add(item);
  }
  return ret;
}
