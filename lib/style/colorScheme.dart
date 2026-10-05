import 'package:flutter/material.dart';

final colorScheme = ColorScheme(
  brightness: Brightness.light, //tema claro
  primary: const Color(0xFF8259d5), //cor primária #f0f5f7
  onPrimary: Colors.white, //elementos em cima da cor primária
  secondary: const Color(0xFFab88f0), //cor secundária
  onSecondary: Colors.white, //elementos em cima da cor secundária
  error: const Color(0xFFd93c26), //mensagens de erro
  onError: Colors.white, //elementos em cima do erro
  surface: const Color(0xFFd2d3e7), //cor de fundo
  surfaceContainer: const Color(0xFFf3f3ff), //cor de fundo de componentes
  onSurface: const Color.fromARGB(255, 54, 42, 92), //textos
  onSurfaceVariant: const Color(0xFF65628e), //textos secundários
);