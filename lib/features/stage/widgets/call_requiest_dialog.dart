

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:manager/widgets/dialogs/common_conformation_dialog.dart';

showCallRequestDialog({
  required String profile,
  required String name,
  required String call_type,
  required String flag,
  required var onAccept,
  required var onDecline,
}){
  bool isVoiceCall= call_type =='audio';
  showCustomActionDialog(
    context: Get.context!,
    image:profile??'',
    title: (isVoiceCall?'Voice Call': 'Video Call') +" From ${name}",
    subtitle: 'Confirm Send Request',
    primaryButtonText: 'Accept',
    secondaryButtonText: 'Decline',
    badge:flag,
    onPrimaryButtonPressed: () async {
      onAccept();
    },
    onSecondaryButtonPressed: () {
      onDecline();
    },
  );

}