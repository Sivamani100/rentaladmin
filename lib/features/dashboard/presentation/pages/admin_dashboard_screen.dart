import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_frame/device_frame.dart';
import 'package:rental_admin/core/widgets/app_snackbar.dart';
import 'package:rental_admin/app/theme/app_theme.dart';
import 'package:rental_admin/app/theme/theme_provider.dart';
import 'package:rental_admin/core/services/notification_broadcast_service.dart';
import 'package:rental_admin/core/services/ai_auto_notifier_service.dart';
import 'package:rental/core/models/property_model.dart';

import 'package:rental/features/property_posting/presentation/pages/posting_screen.dart';
import 'package:rental/features/property_details/presentation/pages/property_details_screen.dart';
import 'package:rental_admin/features/dashboard/presentation/pages/admin_database_analytics_tab.dart';

import 'package:rental/features/home/presentation/pages/home_screen.dart';

part 'admin_dashboard_notifications_ext.dart';
part 'admin_dashboard_overview_ext.dart';
part 'admin_dashboard_analytics_ext.dart';
part 'admin_dashboard_users_ext.dart';
part 'admin_dashboard_properties_ext.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _supabase = Supabase.instance.client;
  final GlobalKey<NavigatorState> _previewNavigatorKey = GlobalKey<NavigatorState>();

  // Authenticated Admin User Details
  String get _adminEmail => _supabase.auth.currentUser?.email ?? 'Admin';

  String get _adminDisplayName {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'Administrator';
    final meta = user.userMetadata;
    if (meta != null) {
      final name = meta['full_name'] ?? meta['name'] ?? meta['display_name'];
      if (name != null && name.toString().trim().isNotEmpty) return name.toString().trim();
    }
    if (user.email != null && user.email!.contains('@')) {
      final handle = user.email!.split('@').first;
      final parts = handle.replaceAll('.', ' ').replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
      final formatted = parts.where((s) => s.isNotEmpty).map((s) => '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}').join(' ').trim();
      if (formatted.isNotEmpty) return formatted;
    }
    return 'Admin';
  }

  String? get _adminAvatarUrl {
    final user = _supabase.auth.currentUser;
    final meta = user?.userMetadata;
    if (meta != null) {
      final avatar = meta['avatar_url'] ?? meta['picture'] ?? meta['photo_url'];
      if (avatar != null && avatar.toString().trim().isNotEmpty) return avatar.toString().trim();
    }
    return null;
  }

  String get _adminInitial {
    final name = _adminDisplayName;
    if (name.isNotEmpty) return name[0].toUpperCase();
    final email = _adminEmail;
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'A';
  }

  // Navigation State
  // 0: Overview, 1: Properties, 2: Analytics & Click Radar, 3: Push Notifications, 4: Users, 5: Banners, 6: Settings
  int _selectedTabIndex = 0;
  bool _isSidebarCollapsed = false;

  // Live Device User App Preview on Right Side
  bool _showLiveUserAppPreview = false;
  bool _previewDarkMode = false;
  int _previewKeyIndex = 0;
  double? _previewPanelWidth;
  int _selectedDeviceIndex = 0; // Default: iPhone 13 Pro Max
  bool _isFrameVisible = true;
  Orientation _previewOrientation = Orientation.portrait;

  static final List<({String name, String category, DeviceInfo device, IconData icon})> _availableDevices = [
    (
      name: 'iPhone 13 Pro Max',
      category: 'iOS',
      device: Devices.ios.iPhone13ProMax,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'iPhone 13',
      category: 'iOS',
      device: Devices.ios.iPhone13,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'iPhone 13 Mini',
      category: 'iOS',
      device: Devices.ios.iPhone13Mini,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'iPhone SE',
      category: 'iOS',
      device: Devices.ios.iPhoneSE,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'Samsung Galaxy S20',
      category: 'Android',
      device: Devices.android.samsungGalaxyS20,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'Samsung Note 20 Ultra',
      category: 'Android',
      device: Devices.android.samsungGalaxyNote20Ultra,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'OnePlus 8 Pro',
      category: 'Android',
      device: Devices.android.onePlus8Pro,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'Samsung Galaxy A50',
      category: 'Android',
      device: Devices.android.samsungGalaxyA50,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'Sony Xperia 1 II',
      category: 'Android',
      device: Devices.android.sonyXperia1II,
      icon: CupertinoIcons.device_phone_portrait,
    ),
    (
      name: 'iPad Pro 11"',
      category: 'Tablet',
      device: Devices.ios.iPadPro11Inches,
      icon: CupertinoIcons.device_laptop,
    ),
    (
      name: 'iPad Air 4',
      category: 'Tablet',
      device: Devices.ios.iPadAir4,
      icon: CupertinoIcons.device_laptop,
    ),
  ];

  // Data State
  List<PropertyModel> _properties = [];
  bool _isLoadingProperties = true;
  String _propertySearchQuery = '';
  String _statusFilter = 'all'; // all, pending, approved, occupied, rejected, pending_photos
  String _typeFilter = 'all'; // all, Rental, PG, Sale, Commercial
  String _localityFilter = 'all';

  // Push Notification Composer State
  final _notifTitleController = TextEditingController(text: '🔥 New Verified Rental in Danavaipeta!');
  final _notifBodyController = TextEditingController(
    text: 'Spacious East-facing 2BHK flat with 100% Vastu and 24/7 Godavari water. Zero broker fee.',
  );
  final _notifImageController = TextEditingController();
  TargetAudience _selectedAudience = TargetAudience.allUsers;
  NotificationActionType _selectedActionType = NotificationActionType.property;
  String? _selectedPropertyId;
  String? _selectedCategoryOrLocality = 'Danavaipeta';
  final _customUrlController = TextEditingController();
  final bool _isHighPriority = true;
  bool _isSendingNotification = false;
  List<BroadcastNotificationModel> _broadcastHistory = [];

  // AI Auto-Notifier State (8 AM, 1 PM, 6 PM IST)
  int _notificationSubTabIndex = 0; // 0: Manual Broadcast, 1: AI Auto-Notifier
  AutoNotifierSettings? _autoNotifierSettings;
  bool _isLoadingAutoSettings = false;
  bool _isSavingAutoSettings = false;
  bool _isGeneratingAiNotif = false;
  bool _isDispatchingAutoNotif = false;
  TargetAudience _selectedAutoAudience = TargetAudience.allUsers;
  bool _isDispatchingSmartSegments = false;
  final _aiInstructionsController = TextEditingController();
  Map<String, String>? _previewAiNotif;

  // Rajamahendravaram Key Localities (Mutable List)
  late List<String> _rajahmundryLocalities = [
    'Danavaipeta',
    'Morampudi',
    'Prakash Nagar',
    'VL Puram',
    'Kotipalli Bus Stand',
    'Aryapuram',
    'T Nagar',
    'Hukumpeta',
    'Diwancheruvu',
    'Bommuru',
    'Lalitha Nagar',
    'Innespeta',
    'Kambala Cheruvu',
    'Dowleswaram',
  ];




  // Top Trending Search Terms in Multi-City Hubs
  final List<Map<String, dynamic>> _trendingSearchTerms = const [
    {'query': '2BHK Danavaipeta with Car Parking', 'count': 840, 'growth': '+24%'},
    {'query': 'Boys PG near Godavari Institute / GIET', 'count': 620, 'growth': '+38%'},
    {'query': 'Single Room with Attached Bath Morampudi', 'count': 510, 'growth': '+15%'},
    {'query': 'Independent House for Sale Prakash Nagar', 'count': 430, 'growth': '+12%'},
    {'query': 'Girls Hostel with Food VL Puram', 'count': 390, 'growth': '+19%'},
    {'query': 'Commercial Shop Main Road Kotipalli', 'count': 280, 'growth': '+8%'},
  ];

  int _allUsersCount = 0;
  int _pgSeekersCount = 0;
  int _roomSeekersCount = 0;
  int _buyersCount = 0;
  int _landlordsCount = 0;

  Map<String, dynamic>? _demandRadarData;
  List<PropertyModel> _topViewedProperties = [];
  List<Map<String, dynamic>> _userReports = [];
  bool _isLoadingUserReports = false;

  Future<void> _fetchUserReports() async {
    setState(() => _isLoadingUserReports = true);
    try {
      final res = await _supabase.from('listing_reports').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _userReports = List<Map<String, dynamic>>.from(res);
          _isLoadingUserReports = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user reports: $e');
      if (mounted) setState(() => _isLoadingUserReports = false);
    }
  }

  Future<void> _fetchDemandRadarData() async {
    try {
      final response = await _supabase.rpc('get_demand_radar_data');
      if (mounted) {
        setState(() {
          _demandRadarData = response as Map<String, dynamic>;
        });
        _matchTopProperties();
      }
    } catch (e) {
      debugPrint('Error fetching demand radar data: $e');
    }
  }

  void _matchTopProperties() {
    if (_demandRadarData == null || _properties.isEmpty) return;
    
    final topProps = _demandRadarData!['top_properties'] as List;
    final List<PropertyModel> matched = [];
    
    for (var tp in topProps) {
      final pid = tp['property_id'];
      try {
        final prop = _properties.firstWhere((p) => p.id == pid);
        matched.add(prop);
      } catch (_) {}
    }
    
    setState(() {
      _topViewedProperties = matched;
    });
  }

  Future<void> _fetchAudienceCounts() async {
    try {
      final allData = await _supabase.rpc('get_segmented_fcm_tokens', params: {'target_audience': 'allUsers'});
      final pgData = await _supabase.rpc('get_segmented_fcm_tokens', params: {'target_audience': 'pgSeekers'});
      final roomData = await _supabase.rpc('get_segmented_fcm_tokens', params: {'target_audience': 'roomSeekers'});
      final buyerData = await _supabase.rpc('get_segmented_fcm_tokens', params: {'target_audience': 'buyers'});
      
      if (mounted) {
        setState(() {
          _allUsersCount = (allData as List).length;
          _pgSeekersCount = (pgData as List).length;
          _roomSeekersCount = (roomData as List).length;
          _buyersCount = (buyerData as List).length;
          _landlordsCount = _properties.where((p) => p.ownerPhone.isNotEmpty).map((p) => p.ownerPhone).toSet().length; 
        });
      }
    } catch (e) {
      debugPrint('Error fetching audience counts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // SECURITY: Verify admin session before loading any data.
    // If the session has expired or been revoked, redirect to login.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        Navigator.of(context).pushReplacementNamed('/admin/login');
        return;
      }
      _fetchProperties();
      _fetchNotificationHistory();
      _fetchAudienceCounts();
      _fetchDemandRadarData();
      _fetchAutoNotifierSettings();
      _fetchUserReports();
    });
  }

  @override
  void dispose() {
    _notifTitleController.dispose();
    _notifBodyController.dispose();
    _notifImageController.dispose();
    _customUrlController.dispose();
    _aiInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _fetchAutoNotifierSettings() async {
    setState(() => _isLoadingAutoSettings = true);
    final settings = await AiAutoNotifierService.instance.fetchSettings();
    AiAutoNotifierService.instance.startPeriodicSchedulerTimer();
    if (mounted) {
      setState(() {
        _autoNotifierSettings = settings;
        if (_aiInstructionsController.text.isEmpty) {
          _aiInstructionsController.text = settings?.aiInstructions ?? '';
        }
        _isLoadingAutoSettings = false;
      });
    }
  }

  Future<void> _toggleAutoNotifier(bool enabled) async {
    setState(() => _isSavingAutoSettings = true);
    final success = await AiAutoNotifierService.instance.updateSettings(isEnabled: enabled);
    if (mounted) {
      setState(() => _isSavingAutoSettings = false);
      if (success) {
        AppSnackbar.success(
          context,
          enabled ? '🟢 AI Auto-Notifier ENABLED (8 AM, 1 PM, 6 PM IST)' : '🔴 AI Auto-Notifier PAUSED',
        );
        _fetchAutoNotifierSettings();
      } else {
        AppSnackbar.error(context, 'Failed to update auto-notifier status.');
      }
    }
  }

  Future<void> _saveAiInstructions() async {
    final text = _aiInstructionsController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSavingAutoSettings = true);
    final success = await AiAutoNotifierService.instance.updateSettings(aiInstructions: text);
    if (mounted) {
      setState(() => _isSavingAutoSettings = false);
      if (success) {
        AppSnackbar.success(context, 'AI Notification Guidelines updated!');
        _fetchAutoNotifierSettings();
      } else {
        AppSnackbar.error(context, 'Failed to save AI guidelines.');
      }
    }
  }

  Future<void> _generateAiNotificationPreview() async {
    setState(() => _isGeneratingAiNotif = true);
    final result = await AiAutoNotifierService.instance.generateAiNotification(
      customPrompt: _aiInstructionsController.text.trim(),
      targetAudience: _selectedAutoAudience,
    );
    if (mounted) {
      setState(() {
        _previewAiNotif = result;
        _isGeneratingAiNotif = false;
      });
      if (result != null) {
        AppSnackbar.success(
          context,
          'AI generated personalized content for ${_selectedAutoAudience.name}!',
        );
      } else {
        AppSnackbar.error(context, 'Failed to generate AI notification.');
      }
    }
  }

  Future<void> _sendTestAutoNotification() async {
    if (_previewAiNotif == null) {
      await _generateAiNotificationPreview();
    }
    if (_previewAiNotif == null) return;

    setState(() => _isDispatchingAutoNotif = true);
    final success = await AiAutoNotifierService.instance.dispatchAutoNotification(
      title: _previewAiNotif!['title']!,
      body: _previewAiNotif!['body']!,
      targetRoute: _previewAiNotif!['target_route']!,
      targetAudience: _selectedAutoAudience,
    );
    if (mounted) {
      setState(() => _isDispatchingAutoNotif = false);
      if (success) {
        AppSnackbar.success(
          context,
          '🚀 AI Notification dispatched live to ${_selectedAutoAudience.name}!',
        );
        _fetchNotificationHistory();
      } else {
        AppSnackbar.error(context, 'Failed to dispatch notification.');
      }
    }
  }

  Future<void> _dispatchSmartPersonalizedMultiSegments() async {
    setState(() => _isDispatchingSmartSegments = true);
    final results = await AiAutoNotifierService.instance.dispatchPersonalizedMultiSegmentNotifications();
    if (mounted) {
      setState(() => _isDispatchingSmartSegments = false);
      final successfulCount = results.values.where((v) => v).length;
      AppSnackbar.success(
        context,
        '🎯 Dispatched personalized AI notifications to $successfulCount/3 segregated audience groups (PG Seekers, Room Seekers, Buyers)!',
      );
      _fetchNotificationHistory();
    }
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() => _isLoadingProperties = true);
    try {
      final data = await _supabase.from('properties').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _properties = (data as List).map((e) => PropertyModel.fromJson(e as Map<String, dynamic>)).toList();
          _isLoadingProperties = false;
          if (_properties.isNotEmpty && _selectedPropertyId == null) {
            _selectedPropertyId = _properties.first.id;
          }
        });
        _matchTopProperties();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to fetch listings: $e');
        setState(() => _isLoadingProperties = false);
      }
    }
  }

  Future<void> _fetchNotificationHistory() async {
    try {
      final history = await NotificationBroadcastService.instance.getHistory();
      if (mounted) {
        setState(() => _broadcastHistory = history);
      }
    } catch (_) {}
  }



  Future<void> _batchApproveAllPending() async {
    final pendingList = _properties.where((p) => p.status == 'pending').toList();
    if (pendingList.isEmpty) {
      AppSnackbar.success(context, 'No pending listings to approve.');
      return;
    }

    // SECURITY: Require explicit confirmation before bulk approving all listings
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batch Approve All?'),
        content: Text(
          'This will approve all ${pendingList.length} pending listing(s) and make them immediately visible to all users.\n\nAre you sure you have reviewed each listing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Approve All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final p in pendingList) {
        if (p.id != null) {
          await _supabase.from('properties').update({'status': 'approved'}).eq('id', p.id!);
        }
      }
      if (mounted) {
        AppSnackbar.success(context, '✅ Approved all ${pendingList.length} pending listings live!');
        _fetchProperties();
      }
    } catch (e) {
      if (mounted) AppSnackbar.error(context, 'Batch approval error: $e');
    }
  }

  Future<void> _toggleAvailability(String id, bool currentStatus) async {
    try {
      await _supabase.from('properties').update({'is_available': !currentStatus}).eq('id', id);
      if (mounted) {
        AppSnackbar.success(
          context,
          !currentStatus ? 'Marked as Available (Vacant)' : 'Marked as Occupied (Full / Sold)',
        );
        _fetchProperties();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to update occupancy: $e');
      }
    }
  }

  

  void _contactOwnerWhatsApp(String phone, String title) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse(
      'https://wa.me/91$cleanPhone?text=Hi%2C%20regarding%20your%20property%20listing%20%22${Uri.encodeComponent(title)}%22%20on%20Rental%20App%20Rajahmundry...',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) AppSnackbar.error(context, 'WhatsApp not available for $phone');
    }
  }

  void _exportPropertiesCSV() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Type,Price,Deposit,Location,Owner Phone,Status,Occupancy');
    for (final p in _properties) {
      buffer.writeln(
        '"${p.id ?? ''}","${p.title.replaceAll('"', '""')}","${p.type}","${p.price}","${p.securityDeposit ?? ''}","${p.locationStr.replaceAll('"', '""')}","${p.ownerPhone}","${p.status}","${p.isAvailable ? 'Available' : 'Occupied'}"',
      );
    }
    AppSnackbar.success(context, '📊 Exported ${_properties.length} listings to CSV buffer!');
  }

  Future<void> _sendPushNotificationBroadcast() async {
    final title = _notifTitleController.text.trim();
    final body = _notifBodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      AppSnackbar.error(context, 'Please provide both notification title and message body');
      return;
    }

    setState(() => _isSendingNotification = true);

    String? targetRouteOrId;
    String? targetLabel;

    switch (_selectedActionType) {
      case NotificationActionType.property:
        targetRouteOrId = _selectedPropertyId;
        final selectedProp = _properties.where((p) => p.id == _selectedPropertyId).firstOrNull;
        targetLabel = selectedProp?.title ?? 'Listing';
        break;
      case NotificationActionType.category:
      case NotificationActionType.searchFilter:
        targetRouteOrId = _selectedCategoryOrLocality;
        targetLabel = _selectedCategoryOrLocality;
        break;
      case NotificationActionType.postProperty:
        targetLabel = 'Post Property';
        break;
      case NotificationActionType.buyAndSell:
        targetLabel = 'Buy & Sell Hub';
        break;
      case NotificationActionType.externalUrl:
        targetRouteOrId = _customUrlController.text.trim();
        targetLabel = targetRouteOrId;
        break;
      case NotificationActionType.general:
        targetLabel = 'App Home';
        break;
    }

    int actualRecipientCount = 0;
    try {
      if (_selectedAudience == TargetAudience.allUsers) {
        final response = await Supabase.instance.client.from('devices').select('device_id').count(CountOption.exact);
        actualRecipientCount = response.count ?? 0;
      } else {
        final response = await Supabase.instance.client.rpc('get_segmented_fcm_tokens', params: {'target_audience': _selectedAudience.name});
        actualRecipientCount = (response as List).length;
      }
    } catch (e) {
      actualRecipientCount = 0;
    }

    final newNotif = BroadcastNotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      imageUrl: _notifImageController.text.trim().isNotEmpty ? _notifImageController.text.trim() : null,
      targetAudience: _selectedAudience,
      actionType: _selectedActionType,
      targetRouteOrId: targetRouteOrId,
      targetLabel: targetLabel,
      isHighPriority: _isHighPriority,
      createdAt: DateTime.now(),
      recipientCount: actualRecipientCount,
      status: 'sent',
    );

    await NotificationBroadcastService.instance.sendBroadcast(newNotif);
    await _fetchNotificationHistory();

    if (mounted) {
      setState(() => _isSendingNotification = false);
      AppSnackbar.success(
        context,
        '🚀 Push Notification successfully broadcasted to ${newNotif.recipientCount} users in Rajamahendravaram!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 950;

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
          trackVisibility: WidgetStateProperty.all(false),
          thickness: WidgetStateProperty.all(5.0),
          radius: const Radius.circular(8.0),
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.dragged) || states.contains(WidgetState.hovered)) {
              return isDark ? Colors.white38 : const Color(0xFF94A3B8);
            }
            return isDark ? Colors.white12 : const Color(0xFFCBD5E1).withValues(alpha: 0.7);
          }),
        ),
      ),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          scrollbars: true,
          overscroll: false,
        ),
        child: Scaffold(
          backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6F9),
          body: isDesktop ? _buildDesktopLayout(isDark) : _buildMobileTabletLayout(isDark),
        ),
      ),
    );
  }

  // ==========================================
  // DESKTOP LAPTOP LAYOUT WITH EMBEDDED IPHONE PREVIEW
  // ==========================================
  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        _buildSidebar(isDark),
        Expanded(
          child: Column(
            children: [
              _buildTopHeader(isDark),
              Expanded(
                child: Container(
                  color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6F9),
                  child: _buildActiveTabContent(isDark),
                ),
              ),
            ],
          ),
        ),

        // Right-Side Live iPhone 16 Pro User App Preview (Full Height)
        if (_showLiveUserAppPreview)
          _buildLiveUserAppSidePanel(isDark),
      ],
    );
  }

  // ==========================================
  // LIVE DEVICE USER APP SIDE PANEL WIDGET
  // ==========================================
  Widget _buildLiveUserAppSidePanel(bool isDark) {
    final activeDevice = _availableDevices[_selectedDeviceIndex];
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Available vertical space for the phone frame inside the container (minus 58px bar and 16px padding)
    final availableHeightForPhone = (screenHeight - 58.0 - 16.0).clamp(200.0, 2400.0);

    // Calculate the phone frame's physical aspect ratio (width / height)
    final dWidth = _isFrameVisible
        ? activeDevice.device.screenSize.width + 36.0
        : activeDevice.device.screenSize.width;
    final dHeight = _isFrameVisible
        ? activeDevice.device.screenSize.height + 36.0
        : activeDevice.device.screenSize.height;

    double ratio = dWidth / dHeight;
    if (_previewOrientation == Orientation.landscape) {
      ratio = 1.0 / ratio;
    }

    // Pixel-perfect fitted width matching the exact scaled phone frame with snug 8px side margin
    final fittedPhoneWidth = (availableHeightForPhone * ratio) + 16.0;

    // Use fitted snug width with safe minimum 380px (or user-adjusted width)
    final effectiveWidth = (_previewPanelWidth ?? fittedPhoneWidth).clamp(380.0, screenWidth * 0.75);

    return Container(
      width: effectiveWidth,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13161F) : const Color(0xFFEEF2F6),
        border: Border(
          left: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          // Control Bar (Height: 58px)
          Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1E29) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                // Dynamic Phone Frame Selector Dropdown
                PopupMenuButton<int>(
                  tooltip: 'Select Phone Device Frame',
                  offset: const Offset(0, 48),
                      color: isDark ? const Color(0xFF1E2330) : Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                        ),
                      ),
                      initialValue: _selectedDeviceIndex,
                      onSelected: (index) {
                        setState(() {
                          _selectedDeviceIndex = index;
                          _previewPanelWidth = null; // Auto-fit to selected device's exact aspect ratio
                        });
                        AppSnackbar.success(
                          context,
                          '📱 Switched to ${_availableDevices[index].name}',
                        );
                      },
                      itemBuilder: (context) {
                        return _availableDevices.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final dev = entry.value;
                          final isSelected = idx == _selectedDeviceIndex;
                          return PopupMenuItem<int>(
                            value: idx,
                            height: 38,
                            child: Row(
                              children: [
                                Icon(
                                  dev.icon,
                                  size: 16,
                                  color: isSelected
                                      ? AppTheme.primaryYellow
                                      : (isDark ? Colors.white70 : Colors.black87),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    dev.name,
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? AppTheme.primaryYellow
                                          : (isDark ? Colors.white : Colors.black87),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    dev.category,
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 6),
                                  const Icon(CupertinoIcons.checkmark_alt, size: 14, color: Color(0xFFFFEB3A)),
                                ],
                              ],
                            ),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252B3B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activeDevice.icon,
                              size: 14,
                              color: AppTheme.primaryYellow,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              activeDevice.name,
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.chevron_down,
                              size: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Toggle Device Frame Bezel
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: Icon(
                        _isFrameVisible ? CupertinoIcons.crop : CupertinoIcons.crop,
                        size: 15,
                        color: _isFrameVisible
                            ? AppTheme.primaryYellow
                            : (isDark ? Colors.white60 : Colors.black45),
                      ),
                      tooltip: _isFrameVisible ? 'Hide Phone Frame Shell' : 'Show Phone Frame Shell',
                      onPressed: () {
                        setState(() {
                          _isFrameVisible = !_isFrameVisible;
                          _previewPanelWidth = null; // Auto-fit to bezel state
                        });
                      },
                    ),
                    const SizedBox(width: 3),

                    // Rotate Orientation (Portrait / Landscape)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: Icon(
                        CupertinoIcons.rotate_right,
                        size: 15,
                        color: _previewOrientation == Orientation.landscape
                            ? AppTheme.primaryYellow
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      tooltip: 'Rotate Portrait / Landscape',
                      onPressed: () {
                        setState(() {
                          _previewOrientation = _previewOrientation == Orientation.portrait
                              ? Orientation.landscape
                              : Orientation.portrait;
                          _previewPanelWidth = null; // Auto-fit to orientation
                        });
                      },
                    ),
                    const SizedBox(width: 3),

                    // Device Theme Toggle
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: Icon(
                        _previewDarkMode ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
                        size: 15,
                        color: _previewDarkMode ? Colors.amber : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      tooltip: 'Toggle App Dark/Light Mode',
                      onPressed: () => setState(() => _previewDarkMode = !_previewDarkMode),
                    ),
                    const SizedBox(width: 3),

                    // Reload Device State
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: Icon(CupertinoIcons.refresh_thick, size: 16, color: isDark ? Colors.white70 : Colors.black87),
                      tooltip: 'Restart & Reload Preview',
                      onPressed: () {
                        setState(() => _previewKeyIndex++);
                        AppSnackbar.success(context, '🔄 ${activeDevice.name} preview reloaded!');
                      },
                    ),
                    const SizedBox(width: 3),

                    // Close Side Preview Button
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: const Icon(CupertinoIcons.clear, size: 16),
                      tooltip: 'Close Live Preview Panel',
                      onPressed: () => setState(() => _showLiveUserAppPreview = false),
                    ),
                  ],
                ),
              ),

              // Embedded Device Frame running REAL User App with uniform margins
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: DeviceFrame(
                      device: activeDevice.device,
                      isFrameVisible: _isFrameVisible,
                      orientation: _previewOrientation,
                      screen: Container(
                        color: _previewDarkMode ? AppTheme.darkScaffold : Colors.white,
                        child: MaterialApp(
                          navigatorKey: _previewNavigatorKey,
                          debugShowCheckedModeBanner: false,
                          theme: AppTheme.lightTheme,
                          darkTheme: AppTheme.darkTheme,
                          themeMode: _previewDarkMode ? ThemeMode.dark : ThemeMode.light,
                          home: HomeScreen(
                            key: ValueKey('preview_home_$_previewKeyIndex'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
  }

  // ==========================================
  // MOBILE / TABLET LAYOUT
  // ==========================================
  Widget _buildMobileTabletLayout(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 26, height: 26, errorBuilder: (_, __, ___) => const Icon(CupertinoIcons.building_2_fill)),
            const SizedBox(width: 8),
            Text(
              'Admin Portal',
              style: TextStyle(fontFamily: 'ProximaNova', 
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.refresh_thick, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              _fetchProperties();
              _fetchNotificationHistory();
            },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        child: _buildSidebarContent(isDark, isDrawer: true),
      ),
      body: _buildActiveTabContent(isDark),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex.clamp(0, 3),
        onDestinationSelected: (idx) => setState(() => _selectedTabIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(CupertinoIcons.square_grid_2x2_fill), label: 'Overview'),
          NavigationDestination(icon: Icon(CupertinoIcons.building_2_fill), label: 'Properties'),
          NavigationDestination(icon: Icon(CupertinoIcons.chart_bar_alt_fill), label: 'Radar'),
          NavigationDestination(icon: Icon(CupertinoIcons.bell_fill), label: 'Broadcasts'),
        ],
      ),
    );
  }

  // ==========================================
  // SIDEBAR NAVIGATION (MATCHING REFERENCE DESIGN)
  // ==========================================
  Widget _buildSidebar(bool isDark) {
    final isCollapsed = _isSidebarCollapsed || _showLiveUserAppPreview;
    final width = isCollapsed ? 68.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : const Color(0xFFFAFAFA),
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFEAEAEA),
            width: 1,
          ),
        ),
      ),
      child: _buildSidebarContent(isDark, isDrawer: false),
    );
  }

  Widget _buildSidebarContent(bool isDark, {required bool isDrawer}) {
    final pendingCount = _properties.where((p) => p.status == 'pending').length;
    final isCollapsed = (_isSidebarCollapsed || _showLiveUserAppPreview) && !isDrawer;
    final mutedColor = isDark ? const Color(0xFF8B94A5) : const Color(0xFF64748B);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),

        // 1. Workspace Brand Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: isCollapsed
              ? Center(
                  child: Tooltip(
                    message: 'Rental App Command Center',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              CupertinoIcons.house_fill,
                              color: isDark ? Colors.black : Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    AppSnackbar.success(context, '📍 Rental Platform Operations Center');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(
                              'assets/logo.png',
                              width: 22,
                              height: 22,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                CupertinoIcons.house_fill,
                                color: isDark ? Colors.black : Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'RENTAL APP',
                          style: TextStyle(fontFamily: 'ProximaNova', 
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor,
                            letterSpacing: 0.4,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: mutedColor,
                      ),
                    ],
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // 2. Top Quick Utilities (Search, Notification, Settings)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUtilityAction(
                icon: CupertinoIcons.search,
                label: 'Search',
                isCollapsed: isCollapsed,
                isDark: isDark,
                onTap: () {
                  setState(() => _selectedTabIndex = 1);
                },
              ),
              const SizedBox(height: 4),
              _buildUtilityAction(
                icon: CupertinoIcons.bell_fill,
                label: 'Notification',
                badgeCount: pendingCount > 0 ? pendingCount : null,
                isCollapsed: isCollapsed,
                isDark: isDark,
                onTap: () {
                  setState(() => _selectedTabIndex = 3);
                },
              ),

            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. Section Label: MENU
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: isCollapsed
              ? SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      'MENU',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: mutedColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 4),
                  child: Text(
                    'MENU',
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: mutedColor.withValues(alpha: 0.8),
                    ),
                  ),
                ),
        ),

        // 4. Main Navigation Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _buildModernSidebarItem(
                index: 0,
                icon: CupertinoIcons.house_fill,
                label: 'Dashboard',
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),
              const SizedBox(height: 4),
              _buildModernSidebarItem(
                index: 1,
                icon: CupertinoIcons.building_2_fill,
                label: 'Property Approvals',
                badgeCount: pendingCount > 0 ? pendingCount : null,
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),
              const SizedBox(height: 4),
              _buildModernSidebarItem(
                index: 2,
                icon: CupertinoIcons.chart_bar_alt_fill,
                label: 'Demand Radar',
                isHighlight: true,
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),
              const SizedBox(height: 4),
              _buildModernSidebarItem(
                index: 3,
                icon: CupertinoIcons.bell_fill,
                label: 'Push Broadcasts',
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),
              const SizedBox(height: 4),
              _buildModernSidebarItem(
                index: 4,
                icon: CupertinoIcons.person_3_fill,
                label: 'Landlords & Users',
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),

              const SizedBox(height: 4),

              _buildModernSidebarItem(
                index: 5,
                icon: CupertinoIcons.flag_fill,
                label: 'User Reports',
                badgeCount: _userReports.where((r) => r['status'] == 'pending').length > 0
                    ? _userReports.where((r) => r['status'] == 'pending').length
                    : null,
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),

              const SizedBox(height: 4),

              _buildModernSidebarItem(
                index: 7,
                icon: CupertinoIcons.chart_bar_fill,
                label: 'Database & Storage',
                isCollapsed: isCollapsed,
                isDark: isDark,
                isDrawer: isDrawer,
              ),
              const SizedBox(height: 4),

            ],
          ),
        ),

        // 5. Bottom Controls (Theme Pill + Sidebar Toggle + User Profile)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: isCollapsed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Collapsed Theme Toggle (Square)
                    Tooltip(
                      message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => ThemeController.instance.toggleTheme(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                                size: 19,
                                color: isDark ? Colors.amber : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Collapsed Sidebar Open Toggle (Square)
                    Tooltip(
                      message: 'Sidebar Open ⌘>',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => setState(() => _isSidebarCollapsed = false),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.sidebar_right,
                                size: 19,
                                color: isDark ? Colors.white70 : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    // Light / Dark Theme Pill Switch
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (isDark) ThemeController.instance.toggleTheme();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: !isDark ? Colors.white : Colors.transparent,
                                shape: BoxShape.circle,
                                boxShadow: !isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                CupertinoIcons.sun_max,
                                size: 14,
                                color: !isDark ? Colors.black87 : Colors.white54,
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (!isDark) ThemeController.instance.toggleTheme();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2E3748) : Colors.transparent,
                                shape: BoxShape.circle,
                                boxShadow: isDark
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                CupertinoIcons.moon,
                                size: 14,
                                color: isDark ? Colors.amber : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Close Sidebar Toggle
                    Tooltip(
                      message: 'Close Sidebar ⌘<',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _isSidebarCollapsed = true),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.sidebar_left,
                            size: 16,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        Divider(
          height: 1,
          thickness: 1,
          color: isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFEAEAEA),
        ),

        // 6. User Profile Section (Real Authenticated Admin)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: isCollapsed
              ? Center(
                  child: PopupMenuButton<String>(
                    tooltip: '$_adminDisplayName (${_adminEmail})',
                    offset: const Offset(40, -40),
                    color: isDark ? const Color(0xFF1E2330) : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onSelected: (val) {
                      if (val == 'logout') _handleLogout();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _adminDisplayName,
                              style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              _adminEmail,
                              style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent, size: 16),
                            SizedBox(width: 8),
                            Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryYellow,
                        backgroundImage: _adminAvatarUrl != null ? CachedNetworkImageProvider(_adminAvatarUrl!) : null,
                        child: _adminAvatarUrl == null
                            ? Text(
                                _adminInitial,
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryYellow,
                          backgroundImage: _adminAvatarUrl != null ? CachedNetworkImageProvider(_adminAvatarUrl!) : null,
                          child: _adminAvatarUrl == null
                              ? Text(
                                  _adminInitial,
                                  style: TextStyle(fontFamily: 'ProximaNova', 
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _adminDisplayName,
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: primaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _adminEmail,
                            style: TextStyle(fontFamily: 'ProximaNova', 
                              fontSize: 10.5,
                              color: mutedColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Admin Menu',
                      offset: const Offset(0, -50),
                      color: isDark ? const Color(0xFF1E2330) : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      icon: Icon(
                        CupertinoIcons.ellipsis_vertical,
                        size: 16,
                        color: mutedColor,
                      ),
                      onSelected: (val) {
                        if (val == 'logout') _handleLogout();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _adminDisplayName,
                                style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              Text(
                                _adminEmail,
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, color: mutedColor),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.square_arrow_right, color: Colors.redAccent, size: 16),
                              SizedBox(width: 8),
                              Text('Log Out', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // Quick Action Item (Search, Notification, Settings)
  Widget _buildUtilityAction({
    required IconData icon,
    required String label,
    int? badgeCount,
    required bool isCollapsed,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: 19, color: mutedColor),
                    if (badgeCount != null)
                      Positioned(
                        top: -1,
                        right: -3,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEB3A),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(icon, size: 19, color: mutedColor),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontFamily: 'ProximaNova', 
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: mutedColor,
                  ),
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Sidebar Navigation Item with flat brand primary yellow filled active state
  Widget _buildModernSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    int? badgeCount,
    bool isHighlight = false,
    required bool isCollapsed,
    required bool isDark,
    required bool isDrawer,
  }) {
    final isSelected = _selectedTabIndex == index;
    final activeBg = AppTheme.primaryYellow; // Rental App Signature Brand Yellow (0xFFFFEB3A)
    final activeIconColor = Colors.black;
    final activeTextColor = Colors.black;
    final inactiveText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() => _selectedTabIndex = index);
                if (isDrawer) Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? activeIconColor : inactiveText,
                    ),
                    if (badgeCount != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : AppTheme.primaryYellow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() => _selectedTabIndex = index);
          if (isDrawer) Navigator.pop(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? activeIconColor : inactiveText,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontFamily: 'ProximaNova', 
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? activeTextColor : inactiveText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppTheme.primaryYellow : Colors.black,
                    ),
                  ),
                ),
              if (isHighlight && badgeCount == null && !isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LIVE',
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP DESKTOP HEADER BAR (CLEAN 58PX MINIMALIST BAR)
  // ==========================================
  Widget _buildTopHeader(bool isDark) {
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Active Tab Title
          Expanded(
            child: Text(
              _getTabTitle(_selectedTabIndex),
              style: TextStyle(fontFamily: 'ProximaNova', 
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: primaryTextColor,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),

          // Toggle Live User App Button
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                _showLiveUserAppPreview = !_showLiveUserAppPreview;
                if (_showLiveUserAppPreview) {
                  _previewPanelWidth = null;
                }
              });
            },
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: _showLiveUserAppPreview
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _showLiveUserAppPreview
                      ? const Color(0xFF10B981).withValues(alpha: 0.5)
                      : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.device_phone_portrait,
                    size: 15,
                    color: _showLiveUserAppPreview ? const Color(0xFF10B981) : mutedColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showLiveUserAppPreview ? 'Hide App' : 'User App',
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _showLiveUserAppPreview ? const Color(0xFF10B981) : (isDark ? Colors.white70 : const Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Export CSV Shortcut
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _exportPropertiesCSV,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.arrow_down_doc, size: 15, color: mutedColor),
                  const SizedBox(width: 5),
                  Text(
                    'CSV',
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Quick Create Broadcast Shortcut
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _selectedTabIndex = 3),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.bell_fill, size: 15, color: Colors.black),
                  const SizedBox(width: 6),
                  Text(
                    'Broadcast',
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Refresh Button
          Tooltip(
            message: 'Refresh All Data',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                _fetchProperties();
                _fetchNotificationHistory();
              },
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                child: Icon(CupertinoIcons.refresh_thick, color: mutedColor, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Theme Toggle
          Tooltip(
            message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => ThemeController.instance.toggleTheme(),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                child: Icon(
                  isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                  color: isDark ? Colors.amber : mutedColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Command Center & System Overview';
      case 1:
        return 'Property Approvals & Inventory Matrix';
      case 2:
        return 'Click Heatmap & Tenant Demand Radar';
      case 3:
        return 'Push Notification & Broadcast Hub';
      case 4:
        return 'Landlords & Registered Users Directory';
      case 5:
        return 'User Reports & Flagged Listings Hub';
      case 7:
        return 'Supabase Database & Cloud Storage Telemetry';
      default:
        return 'Admin Dashboard';
    }
  }

  // ==========================================
  // ACTIVE TAB CONTENT DISPATCHER
  // ==========================================
  Widget _buildActiveTabContent(bool isDark) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab(isDark);
      case 1:
        return _buildPropertiesTab(isDark);
      case 2:
        return _buildClickRadarTab(isDark);
      case 3:
        return _buildPushNotificationsTab(isDark);
      case 4:
        return _buildUsersTab(isDark);
      case 5:
        return _buildUserReportsTab(isDark);
      case 7:
        return AdminDatabaseAnalyticsTab(
          isDark: isDark,
          onRefreshParent: _fetchProperties,
        );
      default:
        return _buildOverviewTab(isDark);
    }
  }

  // ==========================================
  // TAB 5: USER REPORTS & FLAGGED LISTINGS
  // ==========================================
  Widget _buildUserReportsTab(bool isDark) {
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final pendingReports = _userReports.where((r) => r['status'] == 'pending').length;

    return RefreshIndicator(
      onRefresh: _fetchUserReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161922) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(CupertinoIcons.flag_fill, color: Colors.redAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'User Reported Listings',
                              style: TextStyle(fontFamily: 'ProximaNova', 
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (pendingReports > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$pendingReports Pending',
                                  style: TextStyle(fontFamily: 'ProximaNova', 
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Review discrepancies submitted by app users regarding wrong rent, unreachable owner numbers, or misleading photos.',
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons.refresh_thick, color: isDark ? Colors.white70 : Colors.black87),
                    onPressed: _fetchUserReports,
                    tooltip: 'Refresh Reports',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isLoadingUserReports)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.primaryYellow),
                ),
              )
            else if (_userReports.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161922) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(CupertinoIcons.shield_fill, size: 48, color: Colors.green.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No Reported Listings',
                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 16, fontWeight: FontWeight.bold, color: primaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All community posts are in good standing! No discrepancy flags have been submitted.',
                      style: TextStyle(fontSize: 12.5, color: mutedColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userReports.length,
                itemBuilder: (context, index) {
                  final r = _userReports[index];
                  final isPending = r['status'] == 'pending';
                  final createdStr = r['created_at'] != null
                      ? r['created_at'].toString().split('T').first
                      : '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161922) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isPending
                            ? Colors.redAccent.withValues(alpha: 0.4)
                            : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0)),
                        width: isPending ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.redAccent, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r['property_title'] ?? 'Property Listing',
                                    style: TextStyle(fontFamily: 'ProximaNova', 
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppTheme.darkCardElevated : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          r['property_type'] ?? 'Listing',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: mutedColor),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ID: ${r['property_id']}',
                                        style: TextStyle(fontSize: 11, color: mutedColor),
                                      ),
                                      const Spacer(),
                                      Text(
                                        createdStr,
                                        style: TextStyle(fontSize: 11, color: mutedColor),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Reason Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: isDark ? 0.2 : 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(CupertinoIcons.info_circle_fill, color: Colors.redAccent, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Reported Reason: ${r['reason']}',
                                style: TextStyle(fontFamily: 'ProximaNova', 
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFFFCA5A5) : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (r['comments'] != null && r['comments'].toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'User Comment: "${r['comments']}"',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            if (r['owner_phone'] != null && r['owner_phone'].toString().isNotEmpty)
                              InkWell(
                                onTap: () async {
                                  final uri = Uri.parse('tel:${r['owner_phone']}');
                                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                                },
                                child: Row(
                                  children: [
                                    const Icon(CupertinoIcons.phone_fill, size: 14, color: AppTheme.primaryYellow),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Owner: ${r['owner_phone']}',
                                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, fontWeight: FontWeight.bold, color: primaryTextColor),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            if (isPending) ...[
                              OutlinedButton(
                                onPressed: () async {
                                  try {
                                    await _supabase.from('listing_reports').update({'status': 'dismissed'}).eq('id', r['id']);
                                    AppSnackbar.success(context, 'Report dismissed');
                                    _fetchUserReports();
                                  } catch (e) {
                                    AppSnackbar.error(context, 'Failed: $e');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('Dismiss', style: TextStyle(fontSize: 11.5, color: mutedColor)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _deleteProperty(r['property_id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Delete Listing', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              ),
                            ] else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Resolved', style: TextStyle(fontSize: 11, color: mutedColor)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: COMMAND CENTER & SYSTEM OVERVIEW
  // ==========================================
  

  // ==========================================
  // COMPONENT: EXECUTIVE KPI CARD (BIG BOLD TYPOGRAPHY)
  // ==========================================
  Widget _buildExecutiveKpiCard({
      required String title,
      required String value,
      required String subtitle,
      required String badgeLabel,
      required Color badgeColor,
      required IconData icon,
      required Color iconColor,
      required bool isDark,
      required Color primaryTextColor,
      required Color mutedColor,
      VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161922) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Title + Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: mutedColor,
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, color: iconColor, size: 16),
                  ),
                ],
              ),

              // Middle: BIG BOLD NUMBER
              Text(
                value,
                style: TextStyle(fontFamily: 'ProximaNova', 
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor,
                  letterSpacing: -0.5,
                ),
              ),

              // Bottom Row: Subtitle + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: mutedColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
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

  // ==========================================
  // COMPONENT: LOCALITY DEMAND RANKING MATRIX (100% REAL DATA)
  // ==========================================
  

  // ==========================================
  // COMPONENT: INVENTORY BY CATEGORY & PRICE (100% REAL DATA)
  // ==========================================
  Widget _buildInventoryBreakdownCard({
      required bool isDark,
      required Color primaryTextColor,
      required Color mutedColor,
      required int flatsCount,
      required int pgsCount,
      required int commercialCount,
      required int total,
  }) {
    final effectiveTotal = total > 0 ? total.toDouble() : 1.0;
    final flatPct = ((flatsCount / effectiveTotal) * 100).round();
    final pgPct = ((pgsCount / effectiveTotal) * 100).round();
    final commPct = (100 - flatPct - pgPct).clamp(0, 100);

    // Compute real price brackets from live database
    int budgetCount = 0; // < 5000
    int midCount = 0;    // 5000 - 10000
    int highCount = 0;   // > 10000

    for (final p in _properties) {
      final rentNum = double.tryParse(p.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      if (rentNum < 5000) {
        budgetCount++;
      } else if (rentNum <= 10000) {
        midCount++;
      } else {
        highCount++;
      }
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
                  const Icon(CupertinoIcons.square_grid_2x2_fill, size: 17, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Text(
                    'Inventory Breakdown & Rent Tiers',
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
              Text(
                '$total Live Units',
                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w700, color: mutedColor),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Multi-Segment Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(flex: pgPct > 0 ? pgPct : 1, child: Container(color: const Color(0xFF10B981))),
                  const SizedBox(width: 2),
                  Expanded(flex: flatPct > 0 ? flatPct : 1, child: Container(color: AppTheme.primaryYellow)),
                  const SizedBox(width: 2),
                  Expanded(flex: commPct > 0 ? commPct : 1, child: Container(color: const Color(0xFF3B82F6))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Categories with Real Counts
          _buildCategoryPillRow('Hostel / PG (Boys & Girls)', pgsCount, pgPct, const Color(0xFF10B981), primaryTextColor),
          const SizedBox(height: 6),
          _buildCategoryPillRow('Residential Flats / Houses', flatsCount, flatPct, AppTheme.primaryYellow, primaryTextColor),
          const SizedBox(height: 6),
          _buildCategoryPillRow('Commercial & Buy/Sell', commercialCount, commPct, const Color(0xFF3B82F6), primaryTextColor),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          Text(
            'Live Rent Tiers in Database',
            style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w700, color: mutedColor),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _buildPriceTierCard('< ₹5,000', '$budgetCount Units', 'Budget Rooms', const Color(0xFF10B981), isDark),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPriceTierCard('₹5k - ₹10k', '$midCount Units', 'Mid PGs & Rooms', AppTheme.primaryYellow, isDark),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildPriceTierCard('> ₹10,000', '$highCount Units', 'Full Flats', const Color(0xFF8B5CF6), isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COMPONENT: PLATFORM SECURITY & GUARDRAILS
  // ==========================================
  

  Widget _buildGuardrailItem({
      required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required bool isDark,
      required Color primaryTextColor,
      required Color mutedColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, fontWeight: FontWeight.w700, color: primaryTextColor),
              ),
              Text(
                subtitle,
                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10.5, color: mutedColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  

  

  // ==========================================
  // COMPONENT: LIVE REAL INVENTORY FEED (100% REAL DATA)
  // ==========================================
  

  // ==========================================
  // TAB 2: PROPERTIES MANAGEMENT & OCCUPANCY
  // ==========================================
  



  /// Live Phone Preview Navigation Action
  void _viewPropertyInLivePhone(PropertyModel prop) {
    if (!_showLiveUserAppPreview) {
      setState(() {
        _showLiveUserAppPreview = true;
        _previewPanelWidth = null;
      });
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (_previewNavigatorKey.currentState != null) {
        _previewNavigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailsScreen(property: prop),
          ),
        );
        AppSnackbar.success(context, '📱 Loaded "${prop.title}" in live phone device preview');
      }
    });
  }

  /// Property Edit: Opens the full real-user multi-step Posting/Editing flow directly in the Live Phone Preview
  void _showEditPropertyModal(PropertyModel prop, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;

    if (isDesktop) {
      if (!_showLiveUserAppPreview) {
        setState(() {
          _showLiveUserAppPreview = true;
          _previewPanelWidth = null;
        });
      }

      Future.delayed(const Duration(milliseconds: 140), () {
        if (_previewNavigatorKey.currentState != null) {
          _previewNavigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: _previewDarkMode ? AppTheme.darkScaffold : Colors.white,
                body: SafeArea(
                  child: PostingScreen(
                    onDismissForm: () => Navigator.of(context).pop(),
                  propertyToEdit: prop,
                    onPropertyCreated: (updatedProp) {
                      _fetchProperties();
                      AppSnackbar.success(context, '✅ Property "${updatedProp.title}" updated successfully!');
                    },
                  ),
                ),
              ),
            ),
          );
          AppSnackbar.success(context, '📱 Opened real-user posting & editing flow in Live Phone Device Preview');
        } else {
          _showEditBottomSheetModal(prop, isDark);
        }
      });
    } else {
      _showEditBottomSheetModal(prop, isDark);
    }
  }

  void _showEditBottomSheetModal(PropertyModel prop, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        widthFactor: 1.0,
        heightFactor: 0.94,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkScaffold : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF33333E) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Scaffold(
              backgroundColor: isDark ? AppTheme.darkScaffold : Colors.white,
              body: SafeArea(
                child: PostingScreen(
                  onDismissForm: () => Navigator.of(context).pop(),
                  propertyToEdit: prop,
                  onPropertyCreated: (updatedProp) {
                    _fetchProperties();
                    AppSnackbar.success(context, '✅ Property "${updatedProp.title}" updated successfully!');
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  

  // ==========================================
  // TAB 3: CLICK ANALYTICS & TENANT DEMAND RADAR
  // ==========================================
  

  // ==========================================
  // COMPONENT: TOP INQUIRED PROPERTIES LEADERBOARD
  // ==========================================
  

  // ==========================================
  // COMPONENT: AMENITY DEMAND HEATMAP
  // ==========================================
  

  // ==========================================
  // COMPONENT: TRENDING SEARCH RADAR (INTENT)
  // ==========================================
  

  // ==========================================
  // COMPONENT: TENANT INQUIRY FLOW CARD
  // ==========================================
  

  // ==========================================
  // TAB 4: PUSH NOTIFICATION BROADCAST HUB
  // ==========================================
  

  

  Widget _buildTimeSlotCard({
      required bool isDark,
      required String time,
      required String title,
      required String subtitle,
      required IconData icon,
      required Color color,
  }) {
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.all(14),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(fontFamily: 'ProximaNova', 
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontFamily: 'ProximaNova', 
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontFamily: 'ProximaNova', 
              fontSize: 11,
              color: mutedColor,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildAudienceChip({
      required TargetAudience target,
      required String label,
      required String count,
      required IconData icon,
      required bool isDark,
  }) {
    final isSelected = _selectedAudience == target;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedAudience = target),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryYellow.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryYellow
                  : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.primaryYellow : mutedColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(fontFamily: 'ProximaNova', 
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? primaryTextColor : mutedColor,
                ),
                maxLines: 1,
              ),
              Text(
                count,
                style: TextStyle(fontFamily: 'ProximaNova', 
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppTheme.primaryYellow : mutedColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
  }

  

  

  // ==========================================
  // TAB 5: USERS & LANDLORDS DIRECTORY (CARDS & COLUMN GRID)
  // ==========================================
  

  // ==========================================
  // COMPONENT: INDIVIDUAL LANDLORD CARD
  // ==========================================
  Widget _buildLandlordCard({
      required String ownerName,
      required String phone,
      required List<PropertyModel> props,
      required List<String> localities,
      required bool isDark,
      required Color primaryTextColor,
      required Color mutedColor,
  }) {
    final isMulti = props.length > 1;

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Avatar + Name + Property Count Badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isMulti
                        ? [AppTheme.primaryYellow, const Color(0xFFD97706)]
                        : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'O',
                  style: TextStyle(fontFamily: 'ProximaNova', 
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerName,
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.check_mark_circled_solid, size: 12, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          'Direct Landlord',
                          style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isMulti ? AppTheme.primaryYellow : const Color(0xFF3B82F6)).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${props.length} ${props.length == 1 ? 'Unit' : 'Units'}',
                  style: TextStyle(fontFamily: 'ProximaNova', 
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isMulti ? AppTheme.primaryYellow : const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),

          // Contact Details Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.phone_fill, size: 13, color: mutedColor),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: TextStyle(fontFamily: 'ProximaNova', 
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: primaryTextColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, size: 12, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      localities.take(2).join(', '),
                      style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w500, color: mutedColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Mini Portfolio Preview (Top 2 Properties)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Managed Units:',
                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11, fontWeight: FontWeight.w700, color: mutedColor),
              ),
              const SizedBox(height: 5),
              ...props.take(2).map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                p.title,
                                style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w600, color: primaryTextColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${p.price}',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 11.5, fontWeight: FontWeight.w800, color: AppTheme.primaryYellow),
                      ),
                    ],
                  ),
                );
              }),
              if (props.length > 2)
                Text(
                  '+${props.length - 2} more properties in portfolio',
                  style: TextStyle(fontFamily: 'ProximaNova', fontSize: 10, fontWeight: FontWeight.w600, color: mutedColor),
                ),
            ],
          ),

          // Action Buttons: WhatsApp + Phone Preview
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _contactOwnerWhatsApp(phone, props.first.title),
                  icon: const Icon(CupertinoIcons.chat_bubble, size: 14),
                  label: Text('WhatsApp', style: TextStyle(fontFamily: 'ProximaNova', fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'View on Live Phone Preview',
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _viewPropertyInLivePhone(props.first),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: Icon(CupertinoIcons.device_phone_portrait, size: 16, color: mutedColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }





  // ==========================================
  // PROPERTY INSPECTION & REJECT DIALOGS
  // ==========================================
  void _showPropertyInspectionModal(PropertyModel prop, bool isDark) {
    final propId = prop.id ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Listing Inspection',
                        style: TextStyle(fontFamily: 'ProximaNova', fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.clear),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (prop.imageUrls.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: prop.imageUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: prop.imageUrls[i],
                              width: 220,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    prop.title,
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${prop.price}/month • Deposit: ₹${prop.securityDeposit ?? 'N/A'} • ${prop.locationStr}',
                    style: TextStyle(fontFamily: 'ProximaNova', 
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prop.description ?? 'No description provided.',
                    style: TextStyle(fontFamily: 'ProximaNova', fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updatePropertyStatus(propId, 'approved');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Approve Listing'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRejectDialog(propId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reject Listing'),
                      ),
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

  void _showRejectDialog(String id) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Property Submission', style: TextStyle(fontFamily: 'ProximaNova', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide feedback reason for the owner (e.g. unclear room photos, inaccurate address, broker listing):'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason for rejection...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updatePropertyStatus(id, 'rejected', reason: reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Confirm Rejection'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    await _supabase.auth.signOut();
    if (mounted) {
      AppSnackbar.success(context, 'Logged out from Admin Portal');
      Navigator.pushReplacementNamed(context, '/admin');
    }
  }
}

// ==========================================
// CUSTOM WAVE CHART PAINTER FOR INQUIRY TRAFFIC
// ==========================================
class _InquiryWaveChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final bool isDark;
  final Color accentColor;

  _InquiryWaveChartPainter({
    required this.dataPoints,
    required this.isDark,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final double maxVal = dataPoints.reduce((a, b) => a > b ? a : b) * 1.15;
    final double minVal = 0;
    final double range = (maxVal - minVal) <= 0 ? 1 : (maxVal - minVal);

    // 1. Draw subtle horizontal grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Compute point coordinates
    final points = <Offset>[];
    final double dx = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final double normalized = (dataPoints[i] - minVal) / range;
      final double y = size.height - (normalized * (size.height - 24)) - 12;
      points.add(Offset(i * dx, y));
    }

    // 3. Build Smooth Bezier Wave Path
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // 4. Fill Area Gradient Under Curve
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillGradient = LinearGradient(
      colors: [
        accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
        accentColor.withValues(alpha: 0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 5. Draw Glowing Stroke Line
    final strokePaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, strokePaint);

    // 6. Draw Interactive / Stylized Nodes
    final dotPaint = Paint()..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = isDark ? const Color(0xFF161922) : Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final isPeak = i == points.length - 2; // Saturday peak

      // Outer glow for peak
      if (isPeak) {
        final glowPaint = Paint()
          ..color = accentColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(pt, 8, glowPaint);
      }

      // Dot fill & border
      dotPaint.color = isPeak ? const Color(0xFFEF4444) : accentColor;
      canvas.drawCircle(pt, isPeak ? 5 : 3.5, dotPaint);
      canvas.drawCircle(pt, isPeak ? 5 : 3.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InquiryWaveChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.isDark != isDark ||
        oldDelegate.accentColor != accentColor;
  }
}
