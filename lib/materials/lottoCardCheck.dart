import 'package:flutter/material.dart';

class LottoCardCheck extends StatelessWidget {
  final String number; // เลขรางวัล
  final String prizeText; // ข้อความรางวัล เช่น *รางวัลละ 6,000,000 บาท
  final String leftAsset; // asset ด้านซ้าย (คาปิบาร่า)
  final String rightAsset; // asset ด้านขวา (แมวถือเหรียญ)

  final double leftSize;
  final double leftImageSize;
  final double numberFontSize;
  final double rightImageSize;

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
  });

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
                    SizedBox(width: leftSize + 2), 
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
                                  number
                                      .split('')
                                      .join(' '), 
                                  style: TextStyle(
                                    fontSize: numberFontSize, 
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
                      alignment: AlignmentGeometry.centerRight,
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
                      alignment: AlignmentGeometry.centerRight,
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
                  alignment: Alignment
                      .centerRight, // แก้จาก AlignmentGeometry.centerRight
                  child: SizedBox(
                    width: 70,
                    height: 30,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFF28C2D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero, 
                        minimumSize: const Size(
                          0,
                          0,
                        ), 
                        tapTargetSize: MaterialTapTargetSize
                            .shrinkWrap,
                      ),
                      child: const Center(
                        child: FittedBox(
                          fit: BoxFit
                              .scaleDown,
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
