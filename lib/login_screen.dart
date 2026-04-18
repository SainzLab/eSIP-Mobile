import 'package:flutter/foundation.dart';
// --------------------------------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_screen.dart';
import 'models/pocketbase_service.dart';

class LoginController extends GetxController {
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    
    if (kDebugMode) {
      emailController = TextEditingController(text: 'staff@dev.com');
      passwordController = TextEditingController(text: 'admin123');
    } else {
      emailController = TextEditingController();
      passwordController = TextEditingController();
    }
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Perhatian', 
        'Email dan password tidak boleh kosong!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isLoading.value = true;

      await PocketBaseService.pb
          .collection('users')
          .authWithPassword(email, password);

      Get.offAll(() => const MainScreen());

    } catch (e) {
      Get.snackbar(
        'Gagal Masuk', 
        'Email atau password salah. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final LoginController controller = Get.put(LoginController());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideDownHeaderAnimation;
  late Animation<Offset> _slideUpFormAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideDownHeaderAnimation = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideUpFormAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2851E3);
    const Color inputBackground = Color(0xFFF4F5FA);
    const Color textDark = Color(0xFF1E232C);
    const Color textGrey = Color(0xFF8391A1);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _slideDownHeaderAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60.0, bottom: 40.0, left: 24.0, right: 24.0),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/logo.png', 
                                      width: 70, 
                                      height: 70,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.school, color: Colors.white, size: 50);
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'eSIP',
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Sistem Informasi Pengarsipan',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'SMPN 1 PABUARAN',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: SlideTransition(
                          position: _slideUpFormAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Center(
                                    child: Text(
                                      'Selamat Datang',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Center(
                                    child: Text(
                                      'Silakan masuk untuk mengelola arsip Anda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textGrey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),

                                  const Text(
                                    'EMAIL ATAU USERNAME',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textGrey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: controller.emailController,
                                    decoration: InputDecoration(
                                      hintText: 'nama@email.com',
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      prefixIcon: const Icon(Icons.person_outline, color: textGrey),
                                      filled: true,
                                      fillColor: inputBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  const Text(
                                    'KATA SANDI',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: textGrey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Obx(() => TextField(
                                    controller: controller.passwordController,
                                    obscureText: !controller.isPasswordVisible.value,
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      prefixIcon: const Icon(Icons.lock_outline, color: textGrey),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                                          color: textGrey,
                                        ),
                                        onPressed: controller.togglePasswordVisibility,
                                      ),
                                      filled: true,
                                      fillColor: inputBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  )),
                                  const SizedBox(height: 12),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(50, 30),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        'Lupa Password?',
                                        style: TextStyle(
                                          color: primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: Obx(() => ElevatedButton(
                                      onPressed: controller.isLoading.value ? null : controller.login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 4,
                                        shadowColor: primaryBlue.withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: controller.isLoading.value
                                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : const Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Masuk ke Sistem',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(Icons.login, size: 20),
                                              ],
                                            ),
                                    )),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}