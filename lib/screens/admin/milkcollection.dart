import 'package:flutter/material.dart';
import '../color.dart'; // Import the new color file

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

  // Focus nodes to manage keyboard
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _quantityFocusNode = FocusNode();
  final FocusNode _fatFocusNode = FocusNode();

  @override
  void dispose() {
    // Clean up focus nodes
    _codeFocusNode.dispose();
    _nameFocusNode.dispose();
    _quantityFocusNode.dispose();
    _fatFocusNode.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: const Color.fromRGBO(255, 254, 239, 1),
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        automaticallyImplyLeading: true,
        elevation: 0,
=======
      backgroundColor: (bgcolor),
      appBar: AppBar( // Added AppBar with back button
        backgroundColor: (bgcolor),
        automaticallyImplyLeading: true, // This enables the default back button
        elevation: 0, // Remove shadow
>>>>>>> Stashed changes
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
<<<<<<< Updated upstream
        child: SingleChildScrollView(
=======
        child: Padding(
>>>>>>> Stashed changes
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
<<<<<<< Updated upstream
              // Title Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    // Date Row - Now tappable to open calendar
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.inputFieldColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              "${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}",
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
=======
              // Title Section - made more compact
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: (cardColor),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCEA),
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
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Form Container - made more compact
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (cardColor),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Row - made more compact
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                          SizedBox(width: 8),
                          Text(
                            "25 April 2024",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Code No. - made more compact
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Code No.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFFFCEA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
>>>>>>> Stashed changes
                      ),
                    ),
                    const SizedBox(height: 16),

<<<<<<< Updated upstream
                    // Code No.
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Code No.",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
=======
                    // Name - made more compact
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
>>>>>>> Stashed changes
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: TextField(
<<<<<<< Updated upstream
                        controller: _codeController,
                        focusNode: _codeFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.inputFieldColor,
=======
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFFFFCEA),
>>>>>>> Stashed changes
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
<<<<<<< Updated upstream
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
=======
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
>>>>>>> Stashed changes
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

<<<<<<< Updated upstream
                    // Name
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Name",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Animal Type Dropdown
                    Row(
                      children: [
                        const Text("Animal Type",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
=======
                    // Animal Type Dropdown - made more compact
                    Row(
                      children: [
                        const Text("Animal Type", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
>>>>>>> Stashed changes
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownButtonFormField<String>(
<<<<<<< Updated upstream
                              initialValue: _animalType,
                              items: ["Cow", "Buffalo"]
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e,
                                          style:
                                              const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _animalType = val!;
                                });
                              },
                              dropdownColor: AppColors.inputFieldColor,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.inputFieldColor,
=======
                              value: "Cow",
                              items: ["Cow", "Buffalo"]
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (val) {},
                              dropdownColor: const Color(0xFFFFFCEA),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFFFFCEA),
>>>>>>> Stashed changes
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
<<<<<<< Updated upstream
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              icon: const Icon(Icons.arrow_drop_down,
                                  size: 18, color: AppColors.textSecondary),
=======
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              ),
                              borderRadius: BorderRadius.circular(8),
                              icon: const Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
>>>>>>> Stashed changes
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

<<<<<<< Updated upstream
                    // Quantity & Fat Row
=======
                    // Quantity & Fat Row - made more compact
>>>>>>> Stashed changes
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4.0),
<<<<<<< Updated upstream
                                child: Text("Quantity (lit.)",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
=======
                                child: Text("Quantity (lit.)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
>>>>>>> Stashed changes
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 40,
                                child: TextField(
<<<<<<< Updated upstream
                                  controller: _quantityController,
                                  focusNode: _quantityFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor,
=======
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFFFFCEA),
>>>>>>> Stashed changes
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
<<<<<<< Updated upstream
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
=======
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
>>>>>>> Stashed changes
                                  ),
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
<<<<<<< Updated upstream
                                child: Text("Fat %",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
=======
                                child: Text("Fat %", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
>>>>>>> Stashed changes
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 40,
                                child: TextField(
<<<<<<< Updated upstream
                                  controller: _fatController,
                                  focusNode: _fatFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFieldColor,
=======
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFFFFCEA),
>>>>>>> Stashed changes
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
<<<<<<< Updated upstream
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
=======
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
>>>>>>> Stashed changes
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

<<<<<<< Updated upstream
                    // Total Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.inputFieldColor,
=======
                    // Total Price - made more compact
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCEA),
>>>>>>> Stashed changes
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Total Price : ₹ 0.00",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

<<<<<<< Updated upstream
                    // Submit Button
=======
                    // Submit Button - made more compact
>>>>>>> Stashed changes
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton(
<<<<<<< Updated upstream
                        style: AppColors.elevatedButtonStyle,
                        onPressed: () {},
                        child: const Text(
                          "Submit Entry",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
=======
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (buttonColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Submit Entry",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }
}
=======
}
>>>>>>> Stashed changes
