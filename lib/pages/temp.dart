import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/materials/lottoCardCheck.dart';
import 'package:lotto_app/materials/prizeCard.dart';
import 'package:lotto_app/materials/rewardActionBar.dart';
import 'package:lotto_app/materials/smallPrizeCard.dart';
import 'package:lotto_app/model/response/reward_get_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';
import 'package:lotto_app/model/response/user_orderrecord_get_res.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CheckLottoPage extends StatefulWidget {
  final UserLoginRespon currentUser;
  final ValueNotifier<int> walletVN;
  const CheckLottoPage({
    super.key,
    required this.currentUser,
    required this.walletVN,
  });

  @override
  State<CheckLottoPage> createState() => _CheckLottoPageState();
}

class _CheckLottoPageState extends State<CheckLottoPage> {
  static const leftAsset = 'assets/images/lotto_pool.png';
  static const rightAsset = 'assets/images/catcoin.png';

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
        final data = snapshot.data!;

        Result? byRank(int rank) {
          for (final r in data.results) {
            if (r.bountyRank == rank) return r;
          }
          return null;
        }

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 2,
                                    color: const Color.fromARGB(99, 0, 0, 0),
                                  ),
                                ],
                              ),
                              child: PrizeCard(
                                number: r1?.lottoNumber ?? 'ยังไม่ออกรางวัล',
                                prizeText: (r1?.bounty != null)
                                    ? '*รางวัลละ ${formatBalance(r1!.bounty)}'
                                    : '*รางวัลละ 6,000,000 บาท',
                                leftAsset: leftAsset,
                                rightAsset: rightAsset,
                                rightImageSize: 70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('รางวัลที่ 2'),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 3),
                                              blurRadius: 2,
                                              color: const Color.fromARGB(
                                                99,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: SmallPrizeCard(
                                          number:
                                              r2?.lottoNumber ??
                                              'ยังไม่ออกรางวัล',
                                          prizeText: (r2?.bounty != null)
                                              ? '*รางวัลละ ${formatBalance(r2!.bounty)}'
                                              : '*รางวัลละ 1,000,000 บาท',
                                          leftAsset: leftAsset,
                                          rightAsset: rightAsset,
                                          numberFontSize: 52,
                                          rightImageSize: 54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('รางวัลที่ 3'),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 3),
                                              blurRadius: 2,
                                              color: const Color.fromARGB(
                                                99,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: SmallPrizeCard(
                                          number:
                                              r3?.lottoNumber ??
                                              'ยังไม่ออกรางวัล',
                                          prizeText: (r3?.bounty != null)
                                              ? '*รางวัลละ ${formatBalance(r3!.bounty)}'
                                              : '*รางวัลละ 800,000 บาท',
                                          leftAsset: leftAsset,
                                          rightAsset: rightAsset,
                                          numberFontSize: 52,
                                          rightImageSize: 54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('รางวัลเลขท้าย 3 ตัว'),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 3),
                                              blurRadius: 2,
                                              color: const Color.fromARGB(
                                                99,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: SmallPrizeCard(
                                          number: tail(r1?.lottoNumber, 3),
                                          prizeText: (r4?.bounty != null)
                                              ? '*รางวัลละ ${formatBalance(r4!.bounty)}'
                                              : '*รางวัลละ 4,000 บาท',
                                          leftAsset: leftAsset,
                                          rightAsset: rightAsset,
                                          numberFontSize: 16,
                                          rightImageSize: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('รางวัลเลขท้าย 2 ตัว'),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(0, 3),
                                              blurRadius: 2,
                                              color: const Color.fromARGB(
                                                99,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: SmallPrizeCard(
                                          number: tail(r5?.lottoNumber, 2),
                                          prizeText: (r5?.bounty != null)
                                              ? '*รางวัลละ ${formatBalance(r5!.bounty)}'
                                              : '*รางวัลละ 2,000 บาท',
                                          leftAsset: leftAsset,
                                          rightAsset: rightAsset,
                                          numberFontSize: 12,
                                          rightImageSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Align(
                                alignment: AlignmentGeometry.centerRight,
                                child: Text(
                                  'ออกเมื่อ ${formatDateThai(r1!.drawDate)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                if (widget.currentUser.user.role ==
                                    'admin') ...[
                                  const SizedBox(height: 16),
                                  RewardActionBar(
                                    currentUser: widget.currentUser,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.currentUser.user.role == 'member')
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'สลากของฉัน',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 2,
                                                color: const Color.fromARGB(
                                                  99,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: LottoCardCheck(
                                            number: '654321',
                                            prizeText: '*รางวัลละ 800,000 บาท',
                                            leftAsset: leftAsset,
                                            rightAsset: rightAsset,
                                            numberFontSize: 52,
                                            rightImageSize: 54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 2,
                                                color: const Color.fromARGB(
                                                  99,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: LottoCardCheck(
                                            number: '123456',
                                            prizeText: '*รางวัลละ 800,000 บาท',
                                            leftAsset: leftAsset,
                                            rightAsset: rightAsset,
                                            numberFontSize: 52,
                                            rightImageSize: 54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
    // แปลง 1000 เป็น 1,000.00 บาท
  String formatBalance(int amount) {
    final nf = NumberFormat("#,###", "th_TH");
    return '${nf.format(amount.toDouble())} บาท';
  }

  String formatDateThai(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat("dd MMM yyyy - HH:mm", "th_TH").format(dt);
    } catch (_) {
      return iso;
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
}
