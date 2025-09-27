import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:intl/intl.dart';

/// 🎨 โทนสีตรงดีไซน์
class AppColors {
  static const headerRed = Color(0xFFB43F3F); // พื้นหัวแดง
  static const cream = Color(0xFFFFF2D9); // พื้นด้านในครีม
  static const barYellow = Color(0xFFFFEEB4); // แถบล่าง
}

class Myscaffold extends StatefulWidget {
  final String title;
  final Widget? child;
  final int currentIndex; // 0=ตรวจรางวัล, 1=ล็อตโต้, 2=วอลเล็ต
  final void Function(int index)? onNav;
  final UserLoginRespon currentUser;
  final ValueNotifier<int> walletVN;

  const Myscaffold({
    super.key,
    required this.title,
    this.child,
    this.currentIndex = 1,
    this.onNav,
    required this.currentUser,
    required this.walletVN,
  });

  @override
  State<Myscaffold> createState() => _MyscaffoldState();
}

class _MyscaffoldState extends State<Myscaffold> {
  // ===== ปรับค่าตาม asset/จอจริง เพื่อความเหมือน 100% =====
  static const double headerHeight = 224;
  static const double titleFontSize = 46;
  static const double userCardTopOffset = 76;
  static const double contentTopOverlap = 150;
  static const double contentRadius = 36;

  // Bottom bar แบบไอคอนล้น
  static const double barHeight = 64;
  static const double _iconSize = 72;
  static const double overhang = 20;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final bool isAdmin =
        (widget.currentUser.user.role).trim().toLowerCase() == 'admin';

    return Scaffold(
      extendBody: true,
      body: Container(
        color: AppColors.cream,
        child: Stack(
          children: [
            // 1) พื้นหัวสีแดง
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: const ColoredBox(color: AppColors.headerRed),
            ),

            // 2) Title กลาง
            Positioned(
              top: topPad + 5,
              left: 0,
              right: 0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Title กลางเสมอ
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  // ปุ่ม Logout
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 5, 0),
                      child: IconButton(
                        onPressed: Logout,
                        icon: Icon(Icons.door_back_door, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3) การ์ดผู้ใช้
            Positioned(
              top: topPad + userCardTopOffset,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                      color: Colors.black.withOpacity(0.18),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 28, color: Colors.black87),
                    SizedBox(width: 10),

                    Expanded(
                      child: isAdmin
                          ? Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.currentUser.user.username,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 6)),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(
                                      Icons
                                          .workspace_premium, // มงกุฎ/Badge ใน Material
                                      size: 16,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const WidgetSpan(child: SizedBox(width: 4)),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Text(
                              widget.currentUser.user.username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                    ),

                    SizedBox(
                      height: 28,
                      child: VerticalDivider(
                        width: 24,
                        thickness: 1,
                        color: Colors.black.withOpacity(.15),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          widget.onNav?.call(2); // 2 = Wallet tab
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              size: 22,
                              color: Colors.black87,
                            ),
                            const SizedBox(width: 8),
                            ValueListenableBuilder<int>(
                              valueListenable: widget.walletVN,
                              builder: (_, bal, __) {
                                return Text(
                                  formatBalance(bal),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //4) แผงคอนเทนต์ครีม โค้งมุมบน (เป็นพื้นหลังมาตรฐานของทุกหน้า)
            Positioned.fill(
              top: MediaQuery.of(context).padding.top + contentTopOverlap,
              bottom: 65,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(contentRadius),
                    topRight: Radius.circular(contentRadius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(contentRadius),
                    topRight: Radius.circular(contentRadius),
                  ),
                  child:
                      widget.child ??
                      // เนื้อหาตัวอย่าง (ว่างไว้ตามภาพ)
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: SizedBox(
                          height: 800, // เดโมการเลื่อน
                          child: Container(),
                        ),
                      ),
                ),
              ),
            ),
          ],
        ),
      ),

      // 6) Bottom Bar (ตรึง + เงา)
      bottomNavigationBar: Material(
        type: MaterialType.transparency, // โปร่งใส
        child: Container(
          height: barHeight + overhang + bottomPad,

          //เงาครอบทั้งแถบล่าง ให้ฟุ้งนุ่ม ๆ ขึ้นด้านบน
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 25), // เงาย้อยขึ้นด้านบน
              ),
            ],
          ),

          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // พื้นแถบเหลือง (ตัดเริ่มใต้ส่วน overhang)
              Positioned.fill(
                top: overhang,
                bottom: bottomPad,
                child: const ColoredBox(color: AppColors.barYellow),
              ),

              // ปุ่ม 3 ช่อง (ล้นขึ้นเหนือแถบ)
              Positioned(
                top: -overhang,
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    BottomOverhangItem(
                      label: 'ตรวจรางวัล',
                      asset: 'assets/images/capy_check.png',
                      iconSize: _iconSize,
                      selected: widget.currentIndex == 0,
                      onTap: () => widget.onNav?.call(0),
                    ),
                    BottomOverhangItem(
                      label: 'ล็อตโต้',
                      asset: 'assets/images/capy_lotto.png',
                      iconSize: _iconSize,
                      selected: widget.currentIndex == 1,
                      onTap: () => widget.onNav?.call(1),
                    ),
                    BottomOverhangItem(
                      label: 'วอลเล็ต',
                      asset: 'assets/images/capy_wallet.png',
                      iconSize: _iconSize,
                      selected: widget.currentIndex == 2,
                      onTap: () => widget.onNav?.call(2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void Logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()),
      (Route<dynamic> route) => false,
    );
  }
}

/// ปุ่มล่างแบบ “ไอคอนล้น + label”
class BottomOverhangItem extends StatefulWidget {
  final String label;
  final String asset;
  final bool selected;
  final double iconSize;
  final VoidCallback? onTap;

  const BottomOverhangItem({
    required this.label,
    required this.asset,
    required this.iconSize,
    this.selected = false,
    this.onTap,
  });

  @override
  State<BottomOverhangItem> createState() => _BottomOverhangItemState();
}

class _BottomOverhangItemState extends State<BottomOverhangItem> {
  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
      color: Colors.black.withOpacity(widget.selected ? 0.9 : 0.75),
      height: 1.2,
    );

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.iconSize,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  widget.asset,
                  width: widget.iconSize,
                  height: widget.iconSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(widget.label, style: style),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

String formatBalance(int amount) {
  final nf = NumberFormat("#,##0.00", "th_TH");
  return '\$ ${nf.format(amount)}';
}
