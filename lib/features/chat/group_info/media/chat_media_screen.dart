import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager/core/models/attachments_model.dart';
import 'package:manager/resources/app_resources/app_resources.dart';
import 'package:manager/widgets/common/common_cached_image.dart';
import 'package:manager/widgets/common_app_bar.dart';
import 'package:manager/widgets/dialogs/image_preview/image_preview_dialog.dart';
import 'package:stacked/stacked.dart';

import '../../../../resources/multimedia_resources/resources.dart';
import 'chat_media.vm.dart';

class ChatMediaScreen extends StatefulWidget {
  final String roomId;

  const ChatMediaScreen({super.key, required this.roomId});

  @override
  State<ChatMediaScreen> createState() => _ChatMediaScreenState();
}

class _ChatMediaScreenState extends State<ChatMediaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatMediaViewModel>.reactive(
      viewModelBuilder: () => ChatMediaViewModel(),
      onViewModelReady: (model) => model.init(roomId: widget.roomId),
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F6F8),
          appBar: _buildAppBar(context,_tabController),
          body: Column(
            children: [
              // ─── TAB BAR ───


              // ─── TAB VIEWS ───
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── MEDIA TAB ──
                    _MediaGrid(model: model),

                    // ── DOCUMENTS TAB ──
                    _DocumentsList(model: model),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// MEDIA GRID
// ─────────────────────────────────────────────
class _MediaGrid extends StatelessWidget {
  final ChatMediaViewModel model;

  const _MediaGrid({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.loadError != null) {
      return Center(
        child: Text(
          model.loadError!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final images = model.imageAttachments;

    if (images.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 48, color: AppColors.textGrey),
            SizedBox(height: 12),
            Text(
              'No media shared yet',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final imageUrls =
        images.map((a) => a.file.url.trim()).where((u) => u.isNotEmpty).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final attachment = images[index];
        return GestureDetector(
          onTap: () {
            showImagePreviewDialog(
              context: context,
              imageUrls: imageUrls,
              initialIndex: index,
            );
          },
          child: Hero(
            tag: 'media_image_${attachment.file.url}',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth; // square cell
                return CommonCachedImage(
                  imageUrl: attachment.file.url,
                  width: size,
                  height: size,
                  borderRadius: BorderRadius.zero,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// DOCUMENTS LIST
// ─────────────────────────────────────────────
class _DocumentsList extends StatelessWidget {
  final ChatMediaViewModel model;

  const _DocumentsList({required this.model});

  @override
  Widget build(BuildContext context) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.loadError != null) {
      return Center(
        child: Text(
          model.loadError!,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final docs = model.documentAttachments;

    if (docs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_outlined, size: 48, color: AppColors.textGrey),
            SizedBox(height: 12),
            Text(
              'No documents shared yet',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final doc = docs[index];
        return ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _docIcon(doc.file.url),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
getStaticName(doc.file.type ?? ''), // ✅ correct
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            getStaticName(doc.file.url),
            style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
          ),
          trailing: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              Text(
                formatDate(doc.createdAt.toString()), style: TextStyle(color: AppColors.textSecondary,fontSize: 10,fontWeight:FontWeight.w500 ),
              ),
            ],
          )
          // IconButton(
          //   icon: const Icon(Icons.download_outlined,
          //       color: AppColors.textGrey, size: 20),
          //   onPressed: () {
          //     // TODO: implement download
          //   },
          // ),
        );
      },
    );
  }

  IconData _docIcon(String url) {
    final ext = url.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_outlined;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────
PreferredSizeWidget _buildAppBar(BuildContext context, _tabController) {
  return GradientAppBar(
    leading: IconButton(
      icon: Image.asset(
        AppImages.back,
        width: 24,
        height: 24,
        color: AppColors.white,
      ),
      onPressed: () => Navigator.of(context).pop(),
    ),
    titleWidget: const Text(
      'Media & Docs',
      style: TextStyle(
        color: AppColors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    titleSpacing: 0,
    actions:  [
      Container(
        width: 200,
        margin: EdgeInsets.symmetric(vertical: AppSizes.h13),
        // padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary, // blue background
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white, // selected tab bg
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: const TextStyle(
            fontSize: 12, // 👈 yaha size kam karo
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12, // 👈 same yaha bhi
            fontWeight: FontWeight.w500,
          ),
          labelColor: Colors.black, // selected text color
          unselectedLabelColor: Colors.white, // unselected text
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Media'),
            Tab(text: 'Documents'),
          ],
        ),
      ),],
  );
}
String getStaticName(String fileName) {
final ext = fileName.split('.').last.toLowerCase();

if (ext == 'pdf') return 'PDF File';
if (['doc', 'docx'].contains(ext)) return 'Document';
if (['xls', 'xlsx'].contains(ext)) return 'Excel File';

return 'File';
}

String formatDate(String date) {
  final parsedDate = DateTime.parse(date).toLocal();
  return DateFormat('yyyy MMMM dd').format(parsedDate);
}