// Example 5 – Inheritance & Dynamic Dispatch (self / super)
//
// c3 inherits m3() from c2.  m3() calls super.m1(), which resolves to c1.m1().
// c1.m1() calls this.m2() — "this" is the actual runtime object (o3, a c3),
// so dynamic dispatch picks c3.m2(), which returns 33.

class C1 {
  int m1() => m2();
  int m2() => 13;
}

class C2 extends C1 {
  @override
  int m1() => 22;

  @override
  int m2() => 23;

  int m3() => super.m1();
}

class C3 extends C2 {
  @override
  int m1() => 32;

  @override
  int m2() => 33;
}

void main() {
  var o3 = C3();
  print(o3.m3()); // 33
}
