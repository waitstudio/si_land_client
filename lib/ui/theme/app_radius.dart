import 'package:flutter/material.dart';

/// 圆角 token

class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 20;

  static BorderRadius get xsR => BorderRadius.circular(xs);
  static BorderRadius get smR => BorderRadius.circular(sm);
  static BorderRadius get mdR => BorderRadius.circular(md);
  static BorderRadius get lgR => BorderRadius.circular(lg);
  static BorderRadius get xlR => BorderRadius.circular(xl);
}
