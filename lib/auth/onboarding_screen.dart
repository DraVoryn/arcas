import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcas/providers/auth_provider.dart';
import 'package:arcas/l10n/app_localizations.dart';

/// Pantalla de onboarding para nuevos usuarios.
///
/// FLUJO:
/// Muestra 2 slides con información sobre la app.
/// Al final, botón "Comenzar" que llama completeOnboarding()
/// y redirige a PIN setup.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ==========================================================================
  // DATA DE LOS SLIDES
  // ==========================================================================

  final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Control total,\nsin complicaciones',
      subtitle:
          'Registrá tus ingresos y gastos de forma simple.\nTu información, solo en tu teléfono.',
      icon: Icons.account_balance_wallet_rounded,
      gradientColors: [
        const Color(0xFF0D1B2A),
        const Color(0xFF1B263B),
      ],
    ),
    _OnboardingSlide(
      title: 'Privacidad\na tu manera',
      subtitle:
          'Sin cloud, sin terceros, sin sorpresas.\nTus datos viajan solo entre vos y tu dispositivo.',
      icon: Icons.lock_rounded,
      gradientColors: [
        const Color(0xFF1B263B),
        const Color(0xFF2A4365),
      ],
    ),
  ];

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // ACTIONS
  // ==========================================================================

  void _nextSlide() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    ref.read(authNotifierProvider.notifier).completeOnboarding();
    context.go('/pin-setup');
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _slides[_currentPage].gradientColors[0],
              _slides[_currentPage].gradientColors[1],
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      l10n.skip,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView con slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildSlide(_slides[index]);
                  },
                ),
              ),

              // Indicadores de página
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => _buildPageIndicator(index == _currentPage),
                  ),
                ),
              ),

              // Botón CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4A261),
                      foregroundColor: const Color(0xFF0D1B2A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? l10n.getStarted
                          : l10n.next,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono decorativo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              slide.icon,
              size: 56,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),

          // Título
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          // Subtítulo
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF4A261)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Modelo de datos para un slide de onboarding.
class _OnboardingSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });
}
