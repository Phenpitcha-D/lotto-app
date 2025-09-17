import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:lotto_app/config/config.dart'; // ✅ โหลด apiEndpoint
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

  // ✅ ใช้จาก Configuration แทน ไม่ hardcode
  String _baseUrl = '';
  bool _configReady = false;

  late Future<List<WalletTransRespon>> _txFuture;

  // เก็บยอดคงเหลือปัจจุบันเพื่ออัปเดตสดหลังทำรายการ
  int _currentBalance = 0;

  // รวม base + path ให้ถูกต้อง (กัน // และขาด /)
  String _join(String base, String path) {
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    if (!path.startsWith('/')) path = '/$path';
    return '$base$path';
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH');

    _currentBalance = widget.currentUser.user.wallet; // set จากข้อมูล login

    // ✅ โหลดค่าคอนฟิกก่อน แล้วค่อยยิง API (ห้ามให้ setState คืน Future)
    Configuration.getConfig().then((config) {
      final ep = (config['apiEndpoint'] ?? '').toString().trim();
      final base = ep.endsWith('/') ? ep.substring(0, ep.length - 1) : ep;
      final ready = base.isNotEmpty;

      // ทำงาน async นอก setState
      final Future<List<WalletTransRespon>> txFuture =
          ready ? _fetchTransactions(base) : Future.value(<WalletTransRespon>[]);

      // อัปเดต state แบบ synchronous เท่านั้น
      setState(() {
        _baseUrl = base;
        _configReady = ready;
        _txFuture = txFuture;
      });
    });
  }

  // ---------------- Networking helpers ----------------

  Future<Map<String, dynamic>> _apiPost(String path, Map<String, dynamic> body) async {
    if (_baseUrl.isEmpty) {
      throw Exception("ยังไม่ได้ตั้งค่า API endpoint");
    }
    final uri = Uri.parse(_join(_baseUrl, path));
    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.currentUser.token}",
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300 && decoded is Map && decoded["success"] == true) {
      return Map<String, dynamic>.from(decoded);
    }
    final msg = (decoded is Map ? decoded["message"] : null)?.toString() ?? "เกิดข้อผิดพลาด (${res.statusCode})";
    throw Exception(msg);
  }

  Future<void> _updateBalanceFromServer() async {
    if (_baseUrl.isEmpty) return;
    try {
      final uid = widget.currentUser.user.uid;
      final uri = Uri.parse(_join(_baseUrl, "/api/wallet/balance/$uid"));
      final res = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.currentUser.token}",
        },
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        final bal = (decoded["balance"] ?? _currentBalance) as num;
        setState(() => _currentBalance = bal.toInt());
      }
    } catch (_) {
      // ไม่ทำให้ UX พัง
    }
  }

  // ---------------- Load transactions ----------------

  // รับ baseUrl เป็นออปชันเพื่อใช้ตอน init ยังไม่ได้เซ็ต state
  Future<List<WalletTransRespon>> _fetchTransactions([String? baseOverride]) async {
    final base = baseOverride ?? _baseUrl;
    if (base.isEmpty) return <WalletTransRespon>[];

    final uid = widget.currentUser.user.uid;
    final uri = Uri.parse(_join(base, "/api/wallet/transactions/$uid"));

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

  // ---------------- Format helpers ----------------

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
    // NOTE: ถ้าฐานข้อมูลใช้ทศนิยม ให้ปรับ model/จำนวนเงินให้สอดคล้อง
  }

  Color _amountColor(bool isCredit) => isCredit ? Colors.green : Colors.red;

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  // ---------------- Confirm dialog สไตล์ภาพ ----------------

  Future<bool> _showConfirm({
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84C43), // แดง
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(cancelText, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5), // น้ำเงิน
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(okText, style: const TextStyle(color: Colors.white)),
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

  // ---------------- Dialogs: เติม / ถอน / โอน ----------------

  Future<void> _showTopupDialog() async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ยืนยันที่จะทำการเติมเงิน?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("ยกเลิก", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("เติมเงิน", style: TextStyle(color: Colors.white)),
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
        _showSnack("จำนวนเงินไม่ถูกต้อง", error: true);
        return;
      }
      await _topup(amount);
    }
  }

  Future<void> _showWithdrawDialog() async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ยืนยันที่จะทำการถอนเงิน?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("ยกเลิก", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("ถอนเงิน", style: TextStyle(color: Colors.white)),
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
        _showSnack("จำนวนเงินไม่ถูกต้อง", error: true);
        return;
      }
      await _withdraw(amount);
    }
  }

  Future<void> _showTransferDialog() async {
    final uidCtl = TextEditingController();
    final amountCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ยืนยันที่จะทำการโอนเงิน?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
              const SizedBox(height: 12),
              TextField(
                controller: uidCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "uid ปลายทาง",
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("ยกเลิก", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("โอนเงิน", style: TextStyle(color: Colors.white)),
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
      final toUid = int.tryParse(uidCtl.text.trim()) ?? 0;
      final amount = int.tryParse(amountCtl.text.trim()) ?? 0;
      if (toUid <= 0 || amount <= 0) {
        _showSnack("ข้อมูลไม่ถูกต้อง", error: true);
        return;
      }
      await _transfer(toUid, amount);
    }
  }

  // ---------------- API methods ----------------

  Future<void> _topup(int amount) async {
    final uid = widget.currentUser.user.uid;
    final ok = await _showConfirm(
      title: "ยืนยันที่จะทำการเติมเงิน ?",
      message: "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
      okText: "ยืนยัน",
      cancelText: "ยกเลิก",
    );
    if (!ok) return;

    try {
      final r = await _apiPost("/api/wallet/topup", {
        "uid": uid,
        "amount": amount,
        "description": "โอนเงินเข้า",
      });
      final newBal = (r["new_balance"] ?? _currentBalance) as num;
      setState(() => _currentBalance = newBal.toInt());
      _showSnack("เติมเงินสำเร็จ +$amount บาท");
      await _onRefresh();
    } catch (e) {
      _showSnack(e.toString(), error: true);
    }
  }

  Future<void> _withdraw(int amount) async {
    final uid = widget.currentUser.user.uid;
    final ok = await _showConfirm(
      title: "ยืนยันที่จะทำการถอนเงิน ?",
      message: "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
      okText: "ยืนยัน",
      cancelText: "ยกเลิก",
    );
    if (!ok) return;

    try {
      final r = await _apiPost("/api/wallet/withdraw", {
        "uid": uid,
        "amount": amount,
        "description": "ถอนเงินออก",
      });
      final newBal = (r["new_balance"] ?? _currentBalance) as num;
      setState(() => _currentBalance = newBal.toInt());
      _showSnack("ถอนเงินสำเร็จ -$amount บาท");
      await _onRefresh();
    } catch (e) {
      _showSnack(e.toString(), error: true);
    }
  }

  Future<void> _transfer(int toUid, int amount) async {
    final fromUid = widget.currentUser.user.uid;
    final ok = await _showConfirm(
      title: "ยืนยันที่จะทำการโอนเงิน ?",
      message: "เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
      okText: "ยืนยัน",
      cancelText: "ยกเลิก",
    );
    if (!ok) return;

    try {
      final r = await _apiPost("/api/wallet/transfer", {
        "fromUid": fromUid,
        "toUid": toUid,
        "amount": amount,
        "description": "โอนเงิน",
      });

      // อัปเดตยอดฝั่งผู้โอน
      final from = r["from"] as Map<String, dynamic>?;
      if (from != null && from["uid"] == fromUid) {
        final newBal = (from["new_balance"] ?? _currentBalance) as num;
        setState(() => _currentBalance = newBal.toInt());
      } else {
        await _updateBalanceFromServer();
      }

      _showSnack("โอนเงินสำเร็จ $amount บาท ไปยัง uid:$toUid");
      await _onRefresh();
    } catch (e) {
      _showSnack(e.toString(), error: true);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    // ✅ ถ้ายังไม่รู้ URL แสดงโหลดก่อน ป้องกัน future ไม่ถูกกำหนด
    if (!_configReady) {
      return const Center(child: CircularProgressIndicator());
    }

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
                        '$_currentBalance บาท',
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
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showTopupDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/topup.png', width: 48, height: 48),
                        const SizedBox(height: 6),
                        const Text('เติมเงิน'),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 44, color: Colors.black12),

              // ถอนเงิน
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showWithdrawDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/withdraw.png', width: 48, height: 48),
                        const SizedBox(height: 6),
                        const Text('ถอนเงิน'),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 44, color: Colors.black12),

              // โอนเงิน
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showTransferDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/transfer.png', width: 48, height: 48),
                        const SizedBox(height: 6),
                        const Text('โอนเงิน'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- หัวข้อ + รายการย้อนหลัง ---
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
