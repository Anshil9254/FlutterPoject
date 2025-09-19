import 'package:flutter/material.dart';
import '../color.dart'; // Import your color file

class SellMilkPage extends StatelessWidget {
  const SellMilkPage({super.key});

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
                    // Date Row
                    Container(
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
                            "25 April 2024",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary), // Using textPrimary from AppColors
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Code No.
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Code No.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
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
                    ),
                    const SizedBox(height: 20),

                    // Name
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0),
                      child: Text("Name",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
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
                              TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
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
                              DropdownButtonFormField<String>(
                                value: "Cow",
                                items: ["Cow", "Buffalo"]
                                    .map((e) =>
                                        DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) {},
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
                        color: AppColors.inputFieldColor, // Using inputFieldColor from AppColors
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Total Price : ₹ 0.00",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppColors.elevatedButtonStyle, // Using elevatedButtonStyle from AppColors
                        onPressed: () {},
                        child: const Text(
                          "Submit",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                         ),
                      ),
                    )
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