// Example 3 — Inheritance & Field Shadowing
// Dart field inheritance is DYNAMIC — fields are virtual getters,
// so gety1() (defined in C1) still returns C2's y, not C1's y.

class C1 {
  int? x;
  int? y;

  void setx1(int v) => x = v;
  void sety1(int v) => y = v;
  int? getx1() => x;
  int? gety1() => y;
}

class C2 extends C1 {
  @override
  int? y;

  void sety2(int v) => y = v;
  int? getx2() => x;
  int? gety2() => y;
}

void main() {
  var o2 = C2();

  o2.setx1(101);
  o2.sety1(102);
  o2.sety2(999);

  var result = [
    o2.getx1(),
    o2.gety1(),
    o2.getx2(),
    o2.gety2(),
  ];

  print(result); // [101, 999, 101, 999]
}
