part of '../go_router_config.dart';

List<RouteBase> _buildSystemShellRoutes() {
  return [
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.mustakshif, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.mustakshif,
          redirect: (context, state) =>
              state.matchedLocation == AppRoutes.mustakshif
                  ? AppRoutes.adminDashboard
                  : null,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.mustakshif.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.mustakshif.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.mustakshif.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.mustakshif.slug),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.adminData, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.adminData,
          redirect: (context, state) =>
              state.matchedLocation == AppRoutes.adminData
                  ? AppRoutes.adminDashboard
                  : null,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.adminData.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.adminData.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.adminData.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.adminData.slug),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.lands, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.lands,
          redirect: (context, state) =>
              state.matchedLocation == AppRoutes.lands
                  ? AppRoutes.adminDashboard
                  : null,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.lands.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.lands.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.lands.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.lands.slug),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.properties, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.properties,
          redirect: (context, state) =>
              state.matchedLocation == AppRoutes.properties
                  ? AppRoutes.adminDashboard
                  : null,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.properties.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.properties.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.properties.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.properties.slug),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.cases, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.cases,
          redirect: (context, state) =>
              state.matchedLocation == AppRoutes.cases
                  ? AppRoutes.adminDashboard
                  : null,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.cases.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.cases.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.cases.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.cases.slug),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.tasks, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.tasks,
          builder: (context, state) => const TasksDashboardPage(),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const TaskFormPage(),
            ),
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.tasks.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.tasks.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.tasks.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.tasks.slug),
            ),
            GoRoute(
              path: ':taskId/edit',
              builder: (context, state) =>
                  TaskFormPage(taskId: state.pathParameters['taskId']),
            ),
            GoRoute(
              path: ':taskId',
              builder: (context, state) =>
                  TaskDetailPage(taskId: state.pathParameters['taskId'] ?? ''),
            ),
          ],
        ),
      ],
    ),

    // Platform services (zakat / prayer times / quran) now live inside the public shell.
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.mosques, child: child),
      routes: [
        GoRoute(
          path: '/mosques-system',
          redirect: (context, state) => AppRoutes.adminDashboard,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.mosques.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.mosques.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.mosques.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.mosques.slug),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SystemShell(systemKey: SystemKey.billing, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.billing,
          redirect: (context, state) => AppRoutes.adminDashboard,
          routes: [
            GoRoute(
              path: 'news',
              builder: (context, state) =>
                  NewsScreen(unitSlug: SystemKey.billing.slug),
            ),
            GoRoute(
              path: 'news/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                final extra = state.extra is NewsArticle
                    ? state.extra as NewsArticle
                    : null;
                return NewsDetailRouteScreen(
                  unitSlug: SystemKey.billing.slug,
                  id: id,
                  extraArticle: extra,
                );
              },
            ),
            GoRoute(
              path: 'announcements',
              builder: (context, state) =>
                  AnnouncementsScreen(unitSlug: SystemKey.billing.slug),
            ),
            GoRoute(
              path: 'activities',
              builder: (context, state) =>
                  ActivitiesScreen(unitSlug: SystemKey.billing.slug),
            ),
          ],
        ),
      ],
    ),
  ];
}
