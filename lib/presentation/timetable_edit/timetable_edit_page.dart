import 'package:flutter/material.dart';

class TimetableEditPage extends StatefulWidget {
  static const routeName = '/timetable/edit';

  const TimetableEditPage({super.key});

  @override
  State<TimetableEditPage> createState() => _TimetableEditPageState();
}

class _TimetableEditPageState extends State<TimetableEditPage> {
  final bool _isEditMode = false;

  void _onCancelButtonPressed() {
    Navigator.maybePop(context);
  }

  Widget _buildForm() {
    return Column(
      children: [
        Container(),
      ],
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
              onPressed: _onCancelButtonPressed,
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
              child: Text(_isEditMode ? '수정' : '추가'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _isEditMode
                      ? Container(
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 20,
                          ),
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('삭제하기'),
                          ),
                        )
                      : const SizedBox(height: 28),
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: _buildForm(),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }
}
