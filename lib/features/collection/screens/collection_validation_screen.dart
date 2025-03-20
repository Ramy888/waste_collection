import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';


import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../models/collection_point_model.dart';
import '../providers/collection_provider.dart';

class CollectionValidationScreen extends StatefulWidget {
  final CollectionPointModel collectionPoint;

  const CollectionValidationScreen({
    super.key,
    required this.collectionPoint,
  });

  @override
  State<CollectionValidationScreen> createState() =>
      _CollectionValidationScreenState();
}

class _CollectionValidationScreenState
    extends State<CollectionValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  List<String> _photos = [];
  bool _hasAnomalies = false;
  final Map<String, bool> _anomalies = {
    'Blocked Access': false,
    'Container Damaged': false,
    'Overflow': false,
    'Wrong Waste Type': false,
  };

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.collectionPoint.notes ?? '';
    _photos = widget.collectionPoint.photos ?? [];
    if (widget.collectionPoint.anomalies != null) {
      _hasAnomalies = true;
      widget.collectionPoint.anomalies!.forEach((key, value) {
        if (_anomalies.containsKey(key)) {
          _anomalies[key] = value as bool;
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _photos.add(photo.path);
      });
    }
  }

  Future<void> _validateCollection() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedPoint = CollectionPointModel(
        id: widget.collectionPoint.id,
        address: widget.collectionPoint.address,
        latitude: widget.collectionPoint.latitude,
        longitude: widget.collectionPoint.longitude,
        status: 'completed',
        completedAt: DateTime.now(),
        notes: _notesController.text,
        photos: _photos,
        anomalies: _hasAnomalies ? _anomalies : null,
      );

      await context
          .read<CollectionProvider>()
          .updateCollectionPoint('1', updatedPoint);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  title: Text(widget.collectionPoint.address),
                  subtitle: Text(
                    'Status: ${widget.collectionPoint.status.toUpperCase()}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Notes',
                controller: _notesController,
                maxLines: 3,
                hint: 'Add any relevant notes about the collection',
              ),
              const SizedBox(height: 16),
              Text(
                'Photos',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _photos.length) {
                      return InkWell(
                        onTap: _takePicture,
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_a_photo),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(_photos[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _photos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Report Anomalies'),
                value: _hasAnomalies,
                onChanged: (value) {
                  setState(() {
                    _hasAnomalies = value;
                  });
                },
              ),
              if (_hasAnomalies) ...[
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: _anomalies.entries.map((entry) {
                      return CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (bool? value) {
                          setState(() {
                            _anomalies[entry.key] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Consumer<CollectionProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Validate Collection',
                    onPressed: _validateCollection,
                    isLoading: provider.isLoading,
                  );
                },
              ),
              const SizedBox(height: 16),
              if (widget.collectionPoint.status == 'completed') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collection Validated',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed at: ${widget.collectionPoint.completedAt?.toString() ?? 'N/A'}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
