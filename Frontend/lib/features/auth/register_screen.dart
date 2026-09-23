import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).register(name, email, password);
    if (!success && mounted) {
      final error = ref.read(authProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Đăng ký thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Tạo tài khoản',
          style: TextStyle(fontWeight: FontWeight.w700, color: context.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bắt đầu với Huy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tạo tài khoản để đồng bộ lịch trình cá nhân của bạn',
                  style: TextStyle(fontSize: 14, color: context.textSecondary),
                ),
                const SizedBox(height: 24),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: context.surfaceCard,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.borderDivider, width: 0.8),
                    boxShadow: AppColors.cardShadow(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Họ và tên',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.containerLow,
                          hintText: 'Nguyễn Văn A',
                          hintStyle: TextStyle(color: context.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.person_outline, size: 20, color: context.textMuted),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.textPrimary, width: 1.4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Email',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.containerLow,
                          hintText: 'name@example.com',
                          hintStyle: TextStyle(color: context.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.email_outlined, size: 20, color: context.textMuted),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.textPrimary, width: 1.4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Mật khẩu',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: context.containerLow,
                          hintText: 'Tối thiểu 6 ký tự',
                          hintStyle: TextStyle(color: context.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.lock_outline, size: 20, color: context.textMuted),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: context.textMuted,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.textPrimary, width: 1.4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: context.textPrimary,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: context.textPrimary.withValues(alpha: 0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: authState.status == AuthStatus.loading ? null : _handleRegister,
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: authState.status == AuthStatus.loading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: context.surfaceCard, strokeWidth: 2.2),
                                    )
                                  : Text(
                                      'Đăng ký',
                                      style: TextStyle(color: context.surfaceCard, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã có tài khoản? ', style: TextStyle(fontSize: 14, color: context.textSecondary)),
                    InkWell(
                      onTap: () => context.pop(),
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
