import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'dart:io'; // Added for File

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
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Data state
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _allDocs = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filteredDocs = [];

  // Infinite scroll
  static const int _batchSize = 30;
  int _loadedCount = 30;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isLoadingMore = false;

  // Maintain a sortedDocs list in state
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortedDocs = [];

  // Add a vertical scroll controller for the DataTable
  final ScrollController _verticalTableScrollController = ScrollController();
  int _latestFilteredDocsLength =
      0; // Track the latest filteredDocs length for infinite scroll
  DateTime? _lastScrollTime; // For debounce

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
    // Add listener for vertical table scroll to trigger infinite scroll
    _verticalTableScrollController.addListener(() {
      // Debounce: only trigger every 200ms
      final now = DateTime.now();
      if (_lastScrollTime != null &&
          now.difference(_lastScrollTime!).inMilliseconds < 200) {
        return;
      }
      _lastScrollTime = now;
      if (_verticalTableScrollController.position.pixels >=
          _verticalTableScrollController.position.maxScrollExtent - 100) {
        // Near the bottom, load more
        if (mounted) {
          _handleInfiniteScroll(_latestFilteredDocsLength);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _verticalTableScrollController.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterAndSortDocs();
    });
  }

  void _filterAndSortDocs() {
    _filteredDocs = _searchQuery.isEmpty
        ? List.from(_allDocs)
        : _allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final surname = (data['Surname'] ?? '').toString().toLowerCase();
            final forename = (data['Forename'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return surname.contains(query) || forename.contains(query);
          }).toList();
    _sortDocs(_sortColumnIndex, _sortAscending);
  }

  void _sortDocs(int columnIndex, bool ascending) {
    DateTime? parseDate(String s) {
      try {
        // Assuming format is dd/MM/yyyy
        final parts = s.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
      return null;
    }

    _filteredDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      if (columnIndex == 0) {
        // Name
        final aSurname = (aData?['Surname'] ?? '').toString();
        final aForename = (aData?['Forename'] ?? '').toString();
        final bSurname = (bData?['Surname'] ?? '').toString();
        final bForename = (bData?['Forename'] ?? '').toString();
        final aName = (aSurname + aForename).toLowerCase();
        final bName = (bSurname + bForename).toLowerCase();
        return ascending ? aName.compareTo(bName) : bName.compareTo(aName);
      } else if (columnIndex == 1) {
        // Died
        final aDateStr = (aData?['Date of Death'] ?? '').toString();
        final bDateStr = (bData?['Date of Death'] ?? '').toString();
        final aDate = parseDate(aDateStr);
        final bDate = parseDate(bDateStr);
        if (aDate != null && bDate != null) {
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        } else {
          // Fallback to string comparison if parsing fails
          return ascending
              ? aDateStr.compareTo(bDateStr)
              : bDateStr.compareTo(aDateStr);
        }
      }
      return 0;
    });
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortDocs(columnIndex, ascending);
    });
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
        final newCount = _loadedCount + _batchSize;
        _loadedCount = newCount > totalCount ? totalCount : newCount;
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        _isLoadingMore = false;
      });
    } else {
      // Clamp: never allow _loadedCount to exceed totalCount
      if (_loadedCount > totalCount) {
        setState(() {
          _loadedCount = totalCount;
        });
      }
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

              // Camera icon row (show at the top, before other fields)
              fields.add(Row(
                children: [
                  Icon(
                    (data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty)
                        ? Icons.camera
                        : Icons.block,
                    color: (data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty)
                        ? AppConstants.nameWithPhotoColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty)
                        ? 'Photo available'
                        : 'No photo',
                    style: TextStyle(
                      color: (data['imageUrl'] != null &&
                              data['imageUrl'].toString().isNotEmpty)
                          ? AppConstants.nameWithPhotoColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ));
              // Display image if imageUrl is present
              if (data['imageUrl'] != null &&
                  data['imageUrl'].toString().isNotEmpty) {
                fields.add(Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.black.withOpacity(0.95),
                              insetPadding: const EdgeInsets.all(16),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Image.network(
                                      data['imageUrl'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white, size: 32),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          data['imageUrl'],
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Click to enlarge',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ));
              }
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
                    entry.key == 'Surname' ||
                    entry.key == 'imageUrl' ||
                    entry.key == 'Link') {
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
    final TextEditingController plotController = TextEditingController();
    final TextEditingController dateOfDeathController = TextEditingController();
    String? sectionValue;
    final List<String> sectionOptions = ['A', 'B', 'C', 'D', 'E', 'F'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  TextFormField(
                    controller: forenameController,
                    decoration: const InputDecoration(labelText: 'Forename'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: sectionValue,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: sectionOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        sectionValue = val;
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: plotController,
                    decoration: const InputDecoration(labelText: 'Plot'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Plot must be a number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: dateOfDeathController,
                    decoration: const InputDecoration(
                        labelText: 'Date of Death (dd/MM/yyyy)'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final regex = RegExp(
                          r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$');
                      if (!regex.hasMatch(value.trim())) {
                        return 'Enter date as dd/MM/yyyy';
                      }
                      try {
                        final parts = value.trim().split('/');
                        final date = DateTime(
                          int.parse(parts[2]),
                          int.parse(parts[1]),
                          int.parse(parts[0]),
                        );
                        if (date.isAfter(DateTime.now())) {
                          return 'Date must be in the past';
                        }
                      } catch (_) {
                        return 'Invalid date';
                      }
                      return null;
                    },
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
                    'Surname': surnameController.text.trim(),
                    'Forename': forenameController.text.trim(),
                    'Section': sectionValue,
                    'New Plot': plotController.text.trim(),
                    'Date of Death': dateOfDeathController.text.trim(),
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grave entry added.')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSectionDialog(Map<String, dynamic> data, String docId) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController surnameController =
        TextEditingController(text: data['Surname']?.toString() ?? '');
    final TextEditingController forenameController =
        TextEditingController(text: data['Forename']?.toString() ?? '');
    final TextEditingController plotController =
        TextEditingController(text: data['New Plot']?.toString() ?? '');
    final TextEditingController dateOfDeathController =
        TextEditingController(text: data['Date of Death']?.toString() ?? '');
    String? sectionValue = data['Section']?.toString();
    final List<String> sectionOptions = ['A', 'B', 'C', 'D', 'E', 'F'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Grave Entry'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: surnameController,
                    decoration: const InputDecoration(labelText: 'Surname'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  TextFormField(
                    controller: forenameController,
                    decoration: const InputDecoration(labelText: 'Forename'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: sectionOptions.contains(sectionValue)
                        ? sectionValue
                        : null,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: sectionOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        sectionValue = val;
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: plotController,
                    decoration: const InputDecoration(labelText: 'Plot'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Plot must be a number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: dateOfDeathController,
                    decoration: const InputDecoration(
                        labelText: 'Date of Death (dd/MM/yyyy)'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      final regex = RegExp(
                          r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$');
                      if (!regex.hasMatch(value.trim())) {
                        return 'Enter date as dd/MM/yyyy';
                      }
                      try {
                        final parts = value.trim().split('/');
                        final date = DateTime(
                          int.parse(parts[2]),
                          int.parse(parts[1]),
                          int.parse(parts[0]),
                        );
                        if (date.isAfter(DateTime.now())) {
                          return 'Date must be in the past';
                        }
                      } catch (_) {
                        return 'Invalid date';
                      }
                      return null;
                    },
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
                  final Map<String, dynamic> updatedData = {
                    'Surname': surnameController.text.trim(),
                    'Forename': forenameController.text.trim(),
                    'Section': sectionValue,
                    'New Plot': plotController.text.trim(),
                    'Date of Death': dateOfDeathController.text.trim(),
                  };
                  await FirebaseFirestore.instance
                      .collection('sections')
                      .doc(docId)
                      .update(updatedData);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grave entry updated.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
      appBar: AppBar(
        title: const Text("Memorials"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              if (_showSearch) {
                _triggerSearch();
              } else {
                setState(() {
                  _showSearch = true;
                  Future.delayed(Duration.zero, () {
                    _searchFocusNode.requestFocus();
                  });
                });
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add') {
                _showAddSectionDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'add',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Add New Grave'),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Sign Out',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      // Drawer removed as requested
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sections').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Assign _allDocs with correct type casting
          _allDocs = (snapshot.data?.docs ?? [])
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
          _filterAndSortDocs();

          return Column(
            children: [
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                    onSubmitted: (_) => _triggerSearch(),
                  ),
                ),
              if (_filteredDocs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: PaginatedDataTable(
                      header: null,
                      rowsPerPage: 20,
                      availableRowsPerPage: const [10, 20, 30, 50, 100],
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columnSpacing: 12,
                      columns: [
                        DataColumn(
                          label: const Text('Name'),
                          onSort: (columnIndex, ascending) =>
                              _onSort(columnIndex, ascending),
                        ),
                        DataColumn(
                          label: const Text('Died'),
                          onSort: (columnIndex, ascending) =>
                              _onSort(columnIndex, ascending),
                        ),
                        const DataColumn(label: Text('')),
                        const DataColumn(label: Text('')),
                      ],
                      source: _MemorialsDataTableSource(
                        onShowDetails: (data) =>
                            _showDetailsDialog(context, data),
                        onEdit: (data, id) => _showEditSectionDialog(data, id),
                        onDelete: (id) => _confirmDeleteSection(id),
                        docs: _filteredDocs,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Optionally, navigate to login or show a message
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _MemorialsDataTableSource extends DataTableSource {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final void Function(Map<String, dynamic>) onShowDetails;
  final void Function(Map<String, dynamic>, String) onEdit;
  final void Function(String) onDelete;

  _MemorialsDataTableSource({
    required this.docs,
    required this.onShowDetails,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= docs.length) return null;
    final doc = docs[index];
    final data = doc.data() as Map<String, dynamic>?;
    final hasPhoto = data?['imageUrl'] != null &&
        (data?['imageUrl']?.toString().isNotEmpty ?? false);
    return DataRow(
      cells: [
        DataCell(
          Text(
              '${(data?['Surname'] ?? '').toString()}, ${(data?['Forename'] ?? '').toString()}'),
          onTap: () => onShowDetails(data ?? {}),
        ),
        DataCell(
          Row(
            children: [
              Text((data?['Date of Death'] ?? '').toString()),
              if (hasPhoto)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(Icons.photo,
                      color: AppConstants.nameWithPhotoColor, size: 16),
                ),
            ],
          ),
          onTap: () => onShowDetails(data ?? {}),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            tooltip: 'Edit',
            onPressed: () => onEdit(data ?? {}, doc.id),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            tooltip: 'Delete',
            onPressed: () => onDelete(doc.id),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => docs.length;
  @override
  int get selectedRowCount => 0;
}
