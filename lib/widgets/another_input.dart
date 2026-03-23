import 'package:flutter/material.dart';

class AnotherInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final TextEditingController controller;

  const AnotherInput({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),

          TextFormField(
            controller: controller,
            obscureText: obscure,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
            ).copyWith(
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }
}
