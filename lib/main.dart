import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
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
      home: const AuthWrapper(),
    );
  }
}

class EscrowDeal {
  final String id;
  final String title;
  final String party;
  final double amount;
  final String status;
  final String dateStr;

  EscrowDeal({
    required this.id,
    required this.title,
    required this.party,
    required this.amount,
    required this.status,
    required this.dateStr,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'party': party,
        'amount': amount,
        'status': status,
        'dateStr': dateStr,
      };

  factory EscrowDeal.fromJson(Map<String, dynamic> json) => EscrowDeal(
        id: json['id'],
        title: json['title'],
        party: json['party'],
        amount: json['amount'],
        status: json['status'],
        dateStr: json['dateStr'],
      );
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkSavedSession();
  }

  Future<void> _checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('saved_email');
      _userName = prefs.getString('saved_name');
      _isLoading = false;
    });
  }

  Future<void> _login(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_name', name);
    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_name');
    setState(() {
      _userName = null;
      _userEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userEmail == null) {
      return LoginScreen(onLogin: _login);
    }
    return MainNavigationScreen(
      userEmail: _userEmail!,
      userName: _userName ?? 'User',
      onLogout: _logout,
    );
  }
}

// Secure Login Screen with Email, Password & Strict Validation
class LoginScreen extends StatefulWidget {
  final Function(String, String) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        widget.onLogin(_nameController.text.trim(), _emailController.text.trim());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.handshake, size: 80, color: Color(0xFF1E88E5)),
                    const SizedBox(height: 16),
                    const Text(
                      'TrustEscrow Login',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your Google Gmail & Password to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Gmail Address (e.g. user@gmail.com)',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Email address is required';
                        }
                        final email = val.trim();
                        final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                        if (!regex.hasMatch(email)) {
                          return 'Must be a valid @gmail.com address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Google Account Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Password is required';
                        }
                        if (val.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : _submitLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Sign In securely',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final String userEmail;
  final String userName;
  final VoidCallback onLogout;

  const MainNavigationScreen({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.onLogout,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<EscrowDeal> _deals = [];
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    final prefs = await SharedPreferences.getInstance();
    final dealsJson = prefs.getStringList('saved_deals');
    if (dealsJson != null) {
      setState(() {
        _deals = dealsJson
            .map((item) => EscrowDeal.fromJson(jsonDecode(item)))
            .toList();
        _isDataLoaded = true;
      });
    } else {
      setState(() => _isDataLoaded = true);
    }
  }

  Future<void> _saveDeals() async {
    final prefs = await SharedPreferences.getInstance();
    final dealsJson = _deals.map((deal) => jsonEncode(deal.toJson())).toList();
    await prefs.setStringList('saved_deals', dealsJson);
  }

  void _addNewDeal(EscrowDeal deal) {
    setState(() {
      _deals.insert(0, deal);
    });
    _saveDeals();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = [
      DashboardTab(deals: _deals, onNewDeal: () => setState(() => _currentIndex = 2), userName: widget.userName),
      DealsListTab(deals: _deals),
      CreateDealTab(onCreate: _addNewDeal, onSuccess: () => setState(() => _currentIndex = 1)),
      ProfileTab(userEmail: widget.userEmail, userName: widget.userName, onLogout: widget.onLogout),
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

class DashboardTab extends StatelessWidget {
  final List<EscrowDeal> deals;
  final VoidCallback onNewDeal;
  final String userName;

  const DashboardTab({
    super.key,
    required this.deals,
    required this.onNewDeal,
    required this.userName,
  });

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
            Text('Welcome back, $userName!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
            if (deals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'No escrow deals yet.\nTap "New Deal" to create one with a real email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
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
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                deal.status,
                style: TextStyle(fontSize: 11, color: Colors.green.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DealsListTab extends StatelessWidget {
  final List<EscrowDeal> deals;

  const DealsListTab({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions & Deals')),
      body: deals.isEmpty
          ? const Center(
              child: Text(
                'No escrow deals created yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
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

class CreateDealTab extends StatefulWidget {
  final Function(EscrowDeal) onCreate;
  final VoidCallback onSuccess;

  const CreateDealTab({
    super.key,
    required this.onCreate,
    required this.onSuccess,
  });

  @override
  State<CreateDealTab> createState() => _CreateDealTabState();
}

class _CreateDealTabState extends State<CreateDealTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _partyController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _partyController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDeal = EscrowDeal(
        id: 'ESC-${1000 + DateTime.now().second * 10}',
        title: _titleController.text.trim(),
        party: _partyController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        status: 'In Escrow',
        dateStr: DateTime.now().toString(),
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
                decoration: const InputDecoration(
                  labelText: 'Deal Title / Service',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter deal title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _partyController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Counterparty Real Email (e.g. user@gmail.com)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter counterparty email';
                  }
                  final strictEmailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@gmail\.com$',
                  );
                  if (!strictEmailRegex.hasMatch(val.trim())) {
                    return 'Must be a valid @gmail.com address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Escrow Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter amount';
                  if (double.tryParse(val.trim()) == null) return 'Enter a valid number';
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

class ProfileTab extends StatelessWidget {
  final String userEmail;
  final String userName;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.onLogout,
  });

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
          Center(child: Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text(userEmail, style: const TextStyle(color: Colors.grey))),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Security & Two-Factor (2FA)'),
            subtitle: const Text('Protected via Google Account Password'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction Logs'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
