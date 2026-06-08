import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as http;
import 'models/pocketbase_service.dart';
import 'login_screen.dart'; 
import 'components/scanner_screen.dart';
import 'dashboard_screen.dart';
import 'archive_screen.dart'; 
import 'category_screen.dart'; 
import 'disposisi_screen.dart';
import 'sampah_screen.dart';
import 'statistik_screen.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;

  final record = PocketBaseService.pb.authStore.model;

  String get userName => record?.getStringValue('name') ?? 'Pengguna';
  String get userEmail => record?.getStringValue('email') ?? '';
  String get userRole => record?.getStringValue('role') ?? 'Staff';
  String get userDept => record?.getStringValue('bidang') ?? '-';

  bool get isKepsek => userRole == 'Kepala Sekolah';

  String get avatarUrl {
    final avatarFileName = record?.getStringValue('avatar') ?? '';
    if (avatarFileName.isEmpty) return '';
    
    return '${PocketBaseService.baseUrl}/api/files/${record?.collectionId}/${record?.id}/$avatarFileName';
  }

  String get nameInitials {
    final name = userName.trim();
    if (name.isEmpty) return 'U';
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }
  
  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void logout() {
    PocketBaseService.pb.authStore.clear(); 
    Get.offAll(() => const LoginScreen());
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  ChatMessage({required this.text, required this.isBot});
}

class ChatbotSheet extends StatefulWidget {
  const ChatbotSheet({super.key});

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet> {
  final List<ChatMessage> messages = [];
  bool isTyping = false;
  
  final TextEditingController inputController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messages.add(ChatMessage(text: 'Halo! Saya asisten cerdas eSIP. Ada yang bisa saya bantu terkait pengelolaan dokumen hari ini?', isBot: true));
  }

  @override
  void dispose() {
    inputController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isBot: false));
      isTyping = true;
    });
    
    inputController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('https://pbcdn.sainzcloud.my.id/api/tanya-ai'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': PocketBaseService.pb.authStore.token, 
        },
        body: jsonEncode({
          'prompt': text
        }), 
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botReply = data['reply'] ?? 'Tidak ada balasan dari AI.';
        if (mounted) {
          setState(() {
            messages.add(ChatMessage(text: botReply, isBot: true));
          });
        }
      } else {
        if (mounted) {
          setState(() {
            messages.add(ChatMessage(text: 'Maaf, Asisten sedang mengalami gangguan (Error ${response.statusCode}).', isBot: true));
          });
        }
      }
    } catch (e) {
      debugPrint('AI ERROR: $e');
      if (mounted) {
        setState(() {
          messages.add(ChatMessage(text: 'Maaf, Asisten sedang mengalami gangguan koneksi. Coba beberapa saat lagi :)', isBot: true));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void clearChat() {
    setState(() {
      messages.clear();
      messages.add(ChatMessage(text: 'Halo! Saya asisten cerdas eSIP. Ada yang bisa saya bantu terkait pengelolaan dokumen hari ini?', isBot: true));
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget buildChatBubble({required String text, required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280), 
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : const Color(0xFF2563EB),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 0 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 0),
          ),
          border: isBot ? Border.all(color: Colors.grey.shade300) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? const Color(0xFF1E293B) : Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85, 
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FE), 
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), 
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFFA855F7)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('eSip Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Online', style: TextStyle(fontSize: 11, color: Color(0xFF34D399))),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 22),
                        onPressed: clearChat,
                        tooltip: 'Bersihkan Chat',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && isTyping) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                              child: const Icon(Icons.more_horiz, color: Colors.grey, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 60, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomRight: Radius.circular(16)
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                  
                  final msg = messages[index];
                  return buildChatBubble(text: msg.text, isBot: msg.isBot);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9), 
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Tanyakan sesuatu...', 
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 14, color: Colors.grey)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: isTyping ? Colors.grey.shade300 : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isTyping ? null : sendMessage,
                      child: const SizedBox(
                        width: 44, height: 44,
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color bgColor = const Color(0xFFF8F9FE);
    final Color textDark = const Color(0xFF1E293B);

    List<Widget> getPages() {
      return [
        const DashboardScreen(),
        const ArchiveScreen(),
        const CategoryScreen(),
        const DisposisiScreen(),
        controller.isKepsek ? const StatistikScreen() : const SampahScreen(),
      ];
    }

    Widget buildAvatar(double radius, double fontSize) {
      if (controller.avatarUrl.isNotEmpty) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.blue.shade50,
          backgroundImage: NetworkImage(controller.avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {},
        );
      } else {
        return CircleAvatar(
          radius: radius,
          backgroundColor: primaryBlue,
          child: Text(
            controller.nameInitials,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        );
      }
    }
   
    void showProfileMenu(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  children: [
                    buildAvatar(24, 18),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.userName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.userEmail,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 16),

                const Text(
                  'PERAN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF), 
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.userRole.toUpperCase(),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'BIDANG / BAGIAN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.userDept, 
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 8),

                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    controller.logout();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Keluar Sistem',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    void showChatbot(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const ChatbotSheet(),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0, 
        surfaceTintColor: Colors.transparent, 
        titleSpacing: 24.0,
        title: Text(
          'eSIP',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 1.0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => showProfileMenu(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        controller.userName,
                        style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(width: 12),
                      buildAvatar(18, 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Obx(() => getPages()[controller.selectedIndex.value]), 

      floatingActionButton: controller.isKepsek 
          ? null 
          : SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close, 
              spacing: 16, 
              spaceBetweenChildren: 16, 
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              activeBackgroundColor: const Color(0xFFEF4444), 
              activeForegroundColor: Colors.white,
              elevation: 6.0, 
              animationCurve: Curves.easeOutBack, 
              animationDuration: const Duration(milliseconds: 300),
              overlayColor: Colors.black, 
              overlayOpacity: 0.4, 
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 26),
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 4.0,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 26),
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 4.0,
                  onTap: () {
                    showChatbot(context);
                  },
                ),
              ],
            ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: Obx(() => GNav(
              rippleColor: Colors.grey.shade200, 
              hoverColor: Colors.grey.shade100, 
              gap: 6, 
              activeColor: primaryBlue, 
              iconSize: 22, 
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), 
              duration: const Duration(milliseconds: 400), 
              tabBackgroundColor: Colors.blue.shade50, 
              color: Colors.grey.shade500, 
              tabs: [
                const IGNavButton(icon: LineIcons.home, text: 'Home'),
                const IGNavButton(icon: LineIcons.archive, text: 'Arsip'),
                const IGNavButton(icon: LineIcons.folderOpen, text: 'Kategori'),
                const IGNavButton(icon: LineIcons.inbox, text: 'Disposisi'),
                if (controller.isKepsek)
                  const IGNavButton(icon: LineIcons.barChart, text: 'Stats')
                else
                  const IGNavButton(icon: LineIcons.trash, text: 'Sampah'),
              ],
              selectedIndex: controller.selectedIndex.value,
              onTabChange: controller.changeTab, 
            )),
          ),
        ),
      ),
    );
  }
}

class IGNavButton extends GButton {
  const IGNavButton({
    super.key,
    required super.icon,
    required super.text,
  }) : super(
         textStyle: const TextStyle(
           fontSize: 12, 
           fontWeight: FontWeight.bold, 
           color: Color(0xFF2563EB)
         ),
       );
}