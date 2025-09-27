import 'dart:convert';
import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/request/user_register_post_req.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String url = '';
  bool isLoading = false;

  // controllers
  final emailCtl = TextEditingController();
  final usernameCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  final confirmpassCtl = TextEditingController();
  final walletCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      setState(() {
        url = (config['apiEndpoint'] ?? '').toString();
      });
    }).catchError((e, st) {
      log('Load config error: $e', stackTrace: st);
    });
  }

  @override
  void dispose() {
    emailCtl.dispose();
    usernameCtl.dispose();
    passwordCtl.dispose();
    confirmpassCtl.dispose();
    walletCtl.dispose();
    super.dispose();
  }

  // -------------------- helpers --------------------
  bool looksLikeDuplicate(String? msg) {
    final m = (msg ?? '').toLowerCase();
    return m.contains('ใช้งานแล้ว') ||
        m.contains('already in use') ||
        m.contains('already exists') ||
        m.contains('duplicate') ||
        m.contains('unique constraint') ||
        m.contains('constraint failed');
  }

  void showDuplicateGeneric() {
    showError('อีเมลหรือชื่อผู้ใช้นี้มีผู้ใช้งานแล้ว');
  }
  // -------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/lotto888_icon.png",
                width: 113,
                height: 113,
              ),
              Text(
                'Register',
                style: GoogleFonts.zillaSlab(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Lotto',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFCC0000),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '888',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFE88A1A),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Welcome :D',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      Text(
                        'Create a Lotto member now!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Email
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: emailCtl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Username
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: usernameCtl,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Username',
                            prefixIcon: const Icon(Icons.account_circle),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Password
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: passwordCtl,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Confirm Password
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: confirmpassCtl,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Wallet (digits only)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: walletCtl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            hintText: 'Amount',
                            prefixIcon: const Icon(Icons.currency_exchange),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Register Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (isLoading) ? null : onRegisterPressed,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              backgroundColor: Colors.black,
                              disabledBackgroundColor: Colors.black54,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Register',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'มีบัญชีใช่มะ',
                            style: GoogleFonts.inter(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              navToLogin(context);
                            },
                            child: Text(
                              'ล็อกอินเล้ย!',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFCF3030),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ยิง API + แยกผลลัพธ์แบบปลอดภัย
  Future<void> onRegisterPressed() async {
    if (url.isEmpty) {
      showError('ระบบกำลังเตรียมการเชื่อมต่อ โปรดลองใหม่อีกครั้ง');
      return;
    }

    final email = emailCtl.text.trim();
    final username = usernameCtl.text.trim();
    final password = passwordCtl.text;
    final confirm = confirmpassCtl.text;
    final walletText = walletCtl.text.trim();

    if (email.isEmpty) {
      showError('กรุณากรอกอีเมล');
      return;
    }
    final emailOk = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
    if (!emailOk) {
      showError('รูปแบบอีเมลไม่ถูกต้อง');
      return;
    }
    if (username.isEmpty) {
      showError('กรุณากรอกชื่อผู้ใช้');
      return;
    }
    if (password.isEmpty) {
      showError('กรุณากรอกรหัสผ่าน');
      return;
    }
    if (password.length < 6) {
      showError('รหัสผ่านต้องยาวอย่างน้อย 6 ตัวอักษร');
      return;
    }
    if (confirm != password) {
      showError('รหัสผ่านยืนยันไม่ตรงกัน');
      return;
    }

    final wallet = walletText.isEmpty ? 0 : (int.tryParse(walletText) ?? -1);
    if (wallet == -1) {
      showError('Amount ต้องเป็นตัวเลขเท่านั้น');
      return;
    }

    setState(() => isLoading = true);

    try {
      final request = UserRegisterRequest(
        username: username,
        password: password,
        email: email,
        wallet: wallet,
      );

      final uri = Uri.parse('$url/api/auth/register');

      final resp = await http
          .post(
            uri,
            headers: const {
              "Accept": "application/json",
              "Content-Type": "application/json; charset=utf-8",
            },
            body: jsonEncode(request),
          )
          .timeout(const Duration(seconds: 20));

      // รองรับทั้ง 200 + success:false และ 409/400 ตามมาตรฐาน
      Map<String, dynamic>? data;
      try {
        data = jsonDecode(resp.body) as Map<String, dynamic>?;
      } catch (_) {
        data = null;
      }

      final success = (data?['success'] is bool)
          ? (data!['success'] as bool)
          : (resp.statusCode >= 200 && resp.statusCode < 300);

      final message = (data?['message'] ?? data?['error'] ?? 'สมัครสมาชิกไม่สำเร็จ (${resp.statusCode})').toString();

      if (success) {
        if (!mounted) return;
        await showSuccess('สมัครสมาชิกสำเร็จ ล็อกอินเข้าสู่ระบบได้เลย');
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
        return;
      } else {
        if (looksLikeDuplicate(message)) {
          showDuplicateGeneric(); // “อีเมลหรือชื่อผู้ใช้นี้มีผู้ใช้งานแล้ว”
        } else if (resp.statusCode == 400) {
          showError(message); // validation อื่น ๆ
        } else {
          showError(message); // ข้อผิดพลาดทั่วไป
        }
      }
    } on TimeoutException {
      showError('เครือข่ายช้า หรือเซิร์ฟเวอร์ไม่ตอบสนอง โปรดลองใหม่');
    } catch (e, st) {
      log('Register error: $e', stackTrace: st);
      showError('เกิดข้อผิดพลาดไม่ทราบสาเหตุ โปรดลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // คง method เดิมไว้เพื่อความเข้ากัน
  void register() {
    onRegisterPressed();
  }

  // Dialog helpers
  Future<void> showSuccess(String msg) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
          ),
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("ตกลง", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('สมัครไม่สำเร็จ'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void navToLogin(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
  }
}
