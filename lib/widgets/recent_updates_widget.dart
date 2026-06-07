// lib/widgets/recent_updates_widget.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsItem {
  final String title;
  final String link;
  final DateTime? pubDate;
  final String source;

  NewsItem({
    required this.title,
    required this.link,
    this.pubDate,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'link': link,
    'pubDate': pubDate?.toIso8601String(),
    'source': source,
  };

  static NewsItem fromJson(Map<String, dynamic> j) {
    return NewsItem(
      title: j['title'] ?? '',
      link: j['link'] ?? '',
      pubDate: j['pubDate'] != null ? DateTime.tryParse(j['pubDate']) : null,
      source: j['source'] ?? '',
    );
  }
}

class RecentUpdatesWidget extends StatefulWidget {
  final int maxItems;

  const RecentUpdatesWidget({super.key, this.maxItems = 6});

  @override
  State<RecentUpdatesWidget> createState() => _RecentUpdatesWidgetState();
}

class _RecentUpdatesWidgetState extends State<RecentUpdatesWidget> {
  bool _loading = true;
  String? _error;
  List<NewsItem> _items = [];

  // small curated list of agriculture feeds - you can customize
  final List<Map<String, String>> _feeds = [
    {'name': 'Agri-Pulse', 'url': 'https://www.agri-pulse.com/rss'},
    {'name': 'USDA News', 'url': 'https://www.usda.gov/rss'},
    {'name': 'World-Grain', 'url': 'https://www.world-grain.com/rss'},
    {'name': 'AgriFarming', 'url': 'https://www.agrifarming.in/feed'},
  ];

  static const String _cacheKey = 'cached_news_v1';

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();

    // Check network availability
    final bool online = await _checkNetwork();

    if (!online) {
      // Try loading cached data
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        try {
          final List decoded = jsonDecode(cached) as List;
          final cachedItems = decoded
              .map((e) => NewsItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          setState(() {
            _items = cachedItems.take(widget.maxItems).toList();
            _loading = false;
            _error = 'Offline: showing saved updates';
          });
          return;
        } catch (e) {
          // fall through to error message
          setState(() {
            _loading = false;
            _error = 'Offline and failed to read cache.';
          });
          return;
        }
      } else {
        setState(() {
          _loading = false;
          _error = 'No internet and no saved updates available.';
        });
        return;
      }
    }

    // Online: fetch feeds
    final List<NewsItem> all = [];
    for (final feed in _feeds) {
      final String name = feed['name']!;
      final String url = feed['url']!;
      try {
        final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200 && resp.body.isNotEmpty) {
          try {
            final doc = xml.XmlDocument.parse(resp.body);

            // RSS <item>
            final items = doc.findAllElements('item');
            if (items.isNotEmpty) {
              for (final item in items) {
                final title = item.findElements('title').map((n) => n.text).firstWhere((_) => true, orElse: () => 'No title');
                String link = '';
                // sometimes <link> contains text, sometimes href attribute
                final linkEl = item.findElements('link').firstWhere((_) => true, orElse: () => xml.XmlElement(xml.XmlName('link')));
                link = linkEl.text.trim();
                if (link.isEmpty) {
                  // try enclosure or guid
                  final guid = item.findElements('guid').map((n) => n.text).firstWhere((_) => true, orElse: () => '');
                  if (guid.isNotEmpty) link = guid;
                }
                final pubText = item.findElements('pubDate').map((n) => n.text).firstWhere((_) => true, orElse: () => '');
                DateTime? dt;
                try {
                  if (pubText.isNotEmpty) dt = DateTime.parse(pubText);
                } catch (_) {}
                if (title.isNotEmpty && link.isNotEmpty) {
                  all.add(NewsItem(title: title, link: link, pubDate: dt, source: name));
                }
              }
            } else {
              // Atom <entry>
              final entries = doc.findAllElements('entry');
              for (final e in entries) {
                final title = e.findElements('title').map((n) => n.text).firstWhere((_) => true, orElse: () => 'No title');
                String link = '';
                final linkElem = e.findElements('link').firstWhere((_) => true, orElse: () => xml.XmlElement(xml.XmlName('link')));
                link = linkElem.getAttribute('href') ?? linkElem.text;
                final dateText = e.findElements('updated').map((n) => n.text).firstWhere((_) => true, orElse: () => '');
                DateTime? dt;
                try {
                  if (dateText.isNotEmpty) dt = DateTime.parse(dateText);
                } catch (_) {}
                if (title.isNotEmpty && link.isNotEmpty) {
                  all.add(NewsItem(title: title, link: link, pubDate: dt, source: name));
                }
              }
            }
          } catch (_) {
            // ignore parse errors for this feed
          }
        }
      } catch (_) {
        // ignore per-feed network errors and continue
      }
    }

    // Sort newest-first
    all.sort((a, b) {
      if (a.pubDate == null && b.pubDate == null) return 0;
      if (a.pubDate == null) return 1;
      if (b.pubDate == null) return -1;
      return b.pubDate!.compareTo(a.pubDate!);
    });

    // Update state and cache
    final List<NewsItem> result = all.take(widget.maxItems).toList();
    setState(() {
      _items = result;
      _loading = false;
      _error = null;
    });

    try {
      final cachedData = result.map((e) => e.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(cachedData));
    } catch (_) {
      // caching failed silently
    }
  }

  Future<bool> _checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      }
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadFeeds,
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('No recent updates currently. Pull to refresh.'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              onPressed: _loadFeeds,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeeds,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          final subtitle = item.pubDate != null
              ? '${item.source} · ${_formatDate(item.pubDate!)}'
              : item.source;
          return ListTile(
            title: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openLink(item.link),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
