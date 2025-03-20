import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/loading_indicators.dart';
import '../../collection/models/route_model.dart';
import '../../collection/providers/collection_provider.dart';
import '../providers/team_provider.dart';


class RouteManagementScreen extends StatefulWidget {
  const RouteManagementScreen({super.key});

  @override
  State<RouteManagementScreen> createState() => _RouteManagementScreenState();
}

class _RouteManagementScreenState extends State<RouteManagementScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTeamMemberId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().initializeDummyData();
      context.read<CollectionProvider>().initializeDummyData();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(),
              const SizedBox(height: 24),
              _buildTeamMemberSelector(),
              const SizedBox(height: 24),
              _buildRoutesList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateRouteDialog(context);
        },
        label: const Text('Create Route'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberSelector() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        if (teamProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading team members...');
        }

        final collectors = teamProvider.collectors;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assign Team Member',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedTeamMemberId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  hint: const Text('Select team member'),
                  items: collectors.map((member) {
                    return DropdownMenuItem(
                      value: member.id,
                      child: Text(member.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTeamMemberId = value;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutesList() {
    return Consumer<CollectionProvider>(
      builder: (context, collectionProvider, child) {
        if (collectionProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading routes...');
        }

        final routes = collectionProvider.routes;

        if (routes.isEmpty) {
          return const Center(
            child: Text('No routes available for the selected date'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Routes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(route.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Collection Points: ${route.collectionPoints.length}'),
                        Text('Status: ${route.status.toUpperCase()}'),
                        LinearProgressIndicator(
                          value: route.completionPercentage / 100,
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showRouteOptionsDialog(context, route);
                      },
                    ),
                    onTap: () {
                      _showRouteDetailsDialog(context, route);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateRouteDialog(BuildContext context) async {
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Route'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Route Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${DateFormat('MMM d, y').format(_selectedDate)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement route creation
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Route created successfully')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRouteOptionsDialog(BuildContext context, RouteModel route) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(route.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Route'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement edit route
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Assign Team Member'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement team member assignment
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Route'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context, route);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context,
      RouteModel route,
      ) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text(
          'Are you sure you want to delete ${route.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement route deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Route deleted successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRouteDetailsDialog(BuildContext context, RouteModel route) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(route.name),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildDetailRow('Date', route.date),
              _buildDetailRow('Status', route.status.toUpperCase()),
              _buildDetailRow(
                'Progress',
                '${route.completionPercentage.toStringAsFixed(1)}%',
              ),
              _buildDetailRow(
                'Collection Points',
                route.collectionPoints.length.toString(),
              ),
              const Divider(),
              const Text(
                'Collection Points:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...route.collectionPoints.map((point) => Card(
                child: ListTile(
                  title: Text(point.address),
                  subtitle: Text('Status: ${point.status.toUpperCase()}'),
                  leading: Icon(
                    point.status == 'completed'
                        ? Icons.check_circle
                        : Icons.schedule,
                    color: point.status == 'completed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}