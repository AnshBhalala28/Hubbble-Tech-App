import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/Services/themeServices.dart';
import 'package:wavee/Utils/const.dart';
import 'package:wavee/Utils/customAppBar.dart';

class Spotlightview extends StatefulWidget {
  const Spotlightview({super.key});

  @override
  State<Spotlightview> createState() => _SpotlightviewState();
}

class _SpotlightviewState extends State<Spotlightview> {
  int activeTab = 0;
  int treeCount = 1;
  final double pricePerTree = 5.00;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();

    // --- Dynamic Theme Colors (Images mujab) ---
    final Color bgColor =
        theme.isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF0F2F5);
    final Color cardColor =
        theme.isDark ? const Color(0xFF161616) : Colors.white;
    final Color innerBoxColor =
        theme.isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
    final Color primaryGold = const Color(0xFFCBB88C);
    final Color textColor = theme.isDark ? Colors.white : Colors.black;
    final Color subTextColor = theme.isDark ? Colors.grey : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          TitleBar(
            back: () => Get.back(),
            title: 'Spotlight',
            drawerCallback: () {},
          ),
          SizedBox(height: 3.h),

          // Tab Bar
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: theme.isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                width: 1,
                color:
                    theme.isDark
                        ? const Color(0xFF2F2F2F)
                        : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                _buildTabItem("Impact", 0, primaryGold, theme.isDark),
                _buildTabItem("Partners", 1, primaryGold, theme.isDark),
                _buildTabItem("Badges", 2, primaryGold, theme.isDark),
              ],
            ),
          ).paddingOnly(bottom: 3.h),

          Expanded(
            child: SingleChildScrollView(
              child: _buildActiveTabContent(
                cardColor,
                innerBoxColor,
                primaryGold,
                textColor,
                subTextColor,
                theme.isDark,
              ),
            ),
          ),
        ],
      ).paddingOnly(top: 5.h, left: 3.w, right: 3.w),
    );
  }

  Widget _buildActiveTabContent(
    Color cardColor,
    Color innerColor,
    Color gold,
    Color text,
    Color subText,
    bool isDark,
  ) {
    if (activeTab == 0)
      return _buildImpactTab(
        cardColor,
        innerColor,
        gold,
        text,
        subText,
        isDark,
      );
    if (activeTab == 1)
      return _buildPartnersTab(
        cardColor,
        innerColor,
        gold,
        text,
        subText,
        isDark,
      );
    return _buildBadgesTab(cardColor, innerColor, gold, text, subText, isDark);
  }

  // --- IMPACT TAB ---
  Widget _buildImpactTab(
    Color cardColor,
    Color innerColor,
    Color gold,
    Color text,
    Color subText,
    bool isDark,
  ) {
    double totalAmount = treeCount * pricePerTree;
    return Column(
      children: [
        _buildSectionContainer(
          cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(
                Icons.eco,
                "Your Carbon Impact",
                "POWERED BY SKOOTECO",
                text,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      "127.4",
                      "kg CO2 Offset",
                      const Color(0xFF00FF9D),
                      innerColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatBox(
                      "12",
                      "Trees Planted",
                      Colors.amber,
                      innerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMonthlyFootprint(innerColor, text, subText, isDark),
              Divider(
                color: isDark ? Colors.white10 : Colors.black12,
                height: 4.h,
              ),
              Text(
                "This Month's Activity",
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ).paddingOnly(bottom: 2.h),
              _buildActivityItem(
                Icons.inventory_2_outlined,
                "Parcels Delivered",
                "23 deliveries",
                "+18.4 kg",
                cardColor,
                text,
                subText,
                gold,
              ),
              _buildActivityItem(
                Icons.bolt_rounded,
                "Energy Consumption",
                "342 kWh this month",
                "+18.2 kg",
                cardColor,
                text,
                subText,
                gold,
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        _buildSectionContainer(
          cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(Icons.park_outlined, "Plant Trees", "", text),
              Text(
                "Offset your carbon footprint by planting trees with our partner SkootEco.",
                style: TextStyle(
                  color: subText,
                  fontSize: 14.sp,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              const SizedBox(height: 20),
              _buildTreeCounter(totalAmount, innerColor, gold, text),
              const SizedBox(height: 20),
              _buildActionButton(
                "Plant $treeCount Tree${treeCount > 1 ? 's' : ''}",
                gold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- PARTNERS TAB ---
  Widget _buildPartnersTab(
    Color cardColor,
    Color innerColor,
    Color gold,
    Color text,
    Color subText,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Featured Partners",
          style: TextStyle(
            color: text,
            fontSize: 18,
            fontFamily: AppConstants.manropeBold,
          ),
        ),
        const SizedBox(height: 15),
        _buildPartnerCard(
          "Third Space",
          "Luxury fitness club",
          "Free day pass for residents",
          "Fitness",
          cardColor,
          gold,
          text,
          subText,
        ),
        _buildPartnerCard(
          "Royal Albert Hall",
          "World-class performances",
          "Priority booking access",
          "Culture",
          cardColor,
          gold,
          text,
          subText,
        ),
        const SizedBox(height: 25),
        _buildSectionContainer(
          cardColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, color: gold),
                      SizedBox(width: 10),
                      Text(
                        "Rewards",
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          fontFamily: AppConstants.manropeBold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "2450 pts",
                    style: TextStyle(
                      color: subText,
                      fontSize: 14.sp,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: innerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "£100 Restaurant Voucher",
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                        Text(
                          "2000 points",
                          style: TextStyle(
                            color: subText,
                            fontSize: 12,
                            fontFamily: AppConstants.manrope,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        "Redeem",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- BADGES TAB ---
  Widget _buildBadgesTab(
    Color cardColor,
    Color innerColor,
    Color gold,
    Color text,
    Color subText,
    bool isDark,
  ) {
    return Column(
      children: [
        _buildSectionContainer(
          cardColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Badge Collection",
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.manropeBold,
                    ),
                  ),
                  Text(
                    "6/12 unlocked",
                    style: TextStyle(
                      color: subText,
                      fontSize: 12,
                      fontFamily: AppConstants.manrope,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                color: gold,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          childAspectRatio: 0.6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _buildBadgeItem(
              "Explorer",
              Icons.location_on_outlined,
              true,
              gold,
              text,
              isDark,
            ),
            _buildBadgeItem(
              "Foodie",
              Icons.restaurant_menu,
              true,
              gold,
              text,
              isDark,
            ),
            _buildBadgeItem(
              "Shopper",
              Icons.shopping_bag_outlined,
              true,
              gold,
              text,
              isDark,
            ),
            _buildBadgeItem(
              "Glamour",
              Icons.auto_awesome,
              false,
              gold,
              text,
              isDark,
              progress: "2/5",
            ),
          ],
        ),
      ],
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTabItem(String title, int index, Color gold, bool isDark) {
    bool isSelected = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? gold : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isSelected
                      ? Colors.black
                      : (isDark ? Colors.grey : Colors.black54),
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manropeBold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(Color color, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget _buildStatBox(
    String val,
    String label,
    Color color,
    Color innerColor,
  ) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      color: Colors.transparent,
      child: Container(
        height: 15.h,
        decoration: BoxDecoration(
          color: innerColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manrope,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ],
        ).paddingOnly(left: 5.w, top: 4.h),
      ),
    );
  }

  Widget _buildMonthlyFootprint(
    Color innerColor,
    Color text,
    Color subText,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: innerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Monthly Footprint",
                style: TextStyle(
                  color: text,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              Text(
                "34.2 / 50 kg limit",
                style: TextStyle(
                  color: subText,
                  fontSize: 12,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: 0.68,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            color: Colors.orange,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          Text(
            "15.8 kg remaining this month",
            style: TextStyle(
              color: subText,
              fontSize: 11,
              fontFamily: AppConstants.manrope,
            ),
          ).paddingOnly(top: 10),
        ],
      ),
    );
  }

  Widget _buildTreeCounter(
    double total,
    Color innerColor,
    Color gold,
    Color text,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: innerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Number of trees",
                style: TextStyle(color: text, fontFamily: AppConstants.manrope),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap:
                        () =>
                            setState(() => treeCount > 1 ? treeCount-- : null),
                    child: Icon(Icons.remove_circle_outline, color: text),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      "$treeCount",
                      style: TextStyle(
                        color: gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => treeCount++),
                    child: Icon(Icons.add_circle_outline, color: text),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "£5.00 per tree",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: AppConstants.manrope,
                ),
              ),
              Text(
                "£${total.toStringAsFixed(2)}",
                style: TextStyle(
                  color: text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color gold) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: AppConstants.manropeBold,
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeItem(
    String name,
    IconData icon,
    bool unlocked,
    Color gold,
    Color text,
    bool isDark, {
    String? progress,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            color:
                unlocked
                    ? gold
                    : (isDark ? Colors.grey[900] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(icon, color: unlocked ? Colors.black : Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: text,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: AppConstants.manropeBold,
          ),
        ),
        if (progress != null)
          Text(
            progress,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontFamily: AppConstants.manrope,
            ),
          ),
      ],
    );
  }

  Widget _buildCardHeader(IconData icon, String title, String sub, Color text) {
    final theme = context.watch<ThemeController>();

    return Row(
      children: [
        CircleAvatar(
          backgroundColor:
              theme.isDark ? const Color(0xFF0D2D1D) : Colors.green.withValues(alpha: .2),
          child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sub.isNotEmpty)
              Text(
                sub,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 9,
                  letterSpacing: 1,
                  fontFamily: AppConstants.manrope,
                ),
              ),
            Text(
              title,
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.manrope,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String sub,
    String weight,
    Color cardColor,
    Color text,
    Color subText,
    Color gold,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: text,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppConstants.manropeBold,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: subText,
                    fontSize: 12,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ],
            ),
          ),
          Text(
            weight,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontFamily: AppConstants.manrope,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(
    String name,
    String sub,
    String perk,
    String tag,
    Color cardColor,
    Color gold,
    Color text,
    Color subText,
  ) {
    final theme = context.watch<ThemeController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color:theme.isDark? Colors.grey[900]:Colors.grey.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.business, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: text,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppConstants.manrope,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: gold,
                          fontSize: 9,
                          fontFamily: AppConstants.manrope,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  sub,
                  style: TextStyle(
                    color: subText,
                    fontSize: 12,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                Text(
                  perk,
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontFamily: AppConstants.manrope,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: subText),
        ],
      ),
    );
  }
}
