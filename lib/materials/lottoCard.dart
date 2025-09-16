import 'package:flutter/material.dart';

class LottoCard extends StatefulWidget {
  final String number; // เช่น '1 2 3 4 5 6'
  final int price; // เช่น 50
  final String? imageAsset; // path รูป

  const LottoCard({
    super.key,
    required this.number,
    required this.price,
    this.imageAsset,
  });

  @override
  State<LottoCard> createState() => _LottoCardState();
}

class _LottoCardState extends State<LottoCard> {
  bool _isBought = false; // ✅ เก็บสถานะการซื้อ

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // การ์ดพื้นหลัง
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6E9CC), // ครีม
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5CFA2)),
          ),
          padding: const EdgeInsets.fromLTRB(10, 5, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // รูปซ้าย
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF2D29A),
                  shape: BoxShape.circle,
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
                        horizontal: 4,
                        vertical: 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.number,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.25,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ราคา : ${widget.price} บาท',
                      style: TextStyle(color: Colors.grey[800], fontSize: 10),
                    ),

                    // ปุ่มซื้อ
                    Expanded(
                      child: SizedBox(
                        height: 30,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isBought = !_isBought; // ✅ toggle ซื้อ/ไม่ซื้อ
                            });
                          },
                          icon: Icon(
                            _isBought
                                ? Icons.check_circle
                                : Icons.shopping_cart,
                            size: 16,
                          ),
                          label: Text(_isBought ? 'ซื้อแล้ว' : 'ซื้อเลย'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isBought
                                ? Colors.grey
                                : const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
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
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
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
            painter: _DashedLinePainter(color: Colors.brown.withOpacity(0.6)),
            size: const Size(double.infinity, 1),
          ),
        ),
      ],
    );
  }
}

// 🔹 วาดเส้นประแนวนอน
class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  _DashedLinePainter({
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
