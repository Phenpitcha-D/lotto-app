import 'package:flutter/material.dart';

class PrizeCard extends StatelessWidget {
  final String number;       // เลขรางวัล
  final String prizeText;    // ข้อความรางวัล เช่น *รางวัลละ 6,000,000 บาท
  final String leftAsset;    // asset ด้านซ้าย (คาปิบาร่า)
  final String rightAsset;   // asset ด้านขวา (แมวถือเหรียญ)

  // ✅ ปรับขนาดได้
  final double leftSize;       // ขนาดวงกลมด้านซ้าย
  final double leftImageSize;  // ขนาดรูปด้านซ้าย
  final double numberFontSize; // ขนาดฟอนต์เลขรางวัล
  final double rightImageSize; // ขนาดรูปด้านขวา

  const PrizeCard({
    super.key,
    required this.number,
    required this.prizeText,
    required this.leftAsset,
    required this.rightAsset,
    this.leftSize = 70,
    this.leftImageSize = 56,
    this.numberFontSize = 64,
    this.rightImageSize = 52,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ คุม spacing: ถ้ายังไม่ออกรางวัล แสดงข้อความตรง ๆ และไม่เว้นช่อง
    final bool isPending = number.trim() == 'ยังไม่ออกรางวัล';
    final String displayNumber =
        isPending ? number : number.replaceAll(' ', '').split('').join(' ');

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: leftSize + 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayNumber,
                                  style: TextStyle(
                                    fontSize: numberFontSize,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: isPending ? 0 : 4, // ✅ ตรงนี้แหละ!
                                  ),
                                ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Image.asset(
                                      rightAsset,
                                      width: rightImageSize,
                                      height: rightImageSize,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    child: Text(
                      prizeText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFCF3030),
                        fontWeight: FontWeight.w600,
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: leftSize,
                height: leftSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8AD5A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFA35B09)),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  leftAsset,
                  width: leftImageSize,
                  height: leftImageSize,
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
                width: 18,
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
            right: 21,
            bottom: 6,
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
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
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  DashedLinePainter({
    required this.color,
    this.dashWidth = 6,
    this.dashSpace = 3,
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
