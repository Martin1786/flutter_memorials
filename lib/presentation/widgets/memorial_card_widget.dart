import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/memorial.dart';

/// Widget for displaying a memorial in a card format.
///
/// This widget shows the basic information about a memorial
/// in a card layout that can be tapped for more details.
class MemorialCardWidget extends StatelessWidget {
  const MemorialCardWidget({
    super.key,
    required this.memorial,
    required this.onTap,
    this.showDetails = false,
  });

  final Memorial memorial;
  final VoidCallback onTap;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              if (showDetails) ...[
                const SizedBox(height: 8),
                _buildDetails(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memorial.deceasedName ?? 'Unknown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (memorial.dateOfDeath != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Died: ${_formatDate(memorial.dateOfDeath!)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Plot: ${memorial.plotNumber} | Section ${memorial.section.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
        ),
        _buildStatusIcons(context),
      ],
    );
  }

  Widget _buildStatusIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (memorial.hasPhoto)
          Icon(
            Icons.photo,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        if (memorial.hasPhoto) const SizedBox(width: 4),
        if (memorial.hasCoordinates)
          Icon(
            Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        if (memorial.hasCoordinates) const SizedBox(width: 4),
        if (memorial.hasInscription)
          Icon(
            Icons.text_fields,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        const SizedBox(width: 8),
        Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          size: 16,
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (memorial.deceasedName != null) ...[
          _buildDetailRow(
            context,
            'Deceased',
            memorial.deceasedName!,
            Icons.person,
          ),
          const SizedBox(height: 4),
        ],
        if (memorial.dateOfDeath != null) ...[
          _buildDetailRow(
            context,
            'Date of Death',
            _formatDate(memorial.dateOfDeath!),
            Icons.event,
          ),
          const SizedBox(height: 4),
        ],
        _buildDetailRow(
          context,
          'Material',
          memorial.headstoneMaterial.displayName,
          Icons.architecture,
        ),
        if (memorial.additionalDetails.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildDetailRow(
            context,
            'Additional Details',
            memorial.additionalDetails.join(', '),
            Icons.info,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
