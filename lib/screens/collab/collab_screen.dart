import 'package:flutter/material.dart';

class CollabScreen extends StatefulWidget {
  const CollabScreen({super.key});

  @override
  State<CollabScreen> createState() => _CollabScreenState();
}

class _CollabScreenState extends State<CollabScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F4FA),
        foregroundColor: Colors.black87,
        title: const Text('협업 / 개인 관리',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tab,
              labelColor: const Color(0xFF5440D6),
              unselectedLabelColor: Colors.black38,
              indicatorColor: const Color(0xFF5440D6),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: '협업'),
                Tab(text: '개인'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _ModePage(mode: _Mode.collab),
          _ModePage(mode: _Mode.personal),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAdd(context),
        backgroundColor: const Color(0xFF5440D6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showQuickAdd(BuildContext context) async {
    final controller = TextEditingController();
    String selectedProject = '일반';
    TimeOfDay? time;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('빠른 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '할 일 제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 9, minute: 0),
                        );
                      },
                      icon: const Icon(Icons.access_time),
                      label: const Text('시간'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showModalBottomSheet<String>(
                          context: context,
                          showDragHandle: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (context) {
                            const items = ['일반', '디자인', '약속', '식품', '개발'];
                            return ListView(
                              children: items
                                  .map((e) => ListTile(
                                        title: Text(e),
                                        onTap: () => Navigator.pop(context, e),
                                      ))
                                  .toList(),
                            );
                          },
                        );
                        if (picked != null) {
                          selectedProject = picked;
                        }
                      },
                      icon: const Icon(Icons.tag),
                      label: const Text('프로젝트'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                _Inbox.instance.add(
                  TaskItem(
                    title: controller.text.trim(),
                    time: time,
                    tag: selectedProject,
                    isDone: false,
                    assignee: null,
                  ),
                  mode: _Mode.collab, // 기본 협업에 추가(필요시 바꿔)
                );
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }
}

/* --------------------------- 내부 페이지 (탭) --------------------------- */

enum _Mode { collab, personal }

class _ModePage extends StatefulWidget {
  const _ModePage({required this.mode});

  final _Mode mode;

  @override
  State<_ModePage> createState() => _ModePageState();
}

class _ModePageState extends State<_ModePage> {
  final _sections = <CollapsibleSection>[];

  @override
  void initState() {
    super.initState();
    // 샘플 데이터 구성
    final items = _Inbox.instance.itemsFor(widget.mode);

    _sections.addAll([
      CollapsibleSection(
        title: '프로젝트',
        emoji: '📁',
        items: items.where((e) => e.assignee == null).toList(),
      ),
      CollapsibleSection(
        title: widget.mode == _Mode.collab ? '팀' : '사이드',
        emoji: widget.mode == _Mode.collab ? '👥' : '✨',
        items: items.where((e) => e.assignee != null).toList(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemBuilder: (context, index) {
        final sec = _sections[index];
        return _SectionWidget(
          section: sec,
          onChanged: () => setState(() {}),
          onToggleCollapse: () {
            setState(() => sec.collapsed = !sec.collapsed);
          },
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: _sections.length,
    );
  }
}

/* ---------------------------- 데이터 & 상태 ---------------------------- */

class TaskItem {
  TaskItem({
    required this.title,
    required this.tag,
    this.time,
    this.isDone = false,
    this.assignee, // null이면 내 프로젝트, 값 있으면 협업/팀
  });

  String title;
  String tag;
  TimeOfDay? time;
  bool isDone;
  String? assignee;
}

class CollapsibleSection {
  CollapsibleSection({
    required this.title,
    required this.emoji,
    required this.items,
  });

  String title;
  String emoji;
  List<TaskItem> items;
  bool collapsed = false;

  int get count => items.length;
}

class _Inbox {
  _Inbox._();

  static final _Inbox instance = _Inbox._();

  final List<TaskItem> _collab = [
    TaskItem(
      title: '디자인 리뷰',
      tag: '디자인',
      time: const TimeOfDay(hour: 10, minute: 0),
      assignee: '피터',
    ),
    TaskItem(
      title: '데일리 스탠드업',
      tag: '개발',
      time: const TimeOfDay(hour: 9, minute: 30),
      assignee: '팀',
    ),
    TaskItem(
      title: '베타 배포 체크',
      tag: '개발',
      time: const TimeOfDay(hour: 16, minute: 0),
    ),
  ];

  final List<TaskItem> _personal = [
    TaskItem(
      title: '요가 30분',
      tag: '피트니스',
      time: const TimeOfDay(hour: 7, minute: 30),
    ),
    TaskItem(
      title: '치과 예약',
      tag: '약속',
      time: const TimeOfDay(hour: 10, minute: 0),
    ),
    TaskItem(
      title: '빵 구입',
      tag: '식품',
      time: const TimeOfDay(hour: 18, minute: 0),
    ),
  ];

  List<TaskItem> itemsFor(_Mode mode) =>
      mode == _Mode.collab ? _collab : _personal;

  void add(TaskItem item, {required _Mode mode}) {
    (mode == _Mode.collab ? _collab : _personal).insert(0, item);
  }

  void remove(TaskItem item, {required _Mode mode}) {
    (mode == _Mode.collab ? _collab : _personal).remove(item);
  }
}

/* ---------------------------- 프레젠테이션 ---------------------------- */

class _SectionWidget extends StatefulWidget {
  const _SectionWidget({
    required this.section,
    required this.onChanged,
    required this.onToggleCollapse,
  });

  final CollapsibleSection section;
  final VoidCallback onChanged;
  final VoidCallback onToggleCollapse;

  @override
  State<_SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<_SectionWidget> {
  @override
  Widget build(BuildContext context) {
    final s = widget.section;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 섹션 헤더
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: widget.onToggleCollapse,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Text('${s.emoji}  ${s.title}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('${s.count}',
                      style: const TextStyle(
                          color: Colors.black38, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Icon(
                    s.collapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: Colors.black45,
                  )
                ],
              ),
            ),
          ),
          if (!s.collapsed) const Divider(height: 1),
          if (!s.collapsed)
            ...s.items.map((item) => _TaskRow(
                  item: item,
                  onChanged: widget.onChanged,
                )),
          if (!s.collapsed) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TaskRow extends StatefulWidget {
  const _TaskRow({required this.item, required this.onChanged});

  final TaskItem item;
  final VoidCallback onChanged;

  @override
  State<_TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<_TaskRow> {
  @override
  Widget build(BuildContext context) {
    final i = widget.item;
    return InkWell(
      onTap: () {
        setState(() => i.isDone = !i.isDone);
        widget.onChanged();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 원형 체크
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: i.isDone
                      ? const Color(0xFF5440D6)
                      : Colors.black26,
                  width: 2,
                ),
                color: i.isDone ? const Color(0xFF5440D6) : Colors.transparent,
              ),
              child: i.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            // 제목 + 시간칩
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration:
                          i.isDone ? TextDecoration.lineThrough : null,
                      color: i.isDone ? Colors.black38 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (i.time != null) ...[
                        _TimeChip(time: i.time!),
                        const SizedBox(width: 6),
                        const Icon(Icons.alarm, size: 16, color: Colors.black38),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 태그 + 케밥
            _TagChip(text: i.tag),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.black45),
              onSelected: (v) async {
                if (v == 'rename') {
                  final c = TextEditingController(text: i.title);
                  final newTitle = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('제목 수정'),
                      content: TextField(
                        controller: c,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, c.text.trim()),
                          child: const Text('저장'),
                        ),
                      ],
                    ),
                  );
                  if (newTitle != null && newTitle.isNotEmpty) {
                    setState(() => i.title = newTitle);
                  }
                } else if (v == 'time') {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime:
                        i.time ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) setState(() => i.time = picked);
                } else if (v == 'delete') {
                  // 단순히 숨김 처리(실제 삭제는 샘플이라 생략)
                  setState(() => i.title = '[삭제됨] ${i.title}');
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'rename', child: Text('이름 변경')),
                PopupMenuItem(value: 'time', child: Text('시간 변경')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('삭제', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ 작은 위젯 ------------------------------ */

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    final t = time.format(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE9F8EA),
      ),
      child: Text(
        t,
        style: const TextStyle(
          color: Color(0xFF1B8F2E),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});
  final String text;

  Color _tagColor(String t) {
    switch (t) {
      case '디자인':
        return const Color(0xFF7C4DFF);
      case '개발':
        return const Color(0xFF0277BD);
      case '약속':
        return const Color(0xFFEF6C00);
      case '식품':
        return const Color(0xFF8D6E63);
      case '피트니스':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF455A64);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _tagColor(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(.3)),
        color: c.withOpacity(.06),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}