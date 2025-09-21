import 'package:flutter/material.dart';
import '../color.dart';
import '../reusable_header.dart';

class SellMilkPaymentPage extends StatelessWidget {
  const SellMilkPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = [
      {"name": "Johan Deo", "quantity": "2.5 L", "amount": "5.00", "status": "completed"},
      {"name": "Michal", "quantity": "2.5 L", "amount": "5.00", "status": "pending"},
      {"name": "Jack", "quantity": "2.5 L", "amount": "5.00", "status": "completed"},
      {"name": "Jemson", "quantity": "2.5 L", "amount": "5.00", "status": "pending"},
      {"name": "Thomason", "quantity": "2.5 L", "amount": "5.00", "status": "completed"},
    ];

    // Function to show edit payment dialog
    void showEditPaymentDialog(BuildContext context, Map<String, String> customer) {
      final nameController = TextEditingController(text: customer['name']);
      final quantityController = TextEditingController(text: customer['quantity']);
      final amountController = TextEditingController(text: customer['amount']);
      String selectedStatus = customer['status'] ?? 'pending';
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Payment Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Customer Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Quantity Field
                  TextField(
                    controller: quantityController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Milk Quantity",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Amount Field
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Amount",
                      prefixText: "\$",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.inputFieldColor,
                      labelText: "Payment Status",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: AppColors.inputFieldColor,
                    items: const [
                      DropdownMenuItem(
                        value: "completed",
                        child: Text("Completed", style: TextStyle(color: Colors.green)),
                      ),
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Pending", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                    onChanged: (value) {
                      selectedStatus = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Save edited payment details
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
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

    // Function to show payment details dialog
    void showPaymentDetailsDialog(BuildContext context, Map<String, String> customer) {
      bool isCompleted = customer["status"] == "completed";
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Customer Name"),
                    subtitle: Text(customer["name"]!),
                  ),
                  ListTile(
                    leading: Image.asset('assets/milk_bottle.png', width: 24, height: 24),
                    title: const Text("Milk Quantity"),
                    subtitle: Text(customer["quantity"]!),
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text("Amount"),
                    subtitle: Text(
                      "\$${customer["amount"]!}",
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      isCompleted ? Icons.check_circle : Icons.pending,
                      color: isCompleted ? Colors.green : Colors.red,
                    ),
                    title: const Text("Status"),
                    subtitle: Text(
                      isCompleted ? "Completed" : "Pending",
                      style: TextStyle(
                        color: isCompleted ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Date"),
                    subtitle: Text(DateTime.now().toString().split(' ')[0]),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Function to show delete confirmation dialog
    void showDeleteConfirmationDialog(BuildContext context, String customerName) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Delete Payment History",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Are you sure you want to delete $customerName?",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColorSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          // Delete customer logic
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
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

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the reusable header
              ReusableHeader(
                title: "Sell Milk Payment",
                icon: Icons.checklist,
                onBackPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardColor,
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Search",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer List
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    bool isCompleted = customer["status"] == "completed";
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Milk bottle image
                          Image.asset('assets/milk_bottle.png', width: 32, height: 32),
                          const SizedBox(width: 12),
                          
                          // Name and quantity in one line
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        customer["name"]!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      customer["quantity"]!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Status indicator
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isCompleted ? Colors.green : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isCompleted ? "Completed" : "Pending",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCompleted ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Amount with status color
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted 
                                ? Colors.green.withOpacity(0.2) 
                                : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "\$${customer["amount"]!}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isCompleted ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Action Buttons - using a popup menu for a cleaner look
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: ListTile(
                                  leading: Icon(Icons.edit, size: 20),
                                  title: Text("Edit"),
                                ),
                              ),
                              const PopupMenuItem(
                                value: "details",
                                child: ListTile(
                                  leading: Icon(Icons.info_outline, size: 20),
                                  title: Text("Details"),
                                ),
                              ),
                              const PopupMenuItem(
                                value: "delete",
                                child: ListTile(
                                  leading: Icon(Icons.delete, size: 20, color: Colors.red),
                                  title: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == "edit") {
                                showEditPaymentDialog(context, customer);
                              } else if (value == "details") {
                                showPaymentDetailsDialog(context, customer);
                              } else if (value == "delete") {
                                showDeleteConfirmationDialog(context, customer["name"]!);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}