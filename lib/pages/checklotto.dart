// Version 0.2.0

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/response/prize_res.dart';
import 'package:lotto_app/model/response/reward_get_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/model/response/user_orderrecord_get_res.dart'; // <-- ใส่ไฟล์โมเดลของคุณ
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// 🎨 โทนสีพื้นหลังแผงใหญ่
class AppColors {
  static const cream = Color(0xFFFFF2D9);
}

class CheckLottoPage extends StatefulWidget {
  final UserLoginRespon currentUser;
  const CheckLottoPage({super.key, required this.currentUser});
  @override
  State<CheckLottoPage> createState() => _CheckLottoPageState();
}

class _CheckLottoPageState extends State<CheckLottoPage> {
  static const _cream = Color(0xFFF6E9CC);
  static const _creamBorder = Color(0xFFE5CFA2);
  static const _redStripe = Color(0xFFE24A4A);
  static const _warnText = Color(0xFFCF3030);

  static const _leftAsset = 'assets/images/lotto_pool.png';
  static const _rightAsset = 'assets/images/catcoin.png';

  late Future<UserOrdersRecordResponse> loadData;
  late Future<RewardResultResponse> loadReward;

  String url = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('th_TH');
    Configuration.getConfig().then((config) {
      if (!mounted) return;
      setState(() {
        url = config['apiEndpoint'] ?? '';
      });
    });
    loadReward = RewardResult();
    loadData = LoadOrdersRecord();
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
        final data = snapshot.data!; // RewardResultResponse
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Center(
                        child: Text(
                          'รางวัลที่ 1',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      _PrizeLargeCard(
                        cream: _cream,
                        creamBorder: _creamBorder,
                        redStripe: _redStripe,
                        warnText: _warnText,
                        number:
                            data.results.elementAtOrNull(0)?.lottoNumber ?? '',
                        prizeText:
                            data.results.elementAtOrNull(0)?.bounty != null
                            ? '*รางวัลละ ${data.results.elementAtOrNull(0)!.bounty} บาท'
                            : '',
                        leftAsset: _leftAsset,
                        rightAsset: _rightAsset,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PrizeColumn(
                              title: 'รางวัลที่ 2',
                              card: _PrizeSmallCard(
                                cream: _cream,
                                creamBorder: _creamBorder,
                                redStripe: _redStripe,
                                number:
                                    data.results
                                        .elementAtOrNull(1)
                                        ?.lottoNumber ??
                                    '',
                                prizeText:
                                    data.results.elementAtOrNull(1)?.bounty !=
                                        null
                                    ? '*รางวัลละ ${data.results.elementAtOrNull(1)!.bounty} บาท'
                                    : '',
                                leftAsset: _leftAsset,
                                rightAsset: _rightAsset,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PrizeColumn(
                              title: 'รางวัลที่ 3',
                              card: _PrizeSmallCard(
                                cream: _cream,
                                creamBorder: _creamBorder,
                                redStripe: _redStripe,
                                number:
                                    data.results
                                        .elementAtOrNull(2)
                                        ?.lottoNumber ??
                                    '',
                                prizeText:
                                    data.results.elementAtOrNull(2)?.bounty !=
                                        null
                                    ? '*รางวัลละ ${data.results.elementAtOrNull(2)!.bounty} บาท'
                                    : '',
                                leftAsset: _leftAsset,
                                rightAsset: _rightAsset,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PrizeColumn(
                              title: 'รางวัลเลขท้าย 3 ตัว',
                              card: _PrizeSmallCard(
                                cream: _cream,
                                creamBorder: _creamBorder,
                                redStripe: _redStripe,
                                number:
                                    data.results
                                        .elementAtOrNull(3)
                                        ?.lottoNumber ??
                                    '',
                                prizeText:
                                    data.results.elementAtOrNull(3)?.bounty !=
                                        null
                                    ? '*รางวัลละ ${data.results.elementAtOrNull(3)!.bounty} บาท'
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
                                number:
                                    data.results
                                        .elementAtOrNull(4)
                                        ?.lottoNumber ??
                                    '',
                                prizeText:
                                    data.results.elementAtOrNull(4)?.bounty !=
                                        null
                                    ? '*รางวัลละ ${data.results.elementAtOrNull(4)!.bounty} บาท'
                                    : '',
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
                          data.results.elementAtOrNull(0)?.drawDate != null
                              ? 'ออกเมื่อ ${data.results.elementAtOrNull(0)!.drawDate}'
                              : '',
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

                const SizedBox(height: 0),

                // ====== สลากของฉัน ======
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 50),
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<UserOrdersRecordResponse>(
                        future: loadData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text('โหลดข้อมูลผิดพลาด: ${snapshot.error}');
                          }
                          final items = snapshot.data?.data ?? [];
                          if (items.isEmpty) {
                            return const Text('ยังไม่มีประวัติการซื้อ');
                          }

                          return Column(
                            children: [
                              for (var i = 0; i < items.length; i += 2)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _MyTicketCard(
                                          cream: _cream,
                                          creamBorder: _creamBorder,
                                          redStripe: _redStripe,
                                          lid: items[i].lid,
                                          number: items[i].lottoNumber,
                                          price: items[i].purchasePrice,
                                          purchasedAt: items[i].purchaseTime,
                                          url: url,
                                          currentUser: widget.currentUser,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (i + 1 < items.length)
                                        Expanded(
                                          child: _MyTicketCard(
                                            cream: _cream,
                                            creamBorder: _creamBorder,
                                            redStripe: _redStripe,
                                            lid: items[i + 1].lid,
                                            number: items[i + 1].lottoNumber,
                                            price: items[i + 1].purchasePrice,
                                            purchasedAt:
                                                items[i + 1].purchaseTime,
                                            url: url,
                                            currentUser: widget.currentUser,
                                          ),
                                        )
                                      else
                                        const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<UserOrdersRecordResponse> LoadOrdersRecord() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var uid = widget.currentUser.user.uid;
    var uri = Uri.parse('$url/api/orders/$uid');
    var res = await http.get(
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
                      fontSize: 20,
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
  final String number;
  final num price;
  final String purchasedAt;
  final String url;
  final UserLoginRespon currentUser;
  final int lid;

  const _MyTicketCard({
    required this.cream,
    required this.creamBorder,
    required this.redStripe,
    required this.number,
    required this.price,
    required this.purchasedAt,
    required this.url,
    required this.currentUser,
    required this.lid,
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
                  _circleIcon(46),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PillText(number, fontSize: 11, padV: 6),
                        const SizedBox(height: 5),
                        Text('ราคา : ${price.toString()} บาท'),
                        const SizedBox(height: 2),
                        Text(
                          'ซื้อเมื่อ: ${formatDateThai(purchasedAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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
                  onPressed: () => checkReward(context),
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

  void checkReward(BuildContext context) async {
    try {
      final res = await http.get(
        Uri.parse("$url/api/lottos/prizes/$lid"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Bearer ${currentUser.token}",
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
        lottoNumber: parsed.lottoNumber ?? number,
        prizes: parsed.prizes,
        total: parsed.totalBounty,
        onClaim: () async {
          Navigator.of(context).pop();
          await claimPrize(context);
        },
      );
    } catch (e) {
      showErrorDialog(context, title: "ข้อผิดพลาด", message: e.toString());
    }
  }

  Future<void> claimPrize(BuildContext context) async {
    try {
      final res = await http.post(
        Uri.parse("$url/api/lottos/claim"),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Bearer ${currentUser.token}",
        },
        body: jsonEncode({"lid": lid}),
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
          lottoNumber: parsed.lottoNumber ?? number,
          prizes: parsed.prizes,
          total: parsed.totalBounty,
          message: parsed.message ?? "คุณได้ขึ้นเงินรางวัลนี้แล้ว",
        );
      }

      if (parsed.success) {
        return showClaimSuccessDialog(
          context,
          lottoNumber: parsed.lottoNumber ?? number,
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

  String formatDateThai(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("dd MMM yyyy - HH:mm", "th_TH").format(dt);
    } catch (_) {
      return iso;
    }
  }
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

Widget _pillNumberInline({
  required String number,
  required String rightAsset,
  double fontSize = 48,
  double padV = 4,
  double iconSize = 24,
  double gap = 8,
}) {
  return Container(
    clipBehavior: Clip.hardEdge,
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
            fit: BoxFit.scaleDown,
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
    clipBehavior: Clip.hardEdge,
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
            fit: BoxFit.scaleDown,
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
