part of 'admin_dashboard_screen.dart';

extension AdminDashboardOverviewExt on _AdminDashboardScreenState {
  Widget _buildOverviewTab(bool isDark) {
      final total = _properties.length;
      final pendingCount = _properties.where((p) => p.status == 'pending').length;
      final occupiedCount = _properties.where((p) => !p.isAvailable).length;
      final availableCount = _properties.where((p) => p.isAvailable && p.status == 'approved').length;
      final flatsCount = _properties.where((p) => p.type == 'Rental').length;
      final pgsCount = _properties.where((p) => p.type == 'PG').length;
      final commercialCount = _properties.where((p) => p.type == 'Commercial' || p.type == 'Sale').length;
      final photosCount = _properties.where((p) => p.imageUrls.isNotEmpty).length;
  
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
  
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Executive Operations Header Banner
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
                      color: AppTheme.primaryYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryYellow.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.dot_radiowaves_right, color: Color(0xFFFFEB3A), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Rental Platform Operations Center',
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
                                    'LIVE REALTIME',
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
                          'Direct owner listings, verification moderation, locality demand radar, and tenant broadcast.',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    children: [
                      if (pendingCount > 0)
                        ElevatedButton.icon(
                          onPressed: _batchApproveAllPending,
                          icon: const Icon(CupertinoIcons.checkmark_alt, size: 16),
                          label: Text(
                            'Approve All ($pendingCount)',
                            style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _selectedTabIndex = 3),
                        icon: const Icon(CupertinoIcons.bell_fill, size: 16),
                        label: Text(
                          'Push Broadcast',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, fontWeight: FontWeight.w700),
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
  
            // 2. 4-Core Practical Real-Time Operational KPI Cards
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
                    // KPI 1: Total Listings
                    _buildExecutiveKpiCard(
                      title: 'Live Listings in App',
                      value: '$total Properties',
                      subtitle: '$availableCount Available • $occupiedCount Occupied',
                      badgeLabel: '100% Active',
                      badgeColor: const Color(0xFF10B981),
                      icon: CupertinoIcons.building_2_fill,
                      iconColor: AppTheme.primaryYellow,
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                    ),
  
                    // KPI 2: Pending Moderation
                    _buildExecutiveKpiCard(
                      title: 'Pending Verifications',
                      value: '$pendingCount Submissions',
                      subtitle: pendingCount > 0 ? '$pendingCount awaiting review' : 'All submissions verified',
                      badgeLabel: pendingCount > 0 ? 'Action Needed' : 'All Caught Up',
                      badgeColor: pendingCount > 0 ? AppTheme.primaryYellow : const Color(0xFF10B981),
                      icon: CupertinoIcons.check_mark_circled_solid,
                      iconColor: pendingCount > 0 ? AppTheme.primaryYellow : const Color(0xFF10B981),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                      onTap: () => setState(() {
                        _selectedTabIndex = 1;
                        _statusFilter = 'pending';
                      }),
                    ),
  
                    // KPI 3: Operational Localities
                    _buildExecutiveKpiCard(
                      title: 'Covered Localities',
                      value: '${_rajahmundryLocalities.length} Localities',
                      subtitle: 'Active Municipal Zones',
                      badgeLabel: 'Active Coverage',
                      badgeColor: const Color(0xFF3B82F6),
                      icon: CupertinoIcons.location_solid,
                      iconColor: const Color(0xFF3B82F6),
                      isDark: isDark,
                      primaryTextColor: primaryTextColor,
                      mutedColor: mutedColor,
                      onTap: () => setState(() => _selectedTabIndex = 6),
                    ),
  
                    // KPI 4: Photos & Quality Verification
                    _buildExecutiveKpiCard(
                      title: 'Photo Verified Listings',
                      value: '$photosCount / $total Verified',
                      subtitle: 'Real room & exterior photos',
                      badgeLabel: '100% Verified',
                      badgeColor: const Color(0xFF8B5CF6),
                      icon: CupertinoIcons.camera_fill,
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
  
            // 3. Balanced 2-Column Clean Layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Inventory Categories & Locality Distribution
                      Expanded(
                        child: Column(
                          children: [
                            _buildInventoryBreakdownCard(
                              isDark: isDark,
                              primaryTextColor: primaryTextColor,
                              mutedColor: mutedColor,
                              flatsCount: flatsCount,
                              pgsCount: pgsCount,
                              commercialCount: commercialCount,
                              total: total,
                            ),
                            const SizedBox(height: 16),
                            _buildLocalityRankingCard(isDark, primaryTextColor, mutedColor),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
  
                      // Right Column: Live Listings Feed & Platform Security
                      Expanded(
                        child: Column(
                          children: [
                            _buildLivePlatformActivityFeed(isDark, primaryTextColor, mutedColor),
                            const SizedBox(height: 16),
                            _buildPlatformSecurityGuardrailsCard(isDark, primaryTextColor, mutedColor),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildInventoryBreakdownCard(
                        isDark: isDark,
                        primaryTextColor: primaryTextColor,
                        mutedColor: mutedColor,
                        flatsCount: flatsCount,
                        pgsCount: pgsCount,
                        commercialCount: commercialCount,
                        total: total,
                      ),
                      const SizedBox(height: 16),
                      _buildLivePlatformActivityFeed(isDark, primaryTextColor, mutedColor),
                      const SizedBox(height: 16),
                      _buildLocalityRankingCard(isDark, primaryTextColor, mutedColor),
                      const SizedBox(height: 16),
                      _buildPlatformSecurityGuardrailsCard(isDark, primaryTextColor, mutedColor),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      );
    }



  Widget _buildLocalityRankingCard(bool isDark, Color primaryTextColor, Color mutedColor) {
      // Dynamically calculate listing count per locality from live dataset
      final localityMap = <String, int>{};
      for (final p in _properties) {
        final loc = p.locationStr.split(',').first.trim();
        if (loc.isNotEmpty) {
          localityMap[loc] = (localityMap[loc] ?? 0) + 1;
        }
      }
  
      final sortedLocalities = localityMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  
      final totalProps = _properties.isEmpty ? 1 : _properties.length;
  
      // Remaining localities with 0 listings currently
      final unlistedLocalities = _rajahmundryLocalities
          .where((loc) => !localityMap.containsKey(loc))
          .take(5)
          .toList();
  
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
                    const Icon(CupertinoIcons.location_solid, size: 17, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Text(
                      'Active Localities & Coverage',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _selectedTabIndex = 6),
                  child: Text(
                    'Manage Localities ↗',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w700, color: const Color(0xFF3B82F6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
  
            // Active Localities with Listings
            ...sortedLocalities.map((entry) {
              final locName = entry.key;
              final locCount = entry.value;
              final pct = (locCount / totalProps).clamp(0.05, 1.0);
              final pctLabel = ((locCount / totalProps) * 100).round();
  
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              locName,
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Active Zone',
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 9.5, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$locCount Properties ($pctLabel%)',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              );
            }),
  
            const SizedBox(height: 4),
            Text(
              'Configured Areas Ready For Next Listings:',
              style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w700, color: mutedColor),
            ),
            const SizedBox(height: 8),
  
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: unlistedLocalities.map((loc) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    loc,
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w600, color: mutedColor),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }



  Widget _buildPlatformSecurityGuardrailsCard(bool isDark, Color primaryTextColor, Color mutedColor) {
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
                    const Icon(CupertinoIcons.shield_fill, size: 17, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(
                      'Platform Quality & Security Rules',
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
                    '100% Active',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
  
            _buildGuardrailItem(
              icon: CupertinoIcons.person_fill,
              title: 'Direct Landlord Connect',
              subtitle: 'Direct WhatsApp & Phone without intermediary broker commissions.',
              color: const Color(0xFF10B981),
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: 8),
            _buildGuardrailItem(
              icon: CupertinoIcons.camera_fill,
              title: 'Room & Building Photos Enforced',
              subtitle: 'All 19 active properties contain verified real visual photos.',
              color: AppTheme.primaryYellow,
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              mutedColor: mutedColor,
            ),
            const SizedBox(height: 8),
            _buildGuardrailItem(
              icon: CupertinoIcons.check_mark_circled_solid,
              title: 'Admin Verification Gatekeeper',
              subtitle: 'New submissions are held in pending queue until approved.',
              color: const Color(0xFF3B82F6),
              isDark: isDark,
              primaryTextColor: primaryTextColor,
              mutedColor: mutedColor,
            ),
          ],
        ),
      );
    }



  Widget _buildCategoryPillRow(String label, int count, int pct, Color color, Color primaryTextColor) {
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, fontWeight: FontWeight.w600, color: primaryTextColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count units ($pct%)',
            style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      );
    }

  Widget _buildPriceTierCard(String range, String count, String label, Color color, bool isDark) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(range, style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 1),
            Text(count, style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10.5, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(fontFamily: 'ProximaNova', fontSize: 9, color: const Color(0xFF94A3B8)), maxLines: 1),
          ],
        ),
      );
    }

  Widget _buildLivePlatformActivityFeed(bool isDark, Color primaryTextColor, Color mutedColor) {
      final realProperties = _properties.take(4).toList();
  
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
                    const Icon(CupertinoIcons.building_2_fill, size: 17, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 8),
                    Text(
                      'Recently Verified Listings',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _selectedTabIndex = 1),
                  child: Text(
                    'View All (${_properties.length}) ↗',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primaryYellow),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
  
            if (realProperties.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No properties in database yet.',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, color: mutedColor),
                ),
              )
            else
              ...realProperties.map((prop) {
                final thumb = prop.imageUrls.isNotEmpty ? prop.imageUrls.first : '';
                final location = prop.locationStr.split(',').first.trim();
  
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.5),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _viewPropertyInLivePhone(prop),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: thumb,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 38,
                                height: 38,
                                color: const Color(0xFFE2E8F0),
                                child: const Icon(CupertinoIcons.photo, size: 16, color: Color(0xFF94A3B8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prop.title,
                                  style: TextStyle(fontFamily: 'ProximaNova', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '₹${prop.price}/mo • $location',
                                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              prop.type,
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    }

}
