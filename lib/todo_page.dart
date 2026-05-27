import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo_service.dart';
import 'task_page.dart';
import 'auth_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoService _service = TodoService();
  final TextEditingController _controller = TextEditingController();

  // Одоогийн нэвтэрсэн хэрэглэгч
  final User? _user = FirebaseAuth.instance.currentUser;

  // Plan нэмэх dialog
  void _showAddPlanDialog() {
    _controller.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Шинэ Plan нэмэх'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Plan нэр оруулна уу...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addPlan(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () => _addPlan(ctx),
            child: const Text('Нэмэх'),
          ),
        ],
      ),
    );
  }

  // Plan нэмэх
  void _addPlan(BuildContext ctx) {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      _service.addPlan(title);
      _controller.clear();
      Navigator.pop(ctx);
    }
  }

  // Plan засах dialog
  void _showEditPlanDialog(String planId, String currentTitle) {
    _controller.text = currentTitle;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plan засах'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _editPlan(ctx, planId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () => _editPlan(ctx, planId),
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  // Plan засах
  void _editPlan(BuildContext ctx, String planId) {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      _service.updatePlan(planId, title);
      _controller.clear();
      Navigator.pop(ctx);
    }
  }

  // Plan устгах баталгаажуулах dialog
  void _confirmDeletePlan(String planId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plan устгах'),
        content: Text('"$title" планыг устгах уу?\nДотор байгаа task-ууд бүгд устна.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _service.deletePlan(planId);
              Navigator.pop(ctx);
            },
            child: const Text('Устгах', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Гарах (Sign Out)
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    }
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
        title: const Text('Миний Планууд'),
        actions: [
          // Хэрэглэгчийн нэр
          if (_user?.displayName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  _user!.displayName!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          // Profile зураг
          if (_user?.photoURL != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(_user!.photoURL!),
              ),
            ),
          // Гарах товч
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Гарах',
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.getPlans(),
        builder: (context, snapshot) {
          // Ачааллаж байгаа үед
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Алдаа гарсан үед
          if (snapshot.hasError) {
            return Center(
              child: Text('Алдаа: ${snapshot.error}'),
            );
          }

          final plans = snapshot.data?.docs ?? [];

          // Plan байхгүй үед
          if (plans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.playlist_add, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'План байхгүй байна.\n"+" товч дарж нэмнэ үү.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Plan жагсаалт
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final data = plan.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Гарчиггүй';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF4285F4),
                    child: Icon(Icons.folder_outlined, color: Colors.white),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: const Text('Дарж task харах'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Засах товч
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _showEditPlanDialog(plan.id, title),
                        tooltip: 'Засах',
                      ),
                      // Устгах товч
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDeletePlan(plan.id, title),
                        tooltip: 'Устгах',
                      ),
                    ],
                  ),
                  // TaskPage руу шилжих
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskPage(
                          planId: plan.id,
                          planTitle: title,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // Plan нэмэх FAB
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanDialog,
        tooltip: 'Plan нэмэх',
        child: const Icon(Icons.add),
      ),
    );
  }
}