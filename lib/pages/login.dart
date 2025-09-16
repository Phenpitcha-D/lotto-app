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

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    });
  }

  var userloginCtl = TextEditingController();
  var usernameCtl = TextEditingController();
  var passwordCtl = TextEditingController();
  var confirmpassCtl = TextEditingController();
  var amountCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
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
                                color: Color(0xFFCC0000), // Lotto สีแดง
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '888',
                              style: GoogleFonts.inter(
                                color: Color(0xFFE88A1A), // 888 สีเหลือง
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
                          color: const Color.fromARGB(255, 0, 0, 0),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: userloginCtl,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: 'Email or Username',
                            prefixIcon: Icon(Icons.account_circle_rounded),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: passwordCtl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            filled: true,
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Color(0xFFC7C0C0),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Checkbox(value: false, onChanged: (value) {}),
                          Text('Remember me'),
                          Text('Forgot password?'),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              log("Pressed");
                              Login(context); // ✅ ส่ง context เข้าไป
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              backgroundColor: Colors.black,
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.inter(
                                color: Colors.white, // ข้อความสีขาว
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
                            'ยังไม่มีบัญชีใช่มะ',
                            style: GoogleFonts.inter(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              navToRegister(context);
                            },
                            child: Text(
                              'สมัครเล้ย!!',
                              style: GoogleFonts.inter(
                                color: Color(0xFFCF3030), // 888 สีเหลือง
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

  void navToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  void Login(BuildContext context) {
    UserLoginRequest request;

    if (userloginCtl.text.contains('@')) {
      request = UserLoginRequest(
        username: '',
        email: userloginCtl.text,
        password: passwordCtl.text,
      );
    } else {
      request = UserLoginRequest(
        username: userloginCtl.text,
        email: '',
        password: passwordCtl.text,
      );
    }
    http
        .post(
          Uri.parse("$url/api/auth/login"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode(request),
        )
        .then((value) {
          UserLoginRespon userLoginRespon = userLoginResponFromJson(value.body);
          log(userLoginRespon.user.username);
          log(userLoginRespon.user.email);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(currentUser: userLoginRespon),
            ),
          );
        })
        .catchError((error) {
          log('Error $error');
        });
  }
}
