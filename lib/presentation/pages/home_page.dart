import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/memorial.dart';
import '../widgets/memorial_card_widget.dart';

/// Home page of the memorials application.
///
/// This page displays the list of memorials and provides navigation
/// to other parts of the application.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Memorial> _memorials = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Simulate loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _memorials = _getSampleMemorials();
        });
      }
    });
  }

  List<Memorial> _getSampleMemorials() {
    final now = DateTime.now();

    return [
      Memorial(
        id: '1',
        plotNumber: 'A-123',
        section: BurialSection.A,
        headstoneMaterial: HeadstoneMaterial.granite,
        inscription: 'In loving memory of John Smith\n1920 - 1995',
        dateOfDeath: DateTime(1995, 6, 15),
        deceasedName: 'John Smith',
        latitude: 51.5074,
        longitude: -0.1278,
        photoPath: null,
        additionalDetails: ['Vase', 'Plaque'],
        createdAt: now,
        updatedAt: now,
      ),
      Memorial(
        id: '2',
        plotNumber: 'B-456',
        section: BurialSection.B,
        headstoneMaterial: HeadstoneMaterial.limestone,
        inscription: 'Rest in peace\nMary Johnson\n1935 - 2000',
        dateOfDeath: DateTime(2000, 3, 22),
        deceasedName: 'Mary Johnson',
        latitude: 51.5075,
        longitude: -0.1279,
        photoPath: null,
        additionalDetails: ['Cross'],
        createdAt: now,
        updatedAt: now,
      ),
      Memorial(
        id: '3',
        plotNumber: 'C-789',
        section: BurialSection.C,
        headstoneMaterial: HeadstoneMaterial.slate,
        inscription:
            'Beloved father and grandfather\nRobert Brown\n1910 - 1988',
        dateOfDeath: DateTime(1988, 12, 10),
        deceasedName: 'Robert Brown',
        latitude: 51.5076,
        longitude: -0.1280,
        photoPath: null,
        additionalDetails: ['Angel statue'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              _showSyncDialog(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMemorialDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorWidget(_error!);
    }

    if (_memorials.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMemorialList();
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadSampleData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.church,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Memorials Found',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first memorial to get started',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          // Note: ElevatedButton cannot be const if it uses a closure
        ],
      ),
    );
  }

  Widget _buildMemorialList() {
    // Sort by deceasedName (alphabetically, case-insensitive), then by dateOfDeath (earliest first)
    final sortedMemorials = List<Memorial>.from(_memorials)
      ..sort((a, b) {
        final nameA = (a.deceasedName ?? '').toLowerCase();
        final nameB = (b.deceasedName ?? '').toLowerCase();
        final nameCompare = nameA.compareTo(nameB);
        if (nameCompare != 0) return nameCompare;
        if (a.dateOfDeath != null && b.dateOfDeath != null) {
          return a.dateOfDeath!.compareTo(b.dateOfDeath!);
        } else if (a.dateOfDeath != null) {
          return -1;
        } else if (b.dateOfDeath != null) {
          return 1;
        }
        return 0;
      });
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        _loadSampleData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: sortedMemorials.length,
        itemBuilder: (context, index) {
          final memorial = sortedMemorials[index];
          return MemorialCardWidget(
            memorial: memorial,
            onTap: () {
              _showMemorialDetails(context, memorial);
            },
          );
        },
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Memorials'),
        content: const Text('Search functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Data'),
        content: const Text('Sync functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAddMemorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Memorial'),
        content: const Text('Add memorial functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showMemorialDetails(BuildContext context, Memorial memorial) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Memorial Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Name', memorial.deceasedName ?? 'Unknown'),
              if (memorial.dateOfDeath != null)
                _detailRow('Date of Death',
                    '${memorial.dateOfDeath!.day}/${memorial.dateOfDeath!.month}/${memorial.dateOfDeath!.year}'),
              _detailRow('Plot', memorial.plotNumber),
              _detailRow('Section', memorial.section.displayName),
              _detailRow('Material', memorial.headstoneMaterial.displayName),
              if (memorial.inscription != null &&
                  memorial.inscription!.isNotEmpty)
                _detailRow('Inscription', memorial.inscription!),
              if (memorial.latitude != null && memorial.longitude != null)
                _detailRow('Coordinates',
                    '${memorial.latitude}, ${memorial.longitude}'),
              if (memorial.additionalDetails.isNotEmpty)
                _detailRow('Additional Details',
                    memorial.additionalDetails.join(", ")),
              if (memorial.photoPath != null && memorial.photoPath!.isNotEmpty)
                _detailRow('Photo Path', memorial.photoPath!),
              _detailRow('Created At', memorial.createdAt.toString()),
              _detailRow('Updated At', memorial.updatedAt.toString()),
            ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
