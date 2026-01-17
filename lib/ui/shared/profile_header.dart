import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

/// Reusable profile header with avatar and user info using dynamic UI design.
///
/// Displays user profile picture (or initials fallback), display name, and email.
/// Uses teal background matching app theme. Designed for use in Profile and other
/// screens to provide consistent user information display.
///
/// Uses dynamic sizing - NO hardcoded pixel values. All dimensions are relative
/// to screen size for responsive design across different devices and screen ratios.
///
/// Key responsibilities:
/// - Display user avatar (CircleAvatar with NetworkImage or initials fallback)
/// - Show user display name and email from AuthService
/// - Match app theme styling (white text, teal background, SafeArea)
/// - Support optional trailing widget for flexibility
///
/// UI structure:
/// - Teal background (Theme primary color)
/// - SafeArea wrapper (top only)
/// - Row layout: Avatar (5% screen width) | Name/Email | Optional trailing widget
/// - Dynamic sizing: Padding 4%, avatar 5%, fonts 3-4% of screen width
class ProfileHeader extends StatelessWidget {
  /// Optional widget to display at the end of the header (e.g., edit icon, settings)
  final Widget? trailing;

  const ProfileHeader({super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthService, dynamic>(
      selector: (_, auth) => auth.currentUser,
      builder: (context, user, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Use constraints instead of MediaQuery to avoid rebuild triggers
            final screenWidth = constraints.maxWidth;
            // For height, we still need MediaQuery but only once
            final screenHeight = MediaQuery.of(context).size.height;

            return Container(
              color: Theme.of(context).colorScheme.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),  // 4% of screen width
                  child: Row(
                    children: [
                      _buildAvatar(context, user, radius: screenWidth * 0.05),  // 5% of screen width
                      SizedBox(width: screenWidth * 0.03),  // 3% spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              user?.displayName ?? 'User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04,  // 4% of screen width
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.002),  // 0.2% spacing
                            Text(
                              user?.email ?? 'No email',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: screenWidth * 0.03,  // 3% of screen width
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Optional trailing widget
                      if (trailing != null) ...[
                        SizedBox(width: screenWidth * 0.02),  // 2% spacing
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, user, {required double radius}) {
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user!.photoUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Stops NetworkImage retry cycle - prevents BLASTBufferQueue spam
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    }

    final initials = _getInitials(user?.displayName);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
