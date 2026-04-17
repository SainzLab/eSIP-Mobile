import 'package:flutter/material.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2563EB)),
          onPressed: () => Navigator.pop(context), 
        ),
        title: const Text(
          'Scanner',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Color(0xFF2563EB)),
            onPressed: () {
            },
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1616423640778-28d1b53229bd?q=80&w=1000&auto=format&fit=crop', 
              fit: BoxFit.cover,
            ),
          ),
          
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2563EB), width: 2.0), 
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned(top: -2, left: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.blueAccent, width: 4), left: BorderSide(color: Colors.blueAccent, width: 4))))),
                  Positioned(top: -2, right: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.blueAccent, width: 4), right: BorderSide(color: Colors.blueAccent, width: 4))))),
                  Positioned(bottom: -2, left: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blueAccent, width: 4), left: BorderSide(color: Colors.blueAccent, width: 4))))),
                  Positioned(bottom: -2, right: -2, child: Container(width: 20, height: 20, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.blueAccent, width: 4), right: BorderSide(color: Colors.blueAccent, width: 4))))),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: GestureDetector(
                onTap: () {
                },
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 50, 
            right: 40,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 20),
                onPressed: () {
                },
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}