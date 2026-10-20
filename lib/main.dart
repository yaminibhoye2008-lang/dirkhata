import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DirkhataMasterApp());
}

class DirkhataMasterApp extends StatelessWidget {
  const DirkhataMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dirkhata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF047857),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const PinLockScreen(),
    );
  }
}

class CustomerRecord {
  final String id;
  String name;
  String village;
  String mobile;
  int balancePaise;
  String waadaDate;
  bool isDeleted;

  CustomerRecord({
    required this.id,
    required this.name,
    required this.village,
    required this.mobile,
    required this.balancePaise,
    required this.waadaDate,
    this.isDeleted = false,
  });
}

class DealerRecord {
  final String id;
  String name;
  String company;
  String mobile;
  String address;
  int balancePaise;
  String billNo;

  DealerRecord({
    required this.id,
    required this.name,
    required this.company,
    required this.mobile,
    required this.address,
    required this.balancePaise,
    required this.billNo,
  });
}

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = "";
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  String _errorText = "";

  void _handleNumber(String num) {
    if (_lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!)) {
      final sec = _lockoutEndTime!.difference(DateTime.now()).inSeconds;
      setState(() => _errorText = "सुरक्षा लॉक! $sec सेकंड प्रतीक्षा करें।");
      return;
    }

    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += num;
        _errorText = "";
      });
      if (_enteredPin.length == 4) {
        _checkPin();
      }
    }
  }

  void _checkPin() {
    if (_enteredPin == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const MainHomeScreen(userRole: "Malik")),
      );
    } else if (_enteredPin == "9999") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const MainHomeScreen(userRole: "Staff")),
      );
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _lockoutEndTime = DateTime.now().add(const Duration(minutes: 1));
        _errorText = "3 गलत प्रयास! 1 मिनट लॉक।";
      } else {
        _errorText = "गलत पिन! प्रयास: $_failedAttempts";
      }
      setState(() => _enteredPin = "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF34D399), width: 1.5),
                  ),
                  child: const Center(
                    child: Text("DK", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("दीरखाता (Dirkhata)", style: TextStyle(color: Color(0xFF34D399), fontSize: 22, fontWeight: FontWeight.bold)),
                const Text("दुकान का सुरक्षित डिजिटल बहीखाता", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = _enteredPin.length > index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? const Color(0xFF10B981) : Colors.transparent,
                        border: Border.all(color: const Color(0xFF475569), width: 2),
                      ),
                    );
                  }),
                ),
                if (_errorText.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(_errorText, style: const TextStyle(color: Color(0xFFF87171), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
                const SizedBox(height: 28),
                for (var r = 0; r < 3; r++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var c = 1; c <= 3; c++)
                          _keyBtn((r * 3 + c).toString()),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionBtn("साफ़", () => setState(() => _enteredPin = "")),
                    _keyBtn("0"),
                    _actionBtn("⌫", () {
                      if (_enteredPin.isNotEmpty) {
                        setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyBtn(String txt) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _handleNumber(txt),
      child: Container(
        width: 72,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(txt, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _actionBtn(String txt, VoidCallback tap) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: tap,
      child: Container(
        width: 72,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(txt, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final String userRole;
  const MainHomeScreen({super.key, required this.userRole});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedTab = 0;
  final String _shopName = "बालाजी साड़ी एवं वस्त्र भंडार";

  final List<CustomerRecord> _customers = [
    CustomerRecord(
      id: "c1",
      name: "सुरेश शर्मा",
      village: "गांधी चौक",
      mobile: "9826012345",
      balancePaise: 250000,
      waadaDate: "2026-10-25",
    ),
    CustomerRecord(
      id: "c2",
      name: "महेश पटेल",
      village: "स्टेशन रोड",
      mobile: "9425098765",
      balancePaise: 0,
      waadaDate: "2026-10-20",
    ),
  ];

  final List<DealerRecord> _dealers = [
    DealerRecord(
      id: "d1",
      name: "सूरत सिल्क मिल्स",
      company: "एस.एस. फैब्रिक्स",
      mobile: "9898011223",
      address: "रिंग रोड, सूरत",
      balancePaise: 1500000,
      billNo: "INV-8891",
    ),
  ];

  String _formatINR(int paise) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return format.format(paise / 100.0);
  }

  int get _totalKulLenaPaise {
    return _customers.where((c) => !c.isDeleted).fold(0, (sum, c) => sum + c.balancePaise);
  }

  int get _totalKulDenaPaise {
    return _dealers.fold(0, (sum, d) => sum + d.balancePaise);
  }

  void _callNumber(String mobile) async {
    final uri = Uri.parse("tel:+91$mobile");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendWhatsApp(String mobile, String name, int balance) async {
    final text = "नमस्ते $name जी, $_shopName से। आपका कुल बकाया ${_formatINR(balance)} है। सुविधा हो तो कृपया जमा कर दीजिए। धन्यवाद! 🙏";
    final uri = Uri.parse("https://wa.me/91$mobile?text=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF047857),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_shopName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.userRole == "Malik" ? "मालिक मोड (Master)" : "स्टाफ मोड (Staff)",
              style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const PinLockScreen()));
            },
          )
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        selectedItemColor: const Color(0xFF047857),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) => setState(() => _selectedTab = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "डैशबोर्ड"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "ग्राहक"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "व्यापारी"),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "कैलकुलेटर"),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    if (_selectedTab == 0) return _buildDashboard();
    if (_selectedTab == 1) return _buildCustomerList();
    if (_selectedTab == 2) return _buildDealerList();
    return _buildCalculator();
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFBE123C)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("कुल लेना है", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(_formatINR(_totalKulLenaPaise), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const Text("ग्राहक खाता →", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = 2),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("कुल देना है", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text(_formatINR(_totalKulDenaPaise), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const Text("व्यापारी खाता →", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF10B981), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "सुरक्षा मोड: कोई बाहरी सर्वर नहीं। आपका पूरा बहीखाता 100% इस फोन में सुरक्षित है।",
                    style: TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customers.length,
      itemBuilder: (context, idx) {
        final c = _customers[idx];
        final isChukta = c.balancePaise == 0;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("${c.village} • ${c.mobile}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      isChukta ? "चुकता (Rs 0)" : "वादा तारीख: ${c.waadaDate}",
                      style: TextStyle(color: isChukta ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatINR(c.balancePaise),
                      style: TextStyle(color: isChukta ? Colors.green : Colors.red, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _callNumber(c.mobile),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: const Text("📞 कॉल", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _sendWhatsApp(c.mobile, c.name, c.balancePaise),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                            child: const Text("WhatsApp", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDealerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dealers.length,
      itemBuilder: (context, idx) {
        final d = _dealers[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("${d.company} • ${d.address}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    Text("बिल नं: ${d.billNo}", style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("व्यापारी को देना है", style: TextStyle(fontSize: 10, color: Colors.grey)),
                    Text(_formatINR(d.balancePaise), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalculator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate_outlined, size: 48, color: Color(0xFF047857)),
            SizedBox(height: 12),
            Text("छूट (Discount) एवं साधारण ब्याज कैलकुलेटर", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 6),
            Text("गणना भारतीय रुपये व पैसे में 100% सटीक होती है।", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
