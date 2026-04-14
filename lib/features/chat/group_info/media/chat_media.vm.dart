import 'package:manager/core/locator.dart';
import 'package:manager/core/models/attachments_model.dart';
import 'package:manager/core/utils/app_logger.dart';
import 'package:manager/services/chat.service.dart';
import 'package:stacked/stacked.dart';

class ChatMediaViewModel extends ReactiveViewModel {
  final _chatService = locator<ChatService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadError;
  String? get loadError => _loadError;

  final List<AttachmentsDatum> _attachments = [];

  /// All image attachments (jpg, png, gif, webp, etc.)
  List<AttachmentsDatum> get imageAttachments =>
      _attachments.where((a) => a.isImage).toList(growable: false);

  /// Non-image attachments treated as documents
  List<AttachmentsDatum> get documentAttachments =>
      _attachments.where((a) => !a.isImage).toList(growable: false);

  Future<void> init({required String roomId}) async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final response = await _chatService.getAttachments(roomId: roomId);

      response.fold(
        (failure) {
          _attachments.clear();
          _loadError = failure.message;
        },
        (attachmentsModel) {
          _attachments
            ..clear()
            ..addAll(
              attachmentsModel.data
                  .where((a) => a.file.url.trim().isNotEmpty),
            );
        },
      );
    } catch (e) {
      AppLogger.error('Error fetching media: $e');
      _attachments.clear();
      _loadError = 'Failed to load media';
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices => [];
}
