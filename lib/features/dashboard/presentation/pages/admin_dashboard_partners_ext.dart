part of 'admin_dashboard_screen.dart';

extension AdminDashboardPartnersExt on _AdminDashboardScreenState {
  bool _isPartnerProperty(PropertyModel p) {
    return p.tags.any((t) => t.toLowerCase().startsWith('partner:'));
  }

  String _getPartnerEmail(PropertyModel p) {
    for (var t in p.tags) {
      if (t.toLowerCase().startsWith('partner:')) {
        return t.substring('partner:'.length).trim();
      }
    }
    return '';
  }

  String _getPartnerRole(PropertyModel p) {
    for (var t in p.tags) {
      if (t.toLowerCase().startsWith('partner_role:')) {
        return t.substring('partner_role:'.length).trim();
      }
    }
    return 'Direct Property Owner';
  }

  Widget _buildPartnersTab(bool isDark) {
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF161922) : Colors.white;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0);

    // Filter partner properties
    final partnerProperties = _properties
        .where((p) => _isPartnerProperty(p))
        .toList();
    final pendingPartnerUploads = _properties
        .where((p) => _isPartnerProperty(p) && p.status == 'pending')
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        await _fetchProperties();
        await _fetchHandoverRequests();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryYellow.withValues(alpha: 0.4)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.briefcase_fill, color: Colors.black87, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partners & Property Handover Hub',
                          style: TextStyle(
                            fontFamily: 'ProximaNova',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review owner handover requests, manage verified partners, and assign platform listings directly to owners or dealers.',
                          style: TextStyle(
                            fontFamily: 'ProximaNova',
                            fontSize: 12.5,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showDirectAssignDialog(isDark),
                    icon: const Icon(CupertinoIcons.arrow_right_arrow_left, size: 16),
                    label: const Text('Assign Property'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      textStyle: const TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // KPI Metrics Row
            Row(
              children: [
                _buildPartnerKpiCard(
                  title: 'Pending Claims',
                  value: _pendingHandoverRequestsCount.toString(),
                  icon: CupertinoIcons.hand_draw_fill,
                  accentColor: const Color(0xFFFF9F0A),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(width: 12),
                _buildPartnerKpiCard(
                  title: 'Partner Properties',
                  value: partnerProperties.length.toString(),
                  icon: CupertinoIcons.building_2_fill,
                  accentColor: const Color(0xFF10B981),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(width: 12),
                _buildPartnerKpiCard(
                  title: 'Pending Approvals',
                  value: pendingPartnerUploads.length.toString(),
                  icon: CupertinoIcons.clock_fill,
                  accentColor: const Color(0xFF8B5CF6),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(width: 12),
                _buildPartnerKpiCard(
                  title: 'Handover Records',
                  value: _handoverRequests.length.toString(),
                  icon: CupertinoIcons.checkmark_seal_fill,
                  accentColor: const Color(0xFF3B82F6),
                  cardBg: cardBg,
                  borderColor: borderColor,
                  primaryTextColor: primaryTextColor,
                  mutedColor: mutedColor,
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Handover Requests Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.hand_draw_fill, size: 18, color: Color(0xFFFF9F0A)),
                    const SizedBox(width: 8),
                    Text(
                      'Ownership Claim & Handover Requests',
                      style: TextStyle(
                        fontFamily: 'ProximaNova',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    if (_pendingHandoverRequestsCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9F0A).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_pendingHandoverRequestsCount Pending',
                          style: const TextStyle(
                            fontFamily: 'ProximaNova',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF9F0A),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.arrow_clockwise, size: 16),
                  onPressed: _fetchHandoverRequests,
                  tooltip: 'Refresh requests',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Handover Requests List
            if (_handoverRequests.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Icon(CupertinoIcons.checkmark_shield_fill, size: 40, color: mutedColor),
                    const SizedBox(height: 10),
                    Text(
                      'No pending handover requests',
                      style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w700, fontSize: 14, color: primaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'When property owners or dealers claim a listing via "Ask Admin", requests appear here for approval.',
                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, color: mutedColor),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _handoverRequests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final req = _handoverRequests[index];
                  return _buildHandoverRequestCard(req, isDark, cardBg, borderColor, primaryTextColor, mutedColor);
                },
              ),
            const SizedBox(height: 28),

            // Section 2: Partner-Assigned Properties
            Row(
              children: [
                const Icon(CupertinoIcons.building_2_fill, size: 18, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  'Partner-Managed Listings (${partnerProperties.length})',
                  style: TextStyle(
                    fontFamily: 'ProximaNova',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (partnerProperties.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Center(
                  child: Text(
                    'No properties currently assigned to partners. Click "Assign Property" above to handover any listing.',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: mutedColor),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: partnerProperties.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = partnerProperties[index];
                  return _buildPartnerPropertyCard(p, isDark, cardBg, borderColor, primaryTextColor, mutedColor);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color mutedColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 19, color: accentColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'ProximaNova',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'ProximaNova',
                      fontSize: 11.5,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandoverRequestCard(
    Map<String, dynamic> req,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color mutedColor,
  ) {
    final status = (req['status'] ?? 'pending').toString();
    final isPending = status == 'pending';
    final isApproved = status == 'approved';

    final Color statusColor = isApproved
        ? const Color(0xFF10B981)
        : (isPending ? const Color(0xFFFF9F0A) : const Color(0xFFEF4444));

    final propertyTitle = req['property_title'] ?? 'Listing Claim';
    final partnerEmail = req['partner_email'] ?? '';
    final role = req['role'] ?? 'Direct Property Owner';
    final note = req['note'] ?? '';
    final thumb = req['property_image']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? const Color(0xFFFF9F0A).withValues(alpha: 0.4) : borderColor,
          width: isPending ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 58,
                  height: 58,
                  color: Colors.grey.shade300,
                  child: thumb != null && thumb.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: thumb,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(CupertinoIcons.photo, size: 20),
                        )
                      : const Icon(CupertinoIcons.photo, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            propertyTitle,
                            style: TextStyle(
                              fontFamily: 'ProximaNova',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'ProximaNova',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Partner: $partnerEmail  •  Role: $role',
                      style: const TextStyle(
                        fontFamily: 'ProximaNova',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF21262D) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Verification Note: $note',
                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, color: mutedColor),
              ),
            ),
          ],

          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _rejectHandoverRequest(req),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Reject', style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _approveAndHandover(req),
                  icon: const Icon(CupertinoIcons.checkmark_alt, size: 14),
                  label: const Text('Approve & Handover'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartnerPropertyCard(
    PropertyModel p,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color primaryTextColor,
    Color mutedColor,
  ) {
    final thumb = p.imageUrls.isNotEmpty ? p.imageUrls.first : null;
    final partnerEmail = _getPartnerEmail(p);
    final partnerRole = _getPartnerRole(p);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade300,
              child: thumb != null
                  ? CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(CupertinoIcons.photo))
                  : const Icon(CupertinoIcons.photo),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13.5, fontWeight: FontWeight.w800, color: primaryTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  'Partner: $partnerEmail  •  Role: $partnerRole',
                  style: const TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _unlinkPartner(p),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Unlink', style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Future<void> _approveAndHandover(Map<String, dynamic> req) async {
    final propertyId = req['property_id']?.toString() ?? '';
    final partnerEmail = req['partner_email']?.toString().toLowerCase().trim() ?? '';
    final role = req['role']?.toString() ?? 'Direct Property Owner';
    final reqId = req['id']?.toString() ?? '';

    if (propertyId.isEmpty) {
      if (mounted) AppSnackbar.error(context, 'Missing property ID for handover.');
      return;
    }

    try {
      // 1. Update tags on property in Supabase safely
      List<String> updatedTags = [];
      final propIndex = _properties.indexWhere((p) => p.id == propertyId);
      if (propIndex != -1) {
        updatedTags = List<String>.from(_properties[propIndex].tags);
      } else {
        final propRow = await _supabase.from('properties').select('tags').eq('id', propertyId).maybeSingle();
        if (propRow != null && propRow['tags'] != null) {
          updatedTags = List<String>.from((propRow['tags'] as List).map((e) => e.toString()));
        }
      }

      updatedTags.removeWhere((t) => t.toLowerCase().startsWith('partner:') || t.toLowerCase().startsWith('partner_role:'));
      if (partnerEmail.isNotEmpty) {
        updatedTags.add('partner:$partnerEmail');
        updatedTags.add('partner_role:$role');
      }

      await _supabase.from('properties').update({
        'tags': updatedTags,
      }).eq('id', propertyId);

      // 2. Mark request approved in Supabase listing_reports
      if (reqId.isNotEmpty) {
        await _supabase.from('listing_reports').update({'status': 'approved'}).eq('id', reqId);
      }

      if (mounted) AppSnackbar.success(context, 'Property successfully handed over to $partnerEmail!');
      await _fetchProperties();
      await _fetchHandoverRequests();
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Error approving handover: $e');
    }
  }

  Future<void> _rejectHandoverRequest(Map<String, dynamic> req) async {
    final reqId = req['id']?.toString() ?? '';
    try {
      if (reqId.isNotEmpty) {
        await _supabase.from('listing_reports').update({'status': 'rejected'}).eq('id', reqId);
      }
      if (mounted) AppSnackbar.info(context, 'Handover request rejected.');
      await _fetchHandoverRequests();
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Error rejecting request: $e');
    }
  }

  Future<void> _unlinkPartner(PropertyModel p) async {
    if (p.id == null) return;
    try {
      List<String> updatedTags = List<String>.from(p.tags);
      updatedTags.removeWhere((t) => t.toLowerCase().startsWith('partner:') || t.toLowerCase().startsWith('partner_role:'));

      await _supabase.from('properties').update({
        'tags': updatedTags,
      }).eq('id', p.id!);

      if (mounted) AppSnackbar.info(context, 'Partner unlinked from property.');
      await _fetchProperties();
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Error unlinking partner: $e');
    }
  }

  void _showDirectAssignDialog(bool isDark) {
    PropertyModel? selectedProp;
    final partnerEmailCtrl = TextEditingController();
    String selectedRole = 'Direct Property Owner';
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final filtered = searchQuery.isEmpty
                ? _properties
                : _properties.where((p) => p.title.toLowerCase().contains(searchQuery.toLowerCase()) || p.locationStr.toLowerCase().contains(searchQuery.toLowerCase())).toList();

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Direct Property Handover / Assign', style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w800, fontSize: 16)),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. SELECT PROPERTY', style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (val) => setDialogState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search properties...',
                          prefixIcon: const Icon(CupertinoIcons.search, size: 16),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final p = filtered[idx];
                            final isSel = selectedProp?.id == p.id;
                            return ListTile(
                              dense: true,
                              selected: isSel,
                              selectedTileColor: AppTheme.primaryYellow.withValues(alpha: 0.2),
                              title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                              subtitle: Text('₹${p.price} • ${p.locationStr}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                              onTap: () => setDialogState(() => selectedProp = p),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('2. PARTNER DETAILS', style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: partnerEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Partner Registered Email',
                          hintText: 'e.g. owner@example.com',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRole,
                        decoration: InputDecoration(
                          labelText: 'Role',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Direct Property Owner', child: Text('Direct Property Owner')),
                          DropdownMenuItem(value: 'Real Estate Dealer / Broker', child: Text('Real Estate Dealer / Broker')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedRole = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedProp == null) {
                      AppSnackbar.error(dialogCtx, 'Please select a property first.');
                      return;
                    }
                    final email = partnerEmailCtrl.text.trim().toLowerCase();
                    if (email.isEmpty || !email.contains('@')) {
                      AppSnackbar.error(dialogCtx, 'Please provide a valid partner email.');
                      return;
                    }
                    Navigator.pop(dialogCtx);
                    try {
                      List<String> updatedTags = List<String>.from(selectedProp!.tags);
                      updatedTags.removeWhere((t) => t.toLowerCase().startsWith('partner:') || t.toLowerCase().startsWith('partner_role:'));
                      updatedTags.add('partner:$email');
                      updatedTags.add('partner_role:$selectedRole');

                      await _supabase.from('properties').update({
                        'tags': updatedTags,
                      }).eq('id', selectedProp!.id!);

                      if (mounted) AppSnackbar.success(context, 'Property successfully assigned to $email!');
                      await _fetchProperties();
                    } catch (e) {
                      if (mounted) AppSnackbar.error(context, 'Failed to assign property: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryYellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Confirm Handover', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
