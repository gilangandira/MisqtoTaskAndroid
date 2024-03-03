import 'package:flutter/material.dart';
import 'package:task_management/Task/TaskList.dart';

class HistoryTask extends StatefulWidget {
  const HistoryTask({super.key});

  @override
  State<HistoryTask> createState() => _HistoryTaskState();
}

class _HistoryTaskState extends State<HistoryTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('History')),
      ),
      body: Container(
        width: 500,
          height: 1000,
          child: const TaskList(keyword: 'Selesai Dikerjakan',)),
    );
  }
}
