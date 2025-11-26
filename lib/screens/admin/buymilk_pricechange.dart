import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../color.dart';
import '../reusable_header.dart'; // Import the reusable header

class PriceManagementPage extends StatefulWidget {
  const PriceManagementPage({super.key});

  @override
  State<PriceManagementPage> createState() => _PriceManagementPageState();
}

class _PriceManagementPageState extends State<PriceManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _cowPriceController = TextEditingController();
  final TextEditingController _buffaloPriceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load Cow price
      final cowQuery = await _firestore
          .collection('prices')
          .where('animalType', isEqualTo: 'Cow')
          .limit(1)
          .get();

      if (cowQuery.docs.isNotEmpty) {
        final cowPrice = PriceModel.fromMap(
            cowQuery.docs.first.data(), cowQuery.docs.first.id);
        _cowPriceController.text = cowPrice.pricePerFat.toString();
      } else {
        _cowPriceController.text = '8.0'; // Default value
      }

      // Load Buffalo price
      final buffaloQuery = await _firestore
          .collection('prices')
          .where('animalType', isEqualTo: 'Buffalo')
          .limit(1)
          .get();

      if (buffaloQuery.docs.isNotEmpty) {
        final buffaloPrice = PriceModel.fromMap(
            buffaloQuery.docs.first.data(), buffaloQuery.docs.first.id);
        _buffaloPriceController.text = buffaloPrice.pricePerFat.toString();
      } else {
        _buffaloPriceController.text = '10.0'; // Default value
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading prices: $e'),
          backgroundColor: AppColors.buttonColorSecondary,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePrices() async {
    if (_cowPriceController.text.isEmpty ||
        _buffaloPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter prices for both animal types'),
          backgroundColor: AppColors.buttonColorSecondary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double cowPrice = double.parse(_cowPriceController.text);
      final double buffaloPrice = double.parse(_buffaloPriceController.text);

      // Save Cow price
      final cowQuery = await _firestore
          .collection('prices')
          .where('animalType', isEqualTo: 'Cow')
          .limit(1)
          .get();

      if (cowQuery.docs.isNotEmpty) {
        await _firestore
            .collection('prices')
            .doc(cowQuery.docs.first.id)
            .update({
          'pricePerFat': cowPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('prices').add({
          'animalType': 'Cow',
          'pricePerFat': cowPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Save Buffalo price
      final buffaloQuery = await _firestore
          .collection('prices')
          .where('animalType', isEqualTo: 'Buffalo')
          .limit(1)
          .get();

      if (buffaloQuery.docs.isNotEmpty) {
        await _firestore
            .collection('prices')
            .doc(buffaloQuery.docs.first.id)
            .update({
          'pricePerFat': buffaloPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('prices').add({
          'animalType': 'Buffalo',
          'pricePerFat': buffaloPrice,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prices updated successfully!'),
          backgroundColor: AppColors.buttonColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving prices: $e'),
          backgroundColor: AppColors.buttonColorSecondary,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reusable Header
                  ReusableHeader(
                    title: 'Buy Milk Price Management',
                    icon: Icons.price_change_rounded,
                    onBackPressed: () => Navigator.of(context).pop(),
                  ),

                 

                  // Cow Price Card
                  _buildPriceCard(
                    title: 'Cow Milk Price',
                    subtitle: 'Price per fat unit',
                    imagePath: 'assets/cow.png',
                    controller: _cowPriceController,
                  ),
                  const SizedBox(height: 16),

                  // Buffalo Price Card
                  _buildPriceCard(
                    title: 'Buffalo Milk Price',
                    subtitle: 'Price per fat unit',
                    imagePath: 'assets/buffalo.png',
                    controller: _buffaloPriceController,
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.buttonColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: AppColors.textOnGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _savePrices,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_alt_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'SAVE PRICES',
                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              letterSpacing: 1.1,
                                              fontWeight: FontWeight.w600,
                                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, 
                                size: 16, color: AppColors.textSecondary),
                            SizedBox(width: 8),
                            Text(
                              'Price Information',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The price set here will be used to calculate milk payments based on fat content. Ensure prices are updated regularly.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required TextEditingController controller,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.cardColor,
      shadowColor: AppColors.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Animal Image
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback icon if image is not found
                      return Icon(
                        title.contains('Cow') ? Icons.agriculture : Icons.pets,
                        size: 30,
                        color: title.contains('Cow') ? Colors.brown : Colors.grey[700],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.boxShadow,
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  fillColor: AppColors.inputFieldColor,
                  filled: true,
                  prefixIcon: const Icon(Icons.currency_rupee,
                      color: AppColors.goldDark),
                  labelText: 'Enter price per fat',
                  labelStyle: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.gold,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class PriceModel {
  final String id;
  final String animalType;
  final double pricePerFat;
  final DateTime updatedAt;

  PriceModel({
    required this.id,
    required this.animalType,
    required this.pricePerFat,
    required this.updatedAt,
  });

  factory PriceModel.fromMap(Map<String, dynamic> data, String id) {
    return PriceModel(
      id: id,
      animalType: data['animalType'] ?? '',
      pricePerFat: (data['pricePerFat'] ?? 0).toDouble(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'animalType': animalType,
      'pricePerFat': pricePerFat,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
