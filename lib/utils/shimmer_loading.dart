import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer Loading Widgets untuk berbagai komponen
class ShimmerLoading {
  // Base shimmer wrapper
  static Widget shimmerWrapper({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }

  // Shimmer box dengan border radius
  static Widget box({
    double width = double.infinity,
    double height = 100,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }

  // Shimmer untuk list cards
  static Widget cardList({int itemCount = 5}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: shimmerWrapper(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  box(width: 150, height: 20, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  box(width: double.infinity, height: 16, borderRadius: BorderRadius.circular(4)),
                  const SizedBox(height: 8),
                  box(width: 200, height: 16, borderRadius: BorderRadius.circular(4)),
                  const Spacer(),
                  Row(
                    children: [
                      box(width: 80, height: 24, borderRadius: BorderRadius.circular(12)),
                      const SizedBox(width: 8),
                      box(width: 100, height: 16, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Shimmer untuk complaint card
  static Widget complaintCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: shimmerWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  box(width: 40, height: 40, borderRadius: BorderRadius.circular(8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        box(width: 180, height: 18, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 6),
                        box(width: 120, height: 14, borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              box(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 6),
              box(width: 220, height: 14, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 12),
              Row(
                children: [
                  box(width: 80, height: 28, borderRadius: BorderRadius.circular(14)),
                  const Spacer(),
                  box(width: 100, height: 14, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer untuk payment card
  static Widget paymentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: shimmerWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  box(width: 100, height: 18, borderRadius: BorderRadius.circular(4)),
                  box(width: 80, height: 26, borderRadius: BorderRadius.circular(13)),
                ],
              ),
              const SizedBox(height: 12),
              box(width: 150, height: 24, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 8),
              box(width: 130, height: 14, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 8),
              box(width: 110, height: 14, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer untuk dashboard stats
  static Widget statsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
              child: shimmerWrapper(
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      box(width: 40, height: 40, borderRadius: BorderRadius.circular(8)),
                      box(width: 60, height: 24, borderRadius: BorderRadius.circular(4)),
                      box(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Shimmer untuk tenant info card
  static Widget tenantInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: shimmerWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(width: 200, height: 24, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 8),
              box(width: 150, height: 16, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 20),
              box(width: double.infinity, height: 1, borderRadius: BorderRadius.zero),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        box(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 6),
                        box(width: 60, height: 18, borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        box(width: 80, height: 14, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 6),
                        box(width: 100, height: 18, borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic shimmer list (flexible)
  static Widget list({
    int itemCount = 5,
    double itemHeight = 100,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: padding ?? const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: shimmerWrapper(
            child: box(
              height: itemHeight,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}