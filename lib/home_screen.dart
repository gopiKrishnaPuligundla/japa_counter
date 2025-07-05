import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'counter_widget/counter_widget.dart';
import 'counter_widget/bloc/counter_bloc.dart';
import 'counter_form.dart';
import 'vaishnav_calendar_screen.dart';
import 'quotes_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/favorites_screen.dart';
import 'sankalpa_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Japa Counter'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[400]!, Colors.teal[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to your Spiritual Journey',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<CounterBloc, CounterState>(
                    builder: (context, state) {
                      return Text(
                        'Current: ${state.counter.liveRounds} rounds, ${state.counter.liveCount} beads',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Feature cards grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(
                  context,
                  icon: Icons.add_circle_outline,
                  title: 'Counter',
                  subtitle: 'Track your japa',
                  color: Colors.green,
                  onTap: () => _navigateToPage(context, const CounterPage()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.task_alt,
                  title: 'Sankalpa',
                  subtitle: 'Spiritual vows',
                  color: Colors.orange,
                  onTap: () => _navigateToPage(context, const SankalpaScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.info_outline,
                  title: 'Quotes',
                  subtitle: 'Daily inspiration',
                  color: Colors.purple,
                  onTap: () => _navigateToPage(context, const QuotesScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.calendar_month,
                  title: 'Calendar',
                  subtitle: 'Vaishnav events',
                  color: Colors.blue,
                  onTap: () => _navigateToPage(context, const VaishnavCalendarScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.note_alt,
                  title: 'Notes',
                  subtitle: 'Daily insights',
                  color: Colors.indigo,
                  onTap: () => _navigateToPage(context, const NotesScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.favorite,
                  title: 'Favorites',
                  subtitle: 'Saved content',
                  color: Colors.red,
                  onTap: () => _navigateToPage(context, const FavoritesScreen()),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'Configure app',
                  color: Colors.grey,
                  onTap: () => _navigateToPage(context, const ResetForm()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Japa Counter',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Counter'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, const CounterPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.task_alt),
            title: const Text('Sankalpa'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, const SankalpaScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Quotes'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/quotes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, const VaishnavCalendarScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_alt),
            title: const Text('Notes'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, const NotesScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              Navigator.pop(context);
              _navigateToPage(context, const FavoritesScreen());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Us'),
            onTap: () => _showAboutUs(context),
          ),
        ],
      ),
    );
  }

  void _showAboutUs(BuildContext context) async {
    Navigator.pop(context); // Close drawer first
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("ISL collaboration"),
        );
      },
    );
  }
}

// Counter page as a separate screen
class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

enum Menu { resetBeads, resetRounds, resetBoth }

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Japa Counter'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<Menu>(
            onSelected: (Menu item) {
              switch (item) {
                case Menu.resetBeads:
                  context.read<CounterBloc>().add(ResetBeads());
                  break;
                case Menu.resetRounds:
                  context.read<CounterBloc>().add(ResetRounds());
                  break;
                case Menu.resetBoth:
                  context.read<CounterBloc>().add(ResetCounters());
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: Menu.resetBeads,
                  child: Text('Reset Beads'),
                ),
                const PopupMenuItem(
                  value: Menu.resetRounds,
                  child: Text('Reset Rounds'),
                ),
                const PopupMenuItem(
                  value: Menu.resetBoth,
                  child: Text('Reset Both'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Counter display
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[400]!, Colors.teal[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CounterWidget(),
            ),
            
            const SizedBox(height: 32),
            
            // Counter buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: const ValueKey("increment"),
                  onPressed: () => context.read<CounterBloc>().add(IncrementCounter()),
                  tooltip: 'Increment',
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add, size: 32),
                ),
                FloatingActionButton(
                  heroTag: const ValueKey("decrement"),
                  onPressed: () => context.read<CounterBloc>().add(DecrementCounter()),
                  tooltip: 'Decrement',
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.remove, size: 32),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Instructions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Volume Key Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.volume_up, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          const Text('Volume Up = +1'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.volume_down, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          const Text('Volume Down = -1'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 