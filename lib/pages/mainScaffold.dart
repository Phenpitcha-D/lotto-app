import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ✅ เพิ่ม
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/pages/checklotto.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:lotto_app/pages/lottolist.dart';
import 'package:lotto_app/pages/lottolist_admin.dart';
import 'package:lotto_app/pages/myScaffold.dart';
import 'package:lotto_app/pages/wallet.dart';

class MainScaffold extends StatefulWidget {
  final UserLoginRespon currentUser;
  final int startIndex;
  const MainScaffold({
    super.key,
    required this.currentUser,
    required this.startIndex,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int tab = 1; //หน้าล็อตโต้
  String _titleName = "Lotto";
  bool showAdminPage = false;

  late final ValueNotifier<int> walletVN; //ใช้อัพเดตค่า แบบ Real ไทม์เด้

  bool _checking = false;         // ✅ กันเช็คซ้ำ
  bool _shownDeleted = false;     // ✅ กัน dialog ซ้ำ

  @override
  void initState() {
    super.initState();
    tab = widget.startIndex;
    walletVN = ValueNotifier<int>(widget.currentUser.user.wallet);

    // ✅ เช็ค me ครั้งแรกหลัง UI render รอบแรก
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMe(); // ไม่ await เพื่อไม่บล็อก UI
    });
  }

  Widget buildChild(String role) {
    if (tab == 0) {
      return CheckLottoPage(currentUser: widget.currentUser, walletVN: walletVN);
    } else if (tab == 1) {
      if (role == 'admin' && showAdminPage) {
        // ✅ admin → เปิดหน้า Admin
        return LottolistAdminPage(currentUser: widget.currentUser);
      }
      return LottolistPage(
        currentUser: widget.currentUser,
        walletVN: walletVN,
        onGoAdmin: () async {
          // ✅ เช็คสิทธิ์/สถานะบัญชีก่อนจะไปหน้า admin
          final ok = await _checkMe();
          if (!ok) return;
          if (!mounted) return;
          setState(() {
            showAdminPage = true;
          });
        },
      );
    } else {
      return WalletPage(currentUser: widget.currentUser, walletVN: walletVN);
    }
  }

  @override
  Widget build(BuildContext context) {
    String role = widget.currentUser.user.role;
    return Myscaffold(
      title: _titleName,
      currentIndex: tab,
      onNav: (i) async {
        // ✅ ตรวจ /auth/me ทุกครั้งก่อนเปลี่ยนแท็บ
        final ok = await _checkMe();
        if (!ok) return;

        if (!mounted) return;
        setState(() {
          tab = i;
          if (tab == 0) {
            _titleName = "Check Lotto";
          } else if (tab == 1) {
            _titleName = "Lotto";
          } else {
            _titleName = "Wallet";
          }
        });
      },
      currentUser: widget.currentUser,
      walletVN: walletVN,
      child: buildChild(role),
    );
  }

  // ===================== auth/me guard =====================

  Future<bool> _checkMe() async {
    if (_checking) return true; // ถ้ากำลังเช็คอยู่ ให้ถือว่าโอเคชั่วคราว
    _checking = true;
    try {
      final uri = Uri.parse('https://lotto888db.onrender.com/api/auth/me');
      final resp = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${widget.currentUser.token}',
          'Content-Type': 'application/json; charset=utf-8',
        },
      );

      // ถอดรหัส body อย่างปลอดภัย
      Map<String, dynamic>? json;
      try {
        json = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>?;
      } catch (_) {
        json = null;
      }

      final success = (resp.statusCode >= 200 && resp.statusCode < 300) &&
          (json != null && json['success'] == true && json['user'] != null);

      if (success) {
        // ✅ sync ข้อมูลเผื่อฝั่ง server อัปเดตแล้ว
        final u = json['user'] as Map<String, dynamic>;
        final newWallet = (u['wallet'] as num?)?.toInt();
        if (newWallet != null && walletVN.value != newWallet) {
          walletVN.value = newWallet;
        }
        // อัปเดต role/username ใน currentUser (ไม่กระทบ token)
        final role = (u['role'] as String?) ?? widget.currentUser.user.role;
        final username = (u['username'] as String?) ?? widget.currentUser.user.username;
        widget.currentUser.user.role = role;
        widget.currentUser.user.username = username;
        return true;
      }

      // ❌ ไม่พบผู้ใช้ / โทเค็นใช้ไม่ได้ → แจ้งเตือนแล้วเด้งไป Login
      _showAccountDeletedAndLogout();
      return false;
    } catch (_) {
      // ถ้าเช็คไม่ได้ (เน็ตหลุด) — ไม่เด้งออก แต่ไม่เปลี่ยนหน้า
      return false;
    } finally {
      _checking = false;
    }
  }

  Future<void> _showAccountDeletedAndLogout() async {
    if (_shownDeleted || !mounted) return;
    _shownDeleted = true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
        ),
        title: const Text(
          'บัญชีถูกลบแล้ว',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'บัญชีของคุณถูกลบเนื่องจากมีการรีเซ็ตระบบ\nโปรดสมัครบัญชีใหม่',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('ตกลง', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    _logoutToLogin();
  }

  void _logoutToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }
}
