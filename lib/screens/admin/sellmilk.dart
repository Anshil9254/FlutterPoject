import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../color.dart'; // Import your color file

class SellMilkPage extends StatefulWidget {
  const SellMilkPage({super.key});

  @override
  State<SellMilkPage> createState() => _SellMilkPageState();
}

class _SellMilkPageState extends State<SellMilkPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _animalType = "Cow";
  bool _isLoading = false;
  double _totalPrice = 0.0;
  double _cowPricePerLiter = 50.0; // Price per liter for cow milk
  double _buffaloPricePerLiter = 60.0; // Price per liter for buffalo milk

  // Focus nodes to manage keyboard
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _codeController.addListener(() {
      if (_nameController.text.isNotEmpty) {
        _nameController.clear();
      }
    });
    _quantityController.addListener(_calculateTotalPrice);
  }

  @override
  void dispose() {
    _codeFocusNode.dispose();
    _nameFocusNode.dispose();
    _quantityFocusNode.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    try {
      // Load Cow price per liter
      final cowQuery = await FirebaseFirestore.instance
          .collection('prices')
          .where('animalType', isEqualTo: 'Cow')
          .limit(1)
          .get();

      if (cowQuery.docs.isNotEmpty) {
        setState(() {
          _cowPricePerLiter = (cowQuery.docs.first.data()['pricePerLiter'] ?? 50.0).toDouble();
        });
      }

      // Load Buffalo price per liter
      final buffaloQuery = await FirebaseFirestore.instance
          .collection('prices')
          .where('animalType', isEqualTo: 'Buffalo')
          .limit(1)
          .get();

      if (buffaloQuery.docs.isNotEmpty) {
        setState(() {
          _buffaloPricePerLiter = (buffaloQuery.docs.first.data()['pricePerLiter'] ?? 60.0).toDouble();
        });
      }
    } catch (e) {
      print("Error loading prices: $e");
    }
  }

  void _calculateTotalPrice() {
    if (_quantityController.text.isNotEmpty) {
      try {
        final double quantity = double.parse(_quantityController.text);
        final double pricePerLiter = _animalType == "Cow" ? _cowPricePerLiter : _buffaloPricePerLiter;
        
        setState(() {
          _totalPrice = quantity * pricePerLiter;
        });
      } catch (e) {
        setState(() {
          _totalPrice = 0.0;
        });
      }
    } else {
      setState(() {
        _totalPrice = 0.0;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: AppColors.datePickerColorScheme,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fetch user from 'users' collection
  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Generate unique key for milk sale (date + animalType) in DD-MM-YYYY format
  String _generateSaleKey() {
    final String dateStr = "${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}";
    return "${dateStr}_$_animalType";
  }

  // Generate monthYear for reporting (MM-YYYY format)
  String _generateMonthYear() {
    return "${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}";
  }

  // Check if sale already exists for this date and animal type
  Future<Map<String, dynamic>?> _findExistingSale(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('milk_sales')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data()?['salesEntries'] != null) {
        final Map<String, dynamic> salesEntries = userDoc.data()!['salesEntries'];
        final String saleKey = _generateSaleKey();
        
        if (salesEntries.containsKey(saleKey)) {
          return salesEntries[saleKey];
        }
      }
      return null;
    } catch (e) {
      print("Error finding existing sale: $e");
      return null;
    }
  }

  // Calculate total amount from all sales entries
  double _calculateTotalAmountFromEntries(Map<String, dynamic> salesEntries) {
    double total = 0.0;
    salesEntries.forEach((key, entry) {
      total += (entry['totalPrice'] as double? ?? 0.0);
    });
    return total;
  }

  Future<void> _fetchUserByCode() async {
    if (_codeController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userData = await _fetchUserData(_codeController.text);
      
      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        FocusScope.of(context).requestFocus(_quantityFocusNode);
        
        // Check if there's an existing sale for today with current animal type
        final existingSale = await _findExistingSale(_codeController.text);
        if (existingSale != null) {
          setState(() {
            _quantityController.text = (existingSale['quantity'] as double).toString();
            _totalPrice = (existingSale['totalPrice'] as double);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Existing ${_animalType.toLowerCase()} sale found for ${_generateSaleKey()} - Pre-filled form"),
              backgroundColor: Colors.blue,
            ),
          );
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User found: ${userData['name']}"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _nameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User with ID ${_codeController.text} not found in users collection"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching user data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitMilkSale() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a user ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please search for a user first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in quantity"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double quantity = double.parse(_quantityController.text);
    final double pricePerLiter = _animalType == "Cow" ? _cowPricePerLiter : _buffaloPricePerLiter;
    
    // Create milk sale entry object
    final milkSaleEntry = {
      'animalType': _animalType,
      'date': Timestamp.fromDate(_selectedDate),
      'quantity': quantity,
      'pricePerLiter': pricePerLiter,
      'totalPrice': _totalPrice,
      'timestamp': Timestamp.now(),
      'monthYear': _generateMonthYear(), // For monthly reports
    };

    try {
      final userId = _codeController.text;
      final userDoc = FirebaseFirestore.instance.collection('milk_sales').doc(userId);
      final String saleKey = _generateSaleKey();
      
      // Check if user document exists in milk_sales collection
      final userSnapshot = await userDoc.get();
      
      // Check if sale already exists for this date and animal type
      final existingSale = await _findExistingSale(userId);
      
      if (existingSale != null) {
        // Update existing sale - get current data first
        final currentData = userSnapshot.data()!;
        final Map<String, dynamic> currentSalesEntries = Map<String, dynamic>.from(currentData['salesEntries'] ?? {});
        
        // Update the specific entry
        currentSalesEntries[saleKey] = milkSaleEntry;
        
        // Calculate new total amount
        final double newTotalAmount = _calculateTotalAmountFromEntries(currentSalesEntries);
        final int totalEntries = currentSalesEntries.length;
        
        await userDoc.update({
          'salesEntries.$saleKey': milkSaleEntry,
          'name': _nameController.text,
          'TotalAmount': newTotalAmount,
          'totalEntries': totalEntries,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ ${_animalType} sale updated for ${_nameController.text} - ₹${_totalPrice.toStringAsFixed(2)}"),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Add new sale entry
        if (userSnapshot.exists) {
          // User exists - add to existing salesEntries map
          final currentData = userSnapshot.data()!;
          final Map<String, dynamic> currentSalesEntries = Map<String, dynamic>.from(currentData['salesEntries'] ?? {});
          
          // Add new entry
          currentSalesEntries[saleKey] = milkSaleEntry;
          
          // Calculate new total amount
          final double newTotalAmount = _calculateTotalAmountFromEntries(currentSalesEntries);
          final int totalEntries = currentSalesEntries.length;
          
          await userDoc.update({
            'salesEntries': currentSalesEntries,
            'name': _nameController.text,
            'TotalAmount': newTotalAmount,
            'totalEntries': totalEntries,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // User doesn't exist - create new document with complete structure
          await userDoc.set({
            'code': userId,
            'name': _nameController.text,
            'TotalAmount': _totalPrice,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
            'totalEntries': 1,
            'salesEntries': {
              saleKey: milkSaleEntry
            },
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ New ${_animalType.toLowerCase()} sale submitted for ${_nameController.text} - ₹${_totalPrice.toStringAsFixed(2)}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      _clearForm();
      
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error submitting sale: $error"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      print("Detailed error: $error");
    }
  }

  void _clearForm() {
    _codeController.clear();
    _nameController.clear();
    _quantityController.clear();
    setState(() {
      _animalType = "Cow";
      _totalPrice = 0.0;
      _selectedDate = DateTime.now();
    });
    FocusScope.of(context).requestFocus(_codeFocusNode);
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return "January";
      case 2: return "February";
      case 3: return "March";
      case 4: return "April";
      case 5: return "May";
      case 6: return "June";
      case 7: return "July";
      case 8: return "August";
      case 9: return "September";
      case 10: return "October";
      case 11: return "November";
      case 12: return "December";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Using bgColor from AppColors
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        automaticallyImplyLeading: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor, // Using cardColor from AppColors
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.boxShadow, // Using boxShadow from AppColors
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/milk_bottle.png'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Sell Milk",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, // Using textPrimary from AppColors
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor, // Using cardColor from AppColors
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.boxShadow, // Using boxShadow from AppColors
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Row with Price Badge
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textSecondary), // Using textSecondary from AppColors
                                  const SizedBox(width: 10),
                                  Text(
                                    "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary), // Using textPrimary from AppColors
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Current Price Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _animalType == "Cow" ? Colors.blue.shade100 : Colors.orange.shade100,
                                _animalType == "Cow" ? Colors.blue.shade50 : Colors.orange.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _animalType == "Cow" ? Colors.blue.shade300 : Colors.orange.shade300,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.price_change,
                                size: 14,
                                color: _animalType == "Cow" ? Colors.blue.shade700 : Colors.orange.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "₹${_animalType == "Cow" ? _cowPricePerLiter.toStringAsFixed(1) : _buffaloPricePerLiter.toStringAsFixed(1)}/L",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _animalType == "Cow" ? Colors.blue.shade800 : Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Code No.
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("User ID",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: Stack(
                        children: [
                          TextField(
                            controller: _codeController,
                            focusNode: _codeFocusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              hintText: "Enter user ID and press Enter",
                              suffixIcon: _isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.search, size: 20),
                                      onPressed: _fetchUserByCode,
                                    ),
                            ),
                            onSubmitted: (value) => _fetchUserByCode(),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Name",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quantity & Animal Type Row
                    Row(
                      children: [
                        // Quantity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Text("Quantity (lit.)",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: TextField(
                                  controller: _quantityController,
                                  focusNode: _quantityFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    hintText: "0.0",
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (value) {
                                    _submitMilkSale();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Animal Type Dropdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Text("Animal Type",
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: DropdownButtonFormField<String>(
                                  value: _animalType,
                                  items: ["Cow", "Buffalo"]
                                      .map((e) =>
                                          DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _animalType = val!;
                                      _calculateTotalPrice();
                                    });
                                    // Check for existing sale when animal type changes
                                    if (_codeController.text.isNotEmpty) {
                                      _fetchUserByCode();
                                    }
                                  },
                                  dropdownColor: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 0),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: AppColors.textSecondary), // Using textSecondary from AppColors
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Total Price
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade100, Colors.green.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade100,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calculate, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                "Total Price:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "₹ ${_totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppColors.elevatedButtonStyle,
                        onPressed: _submitMilkSale,
                        child: const Text(
                          "SUBMIT ENTRY",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
