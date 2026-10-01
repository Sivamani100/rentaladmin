part of 'admin_dashboard_screen.dart';

extension AdminDashboardPropertiesExt on _AdminDashboardScreenState {
  Widget _buildPropertiesTab(bool isDark) {
      final filtered = _properties.where((p) {
        if (_statusFilter == 'pending' && p.status != 'pending') return false;
        if (_statusFilter == 'approved' && p.status != 'approved') return false;
        if (_statusFilter == 'occupied' && p.isAvailable) return false;
        if (_statusFilter == 'rejected' && p.status != 'rejected') return false;
        if (_statusFilter == 'pending_photos' && !p.suggestedPhotos.any((ph) => ph['status'] == 'pending')) {
          return false;
        }
  
        if (_typeFilter != 'all' && !p.type.toLowerCase().contains(_typeFilter.toLowerCase())) {
          return false;
        }
  
        if (_localityFilter != 'all' && !p.locationStr.toLowerCase().contains(_localityFilter.toLowerCase())) {
          return false;
        }
  
        if (_propertySearchQuery.isNotEmpty) {
          final q = _propertySearchQuery.toLowerCase();
          return p.title.toLowerCase().contains(q) ||
              p.locationStr.toLowerCase().contains(q) ||
              p.ownerPhone.toLowerCase().contains(q) ||
              (p.id?.toLowerCase().contains(q) ?? false);
        }
  
        return true;
      }).toList();
  
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
  
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter & Search Controls Container
            Container(
              padding: const EdgeInsets.all(16),
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
                    children: [
                      // Search Input (Height: 44px)
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: TextField(
                            onChanged: (val) => setState(() => _propertySearchQuery = val),
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              color: primaryTextColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search properties by Title, Owner Phone, Locality, or ID...',
                              hintStyle: TextStyle(fontFamily: 'ProximaNova', 
                                color: mutedColor.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                CupertinoIcons.search,
                                size: 17,
                                color: mutedColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
  
                      // Property Type PopupMenu (Height: 44px)
                      PopupMenuButton<String>(
                        tooltip: 'Filter by Property Type',
                        offset: const Offset(0, 48),
                        color: isDark ? const Color(0xFF1E2330) : Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                          ),
                        ),
                        initialValue: _typeFilter,
                        onSelected: (val) => setState(() => _typeFilter = val),
                        itemBuilder: (context) {
                          return [
                            {'val': 'all', 'label': 'All Types', 'icon': CupertinoIcons.square_grid_2x2_fill},
                            {'val': 'Rental', 'label': 'House / Flat', 'icon': CupertinoIcons.building_2_fill},
                            {'val': 'PG', 'label': 'Hostel / PG', 'icon': CupertinoIcons.person_fill},
                            {'val': 'Commercial', 'label': 'Commercial', 'icon': CupertinoIcons.tag_fill},
                          ].map((item) {
                            final isSelected = _typeFilter == item['val'];
                            return PopupMenuItem<String>(
                              value: item['val'] as String,
                              height: 38,
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    size: 16,
                                    color: isSelected ? AppTheme.primaryYellow : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      item['label'] as String,
                                      style: TextStyle(fontFamily: 'ProximaNova', 
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? AppTheme.primaryYellow : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(CupertinoIcons.checkmark_alt, size: 15, color: Color(0xFFFFEB3A)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.square_grid_2x2_fill, size: 16, color: mutedColor),
                              const SizedBox(width: 7),
                              Text(
                                _typeFilter == 'all'
                                    ? 'All Types'
                                    : (_typeFilter == 'PG' ? 'Hostel / PG' : (_typeFilter == 'Rental' ? 'House / Flat' : _typeFilter)),
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(CupertinoIcons.chevron_down, size: 16, color: mutedColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
  
                      // Locality PopupMenu (Height: 44px)
                      PopupMenuButton<String>(
                        tooltip: 'Filter by Locality',
                        offset: const Offset(0, 48),
                        color: isDark ? const Color(0xFF1E2330) : Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                          ),
                        ),
                        initialValue: _localityFilter,
                        onSelected: (val) => setState(() => _localityFilter = val),
                        itemBuilder: (context) {
                          final allLocs = ['all', ..._rajahmundryLocalities];
                          return allLocs.map((loc) {
                            final isSelected = _localityFilter == loc;
                            final label = loc == 'all' ? 'All Localities' : loc;
                            return PopupMenuItem<String>(
                              value: loc,
                              height: 36,
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.location_solid,
                                    size: 15,
                                    color: isSelected ? AppTheme.primaryYellow : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      label,
                                      style: TextStyle(fontFamily: 'ProximaNova', 
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? AppTheme.primaryYellow : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(CupertinoIcons.checkmark_alt, size: 15, color: Color(0xFFFFEB3A)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.location_solid, size: 16, color: mutedColor),
                              const SizedBox(width: 7),
                              Text(
                                _localityFilter == 'all' ? 'All Localities' : _localityFilter,
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(CupertinoIcons.chevron_down, size: 16, color: mutedColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
  
                  // Status Filter Badges Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusFilterChip('all', 'All Listings (${_properties.length})', isDark),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          'pending',
                          'Pending Review (${_properties.where((p) => p.status == 'pending').length})',
                          isDark,
                          badgeColor: AppTheme.primaryYellow,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          'approved',
                          'Live Vacant (${_properties.where((p) => p.status == 'approved' && p.isAvailable).length})',
                          isDark,
                          badgeColor: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          'occupied',
                          'Occupied (${_properties.where((p) => !p.isAvailable).length})',
                          isDark,
                          badgeColor: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          'pending_photos',
                          'Pending Photos (${_properties.where((p) => p.suggestedPhotos.any((ph) => ph['status'] == 'pending')).length})',
                          isDark,
                          badgeColor: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusFilterChip(
                          'rejected',
                          'Rejected (${_properties.where((p) => p.status == 'rejected').length})',
                          isDark,
                          badgeColor: const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
  
            // Properties Matrix List View
            Expanded(
              child: _isLoadingProperties
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFEB3A)))
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.building_2_fill, size: 48, color: mutedColor.withValues(alpha: 0.3)),
                              const SizedBox(height: 12),
                              Text(
                                'No properties matching the selected filters.',
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 14,
                                  color: mutedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) => _buildDesktopPropertyRow(filtered[idx], isDark),
                        ),
            ),
          ],
        ),
      );
    }

  Widget _buildStatusFilterChip(String value, String label, bool isDark, {Color? badgeColor}) {
    final isSelected = _statusFilter == value;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _statusFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected
              ? (badgeColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)))
              : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontFamily: 'ProximaNova', 
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? (badgeColor != null ? Colors.black : (isDark ? Colors.black : Colors.white))
                : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPropertyRow(PropertyModel prop, bool isDark) {
      final propId = prop.id ?? '';
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
  
      final statusColor = prop.status == 'approved'
          ? const Color(0xFF10B981)
          : (prop.status == 'pending' ? AppTheme.primaryYellow : const Color(0xFFEF4444));
  
      // Cleanly parse price numbers without double ₹ and without double /mo
      final cleanPriceNum = prop.price.replaceAll(RegExp(r'[^0-9]'), '');
      final displayPrice = cleanPriceNum.isNotEmpty ? '₹$cleanPriceNum/mo' : prop.price;
  
      final cleanDepNum = (prop.securityDeposit ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
      final displayDeposit = cleanDepNum.isNotEmpty ? 'Deposit: ₹$cleanDepNum' : 'Deposit: ₹0';
  
      // Build clean inline specs summary
      final List<String> specSummary = [];
      if (prop.type == 'PG') {
        if (prop.sharingType != null && prop.sharingType!.isNotEmpty) specSummary.add(prop.sharingType!);
        if (prop.genderPreference != null && prop.genderPreference!.isNotEmpty) specSummary.add(prop.genderPreference!);
        if (prop.foodDetails != null && prop.foodDetails!.isNotEmpty) specSummary.add('Food Included');
        if (prop.acType != null && prop.acType!.isNotEmpty) specSummary.add(prop.acType!);
      } else {
        if (prop.bhkType != null && prop.bhkType!.isNotEmpty) specSummary.add(prop.bhkType!);
        if (prop.furnishingStatus != null && prop.furnishingStatus!.isNotEmpty) specSummary.add(prop.furnishingStatus!);
        if (prop.tenantPreference != null && prop.tenantPreference!.isNotEmpty) specSummary.add(prop.tenantPreference!);
      }
      final specsText = specSummary.join(' • ');
  
      // Distinct Blue/Slate Vacancy Colors (NOT green, avoiding confusion with Approved!)
      final vacancyColor = prop.isAvailable ? const Color(0xFF2563EB) : const Color(0xFF64748B);
      final vacancyBgColor = prop.isAvailable
          ? const Color(0xFF2563EB).withValues(alpha: 0.12)
          : const Color(0xFF64748B).withValues(alpha: 0.12);
      final vacancyBorderColor = prop.isAvailable
          ? const Color(0xFF2563EB).withValues(alpha: 0.35)
          : const Color(0xFF64748B).withValues(alpha: 0.35);
  
      return LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 960;
          final isMedium = constraints.maxWidth >= 680;
  
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161922) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                // 1. Image Thumbnail (90x70)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: prop.imageUrls.isNotEmpty ? prop.imageUrls.first : '',
                        width: 90,
                        height: 70,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          width: 90,
                          height: 70,
                          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                          child: Icon(CupertinoIcons.photo, size: 24, color: mutedColor),
                        ),
                      ),
                      Positioned(
                        bottom: 3,
                        right: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${prop.imageUrls.length} photos',
                            style: TextStyle(fontFamily: 'ProximaNova', fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
  
                // 2. Title, Locality & Clean Specs Info
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              prop.title,
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: prop.type == 'PG'
                                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                                  : const Color(0xFF3B82F6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              prop.type,
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: prop.type == 'PG' ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prop.locationStr,
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          fontSize: 11.5,
                          color: mutedColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.5),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              specsText.isNotEmpty ? 'Owner: ${prop.ownerPhone}  •  $specsText' : 'Owner: ${prop.ownerPhone}',
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: mutedColor.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
  
                // 3. Price Column
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayPrice,
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    if (prop.perDayWithFood != null && prop.perDayWithFood!.isNotEmpty)
                      Text(
                        '₹${prop.perDayWithFood}/day',
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                  ],
                ),
  
                const SizedBox(width: 14),
  
                // 4. Functional Availability Toggle Button (Distinct Blue/Slate color - NOT green!)
                Tooltip(
                  message: prop.isAvailable ? 'Status: VACANT (Click to mark Occupied)' : 'Status: OCCUPIED (Click to mark Vacant)',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _toggleAvailability(propId, prop.isAvailable),
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: isWide ? 10 : 8),
                      decoration: BoxDecoration(
                        color: vacancyBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: vacancyBorderColor),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            prop.isAvailable ? CupertinoIcons.building_2_fill : CupertinoIcons.lock_fill,
                            size: 14,
                            color: vacancyColor,
                          ),
                          if (isWide) ...[
                            const SizedBox(width: 5),
                            Text(
                              prop.isAvailable ? 'VACANT' : 'OCCUPIED',
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: vacancyColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
  
                // 5. Functional Approval Status Badge / Button
                Tooltip(
                  message: 'Listing Status: ${prop.status.toUpperCase()}',
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 10 : 8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          prop.status == 'approved'
                              ? CupertinoIcons.checkmark_alt
                              : (prop.status == 'pending' ? CupertinoIcons.clock_fill : CupertinoIcons.clear_circled_solid),
                          size: 14,
                          color: statusColor,
                        ),
                        if (isWide) ...[
                          const SizedBox(width: 5),
                          Text(
                            prop.status.toUpperCase(),
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
  
                // 6. Action Icon Buttons (Always functional, crisp 32x32 buttons)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // View in Live Phone Device Preview Button
                    Tooltip(
                      message: 'View on Live Phone Device',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _viewPropertyInLivePhone(prop),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                          ),
                          alignment: Alignment.center,
                          child: Icon(CupertinoIcons.eye_solid, size: 15, color: mutedColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
  
                    // Edit Property Button
                    Tooltip(
                      message: 'Edit Property Details',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showEditPropertyModal(prop, isDark),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(CupertinoIcons.pencil, size: 14, color: Color(0xFFFFEB3A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
  
                    if (prop.status != 'approved') ...[
                      Tooltip(
                        message: 'Approve Listing',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _updatePropertyStatus(propId, 'approved'),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(CupertinoIcons.checkmark_alt, color: Color(0xFF10B981), size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
  
                    if (prop.status != 'rejected') ...[
                      Tooltip(
                        message: 'Reject Listing',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showRejectDialog(propId),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(CupertinoIcons.clear_circled_solid, color: Color(0xFFEF4444), size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
  
                    // More Options Popup Menu (Styled like Device Selector Dropdown)
                    PopupMenuButton<String>(
                      tooltip: 'More Options',
                      offset: const Offset(0, 40),
                      color: isDark ? const Color(0xFF1E2330) : Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      icon: Icon(CupertinoIcons.ellipsis_vertical, size: 17, color: mutedColor),
                      onSelected: (val) {
                        if (val == 'inspect') _showPropertyInspectionModal(prop, isDark);
                        if (val == 'edit') _showEditPropertyModal(prop, isDark);
                        if (val == 'phone') _viewPropertyInLivePhone(prop);
                        if (val == 'availability') _toggleAvailability(propId, prop.isAvailable);
                        if (val == 'delete') _deleteProperty(propId);
                        if (val == 'broadcast') {
                          setState(() {
                            _selectedTabIndex = 3;
                            _selectedActionType = NotificationActionType.property;
                            _selectedPropertyId = propId;
                            _notifTitleController.text = '🔥 Check out this property in ${prop.locationStr.split(',').first}!';
                            _notifBodyController.text = '${prop.title} available now for ${displayPrice}. Zero broker fee.';
                          });
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'phone',
                          height: 38,
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.device_phone_portrait, size: 15, color: Color(0xFF3B82F6)),
                              const SizedBox(width: 9),
                              Text(
                                'View in Phone Preview',
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'edit',
                          height: 38,
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.pencil, size: 15, color: Color(0xFFFFEB3A)),
                              const SizedBox(width: 9),
                              Text(
                                'Edit Property Details',
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'inspect',
                          height: 38,
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.doc_text_fill, size: 15, color: mutedColor),
                              const SizedBox(width: 9),
                              Text(
                                'Inspect Photos & Logs',
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'availability',
                          height: 38,
                          child: Row(
                            children: [
                              Icon(
                                prop.isAvailable ? CupertinoIcons.lock_fill : CupertinoIcons.building_2_fill,
                                size: 15,
                                color: prop.isAvailable ? const Color(0xFF64748B) : const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                prop.isAvailable ? 'Mark as Occupied' : 'Mark as Available',
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'broadcast',
                          height: 38,
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.bell_fill, size: 15, color: Color(0xFF8B5CF6)),
                              const SizedBox(width: 9),
                              Text(
                                'Create Push Notification',
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          height: 38,
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.trash, size: 15, color: Color(0xFFEF4444)),
                              const SizedBox(width: 9),
                              Text(
                                'Delete Listing',
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

  Future<void> _updatePropertyStatus(String propertyId, String newStatus, {String? reason}) async {
    try {
      final Map<String, dynamic> updateData = {'status': newStatus};
      if (reason != null) {
        updateData['rejection_reason'] = reason;
      }

      await _supabase.from('properties').update(updateData).eq('id', propertyId);
      if (mounted) {
        AppSnackbar.success(context, 'Listing status updated to ""');
        _fetchProperties();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to update status: ');
      }
    }
  }

  Future<void> _deleteProperty(String id) async {
      try {
        // 1. Fetch exact image URLs directly from database to guarantee storage deletion
        List<String> imageUrls = [];
        try {
          final data = await _supabase.from('properties').select('image_urls').eq('id', id).maybeSingle();
          if (data != null && data['image_urls'] != null) {
            imageUrls = List<String>.from(data['image_urls'] as List);
          }
        } catch (_) {}
  
        // Fallback to local memory if database query had no result
        if (imageUrls.isEmpty) {
          final PropertyModel? prop = _properties.cast<PropertyModel?>().firstWhere(
            (p) => p?.id == id,
            orElse: () => null,
          );
          if (prop != null) {
            imageUrls = prop.imageUrls;
          }
        }
  
        // 2. Delete photos from Supabase Storage bucket 'property_images'
        if (imageUrls.isNotEmpty) {
          final List<String> storagePaths = [];
          for (final url in imageUrls) {
            if (url.contains('/property_images/')) {
              final fileName = url.split('/property_images/').last.split('?').first;
              if (fileName.isNotEmpty) {
                storagePaths.add(fileName);
              }
            }
          }
          if (storagePaths.isNotEmpty) {
            try {
              await _supabase.storage.from('property_images').remove(storagePaths);
            } catch (storageErr) {
              debugPrint('Failed to delete storage photos: $storageErr');
            }
          }
        }
  
        // 3. Delete database row
        await _supabase.from('properties').delete().eq('id', id);
        if (mounted) {
          AppSnackbar.success(context, 'Property & photos permanently deleted');
          _fetchProperties();
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.error(context, 'Failed to delete property: $e');
        }
      }
    }

}
