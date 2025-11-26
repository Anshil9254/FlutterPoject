import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../color.dart';
import 'buymilk_pricechange.dart';

class MilkEntryPage extends StatefulWidget {
  const MilkEntryPage({super.key});

  @override
  State<MilkEntryPage> createState() => _MilkEntryPageState();
}

class _MilkEntryPageState extends State<MilkEntryPage> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  String _animalType = "Cow";
  bool _isLoading = false;
  double _totalPrice = 0.0;
  double _cowPricePerFat = 8.0;
  double _buffaloPricePerFat = 10.0;

  // Focus nodes to manage keyboard
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _fatFocusNode = FocusNode();

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
    _fatController.addListener(_calculateTotalPrice);
  }

  @override
  void dispose() {
    _codeFocusNode.dispose();
    _nameFocusNode.dispose();
    _quantityFocusNode.dispose();
    _fatFocusNode.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    try {
      // Load Cow price
      final cowQuery = await FirebaseFirestore.instance
          .collection('prices')
          .where('animalType', isEqualTo: 'Cow')
          .limit(1)
          .get();

      if (cowQuery.docs.isNotEmpty) {
        setState(() {
          _cowPricePerFat = (cowQuery.docs.first.data()['pricePerFat'] ?? 8.0).toDouble();
        });
      }

      // Load Buffalo price
      final buffaloQuery = await FirebaseFirestore.instance
          .collection('prices')
          .where('animalType', isEqualTo: 'Buffalo')
          .limit(1)
          .get();

      if (buffaloQuery.docs.isNotEmpty) {
        setState(() {
          _buffaloPricePerFat = (buffaloQuery.docs.first.data()['pricePerFat'] ?? 10.0).toDouble();
        });
      }
    } catch (e) {
      print("Error loading prices: $e");
    }
  }

  void _calculateTotalPrice() {
    if (_quantityController.text.isNotEmpty && _fatController.text.isNotEmpty) {
      try {
        final double quantity = double.parse(_quantityController.text);
        final double fat = double.parse(_fatController.text);
        final double pricePerFat = _animalType == "Cow" ? _cowPricePerFat : _buffaloPricePerFat;
        
        setState(() {
          _totalPrice = quantity * fat * pricePerFat;
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

  // Generate unique key for milk entry (date + animalType) in DD-MM-YYYY format
  String _generateEntryKey() {
    final String dateStr = "${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}";
    return "${dateStr}_$_animalType";
  }

  // Generate monthYear for reporting (MM-YYYY format)
  String _generateMonthYear() {
    return "${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}";
  }

  // Check if entry already exists for this date and animal type
  Future<Map<String, dynamic>?> _findExistingEntry(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('milk')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data()?['milkEntries'] != null) {
        final Map<String, dynamic> milkEntries = userDoc.data()!['milkEntries'];
        final String entryKey = _generateEntryKey();
        
        if (milkEntries.containsKey(entryKey)) {
          return milkEntries[entryKey];
        }
      }
      return null;
    } catch (e) {
      print("Error finding existing entry: $e");
      return null;
    }
  }

  // Calculate total amount from all milk entries
  double _calculateTotalAmountFromEntries(Map<String, dynamic> milkEntries) {
    double total = 0.0;
    milkEntries.forEach((key, entry) {
      total += (entry['totalPrice'] as double? ?? 0.0);
    });
    return total;
  }

  Future<void> _fetchUserByNameCode() async {
    if (_codeController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userData = await _fetchUserData(_codeController.text);
      
      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        FocusScope.of(context).requestFocus(_quantityFocusNode);
        
        // Check if there's an existing entry for today with current animal type
        final existingEntry = await _findExistingEntry(_codeController.text);
        if (existingEntry != null) {
          setState(() {
            _quantityController.text = (existingEntry['quantity'] as double).toString();
            _fatController.text = (existingEntry['fat'] as double).toString();
            _totalPrice = (existingEntry['totalPrice'] as double);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Existing ${_animalType.toLowerCase()} entry found for ${_generateEntryKey()} - Pre-filled form"),
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

  void _submitMilkEntry() async {
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
    
    if (_quantityController.text.isEmpty || _fatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in quantity and fat percentage"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double quantity = double.parse(_quantityController.text);
    final double fat = double.parse(_fatController.text);
    final double pricePerFat = _animalType == "Cow" ? _cowPricePerFat : _buffaloPricePerFat;
    
    // Create milk entry object with the exact structure
    final milkEntry = {
      'animalType': _animalType,
      'date': Timestamp.fromDate(_selectedDate),
      'quantity': quantity,
      'fat': fat,
      'pricePerFat': pricePerFat,
      'totalPrice': _totalPrice,
      'timestamp': Timestamp.now(),
      'monthYear': _generateMonthYear(), // For monthly reports
    };

    try {
      final userId = _codeController.text;
      final userDoc = FirebaseFirestore.instance.collection('milk').doc(userId);
      final String entryKey = _generateEntryKey();
      
      // Check if user document exists in milk collection
      final userSnapshot = await userDoc.get();
      
      // Check if entry already exists for this date and animal type
      final existingEntry = await _findExistingEntry(userId);
      
      if (existingEntry != null) {
        // Update existing entry - get current data first
        final currentData = userSnapshot.data()!;
        final Map<String, dynamic> currentMilkEntries = Map<String, dynamic>.from(currentData['milkEntries'] ?? {});
        
        // Update the specific entry
        currentMilkEntries[entryKey] = milkEntry;
        
        // Calculate new total amount
        final double newTotalAmount = _calculateTotalAmountFromEntries(currentMilkEntries);
        final int totalEntries = currentMilkEntries.length;
        
        await userDoc.update({
          'milkEntries.$entryKey': milkEntry,
          'name': _nameController.text,
          'TotalAmount': newTotalAmount,
          'remainingAmount': newTotalAmount - (currentData['paidAmount'] ?? 0),
          'totalEntries': totalEntries,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ ${_animalType} entry updated for ${_nameController.text} - ₹${_totalPrice.toStringAsFixed(2)}"),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Add new entry
        if (userSnapshot.exists) {
          // User exists - add to existing milkEntries map
          final currentData = userSnapshot.data()!;
          final Map<String, dynamic> currentMilkEntries = Map<String, dynamic>.from(currentData['milkEntries'] ?? {});
          
          // Add new entry
          currentMilkEntries[entryKey] = milkEntry;
          
          // Calculate new total amount
          final double newTotalAmount = _calculateTotalAmountFromEntries(currentMilkEntries);
          final int totalEntries = currentMilkEntries.length;
          final double paidAmount = currentData['paidAmount'] ?? 0;
          
          await userDoc.update({
            'milkEntries': currentMilkEntries,
            'name': _nameController.text,
            'TotalAmount': newTotalAmount,
            'remainingAmount': newTotalAmount - paidAmount,
            'totalEntries': totalEntries,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          // User doesn't exist - create new document with complete structure
          await userDoc.set({
            'code': userId,
            'name': _nameController.text,
            'paymentStatus': 'pending',
            'TotalAmount': _totalPrice,
            'paidAmount': 0.0,
            'remainingAmount': _totalPrice,
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
            'lastPaymentDate': null,
            'totalEntries': 1,
            'milkEntries': {
              entryKey: milkEntry
            },
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ New ${_animalType.toLowerCase()} entry submitted for ${_nameController.text} - ₹${_totalPrice.toStringAsFixed(2)}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      _clearForm();
      
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error submitting entry: $error"),
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
    _fatController.clear();
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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        automaticallyImplyLeading: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PriceManagementPage()),
              ).then((_) => _loadPrices());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.boxShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.inputFieldColor,
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/milk_bottle.png'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Milk Entry",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.boxShadow,
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
                                color: AppColors.inputFieldColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
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
                                "₹${_animalType == "Cow" ? _cowPricePerFat.toStringAsFixed(1) : _buffaloPricePerFat.toStringAsFixed(1)}/fat",
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
                    const SizedBox(height: 16),

                    // Code No.
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("User ID", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: Stack(
                        children: [
                          TextField(
                            controller: _codeController,
                            focusNode: _codeFocusNode,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.inputFieldColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                      onPressed: _fetchUserByNameCode,
                                    ),
                            ),
                            onSubmitted: (value) => _fetchUserByNameCode(),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Animal Type Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("Animal Type", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _animalType,
                                  items: ["Cow", "Buffalo"]
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 8),
                                                Text(e, style: const TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _animalType = val!;
                                      _calculateTotalPrice();
                                    });
                                    // Check for existing entry when animal type changes
                                    if (_codeController.text.isNotEmpty) {
                                      _fetchUserByNameCode();
                                    }
                                  },
                                  dropdownColor: AppColors.inputFieldColor,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quantity & Fat Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Text("Quantity (lit.)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _quantityController,
                                  focusNode: _quantityFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    hintText: "0.0",
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (value) {
                                    FocusScope.of(context).requestFocus(_fatFocusNode);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
                                child: Text("Fat %", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _fatController,
                                  focusNode: _fatFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    hintText: "0.0",
                                  ),
                                  onSubmitted: (value) {
                                    _submitMilkEntry();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Total Price
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade100, Colors.green.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
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
                                "Total Amount:",
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
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppColors.elevatedButtonStyle,
                        onPressed: _submitMilkEntry,
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}