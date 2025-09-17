import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/model/response/wallet_trans_get_res.dart';

class WalletPage extends StatefulWidget {
  final UserLoginRespon currentUser;
  const WalletPage({super.key, required this.currentUser});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final int _tab = 2;

  // TODO: แก้เป็น URL จริงของ API คุณ
  static const String _baseUrl = "https://lotto888db.onrender.com";

  late Future<List<WalletTransRespon>> _txFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH');
    _txFuture = _fetchTransactions();
  }

  Future<List<WalletTransRespon>> _fetchTransactions() async {
    final uid = widget.currentUser.user.uid;
    final uri = Uri.parse("$_baseUrl/api/wallet/transactions/$uid");

    final res = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.currentUser.token}",
      },
    );

    if (res.statusCode != 200) {
      throw Exception("โหลดรายการไม่สำเร็จ (${res.statusCode})");
    }

    final body = jsonDecode(utf8.decode(res.bodyBytes));

    final List listJson = (body is List) ? body : (body["transactions"] as List? ?? []);
    return listJson.map((e) => WalletTransRespon.fromJson(e)).toList();
  }

  Future<void> _onRefresh() async {
    final fut = _fetchTransactions();
    setState(() => _txFuture = fut);
    await fut;
  }

  String _formatDateThai(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("dd MMM yyyy - HH:mm", "th_TH").format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _formatAmount(int amount, {required bool isCredit}) {
    final nf = NumberFormat("#,##0.00", "th_TH");
    return "${isCredit ? '+' : '-'}${nf.format(amount.toDouble())}";
  }

  Color _amountColor(bool isCredit) => isCredit ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- บัตรยอดเงินคงเหลือ ---
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
                        '${widget.currentUser.user.wallet} บาท',
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

        // --- ปุ่มลัด 3 อัน (เติม/ถอน/โอน) ---
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
                    Image.asset('assets/images/topup.png', width: 48, height: 48),
                    const SizedBox(height: 6),
                    const Text('เติมเงิน'),
                  ],
                ),
              ),
              Container(width: 1, height: 44, color: Colors.black12),

              // ถอนเงิน
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/withdraw.png', width: 48, height: 48),
                    const SizedBox(height: 6),
                    const Text('ถอนเงิน'),
                  ],
                ),
              ),
              Container(width: 1, height: 44, color: Colors.black12),

              // โอนเงิน
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/transfer.png', width: 48, height: 48),
                    const SizedBox(height: 6),
                    const Text('โอนเงิน'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- หัวข้อ + รายการย้อนหลัง (ทำให้เลื่อนและไม่ล้นจอ) ---
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'รายการย้อนหลัง',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF360000),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // ✅ ส่วนนี้จะกินพื้นที่ที่เหลือทั้งหมด และ “เลื่อน” ได้
        Expanded(
          child: Container(
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
            child: FutureBuilder<List<WalletTransRespon>>(
              future: _txFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "เกิดข้อผิดพลาด: ${snap.error}",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => _onRefresh(),
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snap.data ?? [];
                if (transactions.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text("ไม่มีรายการเดินบัญชี")),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ เลื่อนสบาย ๆ + ดึงรีเฟรชได้
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.black12),
                      itemBuilder: (context, i) {
                        final tx = transactions[i];
                        final isCredit = tx.type.toLowerCase() == 'credit';
                        final amtStr = _formatAmount(tx.amount, isCredit: isCredit);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              // description
                              Expanded(
                                child: Text(
                                  tx.description,
                                  style: const TextStyle(fontSize: 15, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // createdAt
                              Text(
                                _formatDateThai(tx.createdAt),
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),

                              const SizedBox(width: 8),

                              // amount (+/- และสีตาม type)
                              Text(
                                amtStr,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _amountColor(isCredit),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
