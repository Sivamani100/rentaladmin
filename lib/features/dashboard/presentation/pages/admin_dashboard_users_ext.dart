part of 'admin_dashboard_screen.dart';

extension AdminDashboardUsersExt on _AdminDashboardScreenState {
  Widget _buildUsersTab(bool isDark) {
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
  
      // Dynamically group properties by owner phone number
      final Map<String, List<PropertyModel>> ownerMap = {};
      for (final prop in _properties) {
        if (prop.ownerPhone.isNotEmpty) {
          ownerMap.putIfAbsent(prop.ownerPhone, () => []).add(prop);
        }
      }
  
      final totalOwners = ownerMap.length;
      final totalListings = _properties.length;
      final avgListings = totalOwners > 0 ? (totalListings / totalOwners).toStringAsFixed(1) : '1.0';
  
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Executive Header Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161922) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.person_2_fill, color: Color(0xFF3B82F6), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Landlords & Property Owners Directory',
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6.5,
                                    height: 6.5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'DIRECT OWNERS',
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Direct property owners, verified phone contacts, multi-property portfolios, and 1-tap WhatsApp communication.',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedTabIndex = 3;
                            _selectedAudience = TargetAudience.landlords;
                          });
                        },
                        icon: const Icon(CupertinoIcons.bell_fill, size: 16, color: Colors.black),
                        label: Text(
                          'Alert Landlords',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryYellow,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
  
            // 2. 4-Core Landlord Statistics KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final crossAxisCount = isDesktop ? 4 : (constraints.maxWidth > 550 ? 2 : 1);
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 2.1 : 2.4,
                  children: [
                    // KPI 1: Total Registered Landlords
                    _buildExecutiveKpiCard(
                      title: 'Registered Owners',
                      value: '$totalOwners Landlords',
                      subtitle: '100% Direct Owners',
                      badgeLabel: 'Zero Brokers',
                      badgeColor: const Color(0xFF10B981),
                      icon: CupertinoIcons.person_fill,
                      iconColor: const Color(0xFF3B82F6),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
  
                    // KPI 2: Total Managed Properties
                    _buildExecutiveKpiCard(
                      title: 'Managed Inventory',
                      value: '$totalListings Listings',
                      subtitle: 'Avg $avgListings units / owner',
                      badgeLabel: 'Active Portfolios',
                      badgeColor: AppTheme.primaryYellow,
                      icon: CupertinoIcons.building_2_fill,
                      iconColor: AppTheme.primaryYellow,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
  
                    // KPI 3: WhatsApp Verified
                    _buildExecutiveKpiCard(
                      title: 'Direct WhatsApp Verified',
                      value: '$totalOwners / $totalOwners Verified',
                      subtitle: 'Direct tenant chat ready',
                      badgeLabel: '100% Ready',
                      badgeColor: const Color(0xFF10B981),
                      icon: CupertinoIcons.chat_bubble_text,
                      iconColor: const Color(0xFF10B981),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
  
                    // KPI 4: Multi-Listing Landlords
                    _buildExecutiveKpiCard(
                      title: 'Portfolio Landlords',
                      value: '${ownerMap.values.where((l) => l.length > 1).length} Multi-Unit',
                      subtitle: 'Owners with > 1 listing',
                      badgeLabel: 'Power Hosts',
                      badgeColor: const Color(0xFF8B5CF6),
                      icon: CupertinoIcons.rosette,
                      iconColor: const Color(0xFF8B5CF6),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
  
            // 3. Multi-Column Landlord Card Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 1150 ? 3 : (width > 680 ? 2 : 1);
  
                if (ownerMap.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161922) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: Text('No property owners registered yet.', style: TextStyle(fontFamily: 'ProximaNova', color: mutedColor, fontSize: 13)),
                    ),
                  );
                }
  
                final entries = ownerMap.entries.toList();
  
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 310, // snug, perfectly fitted height
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, idx) {
                    final entry = entries[idx];
                    final phone = entry.key;
                    final props = entry.value;
                    final ownerName = props.first.title.split('-').first.trim().isNotEmpty
                        ? props.first.title.split('-').first.trim()
                        : 'Landlord ${idx + 1}';
  
                    final localities = props.map((p) => p.locationStr.split(',').first.trim()).toSet().toList();
  
                    return _buildLandlordCard(
                      ownerName: ownerName,
                      phone: phone,
                      props: props,
                      localities: localities,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }



}
