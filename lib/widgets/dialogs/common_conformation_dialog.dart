import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:manager/widgets/extantion/common_extantion.dart';

import '../../resources/multimedia_resources/resources.dart';

void showCustomActionDialog({
  required BuildContext context,
  required String image,
  required String title,
  required String primaryButtonText,
  required VoidCallback onPrimaryButtonPressed,
  required String secondaryButtonText,
  required VoidCallback onSecondaryButtonPressed,
  String? badge,
  String? subtitle,
}) {
  showDialog(
    context: context,
    // डायलॉग के बाहर क्लिक करने पर उसे बंद होने से रोकने के लिए
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        // कोनों को गोल करने के लिए
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // मुख्य इमेज
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),

                    child: ClipOval(
                      child:
                          image != ''
                              ? Image.network(
                                image.prefixWithBaseUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    AppImages.team_default,
                                    width: 60,
                                    height: 60,
                                  );
                                },
                              )
                              : Image.asset(
                                AppImages.team_default,
                                width: 60,
                                height: 60,
                              ),
                    ),
                  ),
                  // अगर बैज दिया गया है, तो उसे दिखाएँ
                  if (badge != null && badge != '')
                    Positioned(
                      bottom: 1,
                      right: 0,
                      child: SvgPicture.network(
                        badge.prefixWithBaseUrl ?? '',
                        width: 17,
                        height: 17,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // टाइटल
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              // अगर सबटाइटल दिया गया है, तो उसे दिखाएँ
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),

              // बटन्स
              Row(
                children: [
                  // सेकेंडरी बटन (जैसे "Cancel")
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryButtonPressed,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        secondaryButtonText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // प्राइमरी बटन (जैसे "Send Request")
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF0D47A1,
                        ), // डार्क ब्लू कलर
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        primaryButtonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
