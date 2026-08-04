import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/vibra_colors.dart';
import '../../../domain/entities/app_user.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double radius;

  const UserAvatar({super.key, this.avatarUrl, this.name, this.radius = 24.0});

  factory UserAvatar.fromUser(AppUser? user, {double radius = 24.0}) {
    return UserAvatar(
      avatarUrl: user?.avatarUrl,
      name: user?.displayName ?? user?.username ?? 'User',
      radius: radius,
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _getDeterministicColor(String name) {
    if (name.isEmpty) return VibraColors.primary;
    final hash = name.hashCode;
    final colors = [
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.orange,
      Colors.deepOrange,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      final isNetwork =
          avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://');

      return CircleAvatar(
        radius: radius,
        backgroundImage: isNetwork
            ? NetworkImage(avatarUrl!) as ImageProvider
            : FileImage(File(avatarUrl!)),
        backgroundColor: Colors.transparent,
      );
    }

    final safeName = name ?? 'U';
    return CircleAvatar(
      radius: radius,
      backgroundColor: _getDeterministicColor(safeName),
      child: Text(
        _getInitials(safeName),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
