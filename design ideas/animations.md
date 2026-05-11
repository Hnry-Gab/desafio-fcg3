web application/stitch/projects/16301219792209935728/screens/10b46e1401794f05a54879c887e28a53
import 'package:flutter/material.dart';

void main() {
  runApp(const StudySanctuaryApp());
}

class StudySanctuaryApp extends StatelessWidget {
  const StudySanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF131313),
        primaryColor: const Color(0xFFa3e635),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderSection(),
              const SizedBox(height: 30),
              // ANIMATION 1: Fade-In-Up for the Main Hero Card
              const AnimatedEntrance(
                delay: Duration(milliseconds: 200),
                child: HeroCard(),
              ),
              const SizedBox(height: 20),
              // ANIMATION 2: Staggered Fade-In for Stats Cards
              Row(
                children: const [
                  Expanded(
                    child: AnimatedEntrance(
                      delay: Duration(milliseconds: 400),
                      child: StatCard(label: 'DAILY FOCUS', value: '94.8'),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: AnimatedEntrance(
                      delay: Duration(milliseconds: 600),
                      child: StatCard(label: 'TOTAL TIME', value: '128.5 hrs'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

/// ANIMATION: Entrance Transition (Fade + Slide)
/// Used for cards and sections to create a "loading" rhythm.
class AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const AnimatedEntrance({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// ANIMATION: Scaling Glow Navigation Bar
/// Replicates the logic from the "Scaling Glow" screen.
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF1c1b1b),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined),
          _buildNavItem(1, Icons.access_time),
          _buildNavItem(2, Icons.bar_chart_outlined),
          _buildNavItem(3, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFa3e635) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFa3e635).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white54,
          size: isSelected ? 28 : 24,
        ),
      ),
    );
  }
}

// Minimalist placeholder widgets for structure
class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Deep Work Sanctuary', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Achieve clarity through precision.', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1c1b1b),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(20),
      child: const Text('Quantum Physics Analysis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  const StatCard({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1c1b1b),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
