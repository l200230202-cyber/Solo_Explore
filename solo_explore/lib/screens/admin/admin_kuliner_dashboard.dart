import 'package:flutter/material.dart';

class AdminKulinerDashboard extends StatefulWidget {
  const AdminKulinerDashboard({super.key});

  @override
  State<AdminKulinerDashboard> createState() => _AdminKulinerDashboardState();
}

class _AdminKulinerDashboardState extends State<AdminKulinerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // ── Palette ─────────────────────────────────────────────────────────────────
  static const _bg        = Color(0xFF0D1117);
  static const _bgCard    = Color(0xFF161B22);
  static const _bgItem    = Color(0xFF1C2128);
  static const _border    = Color(0xFF30363D);
  static const _green     = Color(0xFF2EA043);
  static const _greenGlow = Color(0xFF3FB950);
  static const _amber     = Color(0xFFD29922);
  static const _blue      = Color(0xFF388BFD);
  static const _orange    = Color(0xFFDB6D28);
  static const _textPri   = Color(0xFFE6EDF3);
  static const _textSec   = Color(0xFF8B949E);
  static const _textMut   = Color(0xFF484F58);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // LOGIKA (tidak diubah)
  // ────────────────────────────────────────────────────────────────────────────

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: _textPri)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _green, width: 0.5),
        ),
      ),
    );
  }

  Future<void> _handleReply(int ratingId, String message) async {
    Navigator.pop(context);
    _showSnackBar("Balasan terkirim!");
  }

  Future<void> _handleDelete(int ratingId) async {
    _showSnackBar("Ulasan berhasil dihapus");
  }

  void _showAddMenuForm() {
    final formKey        = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant_menu_rounded, color: _green, size: 20),
                ),
                const SizedBox(width: 12),
                const Text("Tambah Menu Baru",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: _textPri,
                  )),
              ]),
              const SizedBox(height: 20),
              _inputField(nameController, "Nama Menu", Icons.fastfood_rounded),
              const SizedBox(height: 12),
              _inputField(priceController, "Harga (Rp)", Icons.payments_rounded,
                  type: TextInputType.number),
              const SizedBox(height: 12),
              _inputField(addressController, "Alamat", Icons.location_on_rounded),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      _showSnackBar("Menu berhasil disimpan!");
                    }
                  },
                  child: const Text("SIMPAN KE DATABASE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    )),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: _textPri, fontSize: 14),
      validator: (v) => v!.isEmpty ? "$label wajib diisi" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _textSec, fontSize: 13),
        prefixIcon: Icon(icon, color: _textMut, size: 18),
        filled: true,
        fillColor: _bgItem,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 1),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildMenuTab(),
          _buildRatingTab(),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bgCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: _textSec),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_green, Color(0xFF1A6B2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.explore_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Text('SoloExplore',
          style: TextStyle(
            color: _textPri,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: -0.3,
          )),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _green.withOpacity(0.3), width: 0.5),
          ),
          child: const Text('Admin',
            style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _border, width: 0.5)),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: _greenGlow,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: _greenGlow,
            unselectedLabelColor: _textSec,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
            tabs: const [
              Tab(text: "Beranda"),
              Tab(text: "Menu"),
              Tab(text: "Ulasan"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: _green.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4))],
        borderRadius: BorderRadius.circular(16),
      ),
      child: FloatingActionButton(
        backgroundColor: _green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white),
        onPressed: () => _showAddMenuForm(),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TAB 1: BERANDA
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    return RefreshIndicator(
      color: _green,
      backgroundColor: _bgCard,
      onRefresh: () async => print("Refresh data..."),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero banner
          _buildHeroBanner(),
          const SizedBox(height: 20),
          _buildStatGrid(),
          const SizedBox(height: 24),
          _sectionHeader("Aktivitas Terbaru", Icons.bolt_rounded),
          const SizedBox(height: 12),
          _activityTile("Pesanan Baru", "Sate Kambing - Meja 4", "Baru saja", _orange),
          _activityTile("Rating Baru", "5 Bintang dari Rafi", "10 mnt lalu", _amber),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3D1F), Color(0xFF1A2F1A), Color(0xFF161B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _green.withOpacity(0.2), width: 0.5),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 30, bottom: -30,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  const Text("🍜", style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text("Selamat datang kembali!",
                    style: TextStyle(color: _textSec, fontSize: 12)),
                ]),
                const SizedBox(height: 6),
                const Text("Dashboard Kuliner\n& Wisata Solo",
                  style: TextStyle(
                    color: _textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  )),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green.withOpacity(0.3), width: 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: _greenGlow, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text("Sistem aktif", style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final stats = [
      _StatData("Views", "1.2k", "↑ 12%", Icons.visibility_rounded, _blue),
      _StatData("Rating", "4.9", "★ Terbaik", Icons.star_rounded, _amber),
      _StatData("Menu", "24", "+2 baru", Icons.restaurant_menu_rounded, _green),
      _StatData("Pesan", "15", "Hari ini", Icons.receipt_long_rounded, _orange),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      children: stats.map((s) => _statCard(s)).toList(),
    );
  }

  Widget _statCard(_StatData s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.label,
                style: const TextStyle(color: _textSec, fontSize: 11, fontWeight: FontWeight.w500)),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: s.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(s.icon, color: s.color, size: 15),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.value,
                style: TextStyle(
                  color: s.color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                )),
              Text(s.sub,
                style: const TextStyle(color: _textMut, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: _green, size: 16),
      const SizedBox(width: 8),
      Text(title,
        style: const TextStyle(
          color: _textPri,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        )),
    ]);
  }

  Widget _activityTile(String title, String sub, String time, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 6)]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: _textPri, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(sub, style: const TextStyle(color: _textSec, fontSize: 12)),
        ])),
        Text(time, style: const TextStyle(color: _textMut, fontSize: 10)),
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TAB 2: MENU
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildMenuTab() {
    return Column(
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: _bgCard,
            border: Border(bottom: BorderSide(color: _border, width: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daftar Menu Aktif",
                style: TextStyle(color: _textPri, fontWeight: FontWeight.w700, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("24 Item",
                  style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            padding: const EdgeInsets.all(14),
            itemBuilder: (context, index) => _menuCard(index),
          ),
        ),
      ],
    );
  }

  Widget _menuCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            child: Stack(
              children: [
                Image.network(
                  'https://via.placeholder.com/150',
                  width: 90, height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90, height: 90,
                    color: _bgItem,
                    child: const Icon(Icons.restaurant, color: _textMut, size: 28),
                  ),
                ),
                // Overlay gradient
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, _bgCard.withOpacity(0.3)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sate Kambing Spesial $index",
                    style: const TextStyle(
                      color: _textPri,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                  const SizedBox(height: 4),
                  Text("Rp 35.000",
                    style: const TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    )),
                  const SizedBox(height: 10),
                  Row(children: [
                    _menuActionBtn(Icons.edit_rounded, _blue, "Edit",
                      () => _showEditMenuDialog(index)),
                    const SizedBox(width: 14),
                    _menuActionBtn(Icons.delete_rounded, const Color(0xFFDA3633), "Hapus",
                      () => _showConfirmDeleteMenu(index)),
                  ]),
                ],
              ),
            ),
          ),
          // Toggle
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Aktif",
                  style: TextStyle(color: _textMut, fontSize: 9, letterSpacing: 0.3)),
                Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: _greenGlow,
                  activeTrackColor: _green.withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuActionBtn(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // TAB 3: RATING
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildRatingTab() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.all(14),
      itemBuilder: (context, index) => _ratingCard(index),
    );
  }

  Widget _ratingCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _bgItem,
                  shape: BoxShape.circle,
                  border: Border.all(color: _border),
                ),
                child: const Icon(Icons.person_rounded, color: _textSec, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Rafi Ardiansyah",
                  style: TextStyle(color: _textPri, fontWeight: FontWeight.w600, fontSize: 13)),
                const Text("2 jam lalu",
                  style: TextStyle(color: _textMut, fontSize: 11)),
              ])),
              GestureDetector(
                onTap: () => _showConfirmDelete(index),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDA3633).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_rounded,
                    color: Color(0xFFDA3633), size: 16),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Stars
            Row(children: List.generate(5, (i) => Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                i < 5 ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: i < 5 ? _amber : _textMut,
              ),
            ))),
            const SizedBox(height: 8),
            const Text("Satenya juara! Bumbunya pas.",
              style: TextStyle(color: _textSec, fontSize: 13, height: 1.5)),
            const SizedBox(height: 14),
            Divider(height: 0, color: _border.withOpacity(0.5)),
            const SizedBox(height: 10),
            // Reply button
            GestureDetector(
              onTap: () => _showReplyDialog("Rafi", index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _green.withOpacity(0.2), width: 0.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.reply_rounded, color: _green, size: 15),
                  SizedBox(width: 6),
                  Text("Balas Ulasan",
                    style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS (tidak diubah)
  // ────────────────────────────────────────────────────────────────────────────

  void _showEditMenuDialog(int id) => _showSnackBar("Edit Menu $id");

  void _showConfirmDeleteMenu(int id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Menu?", style: TextStyle(color: _textPri)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Batal", style: TextStyle(color: _textSec)),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(String name, int id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => Container(
        padding: const EdgeInsets.all(20),
        child: const Text("Form Balas", style: TextStyle(color: _textPri)),
      ),
    );
  }

  void _showConfirmDelete(int id) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Ulasan?", style: TextStyle(color: _textPri)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("Batal", style: TextStyle(color: _textSec)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _bgCard,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F3D1F), Color(0xFF1C2128)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _green.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.explore_rounded, color: _greenGlow, size: 24),
                ),
                const SizedBox(height: 10),
                const Text("SoloExplore",
                  style: TextStyle(
                    color: _textPri,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  )),
                const Text("Admin Panel",
                  style: TextStyle(color: _textSec, fontSize: 12)),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard_rounded, "Dashboard"),
          _drawerItem(Icons.restaurant_menu_rounded, "Kelola Menu"),
          _drawerItem(Icons.star_rounded, "Ulasan"),
          _drawerItem(Icons.settings_rounded, "Pengaturan"),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: _textSec, size: 20),
      title: Text(label, style: const TextStyle(color: _textSec, fontSize: 13)),
      onTap: () {},
      dense: true,
    );
  }
}

// ── Helper data class ─────────────────────────────────────────────────────────
class _StatData {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.sub, this.icon, this.color);
}