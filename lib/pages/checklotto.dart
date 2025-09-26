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

  // สำหรับกรณีอยากใช้ที่อื่นต่อภายหลัง
  String url = '';

  // ตัวเลื่อนหลักของหน้า (ให้ RefreshIndicator จับสโครลนี้)
  final ScrollController _scroll = ScrollController();

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
    // โหลดรอบแรก
    loadReward = RewardResult();
    loadData = LoadOrdersRecord();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // ดึง-ลงเพื่อรีเฟรช: ยิง API ใหม่ทั้ง 2 ชุด แล้ว await ให้จบ
  Future<void> _reloadAll() async {
    final fr = RewardResult();
    final fd = LoadOrdersRecord();
    setState(() {
      loadReward = fr;
      loadData = fd;
    });
    await Future.wait([fr, fd]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RewardResultResponse>(
      future: loadReward,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('โหลดข้อมูลผิดพลาด: ${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _reloadAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
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

        // ✅ ใส่ RefreshIndicator ครอบ SingleChildScrollView และบังคับเลื่อนเสมอ
        return RefreshIndicator.adaptive(
          onRefresh: _reloadAll,
          edgeOffset: 4,
          notificationPredicate: (n) => n.depth == 0, // ป้องกันสโครลซ้อน
          child: SingleChildScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
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
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(0, 3),
                                      blurRadius: 2,
                                      color: Color.fromARGB(99, 0, 0, 0),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('รางวัลที่ 2'),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 2,
                                                color: Color.fromARGB(99, 0, 0, 0),
                                              ),
                                            ],
                                          ),
                                          child: SmallPrizeCard(
                                            number: r2?.lottoNumber ?? 'ยังไม่ออกรางวัล',
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('รางวัลที่ 3'),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 2,
                                                color: Color.fromARGB(99, 0, 0, 0),
                                              ),
                                            ],
                                          ),
                                          child: SmallPrizeCard(
                                            number: r3?.lottoNumber ?? 'ยังไม่ออกรางวัล',
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('รางวัลเลขท้าย 3 ตัว'),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 2,
                                                color: Color.fromARGB(99, 0, 0, 0),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('รางวัลเลขท้าย 2 ตัว'),
                                        Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: const [
                                              BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 2,
                                                color: Color.fromARGB(99, 0, 0, 0),
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
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    (r1?.drawDate != null)
                                        ? 'ออกเมื่อ ${formatDateThai(r1!.drawDate)}'
                                        : 'ยังไม่ประกาศผล',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              if (widget.currentUser.user.role == 'admin') ...[
                                const SizedBox(height: 16),
                                RewardActionBar(currentUser: widget.currentUser),
                              ],
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
                                const Text(
                                  'สลากของฉัน',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // ใช้ future เดิม ไม่ยิง API ซ้ำ
                                buildMyTickets(),
                              ],
                            ),
                          ),
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

  /// วาดรายการสลากของผู้ใช้: 2 ใบต่อแถว จาก loadData (FutureBuilder เดิม)
  Widget buildMyTickets() {
    return FutureBuilder<UserOrdersRecordResponse>(
      future: loadData, // ใช้ future ที่จัดการโดย _reloadAll()
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                    // ซ้าย
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 3),
                              blurRadius: 2,
                              color: Color.fromARGB(99, 0, 0, 0),
                            ),
                          ],
                        ),
                        child: LottoCardCheck(
                          lid: items[i].lid,
                          walletVN: widget.walletVN,
                          currentUser: widget.currentUser,
                          number: items[i].lottoNumber,
                          prizeText: '*รางวัลละ 800,000 บาท',
                          leftAsset: leftAsset,
                          rightAsset: rightAsset,
                          numberFontSize: 52,
                          rightImageSize: 54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ขวา (ถ้ามี)
                    if (i + 1 < items.length)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0, 3),
                                blurRadius: 2,
                                color: Color.fromARGB(99, 0, 0, 0),
                              ),
                            ],
                          ),
                          child: LottoCardCheck(
                            lid: items[i + 1].lid,
                            walletVN: widget.walletVN,
                            currentUser: widget.currentUser,
                            number: items[i + 1].lottoNumber,
                            prizeText: '*รางวัลละ 800,000 บาท',
                            leftAsset: leftAsset,
                            rightAsset: rightAsset,
                            numberFontSize: 52,
                            rightImageSize: 54,
                          ),
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
    );
  }

  // แปลง 1000 เป็น 1,000 บาท
  String formatBalance(int amount) {
    final nf = NumberFormat("#,###", "th_TH");
    return '${nf.format(amount)} บาท';
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
    final config = await Configuration.getConfig();
    final api = config['apiEndpoint'];
    final uri = Uri.parse('$api/api/lottos/results');
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

  Future<UserOrdersRecordResponse> LoadOrdersRecord() async {
    final config = await Configuration.getConfig();
    final api = config['apiEndpoint'];
    final uid = widget.currentUser.user.uid;
    final uri = Uri.parse('$api/api/orders/$uid');
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
}
