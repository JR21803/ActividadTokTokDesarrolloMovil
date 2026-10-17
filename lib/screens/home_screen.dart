import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toktok/presentation/widgets/shared/video_scrollable_view.dart';
import 'package:toktok/shared/data/local_video_posts.dart';

import '../services/auth_service.dart';
import 'filtros_faciale.dart';

class HomeScreen extends StatefulWidget {
  final User usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'TokTok' : 'Filtros faciales'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => authService.cerrarSesion(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          VideoScrollableView(videoPosts: videoPosts),
          const FiltrosFaciale(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Videos'),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Filtros'),
        ],
      ),
    );
  }
}
