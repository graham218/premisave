import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf8f9fa), Color(0xFFe9ecef)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isLargeScreen
                ? _buildWideLayout(context)
                : _buildMobileLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          // Left side - Branding
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0A2463),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_user_outlined, color: Colors.white, size: 80),
                    const SizedBox(height: 24),
                    const Text(
                      "Verify Your Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Complete your registration to start investing in real estate. "
                          "Verification ensures the security of your Premisave account.",
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: const [
                        Icon(Icons.security_outlined, color: Colors.white70, size: 20),
                        SizedBox(width: 10),
                        Text("Secure account verification", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.real_estate_agent, color: Colors.white70, size: 20),
                        SizedBox(width: 10),
                        Text("Access premium features", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.trending_up_outlined, color: Colors.white70, size: 20),
                        SizedBox(width: 10),
                        Text("Start your investment journey", style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right side - Verification Content
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Center(
                child: SingleChildScrollView(
                  child: _buildVerificationContent(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, color: Color(0xFF0A2463), size: 70),
            const SizedBox(height: 16),
            const Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF0A2463),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Almost there! Just one more step to activate your account",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildVerificationContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationContent(BuildContext context) {
    return Column(
      children: [
        // Verification Icon with Animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF0A2463).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mail_outline,
            size: 60,
            color: Color(0xFF0A2463),
          ),
        ),

        const SizedBox(height: 24),

        // Main Message
        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),

        const SizedBox(height: 16),

        // Instructions
        const Text(
          'We\'ve sent a verification link to your email address.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        const Text(
          'Please click the link in the email to activate your Premisave account '
              'and start your real estate investment journey.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 24),

        // Instructions Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFf8f9fa),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Color(0xFF0A2463), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "What to do next:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2463),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInstructionStep(
                "1",
                "Open the email we sent you",
                Icons.email_outlined,
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                "2",
                "Click the verification link",
                Icons.link_outlined,
              ),
              const SizedBox(height: 8),
              _buildInstructionStep(
                "3",
                "Return to login and access your account",
                Icons.login_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Additional Info
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Can't find the email? Check your spam folder",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.access_time_outlined, color: Colors.grey, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "The verification link expires in 24 hours",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Buttons Row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text('Resend Email'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF0A2463)),
                ),
                onPressed: () {
                  // TODO: Add resend email functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Verification email resent'),
                      backgroundColor: const Color(0xFF0A2463),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Back to Login',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2463),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: () => context.go('/login'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Support Text
        TextButton(
          onPressed: () {
            // TODO: Add support contact functionality
          },
          child: const Text(
            'Need help? Contact Support',
            style: TextStyle(
              color: Color(0xFF0A2463),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF0A2463),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: const Color(0xFF0A2463), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}