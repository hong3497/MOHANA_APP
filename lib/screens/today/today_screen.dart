import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': '요가 30분 🧘‍♀️',
      'time': '오전 7시 30분',
      'category': '피트니스',
      'done': false,
    },
    {
      'title': '치과 예약 🦷',
      'time': '오전 10시',
      'category': '약속',
      'done': false,
    },
    {
      'title': '빵 구입 🍞',
      'time': '오후 5시',
      'category': '식품',
      'done': true,
    },
  ];

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['done'] = !_tasks[index]['done'];
    });
  }

  void _addTask() {
    String newTitle = '';
    String newTime = '';
    String newCategory = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('할 일 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '할 일 제목'),
                onChanged: (v) => newTitle = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '시간 (예: 오전 8시)'),
                onChanged: (v) => newTime = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '카테고리'),
                onChanged: (v) => newCategory = v,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
            ElevatedButton(
              onPressed: () {
                if (newTitle.trim().isEmpty) return;
                setState(() {
                  _tasks.add({
                    'title': newTitle,
                    'time': newTime.isEmpty
                        ? DateFormat('a h시 m분', 'ko_KR').format(DateTime.now())
                        : newTime,
                    'category': newCategory.isEmpty ? '기타' : newCategory,
                    'done': false,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayText = DateFormat('M월 d일 (E)', 'ko_KR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todayText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: _tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.grey),
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    leading: Checkbox(
                      shape: const CircleBorder(),
                      value: task['done'],
                      onChanged: (_) => _toggleTask(index),
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration:
                            task['done'] ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task['done'] ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          task['time'],
                          style: const TextStyle(color: Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${task['category']}',
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}