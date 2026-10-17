part of 'admin_dashboard_screen.dart';

extension AdminDashboardNotificationsExt on _AdminDashboardScreenState {
  Widget _buildPushNotificationsTab(bool isDark) {
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
  
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header Banner
            Container(
              padding: const EdgeInsets.all(18),
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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(CupertinoIcons.bell_fill, color: Color(0xFF8B5CF6), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notification & Deep-Link Broadcast Hub',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Blast instant manual push alerts or manage 8 AM, 1 PM & 6 PM automated AI notifications.',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 12.5,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.personalhotspot, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Text(
                          '$_allUsersCount Active Devices',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
  
            // Sub-Tab Segmented Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() => _notificationSubTabIndex = 0),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _notificationSubTabIndex == 0
                            ? (isDark ? AppTheme.primaryYellow : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _notificationSubTabIndex == 0
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.paperplane_fill,
                            size: 16,
                            color: _notificationSubTabIndex == 0
                                ? (isDark ? Colors.black : Colors.black87)
                                : mutedColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '📢 Manual Broadcast',
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 13,
                              fontWeight: _notificationSubTabIndex == 0 ? FontWeight.w700 : FontWeight.w500,
                              color: _notificationSubTabIndex == 0
                                  ? (isDark ? Colors.black : Colors.black87)
                                  : mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => setState(() => _notificationSubTabIndex = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _notificationSubTabIndex == 1
                            ? (isDark ? AppTheme.primaryYellow : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _notificationSubTabIndex == 1
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.device_laptop,
                            size: 16,
                            color: _notificationSubTabIndex == 1
                                ? (isDark ? Colors.black : Colors.black87)
                                : mutedColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🤖 AI Auto-Notifier (8 AM, 1 PM, 6 PM)',
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 13,
                              fontWeight: _notificationSubTabIndex == 1 ? FontWeight.w700 : FontWeight.w500,
                              color: _notificationSubTabIndex == 1
                                  ? (isDark ? Colors.black : Colors.black87)
                                  : mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
  
            // Sub-Tab 0: Manual Broadcast Composer OR Sub-Tab 1: AI Auto-Notifier Manager
            if (_notificationSubTabIndex == 0)
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 980) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildNotificationComposerForm(isDark)),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildNotificationLiveMockupAndHistory(isDark)),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildNotificationComposerForm(isDark),
                        const SizedBox(height: 16),
                        _buildNotificationLiveMockupAndHistory(isDark),
                      ],
                    );
                  }
                },
              )
            else
              _buildAiAutoNotifierSubTab(isDark),
          ],
        ),
      );
    }

  Widget _buildAiAutoNotifierSubTab(bool isDark) {
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
      final isEnabled = _autoNotifierSettings?.isEnabled ?? true;
  
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Master Toggle Control Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161922) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isEnabled
                    ? const Color(0xFF10B981).withValues(alpha: 0.3)
                    : Colors.red.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isEnabled ? CupertinoIcons.timer : CupertinoIcons.timer,
                      color: isEnabled ? const Color(0xFF10B981) : Colors.red,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Automated AI Push Notifier',
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isEnabled
                                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                  : Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isEnabled ? '🟢 ACTIVE' : '🔴 PAUSED',
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isEnabled ? const Color(0xFF10B981) : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEnabled
                            ? 'Automatic notifications will be generated by AI and dispatched daily at 8:00 AM, 1:00 PM, and 6:00 PM IST.'
                            : 'Automated notification dispatches are currently paused. Toggle ON to resume automatic AI sending.',
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          fontSize: 12.5,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Transform.scale(
                  scale: 1.1,
                  child: Switch(
                    value: isEnabled,
                    activeColor: const Color(0xFF10B981),
                    onChanged: _isSavingAutoSettings ? null : (val) => _toggleAutoNotifier(val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
  
          // 2. Scheduled Time Slots Overview Cards
          Text(
            '⏰ Scheduled Time Slots (Daily IST)',
            style: TextStyle(fontFamily: 'ProximaNova', 
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTimeSlotCard(
                  isDark: isDark,
                  time: '8:00 AM',
                  title: 'Morning Pulse',
                  subtitle: 'Student PGs & Early Flat Hunting',
                  icon: CupertinoIcons.sun_max_fill,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimeSlotCard(
                  isDark: isDark,
                  time: '1:00 PM',
                  title: 'Lunch Peak',
                  subtitle: 'Quick AI Property Search & Filters',
                  icon: CupertinoIcons.sun_dust_fill,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimeSlotCard(
                  isDark: isDark,
                  time: '1:20 PM',
                  title: 'Post-Lunch Pulse',
                  subtitle: 'Mid-day Tenant Followup & PGs',
                  icon: CupertinoIcons.circle_grid_hex,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTimeSlotCard(
                  isDark: isDark,
                  time: '6:00 PM',
                  title: 'Evening Prime',
                  subtitle: 'Post-Work Direct Owner Chat',
                  icon: CupertinoIcons.moon_fill,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
  
          // 3. AI Guidelines & System Prompt Editor Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161922) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.wand_stars, color: AppTheme.primaryYellow, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI Notification Guidelines & Prompt Rules',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _isSavingAutoSettings ? null : _saveAiInstructions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryYellow,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _isSavingAutoSettings
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(CupertinoIcons.checkmark_alt, size: 16),
                      label: Text(
                        'Save Guidelines',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Customize instructions for the Notification AI. The AI generates title, body copy, and selects approved generic target routes.',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, color: mutedColor),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _aiInstructionsController,
                  maxLines: 4,
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: primaryTextColor),
                  decoration: InputDecoration(
                    hintText: 'Enter AI prompt instructions...',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F1219) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
  
          // 4. Live AI Generator & Personalized Segmented Dispatch
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161922) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.bolt_fill, color: Color(0xFF3B82F6), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Personalized Audience Segregation & Live Preview',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
  
                // Target Audience Dropdown Selector
                Row(
                  children: [
                    Text(
                      '🎯 Segregated Audience Group:',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1219) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: DropdownButton<TargetAudience>(
                        value: _selectedAutoAudience,
                        underline: const SizedBox(),
                        dropdownColor: isDark ? const Color(0xFF1E2330) : Colors.white,
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, fontWeight: FontWeight.w700, color: primaryTextColor),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedAutoAudience = val;
                              _previewAiNotif = null; // reset preview
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: TargetAudience.allUsers,
                            child: Text('🌐 All Registered Users'),
                          ),
                          DropdownMenuItem(
                            value: TargetAudience.pgSeekers,
                            child: Text('🎓 PG & Hostel Seekers'),
                          ),
                          DropdownMenuItem(
                            value: TargetAudience.roomSeekers,
                            child: Text('🏡 Room & Flat Seekers'),
                          ),
                          DropdownMenuItem(
                            value: TargetAudience.buyers,
                            child: Text('🔑 Property Buyers'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
  
                // Action Buttons Row
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isGeneratingAiNotif ? null : _generateAiNotificationPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      icon: _isGeneratingAiNotif
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(CupertinoIcons.device_laptop, size: 16),
                      label: Text(
                        '⚡ Generate AI Preview',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: (_previewAiNotif == null || _isDispatchingAutoNotif)
                          ? null
                          : _sendTestAutoNotification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      icon: _isDispatchingAutoNotif
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(CupertinoIcons.paperplane_fill, size: 16),
                      label: Text(
                        '🚀 Dispatch to Selected Segment',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isDispatchingSmartSegments ? null : _dispatchSmartPersonalizedMultiSegments,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      icon: _isDispatchingSmartSegments
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(CupertinoIcons.wand_stars, size: 16),
                      label: Text(
                        '🎯 Auto-Dispatch All 3 Segments',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (_previewAiNotif != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1219) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _previewAiNotif!['title'] ?? '',
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Target: ${_previewAiNotif!['target_route']?.toUpperCase()}',
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _previewAiNotif!['body'] ?? '',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
  
                // Strict Constraints Callout Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCardElevated : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.info_circle_fill, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Constraint Enforced: AI is restricted to generic destination routes (pg, rental, ai_chat, posting, nearby, search). No specific property ID is ever linked.',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF92400E),
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



  Widget _buildNotificationComposerForm(bool isDark) {
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
  
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
                Text(
                  'Compose Broadcast Message',
                  style: TextStyle(fontFamily: 'ProximaNova', 
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
                Text(
                  'Instant Cloud Push',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, color: mutedColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
  
            // Quick Templates
            Text(
              'Quick Templates:',
              style: TextStyle(fontFamily: 'ProximaNova', 
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTemplatePill('🔥 Price Drop Alert', isDark),
                  const SizedBox(width: 6),
                  _buildTemplatePill('🏡 New Verified Listing', isDark),
                  const SizedBox(width: 6),
                  _buildTemplatePill('📢 Zero Brokerage Notice', isDark),
                  const SizedBox(width: 6),
                  _buildTemplatePill('⚡ High Demand in Area', isDark),
                ],
              ),
            ),
            const SizedBox(height: 14),
  
            // Target Audience Segment Selector
            Text(
              'Target Audience Segment',
              style: TextStyle(fontFamily: 'ProximaNova', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAudienceChip(
                    target: TargetAudience.allUsers,
                    label: 'All Users',
                    count: '$_allUsersCount',
                    icon: CupertinoIcons.person_3_fill,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildAudienceChip(
                    target: TargetAudience.pgSeekers,
                    label: 'PG Seekers',
                    count: '$_pgSeekersCount',
                    icon: CupertinoIcons.building_2_fill,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildAudienceChip(
                    target: TargetAudience.roomSeekers,
                    label: 'Room Seekers',
                    count: '$_roomSeekersCount',
                    icon: CupertinoIcons.house_fill,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildAudienceChip(
                    target: TargetAudience.buyers,
                    label: 'Buyers',
                    count: '$_buyersCount',
                    icon: CupertinoIcons.creditcard_fill,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildAudienceChip(
                    target: TargetAudience.landlords,
                    label: 'Landlords',
                    count: '$_landlordsCount',
                    icon: CupertinoIcons.building_2_fill,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
  
            // Notification Title
            Text(
              'Notification Title *',
              style: TextStyle(fontFamily: 'ProximaNova', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _notifTitleController,
                onChanged: (_) => setState(() {}),
                style: TextStyle(fontFamily: 'ProximaNova', 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. 🔥 Price drop on verified Danavaipeta flat!',
                  hintStyle: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, color: mutedColor.withValues(alpha: 0.7)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
  
            // Message Body
            Text(
              'Message Body *',
              style: TextStyle(fontFamily: 'ProximaNova', 
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _notifBodyController,
                onChanged: (_) => setState(() {}),
                maxLines: 3,
                style: TextStyle(fontFamily: 'ProximaNova', 
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Rent reduced by ₹2,000/mo. East-facing with car parking & zero brokerage. View listing now.',
                  hintStyle: TextStyle(fontFamily: 'ProximaNova', fontSize: 12.5, color: mutedColor.withValues(alpha: 0.7)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
  
            // Deep Link Routing Destination Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1E29) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(CupertinoIcons.link, size: 16, color: Color(0xFFFFEB3A)),
                      const SizedBox(width: 6),
                      Text(
                        'Deep-Link Destination (On Notification Tap)',
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
  
                  // Global Destination PopupMenuButton
                  PopupMenuButton<NotificationActionType>(
                    tooltip: 'Select Deep-Link Destination',
                    offset: const Offset(0, 44),
                    color: isDark ? const Color(0xFF1E2330) : Colors.white,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    initialValue: _selectedActionType,
                    onSelected: (val) => setState(() => _selectedActionType = val),
                    itemBuilder: (context) {
                      final options = [
                        {'type': NotificationActionType.property, 'label': 'Open Specific Property Details (Direct Listing)', 'icon': CupertinoIcons.building_2_fill},
                        {'type': NotificationActionType.category, 'label': 'Open Locality Filter (e.g. Danavaipeta)', 'icon': CupertinoIcons.location_solid},
                        {'type': NotificationActionType.postProperty, 'label': 'Open Post Property Screen (Prompt Owners)', 'icon': CupertinoIcons.add_circled},
                        {'type': NotificationActionType.buyAndSell, 'label': 'Open Buy & Sell Hub', 'icon': CupertinoIcons.tag_fill},
                        {'type': NotificationActionType.general, 'label': 'Open App Home Feed', 'icon': CupertinoIcons.house_fill},
                      ];
                      return options.map((opt) {
                        final isSelected = _selectedActionType == opt['type'];
                        return PopupMenuItem<NotificationActionType>(
                          value: opt['type'] as NotificationActionType,
                          height: 38,
                          child: Row(
                            children: [
                              Icon(
                                opt['icon'] as IconData,
                                size: 15,
                                color: isSelected ? AppTheme.primaryYellow : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  opt['label'] as String,
                                  style: TextStyle(fontFamily: 'ProximaNova', 
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppTheme.primaryYellow : primaryTextColor,
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
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161922) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedActionType == NotificationActionType.property
                                ? CupertinoIcons.building_2_fill
                                : (_selectedActionType == NotificationActionType.category
                                    ? CupertinoIcons.location_solid
                                    : (_selectedActionType == NotificationActionType.postProperty
                                        ? CupertinoIcons.add_circled
                                        : (_selectedActionType == NotificationActionType.buyAndSell ? CupertinoIcons.tag_fill : CupertinoIcons.house_fill))),
                            size: 16,
                            color: AppTheme.primaryYellow,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedActionType == NotificationActionType.property
                                  ? 'Open Specific Property Details (Direct Listing)'
                                  : (_selectedActionType == NotificationActionType.category
                                      ? 'Open Locality Filter (e.g. Danavaipeta)'
                                      : (_selectedActionType == NotificationActionType.postProperty
                                          ? 'Open Post Property Screen (Prompt Owners)'
                                          : (_selectedActionType == NotificationActionType.buyAndSell
                                              ? 'Open Buy & Sell Hub'
                                              : 'Open App Home Feed'))),
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(CupertinoIcons.chevron_down, size: 16, color: mutedColor),
                        ],
                      ),
                    ),
                  ),
  
                  if (_selectedActionType == NotificationActionType.property && _properties.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Select Target Property:',
                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryYellow),
                    ),
                    const SizedBox(height: 4),
                    PopupMenuButton<String>(
                      tooltip: 'Select Target Property',
                      offset: const Offset(0, 44),
                      color: isDark ? const Color(0xFF1E2330) : Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      initialValue: _selectedPropertyId ?? _properties.first.id,
                      onSelected: (val) => setState(() => _selectedPropertyId = val),
                      itemBuilder: (context) {
                        return _properties.take(25).map((prop) {
                          final propId = prop.id ?? '';
                          final isSelected = (_selectedPropertyId ?? _properties.first.id) == propId;
                          return PopupMenuItem<String>(
                            value: propId,
                            height: 40,
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.building_2_fill,
                                  size: 15,
                                  color: isSelected ? AppTheme.primaryYellow : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${prop.title} • ₹${prop.price} (${prop.locationStr.split(',').first})',
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppTheme.primaryYellow : primaryTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161922) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.building_2_fill, size: 16, color: Color(0xFFFFEB3A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final selectedProp = _properties.firstWhere(
                                    (p) => p.id == (_selectedPropertyId ?? _properties.first.id),
                                    orElse: () => _properties.first,
                                  );
                                  return Text(
                                    '${selectedProp.title} • ₹${selectedProp.price} (${selectedProp.locationStr.split(',').first})',
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryTextColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                            Icon(CupertinoIcons.chevron_down, size: 16, color: mutedColor),
                          ],
                        ),
                      ),
                    ),
                  ],
  
                  if (_selectedActionType == NotificationActionType.category ||
                      _selectedActionType == NotificationActionType.searchFilter) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Select Target Locality in Rajahmundry:',
                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w600, color: AppTheme.primaryYellow),
                    ),
                    const SizedBox(height: 4),
                    PopupMenuButton<String>(
                      tooltip: 'Select Locality',
                      offset: const Offset(0, 44),
                      color: isDark ? const Color(0xFF1E2330) : Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      initialValue: _selectedCategoryOrLocality ?? 'Danavaipeta',
                      onSelected: (val) => setState(() => _selectedCategoryOrLocality = val),
                      itemBuilder: (context) {
                        final locList = _actualPropertyLocations.isNotEmpty
                            ? _actualPropertyLocations
                            : _rajahmundryLocalities.map((e) => MapEntry(e, 0)).toList();
                        return locList.map((entry) {
                          final loc = entry.key;
                          final count = entry.value;
                          final isSelected = (_selectedCategoryOrLocality ?? 'Palacherla') == loc;
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    count > 0 ? '$loc ($count listings)' : loc,
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppTheme.primaryYellow : primaryTextColor,
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
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161922) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.location_solid, size: 16, color: Color(0xFFFFEB3A)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedCategoryOrLocality ?? 'Danavaipeta',
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            Icon(CupertinoIcons.chevron_down, size: 16, color: mutedColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
  
            // Blast Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _isSendingNotification ? null : _sendPushNotificationBroadcast,
                icon: _isSendingNotification
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(CupertinoIcons.paperplane_fill, size: 18),
                label: Text(
                  _isSendingNotification ? 'Broadcasting Push Notification...' : 'Blast Push Notification Now',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      );
    }



  Widget _buildTemplatePill(String template, bool isDark) {
      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          setState(() {
            _notifTitleController.text = template;
            if (template.contains('Price Drop')) {
              _notifBodyController.text = 'Price reduced by ₹2,000/mo on verified Danavaipeta flat. Call owner directly.';
            } else if (template.contains('New Verified')) {
              _notifBodyController.text = 'Brand new East-facing 2BHK flat available for immediate move-in. Zero brokerage.';
            } else {
              _notifBodyController.text = 'Post your property in Rajahmundry today and connect with 5,000+ verified tenants for free.';
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Text(
            template,
            style: TextStyle(fontFamily: 'ProximaNova', 
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ),
      );
    }

  Widget _buildNotificationLiveMockupAndHistory(bool isDark) {
      final title = _notifTitleController.text.isEmpty ? '🔥 New Property Alert!' : _notifTitleController.text;
      final body = _notifBodyController.text.isEmpty
          ? 'Spacious 2BHK flat in Danavaipeta available now for ₹14,000/mo. Zero broker fee.'
          : _notifBodyController.text;
      final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
      final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Realistic iPhone Lockscreen Preview Card
          Container(
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
                    Text(
                      '📱 Live Lockscreen Preview',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'REALTIME',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
  
                // Realistic Phone Enclosure
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // iPhone Top Status Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '9:41',
                            style: TextStyle(fontFamily: 'ProximaNova', color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                          // Dynamic Island Pill
                          Container(
                            width: 46,
                            height: 11,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(CupertinoIcons.antenna_radiowaves_left_right, color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Icon(CupertinoIcons.wifi, color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Icon(CupertinoIcons.battery_100, color: Colors.white, size: 12),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
  
                      // Lock Screen Date & Clock
                      Text(
                        'Friday, August 30',
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '9:41',
                        style: TextStyle(fontFamily: 'ProximaNova', 
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 18),
  
                      // Glassmorphic iOS Notification Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.house_fill, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RENTAL APP',
                                        style: TextStyle(fontFamily: 'ProximaNova', 
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      Text(
                                        'now',
                                        style: TextStyle(fontFamily: 'ProximaNova', color: Colors.white60, fontSize: 9.5),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    title,
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: TextStyle(fontFamily: 'ProximaNova', color: Colors.white.withValues(alpha: 0.85), fontSize: 11, height: 1.3),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
  
          // Recent Broadcast History
          Container(
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
                    Text(
                      'Recent Broadcasts',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                    ),
                    Text(
                      'Last 5 blasts',
                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_broadcastHistory.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text(
                        'No past broadcasts recorded yet.',
                        style: TextStyle(fontFamily: 'ProximaNova', color: mutedColor, fontSize: 12),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _broadcastHistory.take(4).length,
                    separatorBuilder: (_, __) => const Divider(height: 14),
                    itemBuilder: (context, idx) {
                      final item = _broadcastHistory[idx];
                      return Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(CupertinoIcons.bell_fill, size: 14, color: Color(0xFF8B5CF6)),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(fontFamily: 'ProximaNova', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: primaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.recipientCount} sent  •  ${item.actionDisplayName}',
                                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10.5, color: mutedColor),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() {
                                _notifTitleController.text = item.title;
                                _notifBodyController.text = item.body;
                                _selectedActionType = item.actionType;
                                if (item.targetRouteOrId != null) {
                                  _selectedPropertyId = item.targetRouteOrId;
                                }
                              });
                              AppSnackbar.success(context, '📋 Loaded broadcast template');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Reuse',
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryYellow,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      );
    }

}
