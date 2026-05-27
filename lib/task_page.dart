import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_service.dart';

class TaskPage extends StatefulWidget {
  final String planId;
  final String planTitle;

  const TaskPage({
    super.key,
    required this.planId,
    required this.planTitle,
  });

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TodoService _service = TodoService();
  final TextEditingController _controller = TextEditingController();

  void _showAddTaskDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Шинэ Task нэмэх'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Task нэр оруулна уу...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addTask(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () => _addTask(ctx),
            child: const Text('Нэмэх'),
          ),
        ],
      ),
    );
  }

  void _addTask(BuildContext ctx) {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      _service.addTask(widget.planId, title);
      _controller.clear();
      Navigator.pop(ctx);
    }
  }

  void _showEditTaskDialog(String taskId, String currentTitle) {
    _controller.text = currentTitle;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Task засах'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _editTask(ctx, taskId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () => _editTask(ctx, taskId),
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  void _editTask(BuildContext ctx, String taskId) {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      _service.updateTask(widget.planId, taskId, title);
      _controller.clear();
      Navigator.pop(ctx);
    }
  }

  void _confirmDeleteTask(String taskId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Task устгах'),
        content: Text('"$title" task-г устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _service.deleteTask(widget.planId, taskId);
              Navigator.pop(ctx);
            },
            child: const Text('Устгах', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.planTitle),
        leading: const BackButton(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getTasks(widget.planId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Алдаа: ${snapshot.error}'),
            );
          }

          final tasks = snapshot.data?.docs ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Task байхгүй байна.\n"+" товч дарж нэмнэ үү.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final doneCount =
              tasks.where((t) => (t.data() as Map)['isDone'] == true).length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: const Color(0xFFE8F0FE),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: Color(0xFF4285F4)),
                    const SizedBox(width: 8),
                    Text(
                      'Нийт: ${tasks.length}   Дууссан: $doneCount   Үлдсэн: ${tasks.length - doneCount}',
                      style: const TextStyle(
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final data = task.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Гарчиггүй';
                    final isDone = data['isDone'] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDone
                              ? Colors.green.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Checkbox(
                          value: isDone,
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            _service.toggleTask(widget.planId, task.id, isDone);
                          },
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? Colors.grey : Colors.black87,
                          ),
                        ),
                        subtitle: isDone
                            ? const Text(
                                'Дууссан ✓',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              )
                            : const Text(
                                'Хийгдэж байна...',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blue, size: 20),
                              onPressed: () =>
                                  _showEditTaskDialog(task.id, title),
                              tooltip: 'Засах',
                            ),
                            // Устгах товч
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () =>
                                  _confirmDeleteTask(task.id, title),
                              tooltip: 'Устгах',
                            ),
                          ],
                        ),
                        onTap: () {
                          _service.toggleTask(widget.planId, task.id, isDone);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Task нэмэх',
        child: const Icon(Icons.add),
      ),
    );
  }
}