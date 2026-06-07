// lib/screens/market_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import 'package:agri_helper/screens/menubar.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  // -----------------------
  // CONFIG
  // -----------------------
  // Change to your deployed API base URL. For Android emulator use http://10.0.2.2:5000
  final String apiBase = 'http://10.0.2.2:5000';
  final String apiKey = '579b464db66ec23bdd00000186a3ab5c257843e0633f348512a69c8a';

  // -----------------------
  // STATE
  // -----------------------
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  String? _errorMessage;
  String? _lastUpdated;
  List<MarketPrice> _prices = [];

  // default fallback products
  final List<MarketPrice> _defaultProducts = [
    MarketPrice(crop: 'wheat', pricePerKg: 25.39, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'rice', pricePerKg: 40.0, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'onion', pricePerKg: 13.7, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'potato', pricePerKg: 13.46, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'tomato', pricePerKg: 25.16, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'banana', pricePerKg: 17.23, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'sugar', pricePerKg: 42.5, exampleMarket: 'Local mill', exampleSource: 'default'),
    MarketPrice(crop: 'maize', pricePerKg: 23.0, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'soybean', pricePerKg: 45.0, exampleMarket: 'Local mandi', exampleSource: 'default'),
    MarketPrice(crop: 'chilli', pricePerKg: 120.0, exampleMarket: 'Local mandi', exampleSource: 'default'),
  ];

  // counter used to ignore stale API responses
  int _searchCounter = 0;

  @override
  void initState() {
    super.initState();
    _prices = List<MarketPrice>.from(_defaultProducts);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Debounced input handler with immediate local promotion
  void _onSearchChanged() {
    final rawQuery = _searchController.text;
    final query = rawQuery.trim();

    // Immediately show local/default matches so user sees result without waiting
    if (query.isEmpty) {
      setState(() {
        _prices = List<MarketPrice>.from(_defaultProducts);
        _errorMessage = null;
        _lastUpdated = null;
      });
    } else {
      final lower = query.toLowerCase();
      final matches = _defaultProducts.where((p) => p.crop.toLowerCase().contains(lower)).toList();
      if (matches.isNotEmpty) {
        final rest = _defaultProducts.where((p) => !matches.contains(p)).toList();
        setState(() {
          _prices = [...matches, ...rest];
          _errorMessage = null;
        });
      } else {
        // If no local match, show full defaults so UI isn't empty
        setState(() {
          _prices = List<MarketPrice>.from(_defaultProducts);
          _errorMessage = null;
        });
      }
    }

    // still debounce the network request
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      final trimmed = _searchController.text.trim();
      if (trimmed.isEmpty) {
        setState(() {
          _prices = List<MarketPrice>.from(_defaultProducts);
          _errorMessage = null;
          _lastUpdated = null;
        });
      } else {
        _performSearchAndPromote(trimmed);
      }
    });
  }

  // Called when user presses search on keyboard or taps search icon
  void _onSearchSubmitted(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _prices = List<MarketPrice>.from(_defaultProducts);
        _errorMessage = null;
        _lastUpdated = null;
      });
    } else {
      _performSearchAndPromote(trimmed);
    }
  }

  // Helper: move items that match query (case-insensitive substring) to the front of list
  List<MarketPrice> _promoteQueryInList(List<MarketPrice> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    final matching = <MarketPrice>[];
    final others = <MarketPrice>[];
    for (final item in list) {
      final name = item.crop.toLowerCase();
      if (name.contains(q)) {
        matching.add(item);
      } else {
        others.add(item);
      }
    }
    return [...matching, ...others];
  }

  // Core: try API; if API fails or returns empty -> fallback to default match.
  // When we show results, ensure the searched item(s) appear first.
  Future<void> _performSearchAndPromote(String query) async {
    final int thisSearchId = ++_searchCounter;
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$apiBase/api/prices?crop=${Uri.encodeComponent(query)}');
      final headers = {'Accept': 'application/json', 'Authorization': 'Bearer $apiKey'};

      final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));

      // ignore stale responses
      if (thisSearchId != _searchCounter) return;

      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(resp.body) as Map<String, dynamic>;
        final raw = (jsonData['prices'] as List<dynamic>?) ?? [];

        if (raw.isEmpty) {
          // API returned nothing — fallback to matching default
          _fallbackToDefaultMatch(query, note: 'No live data found for "$query". Showing default match.');
          _lastUpdated = jsonData['last_updated'] as String?;
        } else {
          // parse and show results, promoting search match to front
          final fetched = raw.map((e) => MarketPrice.fromJson(e as Map<String, dynamic>)).toList();
          final promoted = _promoteQueryInList(fetched, query);
          setState(() {
            _prices = promoted;
            _lastUpdated = jsonData['last_updated'] as String? ?? (promoted.isNotEmpty ? promoted.first.lastFetched : null);
            _errorMessage = null;
          });
        }
      } else if (resp.statusCode == 401 || resp.statusCode == 403) {
        // auth error -> fallback to default match
        _fallbackToDefaultMatch(query, note: 'Unauthorized — check API key. Showing default match.');
      } else {
        // server error -> fallback
        _fallbackToDefaultMatch(query, note: 'Server error (${resp.statusCode}). Showing default match.');
      }
    } on TimeoutException {
      if (thisSearchId != _searchCounter) return;

      // Promote default match on timeout
      final lower = query.toLowerCase();
      final matches = _defaultProducts.where((p) => p.crop.toLowerCase().contains(lower)).toList();

      setState(() {
        _errorMessage = 'Request timed out. Showing default match.';
        if (matches.isNotEmpty) {
          final rest = _defaultProducts.where((p) => !matches.contains(p)).toList();
          _prices = [...matches, ...rest];
        } else {
          _prices = List<MarketPrice>.from(_defaultProducts);
        }
      });
    } catch (e) {
      if (thisSearchId != _searchCounter) return;

      // On any other error, promote default match
      final lower = query.toLowerCase();
      final matches = _defaultProducts.where((p) => p.crop.toLowerCase().contains(lower)).toList();

      setState(() {
        _errorMessage = 'Failed to search: ${e.toString()}. Showing default match.';
        if (matches.isNotEmpty) {
          final rest = _defaultProducts.where((p) => !matches.contains(p)).toList();
          _prices = [...matches, ...rest];
        } else {
          _prices = List<MarketPrice>.from(_defaultProducts);
        }
      });
    } finally {
      if (thisSearchId == _searchCounter) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // Sets _prices to matching default product(s) if found; otherwise to full defaults.
  // Ensures matches appear first.
  void _fallbackToDefaultMatch(String query, {String? note}) {
    final lower = query.toLowerCase();
    final matches = _defaultProducts.where((p) => p.crop.toLowerCase().contains(lower)).toList();

    setState(() {
      _errorMessage = note;
      if (matches.isNotEmpty) {
        final rest = _defaultProducts.where((p) => !matches.contains(p)).toList();
        _prices = [...matches, ...rest];
      } else {
        _prices = List<MarketPrice>.from(_defaultProducts);
      }
    });
  }

  // fetch aggregated list from API
  Future<void> _fetchAllPrices() async {
    final int thisSearchId = ++_searchCounter;
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$apiBase/api/prices');
      final headers = {'Accept': 'application/json', 'Authorization': 'Bearer $apiKey'};
      final resp = await http.get(uri, headers: headers).timeout(const Duration(seconds: 12));

      if (thisSearchId != _searchCounter) return;

      if (resp.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(resp.body) as Map<String, dynamic>;
        final raw = (jsonData['prices'] as List<dynamic>?) ?? [];
        if (raw.isEmpty) {
          setState(() {
            _errorMessage = 'No aggregated data available. Showing defaults.';
            _prices = List<MarketPrice>.from(_defaultProducts);
          });
        } else {
          final fetched = raw.map((e) => MarketPrice.fromJson(e as Map<String, dynamic>)).toList();
          final currentQuery = _searchController.text.trim();
          final promoted = currentQuery.isNotEmpty ? _promoteQueryInList(fetched, currentQuery) : fetched;
          setState(() {
            _prices = promoted;
            _lastUpdated = jsonData['last_updated'] as String? ?? (promoted.isNotEmpty ? promoted.first.lastFetched : null);
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error (${resp.statusCode})';
          _prices = List<MarketPrice>.from(_defaultProducts);
        });
      }
    } on TimeoutException {
      if (thisSearchId != _searchCounter) return;
      setState(() {
        _errorMessage = 'Request timed out. Showing defaults.';
        _prices = List<MarketPrice>.from(_defaultProducts);
      });
    } catch (e) {
      if (thisSearchId != _searchCounter) return;
      setState(() {
        _errorMessage = 'Failed to fetch: ${e.toString()}. Showing defaults.';
        _prices = List<MarketPrice>.from(_defaultProducts);
      });
    } finally {
      if (thisSearchId == _searchCounter) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // Pull-to-refresh
  Future<void> _onRefresh() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      await _fetchAllPrices();
    } else {
      await _performSearchAndPromote(q);
    }
    if (_errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage!)));
    }
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: AppMenuDrawer(onNavigate: (dest) {
        Navigator.pop(context);
        switch (dest) {
          case MenuDestination.home:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case MenuDestination.schemes:
            Navigator.pushReplacementNamed(context, '/schemes');
            break;
          case MenuDestination.practices:
            Navigator.pushReplacementNamed(context, '/practices');
            break;
          case MenuDestination.market:
            break;
          case MenuDestination.expertHelp:
            Navigator.pushNamed(context, '/expert_help');
            break;
          case MenuDestination.profile:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
          case MenuDestination.logout:
            Navigator.pushReplacementNamed(context, '/login');
            break;
        }
      }),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text('Market Prices'),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _isSearching ? null : _onRefresh,
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Search crop (e.g. wheat, onion)...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                          FocusScope.of(context).unfocus();
                        },
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_isSearching)
                  const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _onSearchSubmitted(_searchController.text),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(onRefresh: _onRefresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_prices.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(_errorMessage ?? 'No products to show', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _prices.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildHeaderCard();
        final item = _prices[index - 1];
        return _buildPriceCard(item);
      },
    );
  }

  Widget _buildHeaderCard() {
    final query = _searchController.text.trim();
    final title = query.isEmpty ? 'Popular Products (per 1 kg)' : 'Search: "$query"';
    final subtitle = _lastUpdated != null ? 'Last refreshed: $_lastUpdated' : (_errorMessage ?? 'Showing results');
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: _isSearching ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : null,
      ),
    );
  }

  Widget _buildPriceCard(MarketPrice data) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        title: Text(_capitalize(data.crop), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.exampleMarket != null) Text(data.exampleMarket!, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text('Source: ${data.exampleSource ?? '—'}', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('₹${data.pricePerKg?.toStringAsFixed(2) ?? '—'} / kg', style: TextStyle(fontSize: 16, color: AppColors.accentBlue)),
            const SizedBox(height: 6),
            if (data.lastFetched != null) Text(data.lastFetched!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        onTap: () => _showPriceDetails(data),
      ),
    );
  }

  void _showPriceDetails(MarketPrice item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
              Text(_capitalize(item.crop), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              const SizedBox(height: 8),
              if (item.exampleMarket != null) Text(item.exampleMarket!, style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ListTile(leading: const Icon(Icons.monetization_on), title: const Text('Price per 1 kg'), subtitle: Text('₹${item.pricePerKg?.toStringAsFixed(2) ?? '—'}')),
              if (item.exampleSource != null) ListTile(leading: const Icon(Icons.source), title: const Text('Source'), subtitle: Text(item.exampleSource!)),
              if (item.sourcesCovered != null) ListTile(leading: const Icon(Icons.link), title: const Text('Sources aggregated'), subtitle: Text('${item.sourcesCovered}')),
              if (item.lastFetched != null) ListTile(leading: const Icon(Icons.access_time), title: const Text('Last fetched'), subtitle: Text(item.lastFetched!)),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen), child: const Text('Close'))),
            ],
          ),
        );
      },
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class MarketPrice {
  final String crop;
  final double? pricePerKg;
  final String? exampleMarket;
  final String? exampleSource;
  final String? lastFetched;
  final int? sourcesCovered;

  MarketPrice({
    required this.crop,
    this.pricePerKg,
    this.exampleMarket,
    this.exampleSource,
    this.lastFetched,
    this.sourcesCovered,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      crop: (json['crop'] as String?) ?? 'unknown',
      pricePerKg: (json['price_per_kg'] is num) ? (json['price_per_kg'] as num).toDouble() : (json['price_per_kg'] != null ? double.tryParse(json['price_per_kg'].toString()) : null),
      exampleMarket: json['example_market'] as String?,
      exampleSource: json['example_source'] as String?,
      lastFetched: json['last_fetched'] as String?,
      sourcesCovered: json['sources_covered'] is int ? json['sources_covered'] as int : (json['sources_covered'] != null ? int.tryParse(json['sources_covered'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crop': crop,
      'price_per_kg': pricePerKg,
      'example_market': exampleMarket,
      'example_source': exampleSource,
      'last_fetched': lastFetched,
      'sources_covered': sourcesCovered,
    };
  }
}
