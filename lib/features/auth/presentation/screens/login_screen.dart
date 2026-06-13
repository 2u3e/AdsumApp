import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Login ekrani — canli & modern:
/// yumusak nefes alan aura arka plan, stagger giris animasyonu,
/// focus'a duyarli alanlar, basisa tepki veren gradient buton.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberUsername = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedUsername();
  }

  /// Hatirlanan kullanici adini yukle ve alani doldur.
  Future<void> _loadRememberedUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Daha once hic ayar yapilmadiysa varsayilan: hatirla (true).
      final remember = prefs.getBool(StorageKeys.rememberUsername) ?? true;
      final saved = prefs.getString(StorageKeys.rememberedUsername);
      if (!mounted) return;
      setState(() {
        _rememberUsername = remember;
        if (remember && saved != null && saved.isNotEmpty) {
          _usernameController.text = saved;
        }
      });
    } catch (_) {
      // Tercih okunamazsa sessizce varsayilanla devam et.
    }
  }

  /// Tercihe gore kullanici adini kaydet ya da temizle.
  Future<void> _persistUsernamePreference(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.rememberUsername, _rememberUsername);
      if (_rememberUsername) {
        await prefs.setString(StorageKeys.rememberedUsername, username);
      } else {
        await prefs.remove(StorageKeys.rememberedUsername);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final username = _usernameController.text.trim();
    await ref.read(authStateProvider.notifier).login(
          username,
          _passwordController.text,
        );
    // Yalnizca giris basariliysa kullanici adini hatirla (yanlis kullanici
    // adini kaydetmemek icin).
    final authenticated =
        ref.read(authStateProvider).value?.isAuthenticated ?? false;
    if (authenticated) {
      await _persistUsernamePreference(username);
    } else if (!_rememberUsername) {
      // Kullanici hatirlamayi kapattiysa, basarisiz giriste de eski kaydi sil.
      await _persistUsernamePreference(username);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final error = authState.value?.error;

    // Stagger ile akacak gorunur bloklar.
    final blocks = <Widget>[
      Center(child: _Logo(animate: !reduce)),
      const SizedBox(height: 28),
      _BrandHeader(isDark: isDark),
      const SizedBox(height: 36),
      if (error != null) ...[
        _ErrorBanner(message: error, isDark: isDark),
        const SizedBox(height: 18),
      ],
      _Field(
        controller: _usernameController,
        label: 'Kullanıcı Adı',
        hint: 'Kullanıcı adınızı girin',
        icon: Icons.person_outline_rounded,
        textInputAction: TextInputAction.next,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Kullanıcı adı gereklidir';
          if (v.trim().length < 3) return 'En az 3 karakter giriniz';
          return null;
        },
      ),
      const SizedBox(height: 14),
      _Field(
        controller: _passwordController,
        label: 'Şifre',
        hint: 'Şifrenizi girin',
        icon: Icons.lock_outline_rounded,
        obscure: _obscurePassword,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _handleLogin(),
        suffix: IconButton(
          splashRadius: 20,
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Şifre gereklidir';
          if (v.length < 6) return 'En az 6 karakter giriniz';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _RememberCheckbox(
        value: _rememberUsername,
        isDark: isDark,
        onChanged: (v) => setState(() => _rememberUsername = v),
      ),
      const SizedBox(height: 22),
      _PrimaryButton(
        label: 'Giriş Yap',
        loading: _isLoading,
        onTap: _handleLogin,
      ),
      const SizedBox(height: 40),
      _Footer(isDark: isDark),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Stack(
        children: [
          _AuroraBackground(isDark: isDark, animate: !reduce),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: blocks
                          .animate(interval: 50.ms)
                          .fadeIn(duration: 420.ms, curve: Curves.easeOutCubic)
                          .slideY(
                            begin: reduce ? 0 : 0.16,
                            end: 0,
                            duration: 420.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Arka plan: yumusak, yavas nefes alan aura'lar
// ─────────────────────────────────────────────────────────────
class _AuroraBackground extends StatelessWidget {
  final bool isDark;
  final bool animate;
  const _AuroraBackground({required this.isDark, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: [
            // Ust-sol: primary mavi aura
            Positioned(
              top: -120,
              left: -90,
              child: _blob(
                size: 320,
                color: AppColors.primary
                    .withValues(alpha: isDark ? 0.22 : 0.16),
                beginScale: 0.95,
                endScale: 1.18,
                duration: 5200,
              ),
            ),
            // Alt-sag: emerald/info hafif aura
            Positioned(
              bottom: -140,
              right: -110,
              child: _blob(
                size: 360,
                color: (isDark ? AppColors.info : AppColors.primaryLight)
                    .withValues(alpha: isDark ? 0.16 : 0.12),
                beginScale: 1.1,
                endScale: 0.92,
                duration: 6400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob({
    required double size,
    required Color color,
    required double beginScale,
    required double endScale,
    required int duration,
  }) {
    final blob = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
    if (!animate) return blob;
    return blob
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: beginScale,
          end: endScale,
          duration: duration.ms,
          curve: Curves.easeInOut,
        );
  }
}

// ─────────────────────────────────────────────────────────────
// Logo: uygulama iconu + yumusak float
// ─────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  final bool animate;
  const _Logo({required this.animate});

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Image.asset(
        'assets/icons/app_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => const Icon(
          Icons.location_city_rounded,
          size: 46,
          color: AppColors.primary,
        ),
      ),
    );
    if (!animate) return logo;
    return logo
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -6, duration: 2600.ms, curve: Curves.easeInOut);
  }
}

// ─────────────────────────────────────────────────────────────
// Marka basligi
// ─────────────────────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  final bool isDark;
  const _BrandHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ADSUM',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: isDark ? Colors.white : AppColors.gray900,
                fontWeight: FontWeight.w800,
                letterSpacing: 5,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Hesabınıza giriş yapın',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hata afisi
// ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  const _ErrorBanner({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.errorSurfaceDark : AppColors.errorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.errorLight : AppColors.errorDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    ).animate().shakeX(amount: 3, duration: 360.ms);
  }
}

// ─────────────────────────────────────────────────────────────
// Focus'a duyarli giris alani
// ─────────────────────────────────────────────────────────────
class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _node = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node.addListener(() {
      if (_node.hasFocus != _focused) setState(() => _focused = _node.hasFocus);
    });
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.primary;
    final idleFill = isDark ? AppColors.gray800 : AppColors.gray50;
    final focusFill =
        isDark ? AppColors.primarySurfaceDark.withValues(alpha: 0.5) : AppColors.primarySurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _node,
        obscureText: widget.obscure,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon: Icon(
            widget.icon,
            size: 21,
            color: _focused ? accent : (isDark ? AppColors.gray400 : AppColors.gray400),
          ),
          suffixIcon: widget.suffix,
          filled: true,
          fillColor: _focused ? focusFill : idleFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.gray200,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.6),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// "Kullanici adimi hatirla" — animasyonlu custom onay kutusu
// ─────────────────────────────────────────────────────────────
class _RememberCheckbox extends StatelessWidget {
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;
  const _RememberCheckbox({
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.primary;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Kullanıcı adımı hatırla',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: value
                      ? accent
                      : (isDark ? AppColors.gray500 : AppColors.gray300),
                  width: 1.6,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Basisa tepki veren gradient buton
// ─────────────────────────────────────────────────────────────
class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.loading ? null : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.loading
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _pressed ? 0.22 : 0.36),
                blurRadius: _pressed ? 10 : 18,
                offset: Offset(0, _pressed ? 4 : 8),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      key: const ValueKey('label'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Alt bilgi + surum rozeti
// ─────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final bool isDark;
  const _Footer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Adsum Belediye Yönetim Sistemi',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Sürüm ${AppConstants.appVersion} · VPS API',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
