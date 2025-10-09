import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/reflections/presentation/reflections_list_page.dart';
import 'features/reflections/presentation/reflection_edit_page.dart';
import 'features/cpd/presentation/cpd_list_page.dart';
import 'features/cpd/presentation/cpd_edit_page.dart';
import 'features/export/export_page.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const DashboardPage()),
    GoRoute(path: '/reflections', builder: (c, s) => const ReflectionsListPage()),
    GoRoute(path: '/reflections/new', builder: (c, s) => const ReflectionEditPage()),
    GoRoute(path: '/reflections/:id', builder: (c, s) => ReflectionEditPage(id: s.pathParameters['id'])),
    GoRoute(path: '/cpd', builder: (c, s) => const CpdListPage()),
    GoRoute(path: '/cpd/new', builder: (c, s) => const CpdEditPage()),
    GoRoute(path: '/cpd/:id', builder: (c, s) => CpdEditPage(id: s.pathParameters['id'])),
    GoRoute(path: '/export', builder: (c, s) => const ExportPage()),
  ],
);
