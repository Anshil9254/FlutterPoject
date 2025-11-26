import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../color.dart';
import '../reusable_header.dart';

class SellMilkPaymentPage extends StatefulWidget {
  const SellMilkPaymentPage({super.key});

  @override
  State<SellMilkPaymentPage> createState() => _SellMilkPaymentPageState();
}

class _SellMilkPaymentPageState extends State<SellMilkPaymentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _filteredSuppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _searchController.addListener(_filterSuppliers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final QuerySnapshot snapshot = await _firestore
          .collection('milk_sales')
          .where('TotalAmount', isGreaterThan: 0)
          .get();

      List<Map<String, dynamic>> suppliers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Calculate payment status based on remaining amount
        double totalAmount = (data['TotalAmount'] ?? 0).toDouble();
        double paidAmount = (data['paidAmount'] ?? 0).toDouble();
        double remainingAmount = (data['remainingAmount'] ?? totalAmount).toDouble();
        
        // Status is completed if remaining amount is 0, otherwise pending
        String status = remainingAmount <= 0 ? "completed" : "pending";
        String amount = totalAmount.toStringAsFixed(2);
        
        // Get milk quantities from sales entries
        Map<String, dynamic> milkQuantities = _getMilkQuantities(data['salesEntries'] ?? {});
        String totalQuantity = milkQuantities['totalQuantity'];
        String cowQuantity = milkQuantities['cowQuantity'];
        String buffaloQuantity = milkQuantities['buffaloQuantity'];

        suppliers.add({
          "id": doc.id,
          "name": data['name'] ?? 'Unknown',
          "quantity": totalQuantity,
          "cowQuantity": cowQuantity,
          "buffaloQuantity": buffaloQuantity,
          "amount": amount,
          "status": status,
          "totalAmount": totalAmount,
          "paidAmount": paidAmount,
          "remainingAmount": remainingAmount,
          "code": data['code'] ?? doc.id,
          "salesEntries": data['salesEntries'] ?? {},
          "paymentHistory": data['paymentHistory'] ?? [],
          "profileImage": data['profileImage'] ?? null,
        });
      }

      setState(() {
        _suppliers = suppliers;
        _filteredSuppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading suppliers: $e");
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading suppliers: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _getMilkQuantities(Map<String, dynamic> salesEntries) {
    try {
      double totalCowQuantity = 0.0;
      double totalBuffaloQuantity = 0.0;
      double totalQuantity = 0.0;
      
      salesEntries.forEach((key, entry) {
        if (entry is Map<String, dynamic>) {
          double quantity = (entry['quantity'] ?? 0).toDouble();
          String animalType = (entry['animalType'] ?? 'Cow').toString();
          
          totalQuantity += quantity;
          
          if (animalType.toLowerCase() == 'cow') {
            totalCowQuantity += quantity;
          } else if (animalType.toLowerCase() == 'buffalo') {
            totalBuffaloQuantity += quantity;
          }
        }
      });
      
      return {
        'totalQuantity': "${totalQuantity.toStringAsFixed(1)} L",
        'cowQuantity': "${totalCowQuantity.toStringAsFixed(1)} L",
        'buffaloQuantity': "${totalBuffaloQuantity.toStringAsFixed(1)} L",
        'totalCowLiters': totalCowQuantity,
        'totalBuffaloLiters': totalBuffaloQuantity,
      };
    } catch (e) {
      return {
        'totalQuantity': "0.0 L",
        'cowQuantity': "0.0 L",
        'buffaloQuantity': "0.0 L",
        'totalCowLiters': 0.0,
        'totalBuffaloLiters': 0.0,
      };
    }
  }

  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredSuppliers = _suppliers;
      });
    } else {
      setState(() {
        _filteredSuppliers = _suppliers.where((supplier) {
          final name = supplier['name']?.toString().toLowerCase() ?? '';
          final code = supplier['code']?.toString().toLowerCase() ?? '';
          return name.contains(query) || code.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _updatePaymentStatus(String supplierId, String status, double paidAmount, double newTotalAmount) async {
    try {
      double newPaidAmount = status == "completed" ? newTotalAmount : paidAmount;
      double newRemainingAmount = newTotalAmount - newPaidAmount;

      // Ensure paid amount doesn't exceed total amount
      if (newPaidAmount > newTotalAmount) {
        newPaidAmount = newTotalAmount;
        newRemainingAmount = 0;
      }

      await _firestore.collection('milk_sales').doc(supplierId).update({
        'TotalAmount': newTotalAmount,
        'paidAmount': newPaidAmount,
        'remainingAmount': newRemainingAmount,
        'paymentStatus': status,
        'lastPaymentDate': status == "completed" ? FieldValue.serverTimestamp() : null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Reload the data
      _loadSuppliers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment details updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating payment: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addPayment(String supplierId, double paymentAmount, String paymentMethod) async {
    try {
      final supplierDoc = await _firestore.collection('milk_sales').doc(supplierId).get();
      
      if (!supplierDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Supplier not found in database"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final supplierData = supplierDoc.data() as Map<String, dynamic>;
      
      double currentPaidAmount = (supplierData['paidAmount'] ?? 0).toDouble();
      double totalAmount = (supplierData['TotalAmount'] ?? 0).toDouble();
      double currentRemainingAmount = (supplierData['remainingAmount'] ?? totalAmount - currentPaidAmount).toDouble();
      
      // Validate payment amount
      if (paymentAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please enter a valid payment amount"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (paymentAmount > currentRemainingAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment amount cannot exceed remaining amount of ₹${currentRemainingAmount.toStringAsFixed(2)}"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      double newPaidAmount = currentPaidAmount + paymentAmount;
      double newRemainingAmount = totalAmount - newPaidAmount;
      
      // Get existing payment history
      List<dynamic> paymentHistory = supplierData['paymentHistory'] ?? [];
      
      // Add new payment to history
      paymentHistory.add({
        'amount': paymentAmount,
        'method': paymentMethod,
        'date': Timestamp.now(),
        'previousPaid': currentPaidAmount,
        'previousRemaining': currentRemainingAmount,
      });
      
      // Update Firestore document
      Map<String, dynamic> updateData = {
        'paidAmount': newPaidAmount,
        'remainingAmount': newRemainingAmount,
        'lastPaymentDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'paymentHistory': paymentHistory,
      };
      
      // Update paymentStatus based on remaining amount
      if (newRemainingAmount <= 0) {
        updateData['paymentStatus'] = "completed";
      } else {
        updateData['paymentStatus'] = "pending";
      }
      
      await _firestore.collection('milk_sales').doc(supplierId).update(updateData);

      // Reload the data
      _loadSuppliers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment of ₹${paymentAmount.toStringAsFixed(2)} added successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error adding payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding payment: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSupplier(String supplierId) async {
    try {
      await _firestore.collection('milk_sales').doc(supplierId).delete();
      
      // Reload the data
      _loadSuppliers();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Supplier deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error deleting supplier: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting supplier: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddPaymentDialog(BuildContext context, Map<String, dynamic> supplier) {
    final paymentController = TextEditingController();
    String selectedMethod = 'cash';
    double remainingAmount = supplier['remainingAmount'] ?? 0.0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;
        
        return Dialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: isSmallScreen ? screenWidth * 0.9 : screenWidth * 0.5,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Payment", 
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Supplier: ${supplier['name']}",
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Payment Summary
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Amount:", style: TextStyle(fontSize: screenWidth * 0.035)),
                            Text("₹${supplier['totalAmount']?.toStringAsFixed(2) ?? supplier['amount']}", 
                                style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Paid Amount:", style: TextStyle(fontSize: screenWidth * 0.035)),
                            Text("₹${(supplier['paidAmount'] ?? 0).toStringAsFixed(2)}", 
                                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.blue)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Remaining Amount:", style: TextStyle(fontSize: screenWidth * 0.035)),
                            Text("₹${remainingAmount.toStringAsFixed(2)}", 
                                style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
                  TextField(
                    controller: paymentController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Payment Amount",
                      prefixText: "₹",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
                  Text(
                    "Payment Method",
                    style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      dropdownColor: AppColors.inputFieldColor,
                      items: [
                        DropdownMenuItem(value: "cash", child: Text("Cash", style: TextStyle(fontSize: screenWidth * 0.035))),
                        DropdownMenuItem(value: "card", child: Text("Card", style: TextStyle(fontSize: screenWidth * 0.035))),
                        DropdownMenuItem(value: "bank_transfer", child: Text("Bank Transfer", style: TextStyle(fontSize: screenWidth * 0.035))),
                        DropdownMenuItem(value: "upi", child: Text("UPI", style: TextStyle(fontSize: screenWidth * 0.035))),
                      ],
                      onChanged: (value) => selectedMethod = value!,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        )
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () {
                          String paymentText = paymentController.text.trim();
                          if (paymentText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter payment amount")),
                            );
                            return;
                          }
                          
                          double paymentAmount = double.tryParse(paymentText) ?? 0.0;
                          if (paymentAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter a valid payment amount")),
                            );
                            return;
                          }
                          if (paymentAmount > remainingAmount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Payment amount cannot exceed remaining amount of ₹${remainingAmount.toStringAsFixed(2)}")),
                            );
                            return;
                          }
                          _addPayment(supplier['id'], paymentAmount, selectedMethod);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Add Payment", 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditPaymentDialog(BuildContext context, Map<String, dynamic> supplier) {
    final nameController = TextEditingController(text: supplier['name']);
    final amountController = TextEditingController(text: supplier['totalAmount']?.toStringAsFixed(2) ?? supplier['amount']);
    String selectedStatus = supplier['status'] ?? 'pending';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        return Dialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: screenWidth * 0.9,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Payment Details", 
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Supplier Information
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Supplier Name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Supplier Code (Read-only)
                  TextField(
                    controller: TextEditingController(text: supplier['code'] ?? supplier['id']),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor.withOpacity(0.5),
                      labelText: "Supplier Code",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                    readOnly: true,
                    style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Milk Quantities Section (Read-only)
                  Text(
                    "Milk Quantities (Read-only)",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  
                  // Total Milk Quantity
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Milk:", style: TextStyle(fontSize: screenWidth * 0.035)),
                        Text(supplier["quantity"]!, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  
                  // Cow and Buffalo Milk Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pets, color: Colors.blue.shade700, size: screenWidth * 0.04),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text("Cow Milk", style: TextStyle(fontSize: screenWidth * 0.033, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(supplier["cowQuantity"]!, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pets, color: Colors.orange.shade700, size: screenWidth * 0.04),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text("Buffalo Milk", style: TextStyle(fontSize: screenWidth * 0.033, fontWeight: FontWeight.w500)),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(supplier["buffaloQuantity"]!, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Payment Amount Section
                  Text(
                    "Payment Amount",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  
                  // Current payment summary
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Amount:", style: TextStyle(fontSize: screenWidth * 0.033)),
                            Text("₹${supplier['totalAmount']?.toStringAsFixed(2) ?? supplier['amount']}", 
                                style: TextStyle(fontSize: screenWidth * 0.033, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Paid Amount:", style: TextStyle(fontSize: screenWidth * 0.033)),
                            Text("₹${(supplier['paidAmount'] ?? 0).toStringAsFixed(2)}", 
                                style: TextStyle(fontSize: screenWidth * 0.033, color: Colors.blue)),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Remaining Amount:", style: TextStyle(fontSize: screenWidth * 0.033)),
                            Text("₹${(supplier['remainingAmount'] ?? 0).toStringAsFixed(2)}", 
                                style: TextStyle(fontSize: screenWidth * 0.033, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Amount field for manual adjustment
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Total Amount (₹)",
                      prefixText: "₹",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      hintText: "Enter total amount",
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(fontSize: screenWidth * 0.04),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Payment Status Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFieldColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        labelText: "Payment Status",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      dropdownColor: AppColors.inputFieldColor,
                      items: [
                        DropdownMenuItem(
                          value: "completed", 
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: screenWidth * 0.04),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Completed", 
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: screenWidth * 0.035
                                )
                              ),
                            ],
                          )
                        ),
                        DropdownMenuItem(
                          value: "pending", 
                          child: Row(
                            children: [
                              Icon(Icons.pending, color: Colors.red, size: screenWidth * 0.04),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "Pending", 
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: screenWidth * 0.035
                                )
                              ),
                            ],
                          )
                        ),
                      ],
                      onChanged: (value) => selectedStatus = value!,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        )
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () {
                          String amountText = amountController.text.trim();
                          if (amountText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please enter total amount")),
                            );
                            return;
                          }
                          
                          double newTotalAmount = double.tryParse(amountText) ?? supplier['totalAmount'] ?? double.parse(supplier['amount']);
                          
                          _updatePaymentStatus(
                            supplier['id'],
                            selectedStatus,
                            supplier['paidAmount'] ?? 0.0,
                            newTotalAmount,
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save Changes", 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPaymentDetailsDialog(BuildContext context, Map<String, dynamic> supplier) {
    bool isCompleted = supplier["status"] == "completed";
    Map<String, dynamic> milkQuantities = _getMilkQuantities(supplier['salesEntries']);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;
        
        return Dialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: isSmallScreen ? screenWidth * 0.95 : screenWidth * 0.6,
            height: screenHeight * 0.8,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details", 
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, 
                      fontWeight: FontWeight.bold, 
                      color: isCompleted ? Colors.green : Colors.red
                    )
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Supplier Information
                          ListTile(
                            leading: Icon(Icons.person, size: screenWidth * 0.05), 
                            title: Text("Supplier Name", style: TextStyle(fontSize: screenWidth * 0.035)), 
                            subtitle: Text(supplier["name"]!, style: TextStyle(fontSize: screenWidth * 0.04))
                          ),
                          ListTile(
                            leading: Icon(Icons.qr_code, size: screenWidth * 0.05), 
                            title: Text("Supplier Code", style: TextStyle(fontSize: screenWidth * 0.035)), 
                            subtitle: Text(supplier["code"] ?? "N/A", style: TextStyle(fontSize: screenWidth * 0.04))
                          ),
                          
                          // Milk Quantities Section
                          SizedBox(height: screenHeight * 0.01),
                          Text("Milk Quantities", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                          SizedBox(height: screenHeight * 0.01),
                          
                          // Total Milk
                          Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: AppColors.inputFieldColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.local_drink, size: screenWidth * 0.05, color: Colors.blue),
                                SizedBox(width: screenWidth * 0.03),
                                Text("Total Milk:", style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500)),
                                Spacer(),
                                Text(supplier["quantity"]!, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          
                          // Cow and Buffalo Milk Row
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.pets, color: Colors.blue.shade700, size: screenWidth * 0.04),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text("Cow Milk", style: TextStyle(fontSize: screenWidth * 0.033, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(supplier["cowQuantity"]!, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.pets, color: Colors.orange.shade700, size: screenWidth * 0.04),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text("Buffalo Milk", style: TextStyle(fontSize: screenWidth * 0.033, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(supplier["buffaloQuantity"]!, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Payment Information
                          Text("Payment Information", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                          SizedBox(height: screenHeight * 0.01),
                          
                          ListTile(
                            leading: Icon(Icons.attach_money, size: screenWidth * 0.05), 
                            title: Text("Total Amount", style: TextStyle(fontSize: screenWidth * 0.035)), 
                              subtitle: Text("₹${supplier["amount"]!}", style: TextStyle(color: isCompleted ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04))
                          ),
                          ListTile(
                            leading: Icon(Icons.payments, size: screenWidth * 0.05), 
                            title: Text("Paid Amount", style: TextStyle(fontSize: screenWidth * 0.035)), 
                            subtitle: Text("₹${(supplier['paidAmount'] ?? 0).toStringAsFixed(2)}", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04))
                          ),
                          ListTile(
                            leading: Icon(Icons.money_off, size: screenWidth * 0.05), 
                            title: Text("Remaining Amount", style: TextStyle(fontSize: screenWidth * 0.035)), 
                            subtitle: Text("₹${(supplier['remainingAmount'] ?? 0).toStringAsFixed(2)}", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04))
                          ),
                          ListTile(
                            leading: Icon(isCompleted ? Icons.check_circle : Icons.pending, color: isCompleted ? Colors.green : Colors.red, size: screenWidth * 0.05), 
                            title: Text("Status", style: TextStyle(fontSize: screenWidth * 0.035)), 
                            subtitle: Text(isCompleted ? "Completed" : "Pending", style: TextStyle(color: isCompleted ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04))
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Close", 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        
        return Dialog(
          backgroundColor: AppColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: screenWidth * 0.8,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delete Payment History", 
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Text(
                    "Are you sure you want to delete ${supplier['name']}?", 
                    style: TextStyle(fontSize: screenWidth * 0.04)
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    "Cow Milk: ${supplier['cowQuantity']}, Buffalo Milk: ${supplier['buffaloQuantity']}", 
                    style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade600)
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), 
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: screenWidth * 0.035),
                        )
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColorSecondary, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () {
                          _deleteSupplier(supplier['id']);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Delete", 
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );  
      },
    );
  }

  Widget _buildSupplierListItem(Map<String, dynamic> supplier) {
    bool isCompleted = supplier["status"] == "completed";
    double remainingAmount = supplier['remainingAmount'] ?? 0.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.015,
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          // User Profile Image
          Container(
            width: MediaQuery.of(context).size.width * 0.12,
            height: MediaQuery.of(context).size.width * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.goldLight,
            ),
            child: supplier['profileImage'] != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(supplier['profileImage']),
                    radius: MediaQuery.of(context).size.width * 0.06,
                  )
                : Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.width * 0.06,
                    color: Colors.grey,
                  ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        supplier["name"]!, 
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.04, 
                          fontWeight: FontWeight.w500, 
                          color: AppColors.textPrimary
                        ), 
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.02, 
                      height: MediaQuery.of(context).size.width * 0.02, 
                      decoration: BoxDecoration(
                        color: isCompleted ? Colors.green : Colors.red, 
                        shape: BoxShape.circle
                      )
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.015),
                    Text(
                      isCompleted ? "Completed" : "Pending", 
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03, 
                        color: isCompleted ? Colors.green : Colors.red
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Only show remaining amount on the card
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03,
                  vertical: MediaQuery.of(context).size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(
                  "₹${remainingAmount.toStringAsFixed(2)}", 
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.038, 
                    fontWeight: FontWeight.w600, 
                    color: isCompleted ? Colors.green : Colors.red
                  )
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.003),
            ],
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey, size: MediaQuery.of(context).size.width * 0.05),
            itemBuilder: (BuildContext context) {
              // Create menu items list
              List<PopupMenuEntry<String>> menuItems = [];

              // Add "Add Payment" only if there's remaining amount
              if (remainingAmount > 0) {
                menuItems.add(
                  PopupMenuItem<String>(
                    value: "add_payment", 
                    child: ListTile(
                      leading: Icon(Icons.payment, size: MediaQuery.of(context).size.width * 0.04, color: Colors.green), 
                      title: Text(
                        "Add Payment",
                        style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
                      )
                    )
                  )
                );
              }

              // Add other menu items
              menuItems.addAll([
                PopupMenuItem<String>(
                  value: "edit", 
                  child: ListTile(
                    leading: Icon(Icons.edit, size: MediaQuery.of(context).size.width * 0.04), 
                    title: Text(
                      "Edit",
                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
                    )
                  )
                ),
                PopupMenuItem<String>(
                  value: "details", 
                  child: ListTile(
                    leading: Icon(Icons.info_outline, size: MediaQuery.of(context).size.width * 0.04), 
                    title: Text(
                      "Details",
                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.035),
                    )
                  )
                ),
                PopupMenuItem<String>(
                  value: "delete", 
                  child: ListTile(
                    leading: Icon(Icons.delete, size: MediaQuery.of(context).size.width * 0.04, color: Colors.red), 
                    title: Text(
                      "Delete", 
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      )
                    )
                  )
                ),
              ]);

              return menuItems;
            },
            color: AppColors.cardColor,
            onSelected: (value) {
              if (value == "add_payment") {
                _showAddPaymentDialog(context, supplier);
              } else if (value == "edit") {
                _showEditPaymentDialog(context, supplier);
              } else if (value == "details") {
                _showPaymentDetailsDialog(context, supplier);
              } else if (value == "delete") {
                _showDeleteConfirmationDialog(context, supplier);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableHeader(
                title: "Sell Milk Payment", 
                icon: Icons.checklist, 
                onBackPressed: () => Navigator.pop(context)
              ),
              SizedBox(height: screenHeight * 0.02),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardColor,
                  prefixIcon: Icon(Icons.search, size: screenWidth * 0.05),
                  hintText: "Search by name or code",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.015,
                  ),
                ),
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              SizedBox(height: screenHeight * 0.02),
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_filteredSuppliers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: screenWidth * 0.15, color: Colors.grey.shade400),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          "No payment records found",
                          style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.grey.shade600),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Add milk sales to see payment records",
                          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredSuppliers.length,
                    itemBuilder: (context, index) => _buildSupplierListItem(_filteredSuppliers[index]),
                  ),
                ),
            
            ],
          ),
        ),
      ),
    );
  }
}