import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/response/reward_get_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';

class ChecklottoAdmin extends StatefulWidget {
  final UserLoginRespon currentUser;
  const ChecklottoAdmin({super.key, required this.currentUser});

  @override
  State<ChecklottoAdmin> createState() => _ChecklottoAdminState();
}

class _ChecklottoAdminState extends State<ChecklottoAdmin> {
  static const _cream = Color(0xFFF6E9CC);
  static const _creamBorder = Color(0xFFE5CFA2);
  static const _redStripe = Color(0xFFE24A4A);
  static const _warnText = Color(0xFFCF3030);

  static const _leftAsset = 'assets/images/lotto_pool.png';
  static const _rightAsset = 'assets/images/catcoin.png';

  late Future<RewardResultResponse> loadReward;

  @override
  void initState() {
    super.initState();
    setState(() {
      loadReward = RewardResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadReward,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('โหลดข้อมูลผิดพลาด: ${snapshot.error}');
        }
        final data = snapshot.data!;
        //หา Result ตามแรงก์
        Result? byRank(int rank) {
          for (final r in data.results) {
            if (r.bountyRank == rank) return r;
          }
          return null;
        }

        // เตรียมตัวแปรตามแรงก์ 1..5
        final r1 = byRank(1);
        final r2 = byRank(2);
        final r3 = byRank(3);
        final r4 = byRank(4); // เลขท้าย 3 ตัว
        final r5 = byRank(5); // เลขท้าย 2 ตัว

        String tail(String? s, int n) {
          if (s == null || s.isEmpty) return '';
          return s.length <= n ? s : s.substring(s.length - n);
        }

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFF2D9),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
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
                        number: r1?.lottoNumber ?? '',
                        prizeText: (r1?.bounty != null)
                            ? '*รางวัลละ ${r1!.bounty} บาท'
                            : '',
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
                                number: r2?.lottoNumber ?? '',
                                prizeText: (r2?.bounty != null)
                                    ? '*รางวัลละ ${r2!.bounty} บาท'
                                    : '',
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
                                number: r3?.lottoNumber ?? '',
                                prizeText: (r3?.bounty != null)
                                    ? '*รางวัลละ ${r3!.bounty} บาท'
                                    : '',
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
                                number: tail(r1?.lottoNumber, 3),
                                prizeText: (r4?.bounty != null)
                                    ? '*รางวัลละ ${r4!.bounty} บาท'
                                    : '',

                                leftAsset: _leftAsset,
                                rightAsset: _rightAsset,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PrizeColumn(
                              title: 'รางวัลเลขท้าย 2 ตัว',
                              card: _PrizeSmallCard(
                                cream: _cream,
                                creamBorder: _creamBorder,
                                redStripe: _redStripe,
                                number: tail(r5?.lottoNumber, 2),
                                prizeText: (r5?.bounty != null)
                                    ? '*รางวัลละ ${r5!.bounty} บาท'
                                    : '',

                                leftAsset: _leftAsset,
                                rightAsset: _rightAsset,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // ==== เพิ่มแถบควบคุมการสุ่ม ====
                      const SizedBox(height: 16),
                      _RewardActionBar(currentUser: widget.currentUser),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<RewardResultResponse> RewardResult() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var uri = Uri.parse('$url/api/lottos/results');
    var res = await http.get(
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
}

// --------------------------------------- Reward Action Bar -----------------------------------------------

class _RewardActionBar extends StatefulWidget {
  final UserLoginRespon currentUser;

  const _RewardActionBar({super.key, required this.currentUser});
  @override
  State<_RewardActionBar> createState() => _RewardActionBarState();
}

class _RewardActionBarState extends State<_RewardActionBar> {
  final List<String> _modes = const [
    'เลือกการสุ่มรางวัล',
    'สุ่มจากลอตเตอรี่ที่ขายไปแล้ว',
    'สุ่มจากลอตเตอรี่ทั้งหมด',
  ];
  String _selected = 'เลือกการสุ่มรางวัล';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionDropdownPill(
          value: _selected,
          items: _modes,
          onChanged: (v) => setState(() => _selected = v),
        ),
        const SizedBox(height: 12),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFD84C43),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
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
                    "ยืนยันที่จะทำการสุ่มรางวัล ? เมื่อกดยืนยันแล้วจะไม่สามารถแก้ไขได้",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  actionsAlignment: MainAxisAlignment.spaceEvenly,
                  actions: [
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFCF3030),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                      onPressed: DrawReward,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.casino_outlined, size: 18),
              SizedBox(width: 8),
              Text('สุ่มรางวัล', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),

        const SizedBox(height: 10),

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 196, 0),
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: const Text(
                  "ยืนยันที่จะทำการรีเซ็ตระบบ ?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  "เมื่อตกลงแล้วจะไม่สามารถแก้ไขได้\nข้อมูลทั้งหมดจะถูกลบ ยกเว้น admin",
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text("ยกเลิก"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text("ยืนยัน"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            if (confirm != true) return;

            try {
              var config = await Configuration.getConfig();
              var url = config['apiEndpoint'];
              var uri = Uri.parse("$url/api/admin/reset");

              final resp = await http.delete(
                uri,
                headers: {
                  "Content-Type": "application/json; charset=utf-8",
                  "Authorization": "Bearer ${widget.currentUser.token}",
                },
              );

              if (resp.statusCode == 200) {
                final data = jsonDecode(resp.body);
                if (data['success'] == true) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("รีเซ็ตระบบสำเร็จ")),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("รีเซ็ตไม่สำเร็จ: ${data['message']}"),
                      ),
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${resp.statusCode}")),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Exception: $e")));
              }
            }
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 18),
              SizedBox(width: 8),
              Text('รีเซ็ตระบบ', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void DrawReward() async {
    Navigator.pop(context);
    try {
      final config = await Configuration.getConfig();
      final url = config['apiEndpoint'];

      final endpoint = _selected == 'สุ่มจากลอตเตอรี่ที่ขายไปแล้ว'
          ? '$url/api/lottos/draw/purchased'
          : '$url/api/lottos/draw/all';

      final uri = Uri.parse(endpoint);
      final resp = await http
          .get(
            uri,
            headers: {
              "Content-Type": "application/json; charset=utf-8",
              "Authorization": "Bearer ${widget.currentUser.token}",
            },
          )
          .timeout(const Duration(seconds: 20));

      final bodyStr = utf8.decode(resp.bodyBytes);

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        String msg;
        try {
          final m = jsonDecode(bodyStr) as Map<String, dynamic>;
          msg = (m['message'] ?? 'ออกรางวัลไม่สำเร็จ (${resp.statusCode})')
              .toString();
        } catch (_) {
          msg = 'ออกรางวัลไม่สำเร็จ (${resp.statusCode})';
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        return;
      }
      log('DrawReward OK: $bodyStr');
      setState(() {});
    } on TimeoutException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('การเชื่อมต่อล่าช้า กรุณาลองใหม่อีกครั้ง'),
        ),
      );
    } catch (e) {
      log('DrawReward error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    }
  }
}

extension on Future<Map<String, dynamic>> {
  operator [](String other) {}
}

// ดรอปดาวน์
class _ActionDropdownPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _ActionDropdownPill({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const ShapeDecoration(
        color: Color(0xFFF2F2F2),
        shadows: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        shape: StadiumBorder(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 44,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.all(Radius.circular(12)),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: e == items.first ? Colors.black54 : Colors.black87,
                      fontWeight: e == items.first
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
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
              const DashedLine(),
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
                      fontSize: 22,
                      padV: 8,
                      digitGap: 10,
                      iconSize: 16,
                      rightGap: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                prizeText,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFCF3030),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const DashedLine(),
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
              const DashedLine(),
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

class DashedLine extends StatelessWidget {
  const DashedLine();
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
