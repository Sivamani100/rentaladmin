part of 'admin_dashboard_screen.dart';

extension AdminDashboardAnalyticsExt on _AdminDashboardScreenState {
  Widget _buildClickRadarTab(bool isDark) {
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
      final total = _properties.length;
      final pgsCount = _properties.where((p) => p.type == 'PG').length;
      final topProps = _topViewedProperties.isNotEmpty ? _topViewedProperties : _properties.take(5).toList();
  
      final topCategory = _demandRadarData?['top_category'] ?? 'N/A';
      final topCategoryCount = _demandRadarData?['top_category_count'] ?? 0;
      final totalCategoryClicks = _demandRadarData?['total_category_clicks'] ?? 1;
      final catPct = totalCategoryClicks > 0 ? ((topCategoryCount / totalCategoryClicks) * 100).toInt() : 0;
  
      double avgRent = 0;
      if (topProps.isNotEmpty) {
        avgRent = topProps.map((e) => (int.tryParse(e.price.replaceAll(',', '')) ?? 0).toDouble()).reduce((a, b) => a + b) / topProps.length;
      }
      String rentTierStr = avgRent > 0 ? '₹${(avgRent/1000).toStringAsFixed(1)}k/mo Avg' : 'N/A';
  
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
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.dot_radiowaves_right, color: Color(0xFF8B5CF6), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tenant Demand Radar & Search Analytics',
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
                                    'LIVE SIGNALS',
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
                          'Real-time tenant search trends, keyword velocities, most-viewed property rankings, and amenity demand heatmaps.',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedTabIndex = 3),
                    icon: const Icon(CupertinoIcons.bell_fill, size: 16, color: Colors.black),
                    label: Text(
                      'Broadcast Trending',
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
            ),
            const SizedBox(height: 16),
  
            // 2. 4-Core Practical Demand KPI Cards
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
                    // KPI 1: Monitored Properties
                    _buildExecutiveKpiCard(
                      title: 'Monitored Inventory',
                      value: '$total Properties',
                      subtitle: '100% Tracking Active',
                      badgeLabel: 'Live Radar',
                      badgeColor: const Color(0xFF10B981),
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      iconColor: const Color(0xFF8B5CF6),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
  
                    // KPI 2: Top Demanded Category
                    _buildExecutiveKpiCard(
                      title: 'Top Demanded Category',
                      value: topCategory,
                      subtitle: '$topCategoryCount clicks ($totalCategoryClicks total)',
                      badgeLabel: '$catPct% Volume',
                      badgeColor: AppTheme.primaryYellow,
                      icon: CupertinoIcons.building_2_fill,
                      iconColor: AppTheme.primaryYellow,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
  
                    // KPI 3: Dominant Rent Bracket
                    _buildExecutiveKpiCard(
                      title: 'High Velocity Rent Tier',
                      value: rentTierStr,
                      subtitle: 'Avg of top properties',
                      badgeLabel: 'Sweet Spot',
                      badgeColor: const Color(0xFF3B82F6),
                      icon: CupertinoIcons.creditcard_fill,
                      iconColor: const Color(0xFF3B82F6),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
  
                    // KPI 4: Must-Have Amenity
                    _buildExecutiveKpiCard(
                      title: 'Most Demanded Amenity',
                      value: 'Attached Bath & Food',
                      subtitle: '94% of search filter combos',
                      badgeLabel: 'Top Filter',
                      badgeColor: const Color(0xFF10B981),
                      icon: CupertinoIcons.checkmark_alt,
                      iconColor: const Color(0xFF10B981),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
  
            // 3. Main 2-Column Balanced Section
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Leaderboard & Amenity Heatmap
                      Expanded(
                        child: Column(
                          children: [
                            _buildMostWatchedLeaderboard(topProps, isDark, primaryTextColor, mutedColor),
                            const SizedBox(height: 16),
                            _buildAmenityDemandHeatmapCard(isDark, primaryTextColor, mutedColor),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
  
                      // Right Column: Trending Searches & Direct Lead Routing
                      Expanded(
                        child: Column(
                          children: [
                            _buildTrendingSearchesRadar(isDark, primaryTextColor, mutedColor),
                            const SizedBox(height: 16),
                            _buildTenantInquiryFlowCard(isDark, primaryTextColor, mutedColor),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildMostWatchedLeaderboard(topProps, isDark, primaryTextColor, mutedColor),
                      const SizedBox(height: 16),
                      _buildTrendingSearchesRadar(isDark, primaryTextColor, mutedColor),
                      const SizedBox(height: 16),
                      _buildAmenityDemandHeatmapCard(isDark, primaryTextColor, mutedColor),
                      const SizedBox(height: 16),
                      _buildTenantInquiryFlowCard(isDark, primaryTextColor, mutedColor),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      );
    }

  Widget _buildMostWatchedLeaderboard(
      List<PropertyModel> props,
      bool isDark,
      Color primaryTextColor,
      Color mutedColor,
    ) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161922) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.chart_bar_alt_fill, size: 17, color: Color(0xFFFFEB3A)),
                    const SizedBox(width: 8),
                    Text(
                      'High Velocity & Inquired Listings',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Top 5 Active',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryYellow),
                ),
              ],
            ),
            const SizedBox(height: 14),
  
            if (props.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No property click data available yet.', style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, color: mutedColor)),
              )
            else
              ...props.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final thumb = p.imageUrls.isNotEmpty ? p.imageUrls.first : '';
                final loc = p.locationStr.split(',').first.trim();
  
                final rankColor = idx == 0
                    ? AppTheme.primaryYellow
                    : (idx == 1 ? const Color(0xFF94A3B8) : (idx == 2 ? const Color(0xFFD97706) : mutedColor));
  
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${idx + 1}',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: rankColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
  
                      // Property Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: thumb,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            child: const Icon(CupertinoIcons.photo, size: 14, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
  
                      // Title & Locality
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '₹${p.price}/mo • $loc',
                              style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
  
                      // Actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'View on Live Phone',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => _viewPropertyInLivePhone(p),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF161922) : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                                ),
                                alignment: Alignment.center,
                                child: Icon(CupertinoIcons.eye_solid, size: 13, color: mutedColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'WhatsApp Landlord',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () => _contactOwnerWhatsApp(p.ownerPhone, p.title),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(CupertinoIcons.chat_bubble, size: 13, color: Color(0xFF10B981)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    }

  Widget _buildAmenityDemandHeatmapCard(bool isDark, Color primaryTextColor, Color mutedColor) {
      List<({String name, String demand, double pct, Color color})> amenities = [];
      if (_topViewedProperties.isNotEmpty) {
        final Map<String, int> amenityCounts = {};
        int totalAmenities = 0;
        for (var p in _topViewedProperties) {
          for (var a in p.features) {
            amenityCounts[a] = (amenityCounts[a] ?? 0) + 1;
            totalAmenities++;
          }
        }
        final sortedAmenities = amenityCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        amenities = sortedAmenities.take(5).map((e) {
          final pct = totalAmenities > 0 ? e.value / totalAmenities : 0.0;
          return (
            name: e.key,
            demand: '${(pct * 100).toInt()}% Inquiries',
            pct: pct,
            color: const Color(0xFF10B981)
          );
        }).toList();
      }
      if (amenities.isEmpty) {
        amenities = [
          (name: 'No data yet', demand: '0%', pct: 0.0, color: const Color(0xFF94A3B8))
        ];
      }
  
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161922) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.slider_horizontal_3, size: 17, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(
                      'High Demand Amenities Heatmap',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Tenant Filter Index',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
  
            ...amenities.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
                        ),
                        Text(
                          item.demand,
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w700, color: item.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.pct,
                        minHeight: 5,
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

  Widget _buildTrendingSearchesRadar(bool isDark, Color primaryTextColor, Color mutedColor) {
      final List<dynamic> topSearchesData = _demandRadarData?['top_searches'] ?? [];
      List<({String query, String volume, String growth, Color color})> searchTerms = topSearchesData.map((e) {
        return (
          query: e['keyword']?.toString() ?? 'Unknown',
          volume: '${e['count']} searches',
          growth: 'Top',
          color: const Color(0xFF10B981)
        );
      }).toList();
  
      if (searchTerms.isEmpty) {
        searchTerms = [
          (query: 'No search data yet', volume: '-', growth: '-', color: const Color(0xFF94A3B8))
        ];
      }
  
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161922) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.search, size: 17, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 8),
                    Text(
                      'Trending Tenant Search Keywords',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Weekly Velocity',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
  
            ...searchTerms.map((term) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.search, size: 14, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            term.query,
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            term.volume,
                            style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10.5, color: mutedColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: term.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        term.growth,
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: term.color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }

  Widget _buildTenantInquiryFlowCard(bool isDark, Color primaryTextColor, Color mutedColor) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161922) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.phone_fill, size: 17, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Text(
                      'Direct Landlord Inquiry Routing',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '100% Direct',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
  
            _buildGuardrailItem(
              icon: CupertinoIcons.chat_bubble_text,
              title: 'Direct WhatsApp Chats',
              subtitle: 'Tenants initiate direct WhatsApp inquiries with verified landlords.',
              color: const Color(0xFF10B981),
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: 8),
            _buildGuardrailItem(
              icon: CupertinoIcons.phone_fill,
              title: '1-Tap Direct Phone Calls',
              subtitle: 'Direct owner contact with no broker fee or hidden commission.',
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: 8),
            _buildGuardrailItem(
              icon: CupertinoIcons.shield_fill,
              title: 'Zero Broker Intermediation',
              subtitle: 'All leads route straight to the owner who posted the listing.',
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              mutedColor: mutedColor,
            ),
          ],
        ),
      );
    }

}
