import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../user/userdashboard.dart';
import '../color.dart';

// Wallet Payment Page (Centered)
class WalletPaymentPage extends StatefulWidget {
  final double amount; // Amount to be paid
  
  const WalletPaymentPage({super.key, required this.amount});
  
  @override
  State<WalletPaymentPage> createState() => _WalletPaymentPageState();
}

class _WalletPaymentPageState extends State<WalletPaymentPage> {
  String? _selectedWallet;
  
  // Wallet app display names
  final Map<String, String> _walletDisplayNames = {
    'phonepe': 'PhonePe',
    'paytm': 'Paytm',
    'gpay': 'Google Pay',
  };
  
  // Wallet app colors
  final Map<String, Color> _walletColors = {
    'phonepe': const Color(0xFF673AB7), // PhonePe purple
    'paytm': const Color(0xFF20336B),   // Paytm blue
    'gpay': const Color(0xFF4285F4),    // Google blue
  };
  
  // Function to generate UPI deep links with proper parameters
  String _generateUpiDeepLink(String walletApp, double amount) {
    // Replace these with your actual UPI details
    const upiId = 'bhuvaanshil9436@okicici'; // Your UPI ID
    const recipientName = 'Your Business Name'; // Your business name
    const transactionNote = 'Payment for services'; // Payment description
    
    // Generate a unique transaction ID
    final transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    
    switch (walletApp) {
      case 'phonepe':
        return 'phonepe://pay?pa=$upiId&pn=$recipientName&mc=0000&tid=$transactionId&tr=$transactionId&tn=$transactionNote&am=$amount&cu=INR';
      case 'paytm':
        return 'paytmmp://pay?pa=$upiId&pn=$recipientName&mc=0000&tid=$transactionId&tr=$transactionId&tn=$transactionNote&am=$amount&cu=INR';
      case 'gpay':
        return 'tez://upi/pay?pa=$upiId&pn=$recipientName&mc=0000&tid=$transactionId&tr=$transactionId&tn=$transactionNote&am=$amount&cu=INR';
      default:
        return '';
    }
  }

  // Web fallback URLs if app is not installed
  final Map<String, String> _walletWebUrls = {
    'phonepe': 'https://www.phonepe.com/',
    'paytm': 'https://paytm.com/',
    'gpay': 'https://pay.google.com/',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Wallet Payment", 
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // Decorative header
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.boxShadow,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.goldLight,
                      AppColors.goldLight.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Payment illustration
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 40,
                        color: AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Payment amount display
                    Text(
                      "₹ ${widget.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Total Amount to Pay",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Wallet selection section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.boxShadow,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Select Wallet", 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "You'll be redirected to the selected app to complete payment",
                      style: TextStyle(
                        fontSize: 14, 
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    
                    // Wallet Options in Card Format
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 5),
                          _buildWalletCard("PhonePe", Icons.payment, "phonepe"),
                          const SizedBox(width: 15),
                          _buildWalletCard("Paytm", Icons.account_balance_wallet, "paytm"),
                          const SizedBox(width: 15),
                          _buildWalletCard("Google Pay", Icons.payment, "gpay"),
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedWallet != null 
                      ? AppColors.buttonColor 
                      : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    shadowColor: AppColors.shadowColor,
                  ),
                  onPressed: _selectedWallet == null 
                    ? null
                    : () async {
                        // Generate the deep link with the correct amount
                        final deepLink = _generateUpiDeepLink(_selectedWallet!, widget.amount);
                        
                        // Open the selected wallet app
                        bool opened = await _openWalletApp(_selectedWallet!, deepLink);
                        
                        if (opened) {
                          // Show processing dialog
                          _showProcessingDialog(context);
                          
                          // Simulate payment processing
                          await Future.delayed(const Duration(seconds: 3));
                          
                          // Close processing dialog
                          Navigator.pop(context);
                          
                          // Show success dialog
                          _showPaymentSuccess(context, _selectedWallet!);
                        } else {
                          // Show error if app not installed
                          _showAppNotInstalledDialog(context, _selectedWallet!);
                        }
                      },
                  child: Text(
                    "Pay ₹ ${widget.amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18, 
                      color: Colors.white,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(String name, IconData icon, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWallet = value;
        });
      },
      child: Container(
        width: 110,
        height: 130,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _selectedWallet == value 
            ? _walletColors[value]!.withOpacity(0.1) 
            : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: _selectedWallet == value 
            ? Border.all(color: _walletColors[value]!, width: 2) 
            : Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: AppColors.boxShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _walletColors[value]!.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: 28, 
                color: _walletColors[value],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600,
                color: _selectedWallet == value 
                  ? _walletColors[value] 
                  : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _openWalletApp(String walletApp, String deepLink) async {
    try {
      final Uri url = Uri.parse(deepLink);
      
      // Try to launch the app
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      } else {
        // If app is not installed, try to open web version
        final String webUrl = _walletWebUrls[walletApp]!;
        final Uri webUri = Uri.parse(webUrl);
        
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }

  void _showProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Processing Payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  "Completing payment via ${_walletDisplayNames[_selectedWallet!]}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSuccess(BuildContext context, String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, 
                         color: Colors.green, size: 60),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text("Paid via ${_walletDisplayNames[method]}", 
                     style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Dashboard
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Userdashboard()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text("Go to Dashboard", 
                         style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAppNotInstalledDialog(BuildContext context, String walletApp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgColor,
          title: const Text("App Not Installed"),
          content: Text(
            "${_walletDisplayNames[walletApp]} is not installed on your device. "
            "Please install it to continue with the payment.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}