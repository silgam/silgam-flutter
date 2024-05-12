import 'package:flutter/material.dart';
import 'package:silgam/presentation/custom_exam_list/custom_exam_list_page.dart';

class CustomExamEditPage extends StatefulWidget {
  static const routeName = '${CustomExamListPage.routeName}/edit';

  const CustomExamEditPage({super.key});

  @override
  State<CustomExamEditPage> createState() => _CustomExamEditPageState();
}

class _CustomExamEditPageState extends State<CustomExamEditPage> {
  Widget _buildForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'test',
              label: Text('과목 이름'),
            ),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'test',
              label: Text('과목 이름'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.grey,
              ),
              child: Text(
                '취소',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('추가'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildForm(),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
