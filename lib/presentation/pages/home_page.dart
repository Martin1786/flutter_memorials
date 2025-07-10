import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  final id = int.tryParse(entry.value.toString());
                  if (id != null) {
                    abbreviationWidget =
                        await _buildAbbreviationField(context, id);
                  } else {
                    abbreviationWidget = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Abbreviation: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(entry.value.toString()),
                      ],
                    );
                  }
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
              // Add abbreviation widget at the bottom if present
              if (abbreviationWidget != null) {
                fields.add(const SizedBox(height: 8));
                fields.add(abbreviationWidget);
              }
              // Add XY widget at the very end if present
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sections').snapshots(),
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
                (aMap['Surname']?.toString().trim().isNotEmpty ?? false)
                    ? aMap['Surname'].toString().toLowerCase()
                    : 'zzzzzzzz'; // Sort 'Unknown' to bottom
            final bSurname =
                (bMap['Surname']?.toString().trim().isNotEmpty ?? false)
                    ? bMap['Surname'].toString().toLowerCase()
                    : 'zzzzzzzz'; // Sort 'Unknown' to bottom
            return aSurname.compareTo(bSurname);
          });
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text('Section: ${data['Section']}',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          if (data['New Plot'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text('Plot: ${data['New Plot']}',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                        ],
                      ),
                      if (data['Date of Death'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text('Date of Death: ${data['Date of Death']}',
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
    );
  }
}
