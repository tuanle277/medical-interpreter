import 'package:flutter/material.dart';
import 'interpreter_screen.dart';
import 'conversations_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Interpreter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.teal.shade300,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ScaleTransition(
              scale: _animation,
              child: GestureDetector(
                onTap: () {
                  _controller.forward(from: 0.0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.teal.shade200,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Icon(
                    Icons.medical_services,
                    size: screenHeight / 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            _buildAnimatedButton(
              'Start Interpreter',
              InterpreterScreen(),
              Colors.teal.shade200,
              Colors.teal.shade400,
              Colors.white,
            ),
            const SizedBox(height: 15),
            _buildAnimatedButton(
              'View Conversations',
              ConversationsScreen(),
              Colors.white,
              Colors.teal.shade100,
              Colors.teal.shade900,
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.teal.shade300,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white70,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.chat),
      //       label: 'Conversations',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      //   onTap: (index) {
      //     if (index == 0)
      //     {
      //       print("this is bad");
      //     }
      //   },
      // ),
    );
  }

  Widget _buildAnimatedButton(String text, Widget targetScreen, Color startColor, Color endColor, Color textColor) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: 0.95),
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: startColor,
            elevation: 3,
            shadowColor: Colors.black38,
          ),
          child: Container(
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //   colors: [startColor, endColor],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
          },
        ),
      ),
    );
  }
}
