import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../userdashboard.dart';
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Payment amount display
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "₹ ${widget.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              const Text(
                "Select Wallet", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "You'll be redirected to the selected app to complete payment",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Wallet Options in Card Format
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _buildWalletCard("PhonePe", Icons.account_balance_wallet, "phonepe"),
                  _buildWalletCard("Paytm", Icons.account_balance_wallet, "paytm"),
                  _buildWalletCard("Google Pay", Icons.account_balance_wallet, "gpay"),
                ],
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedWallet != null 
                      ? AppColors.buttonColor 
                      : Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
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
                      fontSize: 17, 
                      color: Colors.white,
                      fontWeight: FontWeight.w600
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

  Widget _buildWalletCard(String name, IconData icon, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedWallet = value;
        });
      },
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _selectedWallet == value 
            ? _walletColors[value]!.withOpacity(0.1) 
            : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: _selectedWallet == value 
            ? Border.all(color: _walletColors[value]!, width: 2) 
            : Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _walletColors[value]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                size: 30, 
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