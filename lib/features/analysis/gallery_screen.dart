import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/gallery_provider.dart';
import '../../../models/gallery_image.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = false;
  bool _selectionMode = false;
  List<String> _selectedIds = [];
  String _searchQuery = '';
  String _filter = 'All';
  String _sort = 'Most Recent';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    await provider.loadGallery();
    setState(() => _isLoading = false);
  }

  void _filterImages(String filter) {
    setState(() => _filter = filter);
    Provider.of<GalleryProvider>(context, listen: false).applyFilter(filter, _dateRange);
  }

  void _sortImages(String sort) {
    setState(() => _sort = sort);
    Provider.of<GalleryProvider>(context, listen: false).applySort(sort);
  }

  void _searchImages(String query) {
    setState(() => _searchQuery = query);
    Provider.of<GalleryProvider>(context, listen: false).searchImages(query);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectionMode = _selectedIds.isNotEmpty;
    });
  }

  Future<void> _deleteSelected() async {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    await provider.deleteImages(_selectedIds);
    setState(() {
      _selectedIds.clear();
      _selectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected images deleted')),
    );
  }

  Future<void> _shareSelected() async {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    await provider.shareImages(_selectedIds);
  }

  Future<void> _exportSelected() async {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    await provider.exportImages(_selectedIds);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected images exported')),
    );
  }

  void _viewImageDetails(String id) {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final image = provider.getImageById(id);
    if (image == null) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(image.path), fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crop Type: ${image.cropType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Health Score: ${image.healthScore}%'),
                  Text('Date: ${image.date}'),
                  if (image.disease.isNotEmpty) Text('Disease: ${image.disease}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final provider = Provider.of<GalleryProvider>(context, listen: false);
      await provider.addImage(File(picked.path));
      _loadGallery();
    }
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Widget _buildImageCard(GalleryImage image) {
    final isSelected = _selectedIds.contains(image.id);
    return GestureDetector(
      onTap: () {
        if (_selectionMode) {
          _toggleSelection(image.id);
        } else {
          _viewImageDetails(image.id);
        }
      },
      onLongPress: () => _toggleSelection(image.id),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.transparent,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(image.path), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                image.cropType,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getHealthColor(image.healthScore),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${image.healthScore.toInt()}%',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                image.date,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
          if (isSelected)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gallery = Provider.of<GalleryProvider>(context);
    final images = gallery.filteredImages;

    return Scaffold(
      appBar: AppBar(
        title: _selectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Gallery'),
        actions: [
          if (_selectionMode)
            IconButton(icon: const Icon(Icons.delete), onPressed: _deleteSelected),
          if (_selectionMode)
            IconButton(icon: const Icon(Icons.share), onPressed: _shareSelected),
          if (_selectionMode)
            IconButton(icon: const Icon(Icons.download), onPressed: _exportSelected),
          if (!_selectionMode)
            IconButton(icon: const Icon(Icons.add_photo_alternate), onPressed: _pickNewImage),
          if (!_selectionMode)
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGallery),
          if (!_selectionMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: _filterImages,
              itemBuilder: (context) => [
                'All',
                'Wheat',
                'Rice',
                'Corn',
                'Healthy',
                'Moderate',
                'Unhealthy',
                'Disease Detected',
                'By Date Range'
              ].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
            ),
          if (!_selectionMode)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              onSelected: _sortImages,
              itemBuilder: (context) => [
                'Most Recent',
                'Oldest First',
                'Highest Health Score',
                'Lowest Health Score',
                'By Crop Type'
              ].map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: _searchImages,
              decoration: InputDecoration(
                hintText: 'Search by crop, disease, or date...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadGallery,
              child: images.isEmpty
                  ? const Center(child: Text('No images found'))
                  : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return _buildImageCard(image);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !_selectionMode
          ? FloatingActionButton(
        onPressed: _pickNewImage,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add_a_photo),
      )
          : null,
    );
  }
}