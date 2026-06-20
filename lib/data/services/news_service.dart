import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_article.dart';
import 'media_compat_mapper.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const bool _forceLegacyPublicMedia = bool.fromEnvironment(
    'PWF_FORCE_LEGACY_PUBLIC_MEDIA',
    defaultValue: false,
  );
  static const bool _mediaOwnerReadDefault = !_forceLegacyPublicMedia;
  static const Duration _mediaOwnerRuntimeTimeout = Duration(seconds: 8);

  Future<List<NewsArticle>> _getCompatNews({
    int? limit,
    int? offset,
    String? unitSlug,
    NewsCategory? category,
    String? searchQuery,
  }) async {
    if (!_mediaOwnerReadDefault) {
      _logMediaRuntimeFallback(
        family: 'news',
        reason: 'forced-legacy-public-media',
      );
      return const <NewsArticle>[];
    }

    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.vMediaNewsCompatV1)
          .select('*')
          .timeout(_mediaOwnerRuntimeTimeout);

      var items = (response as List<dynamic>)
          .map(
            (json) => MediaCompatMapper.newsFromCompatRow(
              json as Map<String, dynamic>,
            ),
          )
          .where((article) => article.status == PublishStatus.published)
          .toList();

      final normalizedUnitSlug = unitSlug?.trim().toLowerCase();
      if (normalizedUnitSlug != null &&
          normalizedUnitSlug.isNotEmpty &&
          normalizedUnitSlug != 'home') {
        items = items
            .where(
              (article) =>
                  (article.unitId ?? '').trim().toLowerCase() ==
                  normalizedUnitSlug,
            )
            .toList();
      }

      if (category != null && category != NewsCategory.general) {
        items = items.where((article) => article.category == category).toList();
      }

      final q = searchQuery?.trim().toLowerCase();
      if (q != null && q.isNotEmpty) {
        items = items.where((article) {
          return article.title.toLowerCase().contains(q) ||
              article.content.toLowerCase().contains(q) ||
              article.excerpt.toLowerCase().contains(q);
        }).toList();
      }

      _sortNewsOwnerRows(items);
      final windowed = _window(items, limit: limit, offset: offset);
      _logMediaRuntimeSource(
        family: 'news',
        surface: PwfDatabaseOwnerSurfaces.vMediaNewsCompatV1,
        rows: windowed.length,
      );
      return windowed;
    } on TimeoutException {
      _logMediaRuntimeFallback(family: 'news', reason: 'owner-timeout');
      return const <NewsArticle>[];
    } catch (e, stackTrace) {
      dev.log(
        'Media Center owner-read news runtime failed; legacy fallback may run.',
        name: 'NewsService',
        error: e,
        stackTrace: stackTrace,
      );
      _logMediaRuntimeFallback(family: 'news', reason: 'owner-failure');
      return const <NewsArticle>[];
    }
  }

  void _sortNewsOwnerRows(List<NewsArticle> items) {
    items.sort((a, b) {
      final pinned = _boolDesc(a.isPinned, b.isPinned);
      if (pinned != 0) return pinned;
      final order = a.sortOrder.compareTo(b.sortOrder);
      if (order != 0) return order;
      final aDate = a.publishedAt ?? a.createdAt;
      final bDate = b.publishedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
  }

  int _boolDesc(bool a, bool b) => a == b ? 0 : (a ? -1 : 1);

  List<T> _window<T>(List<T> items, {int? limit, int? offset}) {
    final start = offset == null || offset < 0 ? 0 : offset;
    if (start >= items.length) return <T>[];
    final end = limit == null
        ? items.length
        : (start + limit).clamp(0, items.length).toInt();
    return items.sublist(start, end);
  }

  void _logMediaRuntimeSource({
    required String family,
    required String surface,
    required int rows,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_ROOT_CUTOVER '
      'family=$family '
      'owner_read=true '
      'surface=public.$surface '
      'projection=* '
      'filtering=client-side '
      'ordering=client-side '
      'rows=$rows '
      'decision=media-center-owner-read-default-root-cutover',
    );
  }

  void _logMediaRuntimeFallback({
    required String family,
    required String reason,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      'PWF_MEDIA_CENTER_LEGACY_FALLBACK_ONLY '
      'family=$family '
      'legacy_public_fallback=true '
      'reason=$reason '
      'decision=media-center-legacy-public-fallback-only',
    );
  }

  Future<NewsArticle?> _getCompatNewsById(int id, {String? unitSlug}) async {
    if (!_mediaOwnerReadDefault) return null;
    try {
      final items = await _getCompatNews(limit: 500, unitSlug: unitSlug);
      for (final item in items) {
        if (item.id == id) return item;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // news_service.dart - Clean version
  Future<List<NewsArticle>> getAllNews({int? limit, int? offset}) async {
    final compat = await _getCompatNews(limit: limit, offset: offset);
    if (compat.isNotEmpty) return compat;

    try {
      var query = _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .order('published_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews();
    }
  }

  // Get featured news articles
  Future<List<NewsArticle>> getFeaturedNews({int limit = 5}) async {
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat.take(limit).toList();

    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .eq('is_featured', true)
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews().where((article) => article.isFeatured).toList();
    }
  }

  // Get latest news articles
  Future<List<NewsArticle>> getLatestNews({int limit = 10}) async {
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat;

    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews().take(limit).toList();
    }
  }

  // Get news by category
  Future<List<NewsArticle>> getNewsByCategory(NewsCategory category) async {
    final compat = await _getCompatNews(category: category);
    if (compat.isNotEmpty) return compat;

    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .eq('category', category.name)
          .order('published_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews()
          .where((article) => article.category == category)
          .toList();
    }
  }

  // Get single news article by ID
  Future<NewsArticle?> getNewsById(int id) async {
    final compat = await _getCompatNewsById(id);
    if (compat != null) return compat;

    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('id', id)
          .eq('status', 'published')
          .single();

      return NewsArticle.fromJson(response);
    } catch (e) {
      return _getSampleNews().firstWhere((article) => article.id == id);
    }
  }

  // Search news articles
  Future<List<NewsArticle>> searchNews(String query) async {
    final compat = await _getCompatNews(searchQuery: query);
    if (compat.isNotEmpty) return compat;

    try {
      final response = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select()
          .eq('status', 'published')
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('published_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _getSampleNews()
          .where(
            (article) =>
                article.title.toLowerCase().contains(query.toLowerCase()) ||
                article.content.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // Get news statistics
  Future<Map<String, dynamic>> getNewsStatistics() async {
    final compat = await _getCompatNews(limit: 1000);
    if (compat.isNotEmpty) {
      return {
        'total_news': compat.length,
        'featured_news': compat.where((a) => a.isFeatured).length,
        'categories': NewsCategory.values.length,
        'runtime_source': 'public.v_media_news_compat_v1',
        'runtime_decision': 'media-center-owner-read-default-root-cutover',
      };
    }

    try {
      final totalNews = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select('id')
          .eq('status', 'published')
          .count(CountOption.exact);

      final featuredNews = await _supabase
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
          .select('id')
          .eq('status', 'published')
          .eq('is_featured', true)
          .count(CountOption.exact);

      return {
        'total_news': totalNews.count,
        'featured_news': featuredNews.count,
        'categories': NewsCategory.values.length,
      };
    } catch (e) {
      final sampleNews = _getSampleNews();
      return {
        'total_news': sampleNews.length,
        'featured_news': sampleNews.where((a) => a.isFeatured).length,
        'categories': NewsCategory.values.length,
      };
    }
  }

  // Increment view count
  Future<void> incrementViewCount(int articleId) async {
    try {
      await _supabase.rpc(
        'increment_view_count',
        params: {'article_id': articleId},
      );
    } catch (e) {
      // Handle error silently
    }
  }

  // No sample data — return empty list so the UI shows "لا توجد أخبار حالياً"
  List<NewsArticle> _getSampleNews() {
    return [];
  }

  // ============================
  // Unit-scoped methods (Institutional routing)
  // ============================

  Future<List<NewsArticle>> getAllNewsForUnit(
    String unitId, {
    int? limit,
    int? offset,
  }) async {
    final compat = await _getCompatNews(limit: limit, offset: offset);
    if (compat.isNotEmpty) return compat;

    try {
      // Try unit-scoped query first. If unit_id column doesn't exist yet,
      // fall back to global (home) news to avoid breaking the homepage.
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .order('published_at', ascending: false)
            .limit(limit ?? 1000);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .order('published_at', ascending: false)
            .limit(limit ?? 1000);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getLatestNewsForUnit(
    String unitId, {
    int limit = 10,
  }) async {
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat;

    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .order('published_at', ascending: false)
            .limit(limit);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .order('published_at', ascending: false)
            .limit(limit);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getFeaturedNewsForUnit(
    String unitId, {
    int limit = 5,
  }) async {
    final compat = await _getCompatNews(limit: limit);
    if (compat.isNotEmpty) return compat.take(limit).toList();

    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .eq('is_featured', true)
            .order('published_at', ascending: false)
            .limit(limit);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('is_featured', true)
            .order('published_at', ascending: false)
            .limit(limit);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<NewsArticle>> getNewsByCategoryForUnit(
    NewsCategory category,
    String unitId,
  ) async {
    final compat = await _getCompatNews(category: category);
    if (compat.isNotEmpty) return compat;

    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .eq('category', category.name)
            .order('published_at', ascending: false);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('category', category.name)
            .order('published_at', ascending: false);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<NewsArticle?> getNewsByIdForUnit(int id, String unitId) async {
    final compat = await _getCompatNewsById(id);
    if (compat != null) return compat;

    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('id', id)
            .eq('unit_id', unitId)
            .eq('status', 'published')
            .maybeSingle();
      } catch (_) {
        // Fallback when unit_id is not available in schema.
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('id', id)
            .eq('status', 'published')
            .maybeSingle();
      }
      if (response == null) return null;
      return NewsArticle.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  Future<List<NewsArticle>> searchNewsForUnit(
    String query,
    String unitId,
  ) async {
    final compat = await _getCompatNews(searchQuery: query);
    if (compat.isNotEmpty) return compat;

    try {
      dynamic response;
      try {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .eq('unit_id', unitId)
            .or('title.ilike.%$query%,content.ilike.%$query%')
            .order('published_at', ascending: false);
      } catch (_) {
        response = await _supabase
            .from(PwfDatabaseOwnerSurfaces.newsArticles)
            .select()
            .eq('status', 'published')
            .or('title.ilike.%$query%,content.ilike.%$query%')
            .order('published_at', ascending: false);
      }
      return (response as List).map((e) => NewsArticle.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
