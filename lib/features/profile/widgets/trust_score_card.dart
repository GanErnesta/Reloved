import 'package:flutter/material.dart';

class TrustScoreCard extends StatelessWidget {
  final int score;
  final double rating;
  final int chatResponse;
  final int codSuccess;
  final int violations;

  const TrustScoreCard({
    super.key,
    this.score = 0,
    this.rating = 0,
    this.chatResponse = 0,
    this.codSuccess = 0,
    this.violations = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF651B2A),
            Color(0xFFB64A60),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 17,
              ),
              SizedBox(width: 8),
              Text(
                'TRUST SCORE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  children: [
                    _metric(
                      Icons.star_outline,
                      '${rating.toStringAsFixed(1)}/5 Rating',
                    ),
                    const SizedBox(height: 6),
                    _metric(
                      Icons.chat_bubble_outline,
                      '$chatResponse% Balas Chat',
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _metric(
                            Icons.verified_outlined,
                            '$codSuccess% COD Sukses',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _metric(
                            Icons.warning_amber_rounded,
                            '$violations Pelanggaran',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(color: Colors.white38),

          const SizedBox(height: 5),

          const Text(
            'Skor berdasarkan rating, kecepatan respons, '
            'keberhasilan COD, dan riwayat pelanggaran.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF9F283A),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF9F283A),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}