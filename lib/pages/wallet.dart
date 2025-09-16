import 'package:flutter/material.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/pages/lottolist.dart';
import 'package:lotto_app/pages/myScaffold.dart';

class WalletPage extends StatefulWidget {
  final UserLoginRespon currentUser;
  const WalletPage({super.key, required this.currentUser});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final int _tab = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB43F3F),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ยอดเงินคงเหลือ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${widget.currentUser.user.wallet} บาท',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 14,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              // เติมเงิน
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/topup.png',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 6),
                    const Text('เติมเงิน'),
                  ],
                ),
              ),

              // เส้นแบ่ง
              Container(width: 1, height: 44, color: Colors.black12),

              // ถอนเงิน
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/withdraw.png',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 6),
                    const Text('ถอนเงิน'),
                  ],
                ),
              ),

              // เส้นแบ่ง
              Container(width: 1, height: 44, color: Colors.black12),

              // โอนเงิน
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/transfer.png',
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(height: 6),
                    const Text('โอนเงิน'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Text(
                'รายการย้อนหลัง',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF360000), // แดงเข้ม
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // แถว 1
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'เงินโอนเข้า',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ),
                        const Text(
                          '05 ก.ย 2568 - 14:00',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '+300.00',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),

                  // แถว 2
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'ซื้อล็อตเตอรี่',
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                        ),
                        const Text(
                          '05 ก.ย 2568 - 14:00',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '-50.00',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
