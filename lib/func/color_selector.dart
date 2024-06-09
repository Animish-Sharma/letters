import 'package:flutter/material.dart';

Color getpLight(themeInt) {
  if (themeInt == 1) return const Color(0xff4caf50);
  if (themeInt == 2) return const Color(0xff29b6f6);
  if (themeInt == 3) return Colors.red;
  return Colors.purple;
}

Color getpDark(themeInt) {
  if (themeInt == 1) return const Color(0xff2e7d32);
  if (themeInt == 2) return const Color(0xff1565c0);
  if (themeInt == 3) return const Color(0xffd32f2f);
  return Colors.purple;
}

Color getsLight(themeInt) {
  if (themeInt == 1) return const Color(0xffd7d7d7);
  if (themeInt == 2) return const Color(0xfff8bbd0);
  if (themeInt == 3) return const Color(0xffffca28);
  return const Color(0xffb0bec5);
}

Color getsDark(themeInt) {
  if (themeInt == 1) return const Color(0xff424242);
  if (themeInt == 2) return const Color(0xffec407A);
  if (themeInt == 3) return const Color(0xffff6f00);
  return const Color(0xff455a64);
}

List<Color> getBackLight(themeint) {
  if (themeint == 1) {
    return [
      const Color(0xffffd6ff),
      const Color(0xffe7c6ff),
      const Color(0xffc8b6ff),
      const Color(0xffb8c0ff),
      const Color(0xffbbd0ff),
    ];
  }
  if (themeint == 2) {
    return [
      const Color(0xffF07167),
      const Color(0xffFED9B7),
    ];
  }
  if (themeint == 3) {
    return [
      const Color(0xfffd9869),
      const Color(0xfffec9c9),
    ];
  }
  if (themeint == 4) {
    return [
      const Color(0xffeae5c9),
      const Color(0xff6cc6cb),
    ];
  }

  return [Colors.white, Colors.black];
}

List<Color> getBackDark(themeint) {
  if (themeint == 1) {
    return [
      const Color(0xff4ca9df),
      const Color(0xff292e91),
    ];
  }
  if (themeint == 2) {
    return [
      const Color(0xffF07167),
      const Color(0xffFED9B7),
    ];
  }
  if (themeint == 3) {
    return [
      const Color(0xfffd9869),
      const Color(0xfffec9c9),
    ];
  }
  if (themeint == 4) {
    return [
      const Color(0xff112d60),
      const Color(0xffdd83e0),
    ];
  }

  return [Colors.white, Colors.black];
}
