import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manager/core/models/employee.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../resources/app_resources/app_resources.dart';

class EmployeeCardAttributes {
  final String leadingImageUrl;
  final String title;
  final String trailingImageUrl;
  final VoidCallback onTap;
  final String? status;
  final Employee employee;
  EmployeeCardAttributes({
    required this.onTap,
    required this.leadingImageUrl,
    required this.title,
    required this.trailingImageUrl,
    required this.employee,
    this.status,
  });
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.attributes});

  final EmployeeCardAttributes attributes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: attributes.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSizes.h8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.v16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              offset: Offset(0, 3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left color bar
            Container(
              width: 6,
              height: AppSizes.h80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.v16),
                  bottomLeft: Radius.circular(AppSizes.v16),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.h12),
                child: Row(
                  children: [
                    // Profile image
                    _buildProfileImage(context),
                    SizedBox(width: AppSizes.w12),
                    // Employee info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            attributes.title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSizes.h4),
                          Text(
                            attributes.employee.email ?? 'No email',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSizes.h4),
                          _buildRoleBadge(context),
                        ],
                      ),
                    ),
                    // Country flag or trailing info
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppSizes.w36,
                          height: AppSizes.w36,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.lightGrey,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(AppSizes.v6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: CachedNetworkImage(
                            imageUrl: attributes.trailingImageUrl,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: AppColors.lightGrey.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Icon(
                                  Icons.flag_outlined,
                                  color: AppColors.gray,
                                ),
                          ),
                        ),
                        SizedBox(height: AppSizes.h6),
                        // Arrow indicator
                        Container(
                          width: AppSizes.w24,
                          height: AppSizes.h24,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.primary,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    return Container(
      width: AppSizes.w50,
      height: AppSizes.w50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.w50),
        child: CachedNetworkImage(
          imageUrl: attributes.leadingImageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                child: Icon(Icons.person, color: AppColors.gray, size: 30),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, color: AppColors.primary, size: 30),
              ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    String roleText = attributes.status ?? 'Unknown';
    Color badgeColor = _getRoleColor(roleText);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.w8,
        vertical: AppSizes.h2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.v12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            _capitalizeRole(roleText),
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeRole(String role) {
    if (role.isEmpty) return '';
    if (role.length <= 3) return role.toUpperCase(); // For abbreviations

    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  Color _getRoleColor(String role) {
    final lowerRole = role.toLowerCase();

    if (lowerRole.contains('admin')) {
      return Colors.purple.shade700;
    } else if (lowerRole.contains('manager')) {
      return Colors.blue.shade700;
    } else if (lowerRole.contains('employee')) {
      return Colors.teal.shade700;
    } else if (lowerRole.contains('active')) {
      return Colors.green.shade700;
    } else if (lowerRole.contains('pending')) {
      return Colors.orange.shade700;
    } else if (lowerRole.contains('inactive')) {
      return Colors.red.shade700;
    }

    return AppColors.primary;
  }
}

class EmployeeCardShimmer extends StatelessWidget {
  const EmployeeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizes.h8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.v16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left color bar
          Container(
            width: 6,
            height: AppSizes.h80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.v16),
                bottomLeft: Radius.circular(AppSizes.v16),
              ),
            ),
          ),
          // Main content shimmer
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.h12),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Row(
                  children: [
                    // Profile image placeholder
                    Container(
                      width: AppSizes.w50,
                      height: AppSizes.w50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSizes.w12),
                    // Text placeholders
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: AppSizes.h16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.v4),
                            ),
                          ),
                          SizedBox(height: AppSizes.h8),
                          Container(
                            width: AppSizes.w120,
                            height: AppSizes.h12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.v4),
                            ),
                          ),
                          SizedBox(height: AppSizes.h8),
                          Container(
                            width: AppSizes.w80,
                            height: AppSizes.h12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.v16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Flag placeholder
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: AppSizes.w36,
                          height: AppSizes.w36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSizes.v6),
                          ),
                        ),
                        SizedBox(height: AppSizes.h6),
                        Container(
                          width: AppSizes.w24,
                          height: AppSizes.h24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
