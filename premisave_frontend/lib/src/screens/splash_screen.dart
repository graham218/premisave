import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final authState = ref.read(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    Future.delayed(const Duration(seconds: 2), () {
      if (authState.token != null) {
        context.go(authNotifier.getDashboardRoute());
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.blue.shade900.withOpacity(0.8),
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing background effect
                  Transform.scale(
                    scale: _scaleAnimation.value * 1.5,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.withOpacity(_glowAnimation.value * 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main logo container with pulsing effect
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade300,
                          Colors.blue.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: const Icon(
                        Icons.home,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Animated rings
                  Positioned(
                    child: Transform.scale(
                      scale: _scaleAnimation.value * 1.3,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue.withOpacity(_glowAnimation.value * 0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content below the logo
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.3,
                    child: Column(
                      children: [
                        const SizedBox(height: 200),
                        // App name with glowing text
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.blue.shade300,
                              ],
                              stops: [0.5, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Premisave',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.blue.withOpacity(_glowAnimation.value),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Animated progress indicator
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue.withOpacity(_glowAnimation.value),
                              width: 2,
                            ),
                          ),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.withOpacity(_glowAnimation.value),
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}