import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/request/user_lottobuy_post_req.dart';
import 'package:lotto_app/model/response/user_lottobuy_get_res.dart';

class LottoCard extends StatefulWidget {
  final String number;
  final int price;
  final String? imageAsset;
  final int lid;
  final String token;
  final VoidCallback? onBought; // callback หลังซื้อ
  final ValueNotifier<int> walletVN; //update เงินหลังซื้อ

  const LottoCard({
    super.key,
    required this.number,
    required this.price,
    this.imageAsset,
    required this.lid,
    required this.token,
    this.onBought,
    required this.walletVN,
  });

  @override
  State<LottoCard> createState() => _LottoCardState();
}

class _LottoCardState extends State<LottoCard> {
  bool isBought = false;
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
    return Stack(
      children: [
        // การ์ดพื้นหลัง
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFE79F),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Color.fromARGB(255, 255, 240, 189)),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 3),
                blurRadius: 2,
                color: const Color.fromARGB(99, 0, 0, 0),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 5, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // รูปซ้าย
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFE8AD5A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA35B09)),
                ),
                alignment: Alignment.center,
                child: widget.imageAsset != null
                    ? Image.asset(
                        widget.imageAsset!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      )
                    : const Icon(
                        Icons.confirmation_number,
                        size: 28,
                        color: Colors.brown,
                      ),
              ),
              const SizedBox(width: 12),

              // เนื้อหา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // เลข
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.number.split('').map((digit) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Text(
                                digit,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ราคา : ${widget.price} บาท',
                        style: TextStyle(color: Colors.grey[800], fontSize: 10),
                      ),
                    ),

                    // ปุ่มซื้อ
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                      color: Color(0xFF2196F3),
                                      width: 1.5,
                                    ),
                                  ),
                                  content: const Text(
                                    "ยืนยันที่จะทำการซื้อล็อตโต้หมายเลขนี้ ?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actionsAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  actions: [
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFCF3030,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                      onPressed: () {
                                        LottoBuy();
                                        Navigator.of(context).pop();
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2196F3,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                          icon: Icon(
                            isBought ? Icons.check_circle : Icons.shopping_cart,
                            size: 12,
                          ),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'ซื้อเลย',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: const Size(0, 50),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // แถบแดงด้านขวา
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

        // เส้นประด้านล่าง
        Positioned(
          left: 10,
          right: 22,
          bottom: 6,
          child: CustomPaint(
            painter: DashedLinePainter(color: Colors.brown.withOpacity(0.6)),
            size: const Size(double.infinity, 1),
          ),
        ),
      ],
    );
  }

  void LottoBuy() {
    final req = UserLottoBuyRequest(lid: widget.lid);

    http
        .post(
          Uri.parse("$url/api/orders/buy"),
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": "Bearer ${widget.token}",
          },
          body: jsonEncode(req),
        )
        .then((response) {
          if (response.statusCode == 200) {
            Map<String, dynamic> data;
            try {
              data = jsonDecode(response.body) as Map<String, dynamic>;
            } catch (_) {
              _showError("รูปแบบข้อมูลจากเซิร์ฟเวอร์ไม่ถูกต้อง");
              return;
            }

            final bool ok = (data["success"] == true);
            final String serverMsg =
                (data["message"] is String &&
                    (data["message"] as String).isNotEmpty)
                ? data["message"] as String
                : (ok ? "ทำรายการสำเร็จ" : "ไม่สามารถทำรายการได้");

            if (!ok) {
              _showError(serverMsg);
              return;
            }

            //update wallet balance
            if (data["newBalance"] != null) {
              widget.walletVN.value = (data["newBalance"] as num).toInt();
            } else {
              widget.walletVN.value = widget.walletVN.value - widget.price;
            }

            final lottoNumber = data["lotto_number"]?.toString() ?? "-";
            final price = data["price"]?.toString() ?? widget.price.toString();

            _showSuccess(
              "ทำการซื้อล็อตโต้สำเร็จ\nเลขที่ซื้อ: $lottoNumber\nราคา: $price บาท",
              onOk: () {
                if (widget.onBought != null) widget.onBought!(); // refresh list
              },
            );
          } else {
            String msg = "เกิดข้อผิดพลาด (${response.statusCode})";
            try {
              final body = jsonDecode(response.body);
              if (body is Map &&
                  body["message"] is String &&
                  (body["message"] as String).isNotEmpty) {
                msg = body["message"];
              }
            } catch (_) {}
            _showError(msg);
          }
        })
        .catchError((e) {
          _showError("ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้\nโปรดลองใหม่อีกครั้ง");
        });
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("ตกลง", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("ตกลง", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// 🔹 วาดเส้นประแนวนอน
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  DashedLinePainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 4,
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
