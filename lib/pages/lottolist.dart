import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/materials/lottoCard.dart';
import 'package:lotto_app/model/response/lottolist_res.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';

class LottolistPage extends StatefulWidget {
  final UserLoginRespon currentUser;
  final ValueNotifier<int> walletVN;
  final VoidCallback? onGoAdmin;
  const LottolistPage({
    super.key,
    required this.currentUser,
    required this.walletVN,
    this.onGoAdmin,
  });

  @override
  State<LottolistPage> createState() => _LottolistPageState();
}

class _LottolistPageState extends State<LottolistPage> {
  final TextEditingController searchCtrl = TextEditingController();
  final ScrollController scrollController = ScrollController();

  late Future<List<LottoListRespon>> loadData;
  String query = "";

  @override
  void initState() {
    super.initState();
    loadData = loadLottos();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void filter(String q) {
    setState(() {
      query = q.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔎 Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: searchCtrl,
              onChanged: filter,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.black),
                hintText: 'Search Lotto',
                hintStyle: TextStyle(color: Colors.black45),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🟡 FutureBuilder โหลดจาก API
          Expanded(
            child: FutureBuilder<List<LottoListRespon>>(
              future: loadData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  if (widget.currentUser.user.role == 'admin') {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ยังไม่มีการวางขายล็อตโต้',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              widget.onGoAdmin?.call();
                            },
                            icon: const Icon(Icons.add_business),
                            label: const Text('เริ่มวางจำหน่ายล็อตโต้'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'ยังไม่มีการวางขายล็อตโต้',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }
                }

                // กรองตาม search
                final filtered = snapshot.data!.where((lotto) {
                  final num = lotto.lottoNumber.replaceAll(" ", "");
                  return query.isEmpty || num.contains(query);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'ไม่พบข้อมูลที่ค้นหา',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                // ✅ RefreshIndicator ต้องเป็น ancestor ของ scrollable จริง
                return RefreshIndicator.adaptive(
                  onRefresh: reload,
                  edgeOffset: 4,
                  notificationPredicate: (n) => n.depth == 0,
                  child: Scrollbar(
                    controller: scrollController,
                    thickness: 5,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: GridView.count(
                      controller: scrollController,
                      // สำคัญ: ให้ดึงรีเฟรชได้เสมอ แม้ไอเท็มไม่เต็มจอ
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.05,
                      children: List.generate(filtered.length, (i) {
                        return LottoCard(
                          currentUser: widget.currentUser,
                          number: filtered[i].lottoNumber,
                          price: filtered[i].price,
                          imageAsset: "assets/images/lotto_pool.png",
                          lid: filtered[i].lid,
                          token: widget.currentUser.token,
                          walletVN: widget.walletVN,
                          // ซื้อเสร็จให้รีโหลดทันที
                          onBought: () async {
                            await reload();
                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ⬇️ แก้หลัก: ให้ onRefresh “ยิงโหลดใหม่” จริง ๆ และ await ให้จบก่อน
  Future<void> reload() async {
    final future = loadLottos();
    setState(() {
      loadData = future; // สั่ง FutureBuilder โหลดใหม่
    });
    await future; // ให้ RefreshIndicator รู้ว่าการรีเฟรชจบแล้ว -> หยุดสปิน
  }

  Future<List<LottoListRespon>> loadLottos() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/api/lottos'));

    if (res.statusCode == 200) {
      return lottoListResponFromJson(res.body);
    } else {
      throw Exception("โหลดข้อมูลไม่สำเร็จ: ${res.statusCode}");
    }
  }
}
