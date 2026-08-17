// // import '../bloc/logout_bloc.dart';    // dari lib/ui/owner/ (kalau strukturnya beda 1 level)\
// import 'package:bloc/logout_bloc.dart';
// // di logout_bloc.dart, tambahkan:
// static void showLogoutConfirmation(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       title: const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
//       content: const Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontSize: 11)),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Batal", style: TextStyle(fontSize: 10, color: Colors.grey)),
//         ),
//         ElevatedButton(
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
//           onPressed: () async {
//             Navigator.pop(context);
//             await LogoutBloc.logout();
//             if (context.mounted) LogoutBloc.keluarKeHomepage(context);
//           },
//           child: const Text("Ya, Keluar", style: TextStyle(fontSize: 10)),
//         ),
//       ],
//     ),
//   );
// }