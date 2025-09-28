import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';

class RewardActionBar extends StatefulWidget {
  final UserLoginRespon currentUser;
  final Future<void> Function()? onReload;

  const RewardActionBar({
    super.key,
    required this.currentUser,
    required this.onReload,
  });

  @override
  State<RewardActionBar> createState() => _RewardActionBarState();
}

class _RewardActionBarState extends State<RewardActionBar> {
  final List<String> modes = const [
    'เลือกการสุ่มรางวัล',
    'สุ่มจากลอตเตอรี่ที่ขายไปแล้ว',
    'สุ่มจากลอตเตอรี่ทั้งหมด',
  ];
  String selected = 'เลือกการสุ่มรางวัล';

  bool _busy = false; // ✅ กันกดซ้ำ/ปิดปุ่มระหว่างเรียก API

  // ---------- helpers: pre-check existence ----------
  Future<bool> _hasAnyLotto() async {
    try {
      final config = await Configuration.getConfig();
      final url = config['apiEndpoint'];
      final uri = Uri.parse('$url/api/lottos');
      final resp = await http
          .get(
            uri,
            headers: {
              "Content-Type": "application/json; charset=utf-8",
              "Authorization": "Bearer ${widget.currentUser.token}",
            },
          )
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = utf8.decode(resp.bodyBytes);
        final data = jsonDecode(body);
        if (data is List) return data.isNotEmpty;
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).isNotEmpty;
        }
      }
      // ถ้าเช็คไม่ได้ ให้ถือว่า "อาจมี" เพื่อไม่บล็อกผิดพลาด
      return true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> _hasPurchasedLotto() async {
    // พยายามเช็ค /api/lottos/purchased ถ้ามี
    try {
      final config = await Configuration.getConfig();
      final url = config['apiEndpoint'];
      final uri = Uri.parse('$url/api/lottos/purchased');
      final resp = await http
          .get(
            uri,
            headers: {
              "Content-Type": "application/json; charset=utf-8",
              "Authorization": "Bearer ${widget.currentUser.token}",
            },
          )
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = utf8.decode(resp.bodyBytes);
        final data = jsonDecode(body);
        if (data is List) return data.isNotEmpty;
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).isNotEmpty;
        }
        // โครงสร้างไม่ชัด → ไม่บล็อก
        return true;
      }

      // 404/ไม่รองรับ → ไม่บล็อก ปล่อยให้เซิร์ฟเวอร์ตัดสิน
      return true;
    } catch (_) {
      // เช็คไม่ได้ → ไม่บล็อก
      return true;
    }
  }

  // ---------- draw core ----------
  Future<bool> _drawRewardInternal() async {
    final config = await Configuration.getConfig();
    final url = config['apiEndpoint'];

    // pre-check (กันเคสไม่มีลอตเตอรี่หรือไม่มีที่ถูกซื้อ)
    final isPurchased = selected == 'สุ่มจากลอตเตอรี่ที่ขายไปแล้ว';
    final canDraw = isPurchased
        ? await _hasPurchasedLotto()
        : await _hasAnyLotto();
    if (!canDraw) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPurchased
                ? 'ไม่มีลอตเตอรี่ที่ถูกซื้อ จึงไม่สามารถออกรางวัลจากที่ขายไปแล้วได้'
                : 'ไม่มีลอตเตอรี่ในระบบ จึงไม่สามารถออกรางวัลได้',
          ),
        ),
      );
      return false;
    }

    final endpoint = isPurchased
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

    // ⛔️ 1) HTTP error → แสดงสถานะตามเดิม
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      String msg;
      try {
        final m = jsonDecode(bodyStr) as Map<String, dynamic>;
        msg = (m['message'] ?? 'ออกรางวัลไม่สำเร็จ (${resp.statusCode})')
            .toString();
      } catch (_) {
        msg = 'ออกรางวัลไม่สำเร็จ (${resp.statusCode})';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      return false;
    }

    // ✅ 2) HTTP 2xx แต่ผลลัพธ์ธุรกิจไม่ผ่าน → อ่าน success/message แล้วปฏิเสธ
    try {
      final decoded = jsonDecode(bodyStr);
      if (decoded is Map<String, dynamic>) {
        final success = decoded['success'];
        final message = (decoded['message'] ?? '').toString();

        // กรณีอย่าง: {"success":false,"message":"ยังไม่มีเลขที่ถูกซื้อเพียงพอ"}
        if (success is bool && success == false) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message.isNotEmpty ? message : 'ออกรางวัลไม่สำเร็จ',
                ),
              ),
            );
          }
          return false;
        }
      }
    } catch (_) {
      // ถอดรหัสไม่ได้ก็ไม่เป็นไร ให้ถือว่าเซิร์ฟเวอร์ผ่าน (กรณีเก่า)
    }

    log('DrawReward OK: $bodyStr');
    return true;
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final drawDisabled =
        selected == modes.first || _busy; // ยังไม่เลือก/กำลังทำงาน

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionDropdownPill(
          value: selected,
          items: modes,
          onChanged: (v) => setState(() => selected = v),
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
          onPressed: drawDisabled
              ? null
              : () async {
                  // ✅ เช็คว่ามีการออกรางวัลไปแล้วหรือยัง
                  final already = await _isRewardAlreadyDrawn();
                  if (already) {
                    _showAlreadyDrawnDialog();
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
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
                            onPressed: _busy ? null : DrawReward,
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

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.casino_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                _busy ? 'กำลังสุ่ม…' : 'สุ่มรางวัล',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
          onPressed: _busy
              ? null
              : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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

                  setState(() => _busy = true);
                  try {
                    final config = await Configuration.getConfig();
                    final url = config['apiEndpoint'];
                    final uri = Uri.parse("$url/api/admin/reset");

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
                        // 🔁 refresh parent
                        if (widget.onReload != null) {
                          await widget.onReload!();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "รีเซ็ตระบบสำเร็จ และรีเฟรชข้อมูลแล้ว",
                              ),
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "รีเซ็ตไม่สำเร็จ: ${data['message']}",
                              ),
                            ),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${resp.statusCode}")),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Exception: $e")));
                    }
                  } finally {
                    if (mounted) setState(() => _busy = false);
                  }
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.refresh, size: 18),
              const SizedBox(width: 8),
              Text(
                _busy ? 'กำลังรีเซ็ต…' : 'รีเซ็ตระบบ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _isRewardAlreadyDrawn() async {
    try {
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

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(utf8.decode(res.bodyBytes));

        // โครงสร้างแบบ List และมีข้อมูล → ถือว่าออกรางวัลแล้ว
        if (body is List && body.isNotEmpty) return true;

        // โครงสร้างแบบ Map → พยายามเดา field ทั่วไป
        if (body is Map<String, dynamic>) {
          if (body['results'] is List && (body['results'] as List).isNotEmpty)
            return true;
          if (body['data'] is List && (body['data'] as List).isNotEmpty)
            return true;
          if (body['isClosed'] == true ||
              body['closed'] == true ||
              body['hasResult'] == true) {
            return true;
          }
        }
        return false; // ยังไม่พบหลักฐานว่าปิดรอบ
      }

      return false; // สถานะอื่น ๆ → อย่าบล็อกผิดพลาด
    } catch (_) {
      return false; // เช็คไม่ได้ → อย่าบล็อก
    }
  }

  void _showAlreadyDrawnDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
        ),
        title: const Text("ไม่สามารถสุ่มรางวัลได้"),
        content: const Text(
          "มีการออกรางวัลล็อตโต้แล้ว\nโปรดรีเซ็ตระบบเพื่อจำลองใหม่อีกรอบ",
          textAlign: TextAlign.center,
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

  // NOTE: คง signature/ชื่อเดิมไว้ตามที่คุณเรียกใช้อยู่
  void DrawReward() async {
    // ปิด dialog ก่อน (ถ้ายังเปิดอยู่)
    Navigator.of(context, rootNavigator: true).maybePop();

    if (_busy) return; // กันกดซ้ำ
    setState(() => _busy = true);

    try {
      final ok = await _drawRewardInternal();
      if (!ok) return;

      // 🔁 refresh parent
      if (widget.onReload != null) {
        await widget.onReload!();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ออกรางวัลสำเร็จ และรีเฟรชข้อมูลแล้ว')),
      );

      setState(() {}); // คงไว้เพื่อไม่เปลี่ยนพฤติกรรมเดิม
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
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// no-op extension (คงไว้ไม่กระทบของเดิม)
extension on Future<Map<String, dynamic>> {}

// ดรอปดาวน์
class ActionDropdownPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ActionDropdownPill({
    super.key,
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
          borderRadius: const BorderRadius.all(Radius.circular(12)),
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
