import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearch = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Sorting state
  String _sortBy = 'Surname';
  bool _ascending = true;

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
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchQuery = '';
        _searchController.clear();
      } else {
        // Request focus when showing search
        Future.delayed(Duration.zero, () {
          _searchFocusNode.requestFocus();
        });
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
                        const Text('Location: ',
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

  void _showAddSectionDialog() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController surnameController = TextEditingController();
    final TextEditingController forenameController = TextEditingController();
    final TextEditingController sectionController = TextEditingController();
    final TextEditingController plotController = TextEditingController();
    final TextEditingController dateOfDeathController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Grave'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: forenameController,
                  decoration: const InputDecoration(labelText: 'Forename'),
                ),
                TextFormField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                TextFormField(
                  controller: plotController,
                  decoration: const InputDecoration(labelText: 'Plot'),
                ),
                TextFormField(
                  controller: dateOfDeathController,
                  decoration: const InputDecoration(labelText: 'Date of Death'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                await FirebaseFirestore.instance.collection('sections').add({
                  'Surname': surnameController.text,
                  'Forename': forenameController.text,
                  'Section': sectionController.text,
                  'New Plot': plotController.text,
                  'Date of Death': dateOfDeathController.text,
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSectionDialog(Map<String, dynamic> data, String docId) {
    final _formKey = GlobalKey<FormState>();
    // Create a controller for each field
    final Map<String, TextEditingController> controllers = {
      for (final entry in data.entries)
        entry.key: TextEditingController(text: entry.value?.toString() ?? ''),
    };

    // If Abbreviation is a number, fetch the text version from Firestore
    Future<void> _resolveAbbreviation() async {
      final abbrValue = data['Abbreviation']?.toString();
      if (abbrValue != null && int.tryParse(abbrValue) != null) {
        final query = await FirebaseFirestore.instance
            .collection('abbreviations')
            .where('ID', isEqualTo: int.parse(abbrValue))
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final abbrText =
              query.docs.first.data()['Abbreviation']?.toString() ?? abbrValue;
          controllers['Abbreviation']?.text = abbrText;
        }
      }
    }

    // Call the resolver if needed
    if (controllers.containsKey('Abbreviation')) {
      _resolveAbbreviation();
    }

    // Define the preferred order
    final List<String> preferredOrder = [
      'Surname',
      'Forename',
      'Date of Death',
      'New Plot',
      'Section',
      'Row',
      'Burial',
    ];

    // Build the ordered list of fields, excluding 'Old Plot' and 'ID'
    final List<String> orderedFields = [
      ...preferredOrder.where((key) => controllers.containsKey(key)),
      ...controllers.keys.where((key) =>
          !preferredOrder.contains(key) && key != 'Old Plot' && key != 'ID'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Grave Entry'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: orderedFields.map((key) {
                final label = key == 'XY' ? 'Location' : key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: TextFormField(
                    controller: controllers[key],
                    decoration: InputDecoration(labelText: label),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? true) {
                final Map<String, dynamic> updatedData = {
                  for (final entry in controllers.entries)
                    entry.key: entry.value.text,
                };
                await FirebaseFirestore.instance
                    .collection('sections')
                    .doc(docId)
                    .update(updatedData);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSection(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('sections')
                  .doc(docId)
                  .delete();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Sort By',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Surname'),
                trailing: _sortBy == 'Surname' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'Surname';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_on),
                title: const Text('Plot'),
                trailing:
                    _sortBy == 'New Plot' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'New Plot';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Section'),
                trailing: _sortBy == 'Section' ? const Icon(Icons.check) : null,
                onTap: () {
                  setState(() {
                    _sortBy = 'Section';
                  });
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                    _ascending ? Icons.arrow_upward : Icons.arrow_downward),
                title: Text(_ascending ? 'Ascending' : 'Descending'),
                onTap: () {
                  setState(() {
                    _ascending = !_ascending;
                  });
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('Test Scroll Page'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TestScrollPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
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
              stream:
                  FirebaseFirestore.instance.collection('sections').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No sections found.'));
                }
                // Sort by Surname before display, putting missing/empty surnames ('Unknown') at the bottom
                docs.sort((a, b) {
                  final aMap = a.data() as Map<String, dynamic>;
                  final bMap = b.data() as Map<String, dynamic>;
                  String aValue = '';
                  String bValue = '';
                  int cmp = 0;
                  if (_sortBy == 'Surname') {
                    aValue =
                        (aMap['Surname']?.toString().trim().isNotEmpty ?? false)
                            ? aMap['Surname'].toString().toLowerCase()
                            : 'zzzzzzzz';
                    bValue =
                        (bMap['Surname']?.toString().trim().isNotEmpty ?? false)
                            ? bMap['Surname'].toString().toLowerCase()
                            : 'zzzzzzzz';
                    cmp = aValue.compareTo(bValue);
                    if (cmp == 0) {
                      // Secondary sort by Section
                      final aSection =
                          (aMap['Section'] ?? '').toString().toLowerCase();
                      final bSection =
                          (bMap['Section'] ?? '').toString().toLowerCase();
                      cmp = aSection.compareTo(bSection);
                      if (cmp == 0) {
                        // Tertiary sort by Plot
                        final aPlot =
                            (aMap['New Plot'] ?? '').toString().toLowerCase();
                        final bPlot =
                            (bMap['New Plot'] ?? '').toString().toLowerCase();
                        cmp = aPlot.compareTo(bPlot);
                      }
                    }
                  } else if (_sortBy == 'New Plot') {
                    aValue = (aMap['New Plot'] ?? '').toString().toLowerCase();
                    bValue = (bMap['New Plot'] ?? '').toString().toLowerCase();
                    cmp = aValue.compareTo(bValue);
                    if (cmp == 0) {
                      // Secondary sort by Surname
                      final aSurname =
                          (aMap['Surname']?.toString().trim().isNotEmpty ??
                                  false)
                              ? aMap['Surname'].toString().toLowerCase()
                              : 'zzzzzzzz';
                      final bSurname =
                          (bMap['Surname']?.toString().trim().isNotEmpty ??
                                  false)
                              ? bMap['Surname'].toString().toLowerCase()
                              : 'zzzzzzzz';
                      cmp = aSurname.compareTo(bSurname);
                      if (cmp == 0) {
                        // Tertiary sort by Section
                        final aSection =
                            (aMap['Section'] ?? '').toString().toLowerCase();
                        final bSection =
                            (bMap['Section'] ?? '').toString().toLowerCase();
                        cmp = aSection.compareTo(bSection);
                      }
                    }
                  } else if (_sortBy == 'Section') {
                    aValue = (aMap['Section'] ?? '').toString().toLowerCase();
                    bValue = (bMap['Section'] ?? '').toString().toLowerCase();
                    cmp = aValue.compareTo(bValue);
                    if (cmp == 0) {
                      // Secondary sort by Surname
                      final aSurname =
                          (aMap['Surname']?.toString().trim().isNotEmpty ??
                                  false)
                              ? aMap['Surname'].toString().toLowerCase()
                              : 'zzzzzzzz';
                      final bSurname =
                          (bMap['Surname']?.toString().trim().isNotEmpty ??
                                  false)
                              ? bMap['Surname'].toString().toLowerCase()
                              : 'zzzzzzzz';
                      cmp = aSurname.compareTo(bSurname);
                      if (cmp == 0) {
                        // Tertiary sort by Plot
                        final aPlot =
                            (aMap['New Plot'] ?? '').toString().toLowerCase();
                        final bPlot =
                            (bMap['New Plot'] ?? '').toString().toLowerCase();
                        cmp = aPlot.compareTo(bPlot);
                      }
                    }
                  }
                  return _ascending ? cmp : -cmp;
                });
                // Filter by search query
                final filteredDocs = _searchQuery.isEmpty
                    ? docs
                    : docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final surname =
                            (data['Surname'] ?? '').toString().toLowerCase();
                        final forename =
                            (data['Forename'] ?? '').toString().toLowerCase();
                        final query = _searchQuery.toLowerCase();
                        return surname.contains(query) ||
                            forename.contains(query);
                      }).toList();
                final visibleDocs = filteredDocs.take(_loadedCount).toList();
                final showLoader = _loadedCount < filteredDocs.length;

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ScrollConfiguration(
                  behavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse
                    },
                  ),
                  child: ListView.builder(
                    key: const PageStorageKey('sections-list'),
                    controller: _scrollController,
                    cacheExtent: 500,
                    physics: const BouncingScrollPhysics(),
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
                      final doc = visibleDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
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
                                      child: Text('Section: ${data['Section']}',
                                          style: const TextStyle(fontSize: 13)),
                                    ),
                                  if (data['New Plot'] != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text('Plot: ${data['New Plot']}',
                                          style: const TextStyle(fontSize: 13)),
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit',
                                onPressed: () =>
                                    _showEditSectionDialog(data, doc.id),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDeleteSection(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_showScrollToTop)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton(
                mini: true,
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward),
                heroTag: 'scrollToTop',
              ),
            ),
          FloatingActionButton(
            onPressed: _showAddSectionDialog,
            child: const Icon(Icons.add),
            tooltip: 'Add New Grave',
            heroTag: 'addGrave',
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

class TestScrollPage extends StatelessWidget {
  const TestScrollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Scroll Page')),
      body: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) => ListTile(
          title: Text('Item #$index'),
        ),
      ),
    );
  }
}
