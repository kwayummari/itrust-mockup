import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class VideoCardShimmer extends StatelessWidget {
  final bool isHorizontal;

  const VideoCardShimmer({
    super.key,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: EdgeInsets.only(
          right: isHorizontal ? 16 : 0,
          bottom: isHorizontal ? 8 : 16,
        ),
        child: SizedBox(
          width: isHorizontal ? 280 : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: isHorizontal ? 120 : 200,
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 200,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
