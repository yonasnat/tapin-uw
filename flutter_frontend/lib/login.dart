import 'package:flutter/material.dart';
import 'app.dart';


class LoginScreen extends StatelessWidget {
 const LoginScreen({super.key});


 // brand colours
 static const _uwPurple   = Color(0xFF7D3CFF);   // background
 static const _beigeFrom = Color(0xFFF5D598);   // gradient start
 static const _beigeTo   = Color(0xFFE9C983);   // gradient end
 static const _navy      = Color(0xFF231942);   // text / icon


 @override
 Widget build(BuildContext context) {
   final userCtl = TextEditingController();
   final passCtl = TextEditingController();


   return Scaffold(
     backgroundColor: _uwPurple,
     body: SafeArea(
       child: Center(
         child: SingleChildScrollView(
           padding: const EdgeInsets.symmetric(horizontal: 32),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               // ── logo block ───────────────────────────────────────────────
               Container(
                 width: 280,
                 height: 280,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(24),
                   gradient: const LinearGradient(
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                     colors: [_beigeFrom, _beigeTo],
                   ),
                 ),
                 child: Center(
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: const [
                       Icon(Icons.touch_app, size: 80, color: _navy),
                       SizedBox(height: 12),
                       Text('TapIn',
                           style: TextStyle(
                             fontSize: 48,
                             fontWeight: FontWeight.w700,
                             color: _navy,
                           )),
                       Text('CONNECT AT UW',
                           style: TextStyle(
                             fontSize: 14,
                             letterSpacing: 1.4,
                             color: _navy,
                           )),
                     ],
                   ),
                 ),
               ),


               const SizedBox(height: 48),


               // ── username ────────────────────────────────────────────────
               _LabeledField(controller: userCtl, hint: 'Username'),


               const SizedBox(height: 24),


               // ── password ────────────────────────────────────────────────
               _LabeledField(
                 controller: passCtl,
                 hint: 'Password',
                 obscure: true,
               ),


               const SizedBox(height: 36),


               // ── login button ────────────────────────────────────────────
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: TextButton(
                   style: TextButton.styleFrom(
                     backgroundColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                   ),
                   onPressed: () {
                     // TODO: add auth flow
                     Navigator.pushReplacement(
                       context,
                       MaterialPageRoute(builder: (context) => const MainScreen()),
                     );
                   },
                   child: const Text(
                     'Login',
                     style: TextStyle(fontSize: 18, color: _uwPurple),
                   ),
                 ),
               ),


               const SizedBox(height: 24),


               // ── create‑account button ───────────────────────────────────
               SizedBox(
                 width: double.infinity,
                 height: 50,
                 child: OutlinedButton(
                   style: OutlinedButton.styleFrom(
                     backgroundColor: _beigeFrom,
                     side: const BorderSide(color: Colors.black54),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                   ),
                   onPressed: () {
                     // TODO: go to sign‑up screen
                   },
                   child: const Text(
                     'Create an Account',
                     style: TextStyle(fontSize: 18, color: Colors.black87),
                   ),
                 ),
               ),
             ],
           ),
         ),
       ),
     ),
   );
 }
}


// small helper for text fields
class _LabeledField extends StatelessWidget {
 final TextEditingController controller;
 final String hint;
 final bool obscure;


 const _LabeledField({
   required this.controller,
   required this.hint,
   this.obscure = false,
 });


 @override
 Widget build(BuildContext context) {
   return TextField(
     controller: controller,
     obscureText: obscure,
     decoration: InputDecoration(
       hintText: hint,
       filled: true,
       fillColor: Colors.white,
       contentPadding:
           const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(4),
         borderSide: BorderSide.none,
       ),
     ),
   );
 }
}
