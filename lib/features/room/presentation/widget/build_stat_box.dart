import 'package:flutter/material.dart';

class BuildStatBox extends StatelessWidget {
  const BuildStatBox({super.key, required this.label, required this.value});

  final String label ;
  final int value ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );;
  }
}
