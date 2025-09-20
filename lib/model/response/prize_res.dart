/// ------------------------ MODELS ------------------------

class PrizeItem {
  final int bountyRank;
  final int bounty;
  final DateTime? drawDate;

  PrizeItem({
    required this.bountyRank,
    required this.bounty,
    this.drawDate,
  });

  factory PrizeItem.fromJson(Map<String, dynamic> j) => PrizeItem(
        bountyRank: (j['bounty_rank'] ?? j['rank'] ?? j['prizeRank'] ?? 0) as int,
        bounty: (j['bounty'] ?? j['amount'] ?? j['prizeAmount'] ?? 0 as num).toInt(),
        drawDate: j['draw_date'] != null ? DateTime.tryParse(j['draw_date']) : null,
      );
}

/// ใช้ได้กับทั้ง GET /prizes/:lid และ POST /claim
class PrizeResponse {
  final bool success;
  final String? message;
  final int? lid;
  final String? lottoNumber;
  final List<PrizeItem> prizes;
  final int? explicitTotalBounty;        // total_bounty จาก /claim
  final bool alreadyClaimedFlag;         // already_claimed จาก /claim

  PrizeResponse({
    required this.success,
    this.message,
    this.lid,
    this.lottoNumber,
    required this.prizes,
    this.explicitTotalBounty,
    this.alreadyClaimedFlag = false,
  });

  factory PrizeResponse.fromJson(Map<String, dynamic> j) {
    final ps = (j['prizes'] is List)
        ? (j['prizes'] as List).map((e) => PrizeItem.fromJson(e as Map<String, dynamic>)).toList()
        : <PrizeItem>[];

    return PrizeResponse(
      success: j['success'] == true,
      message: j['message'] as String?,
      lid: (j['lid'] as num?)?.toInt(),
      lottoNumber: j['lotto_number'] as String?,
      prizes: ps,
      explicitTotalBounty: (j['total_bounty'] as num?)?.toInt(),
      alreadyClaimedFlag: j['already_claimed'] == true,
    );
  }

  /// รวมยอดจาก prizes ถ้าไม่มี total_bounty
  int get totalBounty =>
      explicitTotalBounty ?? prizes.fold(0, (sum, p) => sum + (p.bounty));

  bool get isWinner => prizes.isNotEmpty && totalBounty > 0;

  bool get alreadyClaimed => alreadyClaimedFlag;

  /// แปลง rank เป็นข้อความสั้นๆ
  static String rankLabel(int rank) => "รางวัลที่ $rank";
}
