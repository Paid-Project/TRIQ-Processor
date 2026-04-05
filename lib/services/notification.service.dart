import "dart:async";
import "dart:convert";
import "dart:io";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/foundation.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "package:manager/api_endpoints.dart";
import "package:manager/routes/routes.dart";
import "package:manager/core/storage/storage.dart";
import "package:stacked_services/stacked_services.dart";

import "../core/locator.dart";
import "../features/chat/chat.vm.dart";
import "../features/chat/chat_view.dart";
import "../features/tickets/ticket_details/ticket_details.view.dart";
import "api.service.dart";


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const String _defaultChannelId = "triq_custom_sound_channel";
const String _defaultChannelName = "Triq Notifications";
const String _defaultChannelDescription = "Channel for Triq manager notifications";

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
    ) async {
  var payload = notificationResponse.payload;
  if (kDebugMode) {
    print("onDidReceiveNotificationResponse: $payload");
  }
  if (payload != null) {
    await FirebaseNotificationService.notificationNavigation(data: payload);
  }
}

final List<String> _soundList = [
  'bamboo',
  'bell',
  'chime',
  'ding',
  'notification',
  'pop',
  'ring',
  'tone',
  'whistle',
];

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
    ) async {
  // Isolate me Firebase ko initialize karna zaroori hai
  await Firebase.initializeApp();
  await _initializeLocalNotifications(isBackground: true);

  if (kDebugMode) {
    print("Background message received. Showing notification manually...");
    print("Background data: ${message.data}");
  }

  // Notification dikhane ke liye function call karein
  FirebaseNotificationService.showNotification(message);
}

Future<void> _initializeLocalNotifications({bool isBackground = false}) async {
  var androidSettings = const AndroidInitializationSettings(
    "@mipmap/ic_launcher",
  );
  var iOSSettings = const DarwinInitializationSettings();
  var initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iOSSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse:
    isBackground ? null : onDidReceiveNotificationResponse,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  // 1. Default Channel
  var defaultChannel = const AndroidNotificationChannel(
    _defaultChannelId,
    _defaultChannelName,
    description: _defaultChannelDescription,
    importance: Importance.max,
    playSound: true,
  );
  await androidPlugin?.createNotificationChannel(defaultChannel);

  for (String soundName in _soundList) {
    final channelId = 'triq_sound_$soundName';
    final channelName = 'Triq ($soundName)';
    final channelDesc = 'Notification channel for $soundName sound';

    var soundChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      sound: RawResourceAndroidNotificationSound(soundName),
    );

    await androidPlugin?.createNotificationChannel(soundChannel);
  }
}



class FirebaseNotificationService {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static var isSound = false;
  static int item = 1;
  static bool _isInitializing = false;
  static bool _isInitialized = false;
  static Map<String, dynamic>? _pendingNavigationData;
  static String? _lastNavigationFingerprint;
  static DateTime? _lastNavigationAt;

  static Future<void> initializeService() async {
    // Check initialization status
    if (_isInitializing || _isInitialized) {
      return;
    }
    _isInitializing = true;

    try {
      final settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('Permission status: ${settings.authorizationStatus}');
      }

      // Local Notification Init
      await _initializeLocalNotifications(isBackground: false);

      // 1. Background Handler yahan set karein (Sirf Ek Baar)
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 2. Foreground Listeners set karein
      getNotification();

      await _captureInitialNotificationTap();

      String? apnsToken;
      if (Platform.isIOS) {
        apnsToken = await _waitForApnsToken(timeout: const Duration(seconds: 6));
      }

      if (!Platform.isIOS || (apnsToken != null && apnsToken.isNotEmpty)) {
        final String? token = await firebaseMessaging.getToken();
        if (token != null) {
          // Save token logic
          final currentUser = getUser();
          if (currentUser.fcmToken == null) {
            saveUser(currentUser.copyWith(fcmToken: token));
          }
        }
      }

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) print("Error init: $e");
    } finally {
      _isInitializing = false;
    }
  }

  static getNotification() {
    // --- FIX: Yahan se onBackgroundMessage HATA diya gaya hai ---

    // Foreground Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("Foreground message: ${message.data}");
      }
      // Foreground me notification dikhayein
      showNotification(message);
    });

    // App Open Listener
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await notificationNavigation(data: message.data);
    });
  }

  static showNotification(RemoteMessage message) async {

    String soundName = message.data['sound'] ?? 'default';
    if (soundName == 'noification') soundName = 'notification';

    // Title/Body Data se lein
    String title = message.data['title'] ?? message.notification?.title ?? 'New Notification';
    String body = message.data['body'] ?? message.notification?.body ?? '';

    String? iosSound = (soundName == 'default') ? 'default' : '$soundName.aiff';

    String androidChannelId;
    if (soundName == 'default' || !_soundList.contains(soundName)) {
      androidChannelId = _defaultChannelId;
    } else {
      androidChannelId = 'triq_sound_$soundName';
    }

    var android = AndroidNotificationDetails(
      androidChannelId,
      _defaultChannelName,
      priority: Priority.high,
      importance: Importance.max,
      // Channel Action (Sound) ensure karein
      playSound: true,
    );

    var iOS = DarwinNotificationDetails(
      sound: iosSound,
      presentSound: true,
    );

    var platform = NotificationDetails(android: android, iOS: iOS);
    var jsonData = jsonEncode(message.data);

    await flutterLocalNotificationsPlugin.show(
      item++, // Unique ID taaki notifications overwrite na hon
      title,
      body,
      platform,
      payload: jsonData,
    );
  }

  static Future<void> handlePendingNavigation() async {
    if (_pendingNavigationData == null) return;
    if (!_isNavigatorReady) return;

    final pendingData = Map<String, dynamic>.from(_pendingNavigationData!);
    _pendingNavigationData = null;
    await notificationNavigation(
      data: pendingData,
      deferIfNavigatorUnavailable: false,
    );
  }

  static Future<void> notificationNavigation({
    dynamic data,
    bool deferIfNavigatorUnavailable = true,
  }) async {
    final normalizedData = _normalizeNavigationData(data);
    print("normal data:-${normalizedData}");
    if (normalizedData == null) {
      if (_isNavigatorReady) {
        locator<NavigationService>().navigateTo(Routes.notification);
      }
      return;
    }

    if (!_isNavigatorReady) {
      if (deferIfNavigatorUnavailable) {
        _pendingNavigationData = normalizedData;
      }
      return;
    }

    if (_shouldSkipDuplicateNavigation(normalizedData)) {
      return;
    }

    final screenName = _readValue(
      normalizedData,
      ['screenName', 'screen', 'targetScreen', 'route'],
    );    final isGroupCall = _readValue(
      normalizedData,
      ['isGroupCall',],
    );
    final notificationType = _readValue(
      normalizedData,
      ['type', 'notificationType', 'notification_type', 'chatType'],
    );
    final roomId = _readRoomId(normalizedData);
    final isTicketDetailsScreen = _isTicketDetailsScreen(screenName);
    final isCallScreen = _isCallScreen(screenName);
    final _navigationService = locator<NavigationService>();

    if (isTicketDetailsScreen) {
      final ticketId = _readValue(normalizedData, ['ticketId', 'ticket_id']);
      if (ticketId.isNotEmpty) {
        await _navigationService.navigateToView(
          TicketDetailsView(ticketId: ticketId),
        );
        return;
      }
    }

    if (isCallScreen) {
      final ticketStatus = _readValue(normalizedData, ['ticketStatus']);
      final ticketId = _readValue(normalizedData, ['ticketId', 'ticket_id']);
      final senderName = _readValue(
        normalizedData,
        ['sender_name', 'senderName', 'contactName', 'name'],
      );
      final flag = _readValue(normalizedData, ['flag']);
      final isGroupId  = _readValue(normalizedData, ['isGroupCall']);
      if (roomId.isNotEmpty) {
        final resolvedSenderName =
            senderName.isNotEmpty ? senderName : 'Caller';
        print("resolvedSenderName::-${ isGroupId == "true" }");

        await _navigationService.navigateToView(
          ChatView(
            contactName: resolvedSenderName,
            contactNumber: '',
            contactInitials: resolvedSenderName.substring(0, 1).toUpperCase(),
            roomId: roomId,
            ticketStatus: ticketStatus,
            screen: isGroupId == "true"?ChatRoomScreenType.groupChat:ChatRoomScreenType.contactChat,
            ticketId: ticketId.isEmpty ? null : ticketId,
            flag: flag.isEmpty ? null : flag,
            incomingCallData: normalizedData,
          ),
        );
        return;
      }
    }

    final chatScreenType = _resolveChatScreenType(
      screenName: screenName,
      notificationType: notificationType,
      roomId: roomId,
    );
    final shouldOpenChat = roomId.isNotEmpty && chatScreenType != null && isGroupCall == "true";

    if (shouldOpenChat) {
      final contactName = _readValue(
        normalizedData,
        ['contactName', 'sender_name', 'senderName', 'name', 'title'],
      );
      final contactNumber = _readValue(
        normalizedData,
        ['contactNumber', 'ticketNumber', 'phone', 'mobile', 'email'],
      );
      final ticketStatus = _readValue(
        normalizedData,
        ['ticketStatus', 'status'],
      );
      final ticketId = _readValue(
        normalizedData,
        ['ticketId', 'ticket_id'],
      );
      final flag = _readValue(normalizedData, ['flag', 'countryFlag']);

      if (roomId.isNotEmpty) {
        final resolvedContactName =
            contactName.isNotEmpty
                ? contactName
                : (chatScreenType == ChatRoomScreenType.groupChat
                    ? 'Group'
                    : 'Chat');
        await _navigationService.navigateToView(
          ChatView(
            isVisible: chatScreenType == ChatRoomScreenType.mainChat,
            contactName: resolvedContactName,
            contactNumber:
                contactNumber.isNotEmpty
                    ? contactNumber
                    : (chatScreenType == ChatRoomScreenType.groupChat
                        ? 'Group'
                        : ''),
            contactInitials: resolvedContactName.substring(0, 1).toUpperCase(),
            roomId: roomId,
            ticketStatus:
                chatScreenType == ChatRoomScreenType.mainChat
                    ? ticketStatus
                    : null,
            ticketId:
                chatScreenType == ChatRoomScreenType.mainChat &&
                        ticketId.isNotEmpty
                    ? ticketId
                    : null,
            flag:
                chatScreenType == ChatRoomScreenType.groupChat || flag.isEmpty
                    ? null
                    : flag,
            screen: chatScreenType,
          ),
        );
        return;
      }
    }

    _navigationService.navigateTo(Routes.notification);
  }

  static Future<void> _captureInitialNotificationTap() async {
    final localLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    final localPayload =
        localLaunchDetails?.notificationResponse?.payload?.trim();

    if (localLaunchDetails?.didNotificationLaunchApp == true &&
        localPayload != null &&
        localPayload.isNotEmpty) {
      final normalizedData = _normalizeNavigationData(localPayload);
      if (normalizedData != null) {
        _pendingNavigationData = normalizedData;
      }
    }

    final initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage == null) return;

    final normalizedData = _normalizeNavigationData(initialMessage.data);
    if (normalizedData != null) {
      _pendingNavigationData = normalizedData;
    }
  }

  static Map<String, dynamic>? _normalizeNavigationData(dynamic data) {
    if (data == null) return null;

    dynamic payload = data;
    if (payload is String) {
      final trimmed = payload.trim();
      if (trimmed.isEmpty) return null;
      try {
        payload = jsonDecode(trimmed);
      } catch (_) {
        return null;
      }
    }

    if (payload is! Map) {
      return null;
    }

    final root = Map<String, dynamic>.from(payload);
    final normalized = <String, dynamic>{};

    final nestedData = root['data'];
    if (nestedData is Map) {
      normalized.addAll(Map<String, dynamic>.from(nestedData));
    }

    final nestedPayload = root['payload'];
    if (nestedPayload is Map) {
      normalized.addAll(Map<String, dynamic>.from(nestedPayload));
    }

    normalized.addAll(root);
    return normalized;
  }

  static String _readValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final rawValue = data[key];
      if (rawValue == null) continue;

      final value = rawValue.toString().trim();
      if (value.isNotEmpty && value.toLowerCase() != 'null') {
        return value;
      }
    }
    return '';
  }

  static String _readRoomId(Map<String, dynamic> data) {
    final directRoomId = _readValue(
      data,
      ['room_id', 'roomId', 'chatRoomId', 'chat_room_id'],
    );
    if (directRoomId.isNotEmpty) {
      return directRoomId;
    }

    for (final key in const ['data', 'payload', 'notificationData']) {
      final nestedValue = data[key];
      if (nestedValue is Map) {
        final nestedRoomId = _readRoomId(Map<String, dynamic>.from(nestedValue));
        if (nestedRoomId.isNotEmpty) {
          return nestedRoomId;
        }
      }
    }

    return '';
  }

  static bool get _isNavigatorReady =>
      StackedService.navigatorKey?.currentState != null;

  static bool _isTicketDetailsScreen(String screenName) {
    final normalized = _normalizeIdentifier(screenName);
    return normalized == 'ticketdetailsview' ||
        normalized == 'ticketdetails';
  }

  static bool _isCallScreen(String screenName) {
    final normalized = _normalizeIdentifier(screenName);
    return normalized == 'videocallview' || normalized == 'audiocallview';
  }

  static ChatRoomScreenType? _resolveChatScreenType({
    required String screenName,
    required String notificationType,
    required String roomId,
  }) {
    final normalizedScreen = _normalizeIdentifier(screenName);
    final normalizedType = _normalizeIdentifier(notificationType);

    if (_isGroupChatIdentifier(normalizedScreen) ||
        _isGroupChatIdentifier(normalizedType)) {
      return ChatRoomScreenType.groupChat;
    }

    if (_isContactChatIdentifier(normalizedScreen) ||
        _isContactChatIdentifier(normalizedType)) {
      return ChatRoomScreenType.contactChat;
    }

    if (_isMainChatIdentifier(normalizedScreen) ||
        _isMainChatIdentifier(normalizedType)) {
      return ChatRoomScreenType.mainChat;
    }

    // Keep legacy behavior for older chat payloads that only provide a room id.
    if (roomId.isNotEmpty &&
        normalizedScreen.isEmpty &&
        normalizedType.isEmpty) {
      return ChatRoomScreenType.mainChat;
    }

    return null;
  }

  static bool _isMainChatIdentifier(String normalized) {
    return normalized == 'chatview' ||
        normalized == 'chat' ||
        normalized == 'mainchat' ||
        normalized == 'ticketchat' ||
        normalized == 'chatnotification';
  }

  static bool _isContactChatIdentifier(String normalized) {
    return normalized == 'contactchat' ||
        normalized == 'contactchatview' ||
        normalized == 'externalchat' ||
        normalized == 'externalchatview' ||
        normalized == 'directchat';
  }

  static bool _isGroupChatIdentifier(String normalized) {
    return normalized == 'groupchat' || normalized == 'groupchatview';
  }

  static String _normalizeIdentifier(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static bool _shouldSkipDuplicateNavigation(Map<String, dynamic> data) {
    final fingerprint = [
      _readValue(data, ['screenName', 'screen', 'targetScreen', 'route']),
      _readValue(data, ['type', 'notificationType', 'notification_type']),
      _readRoomId(data),
      _readValue(data, ['ticketId', 'ticket_id']),
      _readValue(data, ['messageId', 'message_id']),
    ].join('|');

    final now = DateTime.now();
    if (_lastNavigationFingerprint == fingerprint &&
        _lastNavigationAt != null &&
        now.difference(_lastNavigationAt!) < const Duration(seconds: 2)) {
      return true;
    }

    _lastNavigationFingerprint = fingerprint;
    _lastNavigationAt = now;
    return false;
  }



  static Future<String?> _waitForApnsToken({required Duration timeout}) async {

    try {
      final immediate = await firebaseMessaging.getAPNSToken();
      if (immediate != null && immediate.isNotEmpty) return immediate;
      final completer = Completer<String?>();
      final end = DateTime.now().add(timeout);
      Timer.periodic(const Duration(milliseconds: 300), (t) async {
        final tkn = await firebaseMessaging.getAPNSToken();
        if (tkn != null && tkn.isNotEmpty) {
          t.cancel();
          completer.complete(tkn);
        } else if (DateTime.now().isAfter(end)) {
          t.cancel();
          completer.complete(null);
        }
      });
      return completer.future;
    }
    catch (e) {
      return null;
    }

  }
}
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    await FirebaseNotificationService.initializeService();
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final apiService = locator<ApiService>();
      final response = await apiService.get(url: ApiEndpoints.getUnreadNotificationCount);

      if (response.statusCode == 200) {
        // Check if response.data is a Map with unreadCount
        if (response.data is Map && response.data.containsKey('unreadCount')) {
          return response.data['unreadCount'] ?? 0;
        }
        // Fallback: if response.data is a List, count manually
        else if (response.data is List) {
          final List<dynamic> notificationList = response.data;
          final unreadCount = notificationList.where((notification) {
            return notification['isRead'] == false || notification['isRead'] == null;
          }).length;
          return unreadCount;
        }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting unread notification count: $e');
      return 0;
    }
  }


  // notification read
  // Get unread notification count
    Future<int> getUnReadMarkNotificationAsRead({String? id}) async {
    try {
      final apiService = locator<ApiService>();
      final response = await apiService.get(url: "${ApiEndpoints.getMarkNotificationAsRead}/$id");
print("response:- ${response}");

      if (response.statusCode == 200) {
        // Check if response.data is a Map with unreadCount
        // if (response.data is Map && response.data.containsKey('unreadCount')) {
        //   return response.data['unreadCount'] ?? 0;
        // }
        // Fallback: if response.data is a List, count manually
        // else if (response.data is List) {
        //   final List<dynamic> notificationList = response.data;
        //   final unreadCount = notificationList.where((notification) {
        //     return notification['isRead'] == false || notification['isRead'] == null;
        //   }).length;
        //   return unreadCount;
        // }
      }
      return 0;
    } catch (e) {
      if (kDebugMode) print('Error getting unread notification count: $e');
      return 0;
    }
  }
  Future<String?> getToken({Duration waitTimeout = const Duration(seconds: 10)}) async {
    final firebase = FirebaseNotificationService.firebaseMessaging;

    final Completer<String?> tokenCompleter = Completer();
    StreamSubscription<String>? refreshSub;
    refreshSub = firebase.onTokenRefresh.listen((newToken) {
      if (!tokenCompleter.isCompleted) {
        tokenCompleter.complete(newToken);
      }
    }, onError: (err) {
      if (!tokenCompleter.isCompleted) tokenCompleter.completeError(err);
    });

    try {
      // On iOS, ensure APNs token is available; otherwise getToken() will throw.
      if (Platform.isIOS) {
        final apns = await firebase.getAPNSToken();
        if (apns == null || apns.isEmpty) {
          if (kDebugMode) print('APNs token not available yet — waiting up to $waitTimeout for FCM token via onTokenRefresh.');

          // Wait for onTokenRefresh (tokenCompleter) or timeout
          String? fallbackToken;
          try {
            fallbackToken = await tokenCompleter.future.timeout(waitTimeout, onTimeout: () {
              if (kDebugMode) print('Timed out waiting for token via onTokenRefresh.');
              return null;
            });
          } catch (e) {
            if (kDebugMode) print('Error while waiting for onTokenRefresh: $e');
            fallbackToken = null;
          } finally {
            await refreshSub?.cancel();
          }

          if (fallbackToken != null) {
            if (kDebugMode) print('Received token from onTokenRefresh: $fallbackToken');
            return fallbackToken;
          }

          // If still no token, return null (avoid calling getToken() now)
          if (kDebugMode) print('No token available (APNs missing). Returning null.');
          return null;
        }
      }

      // If non-iOS or APNs exists, call getToken() in try/catch.
      try {
        final token = await firebase.getToken();
        if (kDebugMode) print('FCM token (immediate): $token');
        await refreshSub?.cancel();
        return token;
      } catch (e) {
        // If getToken throws apns-token-not-set, fallback to waiting for onTokenRefresh
        if (kDebugMode) print('getToken() threw: $e — falling back to onTokenRefresh wait.');
        try {
          final fallback = await tokenCompleter.future.timeout(waitTimeout, onTimeout: () {
            if (kDebugMode) print('Timed out waiting for fallback token.');
            return null;
          });
          if (kDebugMode) print('Fallback token from onTokenRefresh: $fallback');
          return fallback;
        } finally {
          await refreshSub?.cancel();
        }
      }
    } finally {
      // Ensure subscription cleaned if completer already resolved earlier
      await refreshSub?.cancel();
    }
  }


}
