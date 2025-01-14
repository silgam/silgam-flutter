import 'package:flutter/material.dart';

import 'custom_card.dart';

class LoginButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final String description;

  const LoginButton({
    super.key,
    required this.onTap,
    this.description = '로그인하면 실감의 더 많은 기능들을 누릴 수 있어요!',
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: Theme.of(context).primaryColor,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(
                Icons.login,
                color: Colors.white,
              ),
              const SizedBox(width: 18),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
