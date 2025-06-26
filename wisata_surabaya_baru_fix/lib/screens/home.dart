import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/animation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animasi floating icons
              Positioned(
                top: 50,
                left: 30,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value), 
                      child: child
                    );
                  },
                  child: const Icon(Icons.location_on, size: 40, color: Colors.white54),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 40,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_animation.value), 
                      child: child
                    );
                  },
                  child: const Icon(Icons.explore, size: 50, color: Colors.white54),
                ),
              ),
              Positioned(
                top: 150,
                right: 20,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value * 0.02, 
                      child: child
                    );
                  },
                  child: const Icon(Icons.star, size: 30, color: Colors.white54),
                ),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5), 
                              width: 2
                            ),
                          ),
                          child: const Icon(
                            Icons.travel_explore, 
                            size: 60, 
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 30),
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [Colors.white, Colors.lightBlueAccent],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Selamat Datang!',
                            style: TextStyle(
                              fontSize: 32, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Jelajahi keindahan ',
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white, 
                                  height: 1.5
                                ),
                              ),
                              TextSpan(
                                text: 'kota Surabaya',
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white, 
                                  fontWeight: FontWeight.bold, 
                                  fontStyle: FontStyle.italic, 
                                  height: 1.5
                                ),
                              ),
                              TextSpan(
                                text: ' bersama kami',
                                style: TextStyle(
                                  fontSize: 18, 
                                  color: Colors.white, 
                                  height: 1.5
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.3), 
                                thickness: 1
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Mulai Petualanganmu',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8), 
                                  fontSize: 14
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.3), 
                                thickness: 1
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5), 
                                blurRadius: 10, 
                                offset: const Offset(0, 5)
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final token = prefs.getString('token');
                              if (token != null && token.isNotEmpty) {
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const HomeScreen())
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context, 
                                  MaterialPageRoute(builder: (context) => const LoginScreen())
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0D47A1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  'Masuk Sekarang', 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            // Navigasi ke mode tamu
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen())
                            );
                          },
                          child: const Text(
                            'Jelajahi sebagai tamu',
                            style: TextStyle(
                              color: Colors.white70, 
                              fontSize: 14, 
                              decoration: TextDecoration.underline
                            ),
                          ),
                        ),
                      ],
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
}