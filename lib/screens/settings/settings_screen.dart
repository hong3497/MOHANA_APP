import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:mohana_app/screens/login/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // ✅ Firebase 로그아웃
      await FirebaseAuth.instance.signOut();

      // ✅ Google 로그아웃
      await GoogleSignIn().signOut();

      // ✅ Kakao 로그아웃
      try {
        await kakao.UserApi.instance.logout();
        debugPrint('✅ Kakao 로그아웃 성공');
      } catch (e) {
        debugPrint('⚠️ Kakao 로그아웃 실패: $e');
      }

      // ✅ 로그아웃 후 로그인 화면으로 이동
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      debugPrint('로그아웃 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FB),
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'MOHANA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 30),
            _buildSettingItem(Icons.person_outline, '프로필 설정'),
            const SizedBox(height: 16),
            _buildSettingItem(Icons.notifications_none, '알림 설정'),
            const SizedBox(height: 16),
            _buildSettingItem(Icons.color_lens_outlined, '테마 변경'),
            const SizedBox(height: 30),

            // ✅ 로그아웃 버튼
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '로그아웃',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}