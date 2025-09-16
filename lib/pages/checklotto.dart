import 'package:flutter/material.dart';

/// 🎨 โทนสีพื้นหลังแผงใหญ่
class AppColors {
  static const cream = Color(0xFFFFF2D9);
}

class CheckLottoPage extends StatefulWidget {
  const CheckLottoPage({super.key});
  @override
  State<CheckLottoPage> createState() => _CheckLottoPageState();
}

class _CheckLottoPageState extends State<CheckLottoPage> {
  // สีที่ใช้ซ้ำ
  static const _cream = Color(0xFFF6E9CC);
  static const _creamBorder = Color(0xFFE5CFA2);
  static const _redStripe = Color(0xFFE24A4A);
  static const _warnText = Color(0xFFCF3030);

  // รูปที่ใช้ซ้ำ
  static const _leftAsset = 'assets/images/lotto_pool.png';
  static const _rightAsset = 'assets/images/catcoin.png';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== รางวัลที่ออก ======
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'รางวัลที่ออก',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'รางวัลที่ 1',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  _PrizeLargeCard(
                    cream: _cream,
                    creamBorder: _creamBorder,
                    redStripe: _redStripe,
                    warnText: _warnText,
                    number: '1 2 3 4 5 6',
                    prizeText: '*รางวัลละ: 6,000,000 บาท',
                    leftAsset: _leftAsset,
                    rightAsset: _rightAsset,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _PrizeColumn(
                          title: 'รางวัลที่ 2',
                          card: _PrizeSmallCard(
                            cream: _cream,
                            creamBorder: _creamBorder,
                            redStripe: _redStripe,
                            number: '1 2 3 4 5 6',
                            prizeText: '*รางวัลละ: 50,000 บาท',
                            leftAsset: _leftAsset,
                            rightAsset: _rightAsset,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrizeColumn(
                          title: 'รางวัลที่ 3',
                          card: _PrizeSmallCard(
                            cream: _cream,
                            creamBorder: _creamBorder,
                            redStripe: _redStripe,
                            number: '1 2 3 4 5 6',
                            prizeText: '*รางวัลละ: 1,000 บาท',
                            leftAsset: _leftAsset,
                            rightAsset: _rightAsset,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _PrizeColumn(
                          title: 'รางวัลเลขท้าย 3 ตัว',
                          card: _PrizeSmallCard(
                            cream: _cream,
                            creamBorder: _creamBorder,
                            redStripe: _redStripe,
                            number: '1 2 3 4 5 6',
                            prizeText: '*รางวัลละ: 500 บาท',
                            leftAsset: _leftAsset,
                            rightAsset: _rightAsset,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrizeColumn(
                          title: 'รางวัลเลขท้าย 3 ตัว',
                          card: _PrizeSmallCard(
                            cream: _cream,
                            creamBorder: _creamBorder,
                            redStripe: _redStripe,
                            number: '1 2 3 4 5 6',
                            prizeText: '*รางวัลละ: 100 บาท',
                            leftAsset: _leftAsset,
                            rightAsset: _rightAsset,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'ออกเมื่อ 5 ก.ย 2568',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ====== สลากของฉัน ======
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'สลากของฉัน',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MyTicketCard(
                          cream: _cream,
                          creamBorder: _creamBorder,
                          redStripe: _redStripe,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MyTicketCard(
                          cream: _cream,
                          creamBorder: _creamBorder,
                          redStripe: _redStripe,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------- helpers -------------------------------- */

class _PrizeColumn extends StatelessWidget {
  final String title;
  final Widget card;
  const _PrizeColumn({required this.title, required this.card});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      card,
    ],
  );
}

class _PrizeLargeCard extends StatelessWidget {
  final Color cream, creamBorder, redStripe, warnText;
  final String number, prizeText, leftAsset, rightAsset;
  const _PrizeLargeCard({
    required this.cream,
    required this.creamBorder,
    required this.redStripe,
    required this.warnText,
    required this.number,
    required this.prizeText,
    required this.leftAsset,
    required this.rightAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: creamBorder),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _circleImage(leftAsset, 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pillNumberInline(
                      number: number,
                      rightAsset: rightAsset,
                      fontSize:
                          28, // ขยายได้เต็มที่ แต่ FittedBox จะย่อถ้าพื้นที่ไม่พอ
                      padV: 10,
                      iconSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                prizeText,
                style: TextStyle(
                  fontSize: 12,
                  color: warnText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const _DashedLine(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            decoration: BoxDecoration(
              color: redStripe,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrizeSmallCard extends StatelessWidget {
  final Color cream, creamBorder, redStripe;
  final String number, prizeText, leftAsset, rightAsset;

  const _PrizeSmallCard({
    required this.cream,
    required this.creamBorder,
    required this.redStripe,
    required this.number,
    required this.prizeText,
    required this.leftAsset,
    required this.rightAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: creamBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _circleImage(leftAsset, 42),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _pillNumberInlineSpaced(
                      number: number,
                      rightAsset: rightAsset,
                      fontSize: 22, // ใหญ่ขึ้นได้ ป้องกันล้นด้วย FittedBox
                      padV: 8,
                      digitGap: 10,
                      iconSize: 16,
                      rightGap: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '*รางวัลละ: 50,000 บาท', // ค่าในตัวอย่าง เรียกใช้จริงส่งจากพารามิเตอร์แล้ว
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFCF3030),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const _DashedLine(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            decoration: BoxDecoration(
              color: redStripe,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MyTicketCard extends StatelessWidget {
  final Color cream, creamBorder, redStripe;
  const _MyTicketCard({
    required this.cream,
    required this.creamBorder,
    required this.redStripe,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: creamBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(10, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _circleIcon(56),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PillText('1 2 3 4 5 6'),
                        SizedBox(height: 6),
                        Text('ราคา : 50 บาท'),
                        SizedBox(height: 2),
                        Text(
                          'ซื้อเมื่อวันที่ 09/09/2009',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF28C2D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('ตรวจรางวัล'),
                ),
              ),
              const SizedBox(height: 6),
              const _DashedLine(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            decoration: BoxDecoration(
              color: redStripe,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------------------ leaf widgets ------------------------------ */

Widget _circleIcon(double size) => Container(
  width: size,
  height: size,
  decoration: const BoxDecoration(
    color: Color(0xFFF2D29A),
    shape: BoxShape.circle,
  ),
  alignment: Alignment.center,
  child: Image.asset(
    'assets/images/lotto_pool.png',
    width: size - 10,
    height: size - 10,
    fit: BoxFit.contain,
  ),
);

Widget _circleImage(String asset, double size) => Container(
  width: size,
  height: size,
  decoration: const BoxDecoration(
    color: Color(0xFFF2D29A),
    shape: BoxShape.circle,
  ),
  alignment: Alignment.center,
  child: Image.asset(
    asset,
    width: size - 10,
    height: size - 10,
    fit: BoxFit.contain,
  ),
);

class _PillText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double padV;
  const _PillText(this.text, {this.fontSize = 14, this.padV = 4});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: padV),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
      ],
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        letterSpacing: 1.2,
      ),
    ),
  );
}

/// Pill ตัวเลขแบบข้อความศูนย์กลาง + รูปด้านขวา (ใช้ในการ์ดใหญ่)
Widget _pillNumberInline({
  required String number,
  required String rightAsset,
  double fontSize = 48,
  double padV = 4,
  double iconSize = 24,
  double gap = 8,
}) {
  return Container(
    clipBehavior: Clip.hardEdge, // กันล้น
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: padV),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown, // ย่อข้อความอัตโนมัติให้พอดีกรอบ
            child: Text(
              number,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        SizedBox(width: gap),
        Image.asset(
          rightAsset,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

/// Pill ตัวเลขแบบ “ตัวๆ มีช่องไฟคุมเอง” + รูปด้านขวา (ใช้ในการ์ดเล็ก)
Widget _pillNumberInlineSpaced({
  required String number,
  required String rightAsset,
  double fontSize = 14,
  double padV = 4,
  double digitGap = 20,
  double iconSize = 18,
  double rightGap = 6,
}) {
  final digits = number.replaceAll(RegExp(r'\s+'), '').split('');
  return Container(
    clipBehavior: Clip.hardEdge, // กันล้น
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: padV),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown, // ย่อให้พอดีเมื่อพื้นที่ไม่พอ
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final d in digits)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: digitGap / 2),
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: rightGap),
        Image.asset(
          rightAsset,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const dashW = 6.0, dashSpace = 4.0, h = 1.2;
      final n = (c.maxWidth / (dashW + dashSpace)).floor().clamp(0, 200);
      return Wrap(
        spacing: dashSpace,
        children: List.generate(
          n,
          (_) => Container(
            width: dashW,
            height: h,
            color: const Color(0xFF8B5E3C),
          ),
        ),
      );
    },
  );
}
