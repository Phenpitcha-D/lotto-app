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
  const MainScaffold({super.key, required this.currentUser});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _tab = 1; //หน้าล็อตโต้
  String _titleName = "Lotto";

  late final ValueNotifier<int> walletVN; //ใช้อัพเดตค่า แบบ Real ไทม์เด้

  @override
  void initState() {
    super.initState();
    walletVN = ValueNotifier<int>(widget.currentUser.user.wallet);
  }

  Widget _buildChild(String role) {
    if (_tab == 0) {
      if (role == 'admin') {
        return ChecklottoAdmin(currentUser: widget.currentUser);
      } else {
        return CheckLottoPage(currentUser: widget.currentUser);
      }
    } else if (_tab == 1) {
      if (role == 'admin') {
        return LottolistAdminPage(currentUser: widget.currentUser);
      } else {
        return LottolistPage(currentUser: widget.currentUser);
      }
    } else {
      return WalletPage(
        currentUser: widget.currentUser,
        walletVN: walletVN,
      ); // เนื้อหา wallet ที่คุณเขียนไว้
    }
  }

  @override
  Widget build(BuildContext context) {
    String role = widget.currentUser.user.role;
    return Myscaffold(
      title: _titleName,
      currentIndex: _tab,
      onNav: (i) {
        setState(() {
          _tab = i;
          //  อัปเดต _titleName ตรงเน้
          if (_tab == 0) {
            _titleName = "Check Lotto";
          } else if (_tab == 1) {
            _titleName = "Lotto";
          } else {
            _titleName = "Wallet";
          }
        });
      },
      currentUser: widget.currentUser,
      walletVN: walletVN,
      child: _buildChild(role),
    );
  }
}
