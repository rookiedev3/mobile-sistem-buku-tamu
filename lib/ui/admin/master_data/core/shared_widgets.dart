import 'package:flutter/material.dart';

const Color corporateGreen = Color(0xFF006B3F);

InputDecoration searchDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
    prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF778195)),
    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    filled: true,
    fillColor: Colors.white,
  );
}

Widget dialogField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
      const SizedBox(height: 3),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          filled: true,
          fillColor: const Color(0xFFF4F7FC),
          isDense: true,
        ),
      ),
    ],
  );
}

ButtonStyle btnStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: corporateGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}

Widget actionBtn(String label, Color color, IconData icon, VoidCallback onPressed) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 12, color: color),
    label: Text(label, style: TextStyle(fontSize: 10, color: color)),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      minimumSize: const Size(36, 24),
    ),
  );
}