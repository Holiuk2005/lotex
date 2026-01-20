import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lotex/services/logistics_service.dart';

class CitySearch extends StatefulWidget {
  final LogisticsService logistics;

  const CitySearch({
    super.key,
    required this.logistics,
  });

  @override
  State<CitySearch> createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  late final TextEditingController _controller;

  Timer? _debounce;
  bool _isLoading = false;
  String? _error;
  List<City> _results = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    if (!mounted) return;
    final q = query.trim();
    if (q.length < 2) {
      if (!mounted) return;
      setState(() {
        _results = const [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cities = await widget.logistics.searchCity(q);
      if (!mounted) return;
      setState(() {
        _results = cities;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _results = const [];
      });
    }
  }

  void _onChanged(String value) {
    // Debounce: wait 500ms after user stops typing before calling API.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _runSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.18 * 255).round()),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Оберіть місто',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Почніть вводити (напр. “Льв”)…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final city = _results[index];
                    return ListTile(
                      title: Text(city.name),
                      subtitle: Text(city.ref),
                      onTap: () => Navigator.of(context).pop(city),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _results.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
