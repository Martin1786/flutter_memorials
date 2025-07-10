import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Infinite scroll
  static const int _batchSize = 30;
  int _loadedCount = 30;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 300 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      } catch (_) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _handleInfiniteScroll(int totalCount) {
    if (_isLoadingMore) return;
    if (_loadedCount < totalCount) {
      _isLoadingMore = true;
      setState(() {
        _loadedCount += _batchSize;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        _isLoadingMore = false;
      });
    }
  }

  Future<Widget> _buildAbbreviationField(
      BuildContext context, int abbreviationId) async {
    final query = await FirebaseFirestore.instance
        .collection('abbreviations')
        .where('ID', isEqualTo: abbreviationId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      final abbr = data['Abbreviation'] ?? '';
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Abbreviation: ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _showAbbreviationDialog(context, abbreviationId),
            child: Text(
              abbr,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Abbreviation: ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Not found'),
        ],
      );
    }
  }

  void _showAbbreviationDialog(BuildContext context, int abbreviationId) async {
    final query = await FirebaseFirestore.instance
        .collection('abbreviations')
        .where('ID', isEqualTo: abbreviationId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(data['Abbreviation'] ?? 'Abbreviation'),
          content: Text(data['Meaning'] ?? 'No meaning found.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Abbreviation'),
          content: const Text('No meaning found for this abbreviation.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${data['Forename'] ?? ''} ${data['Surname'] ?? ''}'),
        content: SingleChildScrollView(
          child: FutureBuilder<Widget?>(
            future: () async {
              List<Widget> fields = [];
              Widget? abbreviationWidget;
              Widget? xyWidget;
              Widget? rowWidget;
              // Move Date of Death to the top if present
              if (data.containsKey('Date of Death') &&
                  data['Date of Death'] != null) {
                fields.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date of Death: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text('${data['Date of Death']}')),
                    ],
                  ),
                ));
              }
              // Add Forename and Surname in order
              if (data.containsKey('Forename')) {
                fields.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Forename: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text('${data['Forename'] ?? ''}')),
                    ],
                  ),
                ));
              }
              if (data.containsKey('Surname')) {
                fields.add(Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Surname: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text('${data['Surname'] ?? ''}')),
                    ],
                  ),
                ));
              }
              for (final entry in data.entries) {
                if (entry.key == 'ID' ||
                    entry.key == 'Old Plot' ||
                    entry.key == 'Date of Death' ||
                    entry.key == 'Forename' ||
                    entry.key == 'Surname') {
                  // Skip these fields (already handled or not needed)
                  continue;
                }
                if (entry.key == 'Abbreviation' &&
                    entry.value != null &&
                    entry.value.toString().isNotEmpty) {
                  final abbrValue = entry.value.toString();
                  final id = int.tryParse(abbrValue);
                  if (id != null) {
                    abbreviationWidget =
                        await _buildAbbreviationField(context, id);
                  } else {
                    abbreviationWidget = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Abbreviation: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(abbrValue),
                                content: const Text('No further info found.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Text(
                            abbrValue,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  continue; // Do not add to fields here
                } else if (entry.key == 'XY') {
                  xyWidget = Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('XY: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text('${entry.value ?? ''}')),
                      ],
                    ),
                  );
                  continue; // Do not add to fields here
                } else if (entry.key == 'Row') {
                  rowWidget = Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Row: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text('${entry.value ?? ''}')),
                      ],
                    ),
                  );
                } else if (entry.key == 'New Plot') {
                  fields.add(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Plot: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text('${entry.value ?? ''}')),
                      ],
                    ),
                  ));
                } else if (entry.key == 'Section') {
                  // Add Section, then Row (if present) immediately after
                  fields.add(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Section: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text('${entry.value ?? ''}')),
                      ],
                    ),
                  ));
                  if (rowWidget != null) {
                    fields.add(rowWidget);
                    rowWidget = null; // Prevent double-adding
                  }
                } else {
                  fields.add(Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${entry.key}: ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(child: Text('${entry.value ?? ''}')),
                      ],
                    ),
                  ));
                }
              }
              // Always add abbreviation immediately before XY at the end
              if (abbreviationWidget != null) {
                fields.add(const SizedBox(height: 8));
                fields.add(abbreviationWidget);
              }
              if (xyWidget != null) {
                fields.add(const SizedBox(height: 8));
                fields.add(xyWidget);
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fields,
              );
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return snapshot.data ?? const SizedBox.shrink();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by Surname or Forename',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _loadedCount = _batchSize; // Reset on new search
                      });
                    },
                  ),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sections')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: \\${snapshot.error}'));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No sections found.'));
                    }
                    // Sort by Surname before display, putting missing/empty surnames ('Unknown') at the bottom
                    docs.sort((a, b) {
                      final aMap = a.data() as Map<String, dynamic>;
                      final bMap = b.data() as Map<String, dynamic>;
                      final aSurname =
                          (aMap['Surname']?.toString().trim().isNotEmpty ??
                                  false)
                              ? aMap['Surname'].toString().toLowerCase()
                              : 'zzzzzzzz'; // Sort 'Unknown' to bottom
                      final bSurname =
                          (bMap['Surname']?.toString().trim().isNotEmpty ??
                                  false)
                              ? bMap['Surname'].toString().toLowerCase()
                              : 'zzzzzzzz'; // Sort 'Unknown' to bottom
                      return aSurname.compareTo(bSurname);
                    });
                    // Filter by search query
                    final filteredDocs = _searchQuery.isEmpty
                        ? docs
                        : docs.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final surname = (data['Surname'] ?? '')
                                .toString()
                                .toLowerCase();
                            final forename = (data['Forename'] ?? '')
                                .toString()
                                .toLowerCase();
                            final query = _searchQuery.toLowerCase();
                            return surname.contains(query) ||
                                forename.contains(query);
                          }).toList();
                    final visibleDocs =
                        filteredDocs.take(_loadedCount).toList();
                    final showLoader = _loadedCount < filteredDocs.length;
                    return ListView.builder(
                      key: const PageStorageKey('sections-list'),
                      controller: _scrollController,
                      cacheExtent: 500,
                      itemCount: visibleDocs.length + (showLoader ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Only trigger loading more from the loading indicator at the end
                        if (index == visibleDocs.length && showLoader) {
                          if (!_isLoadingMore) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _handleInfiniteScroll(filteredDocs.length);
                            });
                          }
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final data =
                            visibleDocs[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            '${(data['Surname']?.toString().trim().isNotEmpty ?? false) ? data['Surname'] : 'Unknown'}, ${data['Forename'] ?? ''}')),
                                    if (data['Section'] != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                            'Section: ${data['Section']}',
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ),
                                    if (data['New Plot'] != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text('Plot: ${data['New Plot']}',
                                            style:
                                                const TextStyle(fontSize: 13)),
                                      ),
                                  ],
                                ),
                                if (data['Date of Death'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                        'Date of Death: ${data['Date of Death']}',
                                        style: const TextStyle(fontSize: 13)),
                                  ),
                              ],
                            ),
                            subtitle: null,
                            onTap: () => _showDetailsDialog(context, data),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_showScrollToTop)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward),
              ),
            ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Optionally, navigate to login or show a message
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
