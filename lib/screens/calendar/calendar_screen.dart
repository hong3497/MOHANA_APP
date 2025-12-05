import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  final DateTime _today = DateTime.now();

  // ✅ 일정 저장용 Map<DateTime, List<String>>
  final Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  int _firstWeekdayOfMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1).weekday;
    return first % 7;
  }

  int _daysInMonth(DateTime month) {
    final nextMonth = (month.month == 12)
        ? DateTime(month.year + 1, 1, 1)
        : DateTime(month.year, month.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  void _goPrevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ✅ “오늘로 돌아가기”
  void _goToday() {
    setState(() {
      _focusedMonth = DateTime(_today.year, _today.month, 1);
      _selectedDate = DateTime(_today.year, _today.month, _today.day);
    });
  }

  // ✅ 년/월 선택 다이얼로그
  void _pickYearMonth() async {
  int selectedYear = _focusedMonth.year;
  int selectedMonth = _focusedMonth.month;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("년도 / 월 선택"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ 년도 선택 (setDialogState를 여기서 사용)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedYear--;
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      '$selectedYear년',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setDialogState(() {
                          selectedYear++;
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ✅ 월 선택
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    12,
                    (i) => ChoiceChip(
                      label: Text('${i + 1}월'),
                      selected: selectedMonth == i + 1,
                      selectedColor: Colors.indigo.shade100,
                      onSelected: (_) {
                        selectedMonth = i + 1;
                        Navigator.pop(context);
                        setState(() {
                          _focusedMonth = DateTime(selectedYear, selectedMonth, 1);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("닫기"),
              ),
            ],
          );
        },
      );
    },
  );
}
  // ✅ 일정 추가
  void _addEvent() {
    if (_selectedDate == null) return;

    String newEvent = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(DateFormat('yyyy.MM.dd (E)', 'ko_KR').format(_selectedDate!)),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: '일정 내용 입력'),
            onChanged: (value) => newEvent = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newEvent.trim().isEmpty) return;
                setState(() {
                  _events[_selectedDate!] = [...?_events[_selectedDate], newEvent.trim()];
                });
                Navigator.pop(context);
              },
              child: const Text('적용'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = _firstWeekdayOfMonth(_focusedMonth);
    final totalDays = _daysInMonth(_focusedMonth);
    final totalCells = firstWeekday + totalDays;
    final paddedCells =
        (totalCells % 7 == 0) ? totalCells : totalCells + (7 - totalCells % 7);
    final monthTitle = DateFormat('yyyy년 M월').format(_focusedMonth);

    final todayEvents = _events[_selectedDate] ?? [];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ 월 이동 + 오늘로 돌아가기 + 년/월 선택
            Row(
              children: [
                IconButton(onPressed: _goPrevMonth, icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickYearMonth, // ✅ 클릭 시 다이얼로그
                      child: Text(
                        monthTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: _goNextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),

            // ✅ 오늘로 이동 버튼
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _goToday,
                icon: const Icon(Icons.today, size: 18),
                label: const Text("오늘로 이동"),
              ),
            ),
            const SizedBox(height: 8),

            // 요일 헤더
            Row(
              children: const [
                _WeekdayCell('일'),
                _WeekdayCell('월'),
                _WeekdayCell('화'),
                _WeekdayCell('수'),
                _WeekdayCell('목'),
                _WeekdayCell('금'),
                _WeekdayCell('토'),
              ],
            ),
            const SizedBox(height: 8),

            // 달력 Grid
            Expanded(
              flex: 2,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: paddedCells,
                itemBuilder: (context, index) {
                  final dayNumber = index - firstWeekday + 1;
                  if (index < firstWeekday || dayNumber > totalDays) {
                    return const _DayCell.empty();
                  }

                  final date =
                      DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                  final isToday = _isSameDay(date, _today);
                  final isSelected =
                      _selectedDate != null && _isSameDay(date, _selectedDate!);
                  final hasEvent = _events[date]?.isNotEmpty ?? false;

                  return _DayCell(
                    day: dayNumber,
                    isToday: isToday,
                    isSelected: isSelected,
                    hasEvent: hasEvent,
                    onTap: () {
                      setState(() => _selectedDate = date);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 일정 리스트 영역
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: todayEvents.isEmpty
                    ? const Center(
                        child: Text(
                          '등록된 일정이 없습니다.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: todayEvents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(todayEvents[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                setState(() {
                                  todayEvents.removeAt(index);
                                  _events[_selectedDate!] = todayEvents;
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),

      // 일정 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ================== 날짜 셀 구성 ==================

class _WeekdayCell extends StatelessWidget {
  final String label;
  const _WeekdayCell(this.label);

  @override
  Widget build(BuildContext context) {
    final isSun = label == '일';
    final isSat = label == '토';
    final color = isSun
        ? Colors.redAccent
        : (isSat ? Colors.blueAccent : Theme.of(context).textTheme.bodyMedium?.color);

    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int? day;
  final bool isToday;
  final bool isSelected;
  final bool hasEvent;
  final VoidCallback? onTap;

  const _DayCell({
    super.key,
    this.day,
    this.isToday = false,
    this.isSelected = false,
    this.hasEvent = false,
    this.onTap,
  });

  const _DayCell.empty({super.key})
      : day = null,
        isToday = false,
        isSelected = false,
        hasEvent = false,
        onTap = null;

  @override
  Widget build(BuildContext context) {
    if (day == null) return const SizedBox.shrink();

    final base = Theme.of(context).colorScheme;
    final bgColor = isSelected
        ? base.primary.withOpacity(0.15)
        : (isToday ? base.primary.withOpacity(0.08) : Colors.transparent);
    final borderColor = isSelected
        ? base.primary
        : (isToday ? base.primary.withOpacity(0.6) : Colors.grey.shade300);
    final textColor =
        isSelected ? base.primary : Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          if (hasEvent)
            Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}