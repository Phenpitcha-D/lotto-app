import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lotto_app/config/config.dart';
import 'package:lotto_app/model/response/user_login_post_res.dart';

class RewardActionBar extends StatefulWidget {
  final UserLoginRespon currentUser;

  const RewardActionBar({super.key, required this.currentUser});
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

  @override
  Widget build(BuildContext context) {
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

      final endpoint = selected == 'สุ่มจากลอตเตอรี่ที่ขายไปแล้ว'
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
class ActionDropdownPill extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ActionDropdownPill({
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