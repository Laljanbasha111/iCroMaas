import 'package:flutter/material.dart';
import '../../../models/crop_data_model.dart';

/// Widget for selecting a crop from the reference data
class CropSelectorWidget extends StatefulWidget {
  final CropDataList? cropDataList;
  final CropData? selectedCrop;
  final Function(CropData) onCropSelected;

  const CropSelectorWidget({
    super.key,
    required this.cropDataList,
    required this.selectedCrop,
    required this.onCropSelected,
  });

  @override
  State<CropSelectorWidget> createState() => _CropSelectorWidgetState();
}

class _CropSelectorWidgetState extends State<CropSelectorWidget> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, biomass, nitrogen

  @override
  Widget build(BuildContext context) {
    if (widget.cropDataList == null || widget.cropDataList!.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No crop data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Get filtered and sorted crops
    final crops = _getFilteredAndSortedCrops();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.grass, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Select Crop',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${crops.length} crops',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Search and Sort Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search crops...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Sort options
                Row(
                  children: [
                    const Text(
                      'Sort by:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildSortChip('Name', 'name'),
                          _buildSortChip('Biomass', 'biomass'),
                          _buildSortChip('Nitrogen', 'nitrogen'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Crop List
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: crops.length,
              itemBuilder: (context, index) {
                final crop = crops[index];
                final isSelected = widget.selectedCrop?.id == crop.id;

                return _buildCropTile(crop, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build sort chip
  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
      },
      selectedColor: Colors.green[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontSize: 12,
      ),
    );
  }

  /// Build crop tile
  Widget _buildCropTile(CropData crop, bool isSelected) {
    return InkWell(
      onTap: () => widget.onCropSelected(crop),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Crop icon/image placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.eco,
                color: Colors.green[700],
                size: 30,
              ),
            ),
            const SizedBox(width: 12),

            // Crop info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    crop.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green[700] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.grass,
                        crop.formattedBiomass,
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.science,
                        crop.formattedNitrogen,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  /// Build info chip
  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), // ✅ FIXED: Use withValues instead of withOpacity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get filtered and sorted crops
  List<CropData> _getFilteredAndSortedCrops() {
    if (widget.cropDataList == null) return [];

    // Filter by search query
    List<CropData> filtered = _searchQuery.isEmpty
        ? widget.cropDataList!.crops
        : widget.cropDataList!.searchByName(_searchQuery);

    // Sort
    switch (_sortBy) {
      case 'biomass':
        filtered = List.from(filtered)
          ..sort((a, b) => b.biomass.compareTo(a.biomass));
        break;
      case 'nitrogen':
        filtered = List.from(filtered)
          ..sort((a, b) => b.nitrogen.compareTo(a.nitrogen));
        break;
      case 'name':
      default:
        filtered = List.from(filtered)
          ..sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }
}

