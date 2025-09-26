import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/response/prize_res.dart';
import 'package:lotto_app/model/response/reward_get_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lotto_app/model/response/user_orderrecord_get_res.dart';

class LottoCardCheck extends StatefulWidget {
  final String number; // เลขรางวัล
  final String prizeText; // ข้อความรางวัล เช่น *รางวัลละ 6,000,000 บาท
  final String leftAsset; // asset ด้านซ้าย (คาปิบาร่า)
  final String rightAsset; // asset ด้านขวา (แมวถือเหรียญ)

  final double leftSize;
  final double leftImageSize;
  final double numberFontSize;
  final double rightImageSize;
  final UserLoginRespon currentUser;
  final ValueNotifier<int> walletVN;
  final int lid;

  const LottoCardCheck({
    super.key,
    required this.number,
    required this.prizeText,
    required this.leftAsset,
    required this.rightAsset,
    this.leftSize = 45,
    this.leftImageSize = 38,
    this.numberFontSize = 32,
    this.rightImageSize = 30,
    required this.currentUser,
    required this.walletVN,
    required this.lid,
  });

  @override
  State<LottoCardCheck> createState() => _LottoCardCheckState();
}

class _LottoCardCheckState extends State<LottoCardCheck> {
  // ✅ เพิ่ม getter เพื่ออ้างอิง widget.lid ได้ตรง ๆ แก้ปัญหา lid แดง
  int get lid => widget.lid;

  late Future<UserOrdersRecordResponse> loadData;
  late Future<RewardResultResponse> loadReward;
  String url = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH');

    // โหลด config แล้วเก็บ endpoint ไว้ใช้ซ้ำ
    Configuration.getConfig().then((config) {
      if (!mounted) return;
      setState(() {
        url = config['apiEndpoint'] ?? '';
      });
    });

    // เตรียม future ที่ใช้ภายนอก (ถ้ามีใช้ในหน้า)
    loadReward = RewardResult();
    loadData = LoadOrdersRecord();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE79F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color.fromARGB(255, 255, 240, 189)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 2),
            blurRadius: 1,
            color: Color.fromARGB(100, 0, 0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
                child: Row(
                  children: [
                    SizedBox(width: widget.leftSize + 2),
                    // กล่องเลขรางวัล
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.number.split('').join(' '),
                                  style: TextStyle(
                                    fontSize: widget.numberFontSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ราคา : 80 บาท',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ซื้อเมื่อวันที่ 05 ก.ย 2568',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 18,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 70,
                    height: 30,
                    child: FilledButton(
                      onPressed: () => checkReward(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF28C2D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'ตรวจรางวัล',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 🔹 ไอคอนซ้าย
          Positioned.fill(
            left: 6,
            bottom: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: widget.leftSize,
                height: widget.leftSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8AD5A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA35B09)),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  widget.leftAsset,
                  width: widget.leftImageSize,
                  height: widget.leftImageSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 🔹 แถบสีแดง
          Positioned.fill(
            right: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE24A4A),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ),

          // 🔹 เส้นประด้านล่าง
          Positioned(
            left: 4,
            right: 12,
            bottom: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 1),
              child: CustomPaint(
                painter: DashedLinePainter(
                  color: const Color.fromARGB(255, 96, 34, 9).withOpacity(1),
                ),
                size: const Size(double.infinity, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------- Loads (เดิม) -----------------------------

  Future<UserOrdersRecordResponse> LoadOrdersRecord() async {
    final config = await Configuration.getConfig();
    final base = config['apiEndpoint'];
    final uid = widget.currentUser.user.uid;
    final uri = Uri.parse('$base/api/orders/$uid');

    final res = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer ${widget.currentUser.token}",
      },
    );

    if (res.statusCode == 200) {
      return userOrdersRecordResponseFromJson(res.body);
    } else {
      debugPrint('GET $uri -> ${res.statusCode}\n${res.body}');
      throw Exception("โหลดข้อมูลไม่สำเร็จ: ${res.statusCode}");
    }
  }

  Future<RewardResultResponse> RewardResult() async {
    final config = await Configuration.getConfig();
    final base = config['apiEndpoint'];
    final uri = Uri.parse('$base/api/lottos/results');

    final res = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer ${widget.currentUser.token}",
      },
    );

    if (res.statusCode == 200) {
      return rewardResultResponseFromJson(res.body);
    } else {
      debugPrint('GET $uri -> ${res.statusCode}\n${res.body}');
      throw Exception("โหลดข้อมูลไม่สำเร็จ: ${res.statusCode}");
    }
  }

  // ----------------------------- Methods (ย้ายเข้ามา) -----------------------------

  void checkReward(BuildContext context) async {
    try {
      if (url.isEmpty) {
        return showErrorDialog(
          context,
          title: "กำลังเตรียมเซิร์ฟเวอร์",
          message: "กำลังโหลดการตั้งค่า โปรดลองอีกครั้ง",
        );
      }

      final res = await http.get(
        Uri.parse("$url/api/lottos/prizes/$lid"), // ใช้ getter lid
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Bearer ${widget.currentUser.token}",
        },
      );

      final body = utf8.decode(res.bodyBytes);
      log("CHECK_REWARD[$lid] ${res.statusCode}: $body");

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return showErrorDialog(
          context,
          title: "เกิดข้อผิดพลาด",
          message: "เช็คผลไม่สำเร็จ (${res.statusCode})",
        );
      }

      final parsed = PrizeResponse.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );

      if (!parsed.isWinner) {
        return showLoseDialog(context, extraMessage: parsed.message);
      }

      showPrizeWinDialog(
        context,
        lottoNumber: parsed.lottoNumber ?? widget.number,
        prizes: parsed.prizes,
        total: parsed.totalBounty,
        onClaim: () async {
          if (mounted) Navigator.of(context).pop();
          await claimPrize(context);
        },
      );
    } catch (e) {
      showErrorDialog(context, title: "ข้อผิดพลาด", message: e.toString());
    }
  }

  Future<void> claimPrize(BuildContext context) async {
    try {
      if (url.isEmpty) {
        return showErrorDialog(
          context,
          title: "กำลังเตรียมเซิร์ฟเวอร์",
          message: "กำลังโหลดการตั้งค่า โปรดลองอีกครั้ง",
        );
      }

      final res = await http.post(
        Uri.parse("$url/api/lottos/claim"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Bearer ${widget.currentUser.token}",
        },
        body: jsonEncode({"lid": lid}), // ใช้ getter lid
      );

      final body = utf8.decode(res.bodyBytes);
      log("CLAIM_PRIZE[$lid] ${res.statusCode}: $body");

      if (res.statusCode < 200 || res.statusCode >= 300) {
        return showErrorDialog(
          context,
          title: "เกิดข้อผิดพลาด",
          message: "ขึ้นเงินไม่สำเร็จ (${res.statusCode})",
        );
      }

      final parsed = PrizeResponse.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );

      if (parsed.alreadyClaimed) {
        return showAlreadyClaimedDialog(
          context,
          lottoNumber: parsed.lottoNumber ?? widget.number,
          prizes: parsed.prizes,
          total: parsed.totalBounty,
          message: parsed.message ?? "คุณได้ขึ้นเงินรางวัลนี้แล้ว",
        );
      }

      if (parsed.success) {
        // อัปเดต wallet แบบ Real-time
        widget.walletVN.value += parsed.totalBounty;
        return showClaimSuccessDialog(
          context,
          lottoNumber: parsed.lottoNumber ?? widget.number,
          prizes: parsed.prizes,
          total: parsed.totalBounty,
          message: parsed.message ?? "ขึ้นเงินรางวัลสำเร็จ",
        );
      }

      showErrorDialog(
        context,
        title: "แจ้งเตือน",
        message: parsed.message ?? "ไม่สามารถขึ้นเงินได้",
      );
    } catch (e) {
      showErrorDialog(context, title: "ข้อผิดพลาด", message: e.toString());
    }
  }
}

// ============================ Utilities/Dialogs เดิม ============================

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* ---------------------------- Dialogs & Formatters ---------------------------- */

String formatBaht(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return buf.toString();
}

String baht(int n) => "${formatBaht(n)} บาท";

Widget prizeListView(List<PrizeItem> prizes) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final p in prizes)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  PrizeResponse.rankLabel(p.bountyRank),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(baht(p.bounty)),
            ],
          ),
        ),
    ],
  );
}

void showPrizeWinDialog(
  BuildContext context, {
  required String lottoNumber,
  required List<PrizeItem> prizes,
  required int total,
  required VoidCallback onClaim,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
      title: const Text("🎉 ยินดีด้วย! ถูกรางวัล"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lottoNumber.isNotEmpty) ...[
            Text("สลากเลข: $lottoNumber"),
            const SizedBox(height: 8),
          ],
          const Text(
            "รายละเอียดรางวัล",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          prizeListView(prizes),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "รวมทั้งสิ้น",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(baht(total)),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: onClaim,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          ),
          child: const Text("รับรางวัล"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("ปิด"),
        ),
      ],
    ),
  );
}

void showClaimSuccessDialog(
  BuildContext context, {
  required String lottoNumber,
  required List<PrizeItem> prizes,
  required int total,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
      title: const Text("✅ ขึ้นเงินสำเร็จ"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 8),
          if (lottoNumber.isNotEmpty) Text("สลากเลข: $lottoNumber"),
          const SizedBox(height: 8),
          const Text(
            "รายละเอียดรางวัล",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          prizeListView(prizes),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "ยอดที่ได้รับ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(baht(total)),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("ปิด"),
        ),
      ],
    ),
  );
}

void showAlreadyClaimedDialog(
  BuildContext context, {
  required String lottoNumber,
  required List<PrizeItem> prizes,
  required int total,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFFF9800), width: 1.5),
      ),
      title: const Text("ℹ️ ขึ้นเงินแล้ว"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 8),
          if (lottoNumber.isNotEmpty) Text("สลากเลข: $lottoNumber"),
          const SizedBox(height: 8),
          const Text(
            "รายละเอียดรางวัล",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          prizeListView(prizes),
          const Divider(),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "ยอดที่เคยได้รับ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(baht(total)),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton.tonal(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xFF333333),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("ปิด"),
        ),
      ],
    ),
  );
}

void showLoseDialog(BuildContext context, {String? extraMessage}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("😔", style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          const Text(
            "เสียใจด้วย\nหมายเลขนี้ไม่ถูกรางวัล",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, height: 1.6),
          ),
          if (extraMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              extraMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          ),
          child: const Text("ปิด", style: TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
}

void showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("ปิด"),
        ),
      ],
    ),
  );
}
