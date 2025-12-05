import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

// 🔹 탭바 포함된 홈 화면 (네가 만든 파일)
//    파일 경로/클래스 이름이 다르면 여기만 맞춰 바꿔줘.
import 'screens/home/home_screen.dart' as tabs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Kakao SDK 초기화 (네이티브 앱 키)
  kakao.KakaoSdk.init(nativeAppKey: '8fc3b489a6e4d0c6c8b5d79302f34ecb');

  runApp(const MOHANAApp());
}

class MOHANAApp extends StatelessWidget {
  const MOHANAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOHANA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // 🔹 이미 로그인되어 있으면 자동으로 탭바 홈으로, 아니면 로그인 화면으로.
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasData) {
            // 이미 로그인됨 → 탭바 홈
            return const tabs.HomeScreen();
          }
          // 미로그인 → 로그인 화면
          return const LoginScreen();
        },
      ),
    );
  }
}

/* ----------------------------- 로그인 화면 ----------------------------- */

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  /* ✅ Google 로그인 */
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google 로그인 성공!')),
      );

      // ✅ 탭바 홈으로
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const tabs.HomeScreen()),
      );
    } catch (e) {
      debugPrint("Google 로그인 오류: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Google 로그인 실패')));
    }
  }

  /* ✅ Kakao 로그인 (Firebase 미연동, SDK만 이용) */
  Future<void> _signInWithKakao() async {
    try {
      // 1️⃣ 로그인 시도
      if (await kakao.isKakaoTalkInstalled()) {
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 2️⃣ 사용자 정보 조회
      final user = await kakao.UserApi.instance.me();
      final nickname = user.kakaoAccount?.profile?.nickname ?? '사용자';
      final email = user.kakaoAccount?.email ?? '${user.id}@kakao.fake';

      debugPrint('✅ Kakao 로그인 성공! 닉네임:$nickname, 이메일:$email');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('환영합니다, $nickname님!')),
      );

      // ✅ 탭바 홈으로
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const tabs.HomeScreen()),
      );
    } catch (error) {
      debugPrint('❌ Kakao 로그인 실패: $error');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kakao 로그인 실패')));
    }
  }

  /* ✅ 이메일 로그인 */
  Future<void> _loginWithEmail() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const tabs.HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      var msg = '로그인 실패';
      if (e.code == 'user-not-found') msg = '존재하지 않는 계정입니다.';
      if (e.code == 'wrong-password') msg = '비밀번호가 올바르지 않습니다.';
      if (e.code == 'invalid-email') msg = '이메일 형식이 올바르지 않습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MOHANA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 40),

                // ✅ Google 로그인 버튼
                ElevatedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.account_circle),
                  label: const Text('Google 로그인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Kakao 로그인 버튼
                ElevatedButton.icon(
                  onPressed: _signInWithKakao,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Kakao 로그인'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('로그인'),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    '계정이 없으신가요? 회원가입',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------------- 회원가입 화면 ----------------------------- */

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  Future<void> _signUp() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('회원가입 완료! 로그인해주세요.')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      var msg = '회원가입 실패';
      if (e.code == 'weak-password') msg = '비밀번호가 너무 약합니다.';
      if (e.code == 'email-already-in-use') msg = '이미 존재하는 이메일입니다.';
      if (e.code == 'invalid-email') msg = '이메일 형식이 올바르지 않습니다.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: '이메일', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: '비밀번호', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : _signUp,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('회원가입 완료'),
            ),
          ],
        ),
      ),
    );
  }
}