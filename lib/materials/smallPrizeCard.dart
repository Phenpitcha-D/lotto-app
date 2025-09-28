import 'package:flutter/material.dart';

class SmallPrizeCard extends StatelessWidget {
  final String number; // เลขรางวัล
  final String prizeText; // ข้อความรางวัล เช่น *รางวัลละ 6,000,000 บาท
  final String leftAsset; // asset ด้านซ้าย (คาปิบาร่า)
  final String rightAsset; // asset ด้านขวา (แมวถือเหรียญ)

  final double leftSize; // ✅ ขนาดวงกลมด้านซ้าย
  final double leftImageSize; // ✅ ขนาดรูปด้านซ้าย
  final double numberFontSize; // ✅ ขนาดฟอนต์เลขรางวัล
  final double rightImageSize; // ✅ ขนาดรูปขวา

  const SmallPrizeCard({
    super.key,
    required this.number,
    required this.prizeText,
    required this.leftAsset,
    required this.rightAsset,
    this.leftSize = 40, // default = 40
    this.leftImageSize = 32, // default = 32
    this.numberFontSize = 32, // default = 32 (เล็กกว่า PrizeCard หลัก)
    this.rightImageSize = 28, // default = 28
  });

  @override
  Widget build(BuildContext context) {
    // ✅ เตรียมค่าที่จะแสดงเพื่อคุม spacing ให้ถูกต้อง
    final bool isPending = number.trim() == 'ยังไม่ออกรางวัล';
    final String displayNumber = isPending
        ? number
        : number.replaceAll(' ', '').split('').join(' '); // กันเคสมี space เดิม

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE79F), // ครีมพื้นหลัง
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
                    SizedBox(width: leftSize + 2), // ✅ เว้นที่ตามขนาดไอคอนซ้าย
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
                                  displayNumber,
                                  style: TextStyle(
                                    fontSize: numberFontSize, // ✅ ปรับได้
                                    fontWeight: FontWeight.bold,
                                    // ✅ ไม่เว้นช่องเพิ่มเมื่อเป็นข้อความ “ยังไม่ออกรางวัล”
                                    letterSpacing: isPending ? 0 : 4,
                                  ),
                                ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Image.asset(
                                      rightAsset,
                                      width: rightImageSize, // ✅ ปรับได้
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

              // ข้อความรางวัล
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 15, 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    child: Text(
                      prizeText,
                      style: const TextStyle(
                        fontSize: 12,
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
            bottom: 12,
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
}

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
