import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/request/admin_lottoRelease_post_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/pages/mainScaffold.dart';

class LottolistAdminPage extends StatefulWidget {
  final UserLoginRespon currentUser;
  const LottolistAdminPage({super.key, required this.currentUser});

  @override
  State<LottolistAdminPage> createState() => _LottolistAdminPageState();
}

class _LottolistAdminPageState extends State<LottolistAdminPage> {
  final _amountController = TextEditingController();
  final _priceController = TextEditingController();

  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 96),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white.withOpacity(0.5),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  const SizedBox(height: 12),
                  const Text(
                    'Welcome Admin :D',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.confirmation_number),
                      hintText: 'จำนวนล็อตโต้',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Color(0xFFC7C0C0),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.attach_money),
                      hintText: 'ราคาล็อตโต้ต่อใบ',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Color(0xFFC7C0C0),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 1.5,
                                ),
                              ),
                              content: const Text(
                                "ยืนยันที่จะเริ่มการจำหน่ายล๊อตโต้ ?",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                              actionsAlignment: MainAxisAlignment.spaceEvenly,
                              actions: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFCF3030),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "ยกเลิก",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                FilledButton(
                                  onPressed: (CreateLotto),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "ยืนยัน",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.shopping_basket),
                      label: const Text('เริ่มการจำหน่าย'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF3030),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 140,
            child: Image.asset(
              'assets/images/lotto888_icon.png',
              height: 96,
              width: 96,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> CreateLotto() async {
    LottoReleaseRequest request = LottoReleaseRequest(
      count: int.parse(_amountController.text),
      price: int.parse(_priceController.text),
    );
    final res = await http.post(
      Uri.parse("$url/api/lottos/release"),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer ${widget.currentUser.token}",
      },
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MainScaffold(currentUser: widget.currentUser),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('API error: ${res.statusCode}')));
    }
  }
}
