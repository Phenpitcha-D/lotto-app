import 'package:flutter/material.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/pages/checklotto.dart';
import 'package:lotto_app/pages/checklotto_admin.dart';
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

  @override
  void initState() {
    super.initState();
    tab = widget.startIndex;
    walletVN = ValueNotifier<int>(widget.currentUser.user.wallet);
  }

  Widget buildChild(String role) {
    if (tab == 0) {
      if (role == 'admin') {
        return ChecklottoAdmin(currentUser: widget.currentUser);
      } else {
        return CheckLottoPage(currentUser: widget.currentUser);
      }
    } else if (tab == 1) {
      if (role == 'admin' && showAdminPage) {
        // ✅ ถ้า admin และกดปุ่มจาก LottolistPage → เปิดหน้า LottolistAdminPage
        return LottolistAdminPage(currentUser: widget.currentUser);
      }
      return LottolistPage(
        currentUser: widget.currentUser,
        walletVN: walletVN,
        onGoAdmin: () {
          setState(() {
            showAdminPage = true; // ✅ trigger ให้เปิดหน้า admin
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
      onNav: (i) {
        setState(() {
          tab = i;
          //  อัปเดต _titleName ตรงเน้
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
}
