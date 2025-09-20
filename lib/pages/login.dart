import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/request/user_login_post_req.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/pages/mainScaffold.dart';
import 'package:lotto_app/pages/register.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String url = '';
  bool isLoading = false;
  String? errorText;

  final userloginCtl = TextEditingController();
  final usernameCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  final confirmpassCtl = TextEditingController();
  final amountCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      if (!mounted) return;
      setState(() {
        url = config['apiEndpoint'] ?? '';
      });
    });
  }

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
                'Login',
                style: GoogleFonts.zillaSlab(
                  color: Colors.white,
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
                        'Welcome Back!',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Login to continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (errorText != null) _buildErrorBox(),
                      _buildTextField(
                        controller: userloginCtl,
                        hint: 'Email or Username',
                        icon: Icons.account_circle_rounded,
                      ),
                      _buildTextField(
                        controller: passwordCtl,
                        hint: 'Password',
                        icon: Icons.lock,
                        obscure: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Checkbox(value: false, onChanged: null),
                          Text('Remember me'),
                          Text('Forgot password?'),
                        ],
                      ),
                      _buildLoginButton(context),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ยังไม่มีบัญชีใช่มะ',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => navToRegister(context),
                            child: Text(
                              'สมัครเล้ย!!',
                              style: GoogleFonts.inter(
                                color: Color(0xFFCF3030),
                                fontSize: 14,
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

  Widget _buildErrorBox() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF5350)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFD32F2F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorText!,
              style: GoogleFonts.inter(
                color: const Color(0xFFB71C1C),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Color(0xFFC7C0C0), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : () => SubmitLogin(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Colors.black,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Login',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  void navToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Register()),
    );
  }

  Future<void> SubmitLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

    setState(() {
      errorText = null;
      isLoading = true;
    });

    // ✅ guard เบื้องต้น
    if (url.isEmpty) {
      setState(() => isLoading = false);
      showError('ระบบยังไม่พร้อม (apiEndpoint ว่าง) โปรดลองใหม่อีกครั้ง');
      return;
    }
    if (userloginCtl.text.trim().isEmpty || passwordCtl.text.isEmpty) {
      setState(() => isLoading = false);
      showError('กรอก Email/Username และ Password ให้ครบก่อนนะ');
      return;
    }

    final isEmail = userloginCtl.text.contains('@');
    final req = UserLoginRequest(
      username: isEmail ? '' : userloginCtl.text.trim(),
      email: isEmail ? userloginCtl.text.trim() : '',
      password: passwordCtl.text,
    );

    try {
      final res = await http.post(
        Uri.parse("$url/api/auth/login"),
        headers: const {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(req),
      );

      // อ่าน body แบบ unicode-safe (กันตัวอักษรไทยเพี้ยน)
      final bodyStr = utf8.decode(res.bodyBytes);

      Map<String, dynamic>? json;
      try {
        json = jsonDecode(bodyStr) as Map<String, dynamic>;
      } catch (_) {
        json = null;
      }

      // ❌ เคส HTTP ไม่ใช่ 2xx
      if (res.statusCode < 200 || res.statusCode >= 300) {
        showError(
          (json?['message'] as String?) ??
              'เข้าสู่ระบบไม่สำเร็จ (${res.statusCode})',
        );
        return;
      }

      // ✅ HTTP 2xx แต่ JSON พัง
      if (json == null) {
        showError('รูปแบบข้อมูลตอบกลับไม่ถูกต้อง');
        return;
      }

      // ตรวจ success
      final success = json['success'] == true;
      final message = (json['message'] as String?) ?? '';
      if (!success) {
        showError(message.isNotEmpty ? message : 'เข้าสู่ระบบไม่สำเร็จ');
        return;
      }

      final userLoginRespon = UserLoginRespon.fromJson(json);
      log(userLoginRespon.user.username);
      log(userLoginRespon.user.email);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScaffold(currentUser: userLoginRespon),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showError(
        'ไม่สามารถเชื่อมต่อระบบได้: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String msg, {int seconds = 3}) {
    setState(() => errorText = msg);
    Future.delayed(Duration(seconds: seconds), () {
      if (!mounted) return;
      if (errorText == msg) {
        setState(() => errorText = null);
      }
    });
  }
}
