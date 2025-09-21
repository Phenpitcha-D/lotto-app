import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/request/user_insertTrans_post_req.dart';
import 'package:lotto_app/model/request/user_transfer_post_req.dart';
import 'package:lotto_app/model/response/trans_post_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/model/response/user_transfer_post_res.dart';
import 'package:lotto_app/model/response/wallet_trans_get_res.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class WalletPage extends StatefulWidget {
  final UserLoginRespon currentUser;

  final ValueNotifier<int> walletVN;
  const WalletPage({
    super.key,
    required this.currentUser,
    required this.walletVN,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  String url = '';
  List<WalletTransRespon> transactions = [];
  late Future<void> loadData;

  // เก็บยอดคงเหลือปัจจุบันเพื่ออัปเดตสดหลังทำรายการ
  int currentBalance = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH');
    loadData = loadDataAsync();
    currentBalance = widget.currentUser.user.wallet;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // บัตรยอดเงินคงเหลือ
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFB43F3F),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 2,
                  color: const Color.fromARGB(99, 0, 0, 0),
                ),
              ],
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ยอดเงินคงเหลือ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 3),
                        blurRadius: 2,
                        color: const Color.fromARGB(99, 0, 0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<int>(
                          valueListenable: widget.walletVN,
                          builder: (context, bal, _) {
                            return Center(
                              child: Text(
                                formatBalance(bal),
                                style: TextStyle(fontSize: 36),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ปุ่มลัด 3 อัน (เติม/ถอน/โอน)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 3),
                  blurRadius: 2,
                  color: const Color.fromARGB(99, 0, 0, 0),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                //เติมเงิน
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: showTopupDialog,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/topup.png',
                              width: 48,
                              height: 48,
                            ),
                            SizedBox(height: 6),
                            Text('เติมเงิน'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 44, color: Colors.black12),

                //ถอนเงิน
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: showWithdrawDialog,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/withdraw.png',
                              width: 48,
                              height: 48,
                            ),
                            SizedBox(height: 6),
                            Text('ถอนเงิน'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 44, color: Colors.black12),

                //โอนเงิน
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: showTransferDialog,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/transfer.png',
                              width: 48,
                              height: 48,
                            ),
                            SizedBox(height: 6),
                            Text('โอนเงิน'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(25, 16, 16, 8),
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
        SizedBox(height: 6),

        //ส่วนแสดง List ประวัติทางการเงิน
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FutureBuilder(
                future: loadData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12, width: double.infinity),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                loadData =
                                    loadDataAsync(); // ✅ ต้อง assign กลับ
                              });
                            },
                            child: const Text('ลองใหม่'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (transactions.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: reload,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false, // ยืดเต็มความสูงที่เหลือ
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text("ไม่มีรายการเดินบัญชี"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: reload,
                    child: Scrollbar(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.black12),
                        itemBuilder: (BuildContext context, int index) {
                          final tran = transactions[index];
                          final isCredit = tran.type.toLowerCase() == 'credit';
                          final amtStr = formatAmount(
                            tran.amount,
                            isCredit: isCredit,
                          );

                          //รายการทางการเงิน เช่น โอนเงิน 11 ก.ย 2568  -300
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    //รายการนี้ทำอะไร เช่น โอนเงิน, เติมเงิน, ถอนเงิน, ซื้อล็อตโต้
                                    Expanded(
                                      child: Text(
                                        tran.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // ทำรายการเมื่อ เช่น  19 ก.ย 2025 - 15:09
                                    Text(
                                      formatDateThai(tran.createdAt),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                // amount (+/- และสีตาม type)
                                Text(
                                  amtStr,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: amountColor(isCredit),
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
        ),
      ],
    );
  }

  /// ใช้รีเฟรชข้อมูลทุกอย่าง (ยอด + ลิสต์)
  Future<void> reload() async {
    await loadDataAsync();
    if (!mounted) return;
    setState(() {
      loadData =
          Future.value(); // ทำให้ FutureBuilder สำเร็จเร็ว และใช้ transactions ล่าสุด
    });
  }

  Future<void> loadDataAsync() async {
    // ดึง config
    if (url.isEmpty) {
      final config = await Configuration.getConfig();
      url = (config['apiEndpoint'] as String).trim();
    }

    // เรียก API
    var uid = widget.currentUser.user.uid;
    var res = await http
        .get(
          Uri.parse('$url/api/wallet/transactions/$uid'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.currentUser.token}",
          },
        )
        .timeout(Duration(seconds: 12));

    // Decode JSON
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    final List listJson = (body is List) ? body : (body["data"] as List? ?? []);
    transactions = listJson.map((e) => WalletTransRespon.fromJson(e)).toList();

    log("จำนวนรายการ: ${transactions.length}");
  }

  //แปลง ว่าจะ -100,+100 เงินขาเข้าหรือออก
  String formatAmount(int amount, {required bool isCredit}) {
    final nf = NumberFormat("#,##0.00", "th_TH");
    return "${isCredit ? '+' : '-'}${nf.format(amount.toDouble())}";
    // NOTE: ถ้าฐานข้อมูลใช้ทศนิยม ให้ปรับ model/จำนวนเงินให้สอดคล้อง
  }

  // แปลง 1000 เป็น 1,000.00 บาท
  String formatBalance(int amount) {
    final nf = NumberFormat("#,##0.00", "th_TH");
    return '${nf.format(amount.toDouble())} บาท';
  }

  String formatDateThai(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("dd MMM yyyy - HH:mm", "th_TH").format(dt);
    } catch (_) {
      return iso;
    }
  }

  Color amountColor(bool isCredit) => isCredit ? Colors.green : Colors.red;

  Future<void> showTopupDialog() async {
    final amtCrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ยืนยันที่จะทำการเติมเงิน?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amtCrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวนเงินที่ต้องการเติม (บาท)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84C43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "ยกเลิก",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "เติมเงิน",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      final amount = int.tryParse(amtCrl.text.trim()) ?? 0;
      if (amount <= 0) {
        showSnack("จำนวนเงินไม่ถูกต้อง", error: true);
        return;
      }
      await topup(amount);
    }
  }

  Future<void> topup(int amount) async {
    final uid = widget.currentUser.user.uid;
    final ok = await showConfirm(
      title: "ยืนยันที่จะทำการเติมเงิน ?",
      message: "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
      okText: "ยืนยัน",
      cancelText: "ยกเลิก",
    );
    if (!ok) return;

    try {
      if (url.isEmpty) {
        final config = await Configuration.getConfig();
        url = config['apiEndpoint'];
      }

      final request = TransReq(
        uid: uid,
        amount: amount,
        description: "เติมเงิน",
      );
      final res = await http.post(
        Uri.parse('$url/api/wallet/topup'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.currentUser.token}",
        },
        body: jsonEncode(request),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('เติมเงินไม่สำเร็จ (${res.statusCode})');
      }

      // พยายามอ่านยอดใหม่ถ้ามีใน response
      try {
        final transRes = transResFromJson(utf8.decode(res.bodyBytes));
        if (mounted) {
          setState(() {
            currentBalance = transRes.newBalance;
            widget.currentUser.user.wallet = transRes.newBalance; // <- สำคัญ
          });
          widget.walletVN.value = transRes.newBalance;
        }
      } catch (_) {}

      showSnack("เติมเงินสำเร็จ +$amount บาท");
      await reload();
    } catch (e) {
      showSnack(e.toString(), error: true);
    }
  }

  Future<void> showWithdrawDialog() async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ยืนยันที่จะทำการถอนเงิน?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวนเงินที่ต้องการถอน (บาท)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84C43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "ยกเลิก",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "ถอนเงิน",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      final amount = int.tryParse(ctl.text.trim()) ?? 0;
      if (amount <= 0) {
        showSnack("จำนวนเงินไม่ถูกต้อง", error: true);
        return;
      }
      await withdraw(amount);
    }
  }

  Future<void> withdraw(int amount) async {
    final uid = widget.currentUser.user.uid;
    final ok = await showConfirm(
      title: "ยืนยันที่จะทำการถอนเงิน ?",
      message: "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
      okText: "ยืนยัน",
      cancelText: "ยกเลิก",
    );
    if (!ok) return;

    try {
      if (url.isEmpty) {
        final config = await Configuration.getConfig();
        url = config['apiEndpoint'];
      }

      final request = TransReq(
        uid: uid,
        amount: amount,
        description: "ถอนเงินออก",
      );
      final res = await http.post(
        Uri.parse('$url/api/wallet/withdraw'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.currentUser.token}",
        },
        body: jsonEncode(request),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('ถอนเงินไม่สำเร็จ (${res.statusCode})');
      }

      // พยายามอ่านยอดใหม่ถ้ามีใน response
      try {
        final transRes = transResFromJson(utf8.decode(res.bodyBytes));
        if (mounted) {
          setState(() {
            currentBalance = transRes.newBalance;
            widget.currentUser.user.wallet = transRes.newBalance; // <- สำคัญ
          });
          widget.walletVN?.value = transRes.newBalance;
        }
      } catch (_) {}

      showSnack("ถอนเงินสำเร็จ -$amount บาท");
      await reload();
    } catch (e) {
      showSnack(e.toString(), error: true);
    }
  }

  Future<void> showTransferDialog() async {
    final usernameCrl = TextEditingController();
    final amountCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ยืนยันที่จะทำการโอนเงิน?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameCrl,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Username ปลายทาง",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวนเงินที่ต้องการโอน (บาท)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84C43),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        "ยกเลิก",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        "โอนเงิน",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok == true) {
      final toUsername = usernameCrl.text;
      final amount = int.tryParse(amountCtl.text.trim()) ?? 0;
      if (amount <= 0) {
        showSnack("ข้อมูลไม่ถูกต้อง", error: true);
        return;
      }
      await transfer(toUsername, amount);
    }
  }

  Future<void> transfer(String toUsername, int amount) async {
    final ok = await showConfirm(
      title: "ยืนยันที่จะทำการโอนเงิน ?",
      message: "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
      okText: "ยืนยัน",
      cancelText: "ยกเลิก",
    );
    if (!ok) return;

    try {
      if (url.isEmpty) {
        final config = await Configuration.getConfig();
        url = config['apiEndpoint'];
      }

      final request = TransferReq(
        toUsername: toUsername,
        amount: amount,
        description: "โอนเงินให้ $toUsername",
      );
      final res = await http.post(
        Uri.parse('$url/api/wallet/transfer'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.currentUser.token}",
        },
        body: jsonEncode(request),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('โอนเงินไม่สำเร็จ (${res.statusCode})');
      }

      // พยายามอ่านยอดใหม่ถ้ามีใน response
      try {
        final body = utf8.decode(res.bodyBytes);

        final transferRes = TransferRes.fromJson(jsonDecode(body));

        final selfUid = widget.currentUser.user.uid;
        int? newBal;
        if (transferRes.from.uid == selfUid) {
          newBal = transferRes.from.newBalance;
        } else if (transferRes.to.uid == selfUid) {
          newBal = transferRes.to.newBalance;
        }

        if (newBal != null && mounted) {
          setState(() {
            currentBalance = newBal!;
            widget.currentUser.user.wallet = newBal!; // <- สำคัญ
          });
          widget.walletVN?.value = newBal;
        }
      } catch (_) {}

      showSnack("โอนเงินสำเร็จ -$amount บาท");

      await reload();
    } catch (e) {
      showSnack(e.toString(), error: true);
    }
  }

  Future<bool> showConfirm({
    required String title,
    required String message,
    String cancelText = "ยกเลิก",
    String okText = "ยืนยัน",
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84C43), // แดง
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          cancelText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5), // น้ำเงิน
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          okText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return ok ?? false;
  }

  void showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }
}
