import 'package:chatapp/pages/profile_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF075E54),
        title: _searchQuery.isEmpty
            ? const Text(
                "WhatsChat",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : _buildSearchField(),
        actions: [
          IconButton(
            icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.close),
            onPressed: () {
              setState(() {
                if (_searchQuery.isEmpty) {
                  _searchQuery = ' ';
                } else {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => ProfilePage())),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: signOut,
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildUserList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF075E54),
        child: const Icon(Icons.chat),
        onPressed: () {
          // Add new chat functionality
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  Widget _buildSearchBar() {
    return _searchQuery.isEmpty
        ? const SizedBox.shrink()
        : Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Text('Search results', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return const Center(child: Text('No users found.'));
        }

        final docs = snapshot.data!.docs
            .where((doc) => doc['email'] != _auth.currentUser!.email)
            .where((doc) => doc['email']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildUserCard(docs[index]);
          },
        );
      },
    );
  }

  Widget _buildUserCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
    return StreamBuilder<DatabaseEvent>(
      stream: _dbRef.child("status").child(data['uid']).onValue,
      builder: (context, snapshot) {
        bool isOnline = false;
        String lastSeen = '';
        
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final statusData = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map);
          isOnline = statusData['online'] ?? false;
          if (!isOnline && statusData['last_seen'] != null) {
            final lastSeenTime = DateTime.fromMillisecondsSinceEpoch(
                statusData['last_seen'] as int);
            lastSeen = _formatLastSeen(lastSeenTime);
          }
        }

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverUserEmail: data['email'],
                  receiverUserID: data['uid'],
                ),
              ),
            );
          },
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF075E54),
                child: Text(
                  data['email'][0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            data['email'],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            isOnline ? 'Online' : lastSeen,
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.grey,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
