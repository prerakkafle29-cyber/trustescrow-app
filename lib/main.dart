import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrustEscrowApp());
}

class TrustEscrowApp extends StatelessWidget {
  const TrustEscrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrustEscrow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Data Models
class EscrowDeal {
  final String id;
  final String title;
  final String party;
  final double amount;
  final String status;
  final DateTime date;

  EscrowDeal({
    required this.id,
    required this.title,
    required this.party,
    required this.amount,
    required this.status,
    required this.date,
  });
}

// Main Bottom Navigation Setup
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<EscrowDeal> _deals = [
    EscrowDeal(
      id: 'ESC-9082',
      title: 'Custom Website Design',
      party: 'Alex Rivera',
      amount: 450.00,
      status: 'In Escrow',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    EscrowDeal(
      id: 'ESC-7731',
      title: 'Mobile App UI/UX Mockups',
      party: 'Sarah Chen',
      amount: 280.00,
      status: 'Pending Buyer',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EscrowDeal(
      id: 'ESC-4120',
      title: 'Logo & Brand Identity',
      party: 'DevStudio Ltd.',
      amount: 150.00,
      status: 'Completed',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  void _addNewDeal(EscrowDeal deal) {
    setState(() {
      _deals.insert(0, deal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardTab(deals: _deals, onNewDeal: () => setState(() => _currentIndex = 2)),
      DealsListTab(deals: _deals),
      CreateDealTab(onCreate: _addNewDeal, onSuccess: () => setState(() => _currentIndex = 1)),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Deals'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'New Escrow'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Tab 1: Dashboard Overview
class DashboardTab extends StatelessWidget {
  final List<EscrowDeal> deals;
  final VoidCallback onNewDeal;

  const DashboardTab({super.key, required this.deals, required: this.onNewDeal});

  @override
  Widget build(BuildContext context) {
    final activeDeals = deals.where((d) => d.status != 'Completed').length;
    final totalEscrow = deals
        .where((d) => d.status == 'In Escrow')
        .fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrustEscrow', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications.')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 500)),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Balance Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Protected Funds in Escrow', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('\$${totalEscrow.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$activeDeals Active Escrow Deals', style: const TextStyle(fontWeight: FontWeight.w500)),
                        ElevatedButton(
                          onPressed: onNewDeal,
                          child: const Text('New Deal'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Escrow Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...deals.take(3).map((deal) => _buildDealTile(context, deal)),
          ],
        ),
      ),
    );
  }

  Widget _buildDealTile(BuildContext context, EscrowDeal deal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: const Icon(Icons.handshake_outlined),
        ),
        title: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('With: ${deal.party} • ${deal.id}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${deal.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: deal.status == 'In Escrow' ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                deal.status,
                style: TextStyle(
                  fontSize: 11,
                  color: deal.status == 'In Escrow' ? Colors.green.shade900 : Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tab 2: All Deals View
class DealsListTab extends StatelessWidget {
  final List<EscrowDeal> deals;

  const DealsListTab({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions & Deals')),
      body: deals.isEmpty
          ? const Center(child: Text('No escrow deals created yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${deal.id} | Party: ${deal.party}'),
                    trailing: Text('\$${deal.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
    );
  }
}

// Tab 3: Create New Escrow Form
class CreateDealTab extends StatefulWidget {
  final Function(EscrowDeal) onCreate;
  final VoidCallback onSuccess;

  const CreateDealTab({super.key, required this.onCreate, required: this.onSuccess});

  @override
  State<CreateDealTab> createState() => _CreateDealTabState();
}

class _CreateDealTabState extends State<CreateDealTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _partyController = TextEditingController();
  final _amountController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDeal = EscrowDeal(
        id: 'ESC-${1000 + DateTime.now().second * 10}',
        title: _titleController.text,
        party: _partyController.text,
        amount: double.parse(_amountController.text),
        status: 'In Escrow',
        date: DateTime.now(),
      );
      widget.onCreate(newDeal);
      _titleController.clear();
      _partyController.clear();
      _amountController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escrow Deal Created Successfully!')),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Escrow')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Deal Title / Service', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Enter deal title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _partyController,
                decoration: const InputDecoration(labelText: 'Counterparty (Email/Username)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Enter party details' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Escrow Amount (\$)', border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter amount';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: _submitForm,
                child: const Text('Initiate Escrow', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tab 4: User Profile & Security Settings
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account & Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Prerak Kafle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const Center(child: Text('Verified Escrow User', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security & Two-Factor (2FA)'),
            subtitle: const Text('Protected via App Lock'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction Logs'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Payment Gateways'),
            subtitle: const Text('Manual integration pending'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
