import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../core/widgets/loading_indicators.dart';
import '../models/team_member_model.dart';
import '../providers/team_provider.dart';

class TeamOverviewScreen extends StatefulWidget {
  const TeamOverviewScreen({super.key});

  @override
  State<TeamOverviewScreen> createState() => _TeamOverviewScreenState();
}

class _TeamOverviewScreenState extends State<TeamOverviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamProvider>().initializeDummyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Team Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Team Leaders'),
              Tab(text: 'Collectors'),
            ],
          ),
        ),
        body: Consumer<TeamProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LoadingIndicator(message: 'Loading team data...');
            }

            return TabBarView(
              children: [
                _buildTeamList(provider.teamLeaders),
                _buildTeamList(provider.collectors),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add team member functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add team member functionality coming soon')),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTeamList(List<TeamMemberModel> members) {
    if (members.isEmpty) {
      return const Center(child: Text('No team members found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: member.isActive ? Colors.green : Colors.grey,
              child: Text(
                member.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(member.name),
            subtitle: Text(member.email),
            trailing: Switch(
              value: member.isActive,
              onChanged: (value) {
                context.read<TeamProvider>().toggleMemberStatus(member.id);
              },
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Phone', member.phoneNumber ?? 'N/A'),
                    _buildInfoRow('Role', member.role.toUpperCase()),
                    if (member.performance != null) ...[
                      const Divider(),
                      const Text(
                        'Performance',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildPerformanceGrid(member.performance!),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // TODO: Implement edit functionality
                          },
                          child: const Text('Edit'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement view details functionality
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid(Map<String, dynamic> performance) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: performance.length,
      itemBuilder: (context, index) {
        final entry = performance.entries.elementAt(index);
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.key.toUpperCase(),
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}