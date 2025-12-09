import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/progress.dart';
import '../widgets/progress_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Progress> _weeklyProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final progress = await _db.getWeeklyProgress();
      if (mounted) {
        setState(() {
          _weeklyProgress = progress.reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's an error, just show empty state
      if (mounted) {
        setState(() {
          _weeklyProgress = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ProgressChart(
                    progressData: _weeklyProgress,
                    title: 'Workout Count (Last 7 Days)',
                    color: Colors.blue,
                    getValue: (progress) => progress.workoutCount.toString(),
                  ),
                  const SizedBox(height: 16),
                  ProgressChart(
                    progressData: _weeklyProgress,
                    title: 'Calories Burned (Last 7 Days)',
                    color: Colors.orange,
                    getValue: (progress) => progress.totalCalories.toString(),
                  ),
                  const SizedBox(height: 16),
                  ProgressChart(
                    progressData: _weeklyProgress,
                    title: 'Duration (Last 7 Days)',
                    color: Colors.green,
                    getValue: (progress) => progress.totalDuration.toString(),
                  ),
                ],
              ),
            ),
    );
  }
}
