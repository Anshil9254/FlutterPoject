import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../color.dart';
import '../reusable_header.dart';
import '../../session_manager.dart';

class MilkHistoryPage extends StatefulWidget {
  const MilkHistoryPage({super.key});

  @override
  State<MilkHistoryPage> createState() => _MilkHistoryPageState();
}

class _MilkHistoryPageState extends State<MilkHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _milkHistory = [];
  bool _isLoading = true;
  String _errorMessage = '';
  DateTime _selectedMonth = DateTime.now();
  String _historyType = 'all'; // 'all', 'buy', 'sell'

  @override
  void initState() {
    super.initState();
    _fetchMilkHistory();
  }

  Future<void> _fetchMilkHistory() async {
    try {
      // Check if user is logged in using SessionManager
      final bool isLoggedIn = await SessionManager.isLoggedIn();
      final Map<String, String> userData = await SessionManager.getUserData();
      
      if (!isLoggedIn || userData['userEmail'] == null) {
        setState(() {
          _errorMessage = "No user logged in. Please login again.";
          _isLoading = false;
        });
        return;
      }

      // Get the logged-in user's ID from session
      final String loggedInUserId = userData['userId'] ?? '';
      final String userEmail = userData['userEmail']!;

      print('Fetching milk history for user: $userEmail, ID: $loggedInUserId');

      // Fetch both milk collection (buy) and milk sales (sell)
      await _fetchCombinedHistory(loggedInUserId, userData['userName'] ?? '');

    } catch (e) {
      print('Error fetching milk history: $e');
      setState(() {
        _errorMessage = "Error loading milk history: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCombinedHistory(String userId, String userName) async {
    try {
      List<Map<String, dynamic>> combinedHistory = [];

      // Fetch milk collection entries (EXPORT - since we're collecting from farmers)
      final milkCollectionDoc = await _firestore.collection('milk').doc(userId).get();
      if (milkCollectionDoc.exists) {
        final milkData = milkCollectionDoc.data() as Map<String, dynamic>;
        final Map<String, dynamic>? milkEntries = milkData['milkEntries'] as Map<String, dynamic>?;
        
        if (milkEntries != null) {
          milkEntries.forEach((key, entry) {
            if (entry is Map<String, dynamic>) {
              final entryData = Map<String, dynamic>.from(entry);
              entryData['entryKey'] = key;
              entryData['type'] = 'buy'; // This represents EXPORT (milk collection)
              entryData['collection'] = 'milk';
              combinedHistory.add(entryData);
            }
          });
        }
      }

      // Fetch milk sales entries (IMPORT - since we're selling to customers)
      final milkSalesDoc = await _firestore.collection('milk_sales').doc(userId).get();
      if (milkSalesDoc.exists) {
        final salesData = milkSalesDoc.data() as Map<String, dynamic>;
        final Map<String, dynamic>? salesEntries = salesData['salesEntries'] as Map<String, dynamic>?;
        
        if (salesEntries != null) {
          salesEntries.forEach((key, entry) {
            if (entry is Map<String, dynamic>) {
              final entryData = Map<String, dynamic>.from(entry);
              entryData['entryKey'] = key;
              entryData['type'] = 'sell'; // This represents IMPORT (milk sales)
              entryData['collection'] = 'milk_sales';
              combinedHistory.add(entryData);
            }
          });
        }
      }

      // Filter by selected month and year
      final filteredHistory = combinedHistory.where((entry) {
        final Timestamp timestamp = entry['date'] ?? Timestamp.now();
        final DateTime entryDate = timestamp.toDate();
        return entryDate.year == _selectedMonth.year && 
               entryDate.month == _selectedMonth.month;
      }).toList();

      // Sort by date (newest first)
      filteredHistory.sort((a, b) {
        final Timestamp timestampA = a['date'] ?? Timestamp.now();
        final Timestamp timestampB = b['date'] ?? Timestamp.now();
        return timestampB.compareTo(timestampA);
      });

      setState(() {
        _milkHistory = filteredHistory;
        _isLoading = false;
        _errorMessage = '';
      });

      print('Loaded ${_milkHistory.length} milk entries');
      
    } catch (e) {
      print('Error processing milk data: $e');
      setState(() {
        _errorMessage = "Error processing milk data: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: AppColors.datePickerColorScheme,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
        _isLoading = true;
      });
      await _fetchMilkHistory();
    }
  }

  String _formatDate(Timestamp timestamp) {
    try {
      final date = timestamp.toDate();
      return DateFormat('dd MMMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _formatQuantity(double quantity) {
    return 'Ltr. ${quantity.toStringAsFixed(1)}';
  }

  String _getTypeText(String type) {
    return type == 'buy' ? 'Export' : 'Import'; // Swapped the labels
  }

  Color _getTypeColor(String type) {
    return type == 'buy' ? Colors.green : Colors.red; // Swapped the colors
  }

  IconData _getTypeIcon(String type) {
    return type == 'buy' ? Icons.arrow_upward : Icons.arrow_downward; // Swapped the icons
  }

  String _getAnimalTypeText(String animalType) {
    return animalType?.toString().toLowerCase() == 'buffalo' ? 'Buffalo' : 'Cow';
  }

  Widget _buildTypeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getTypeColor(type)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(type),
            size: 12,
            color: _getTypeColor(type),
          ),
          const SizedBox(width: 4),
          Text(
            _getTypeText(type),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getTypeColor(type),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Expanded(
      child: ListView.builder(
        itemCount: 7,
        padding: const EdgeInsets.only(bottom: 12),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 7),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchMilkHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/milk_bottle.png',
              width: 80,
              height: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No Milk History Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No entries found for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Filter by type if needed
    List<Map<String, dynamic>> filteredHistory = _milkHistory;
    if (_historyType != 'all') {
      filteredHistory = _milkHistory.where((entry) => entry['type'] == _historyType).toList();
    }

    return Expanded(
      child: Column(
        children: [
          // Type Filter Chips - Updated labels to match new terminology
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Export', 'buy'), // Changed from 'Import' to 'Export'
                const SizedBox(width: 8),
                _buildFilterChip('Import', 'sell'), // Changed from 'Export' to 'Import'
              ],
            ),
          ),
          const SizedBox(height: 8),

          // History List
          Expanded(
            child: ListView.builder(
              itemCount: filteredHistory.length,
              padding: const EdgeInsets.only(bottom: 12),
              itemBuilder: (context, index) {
                final entry = filteredHistory[index];
                final Timestamp date = entry['date'] ?? Timestamp.now();
                final double quantity = entry['quantity'] ?? 0.0;
                final String type = entry['type'] ?? 'buy';
                final String animalType = entry['animalType'] ?? 'Cow';
                final double fat = entry['fat'] ?? 0.0;
                final double totalPrice = entry['totalPrice'] ?? 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Milk bottle image with type indicator
                      Stack(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/milk_bottle.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.local_drink, size: 30);
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getTypeIcon(type),
                                size: 12,
                                color: _getTypeColor(type),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Entry details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDate(date),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _buildTypeChip(type),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _formatQuantity(quantity),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${_getAnimalTypeText(animalType)} • Fat: ${fat.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _getTypeColor(type),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _historyType == value,
      onSelected: (selected) {
        setState(() {
          _historyType = value;
        });
      },
      selectedColor: AppColors.buttonColor,
      labelStyle: TextStyle(
        color: _historyType == value ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ReusableHeader(
                title: "Milk History",
                icon: Icons.history,
                onBackPressed: () => Navigator.pop(context),
              ),
              
              const SizedBox(height: 16),
              
              // Month Display with Selection
              GestureDetector(
                onTap: () => _selectMonth(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 22, color: Colors.black),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Colors.black),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Content based on state
              if (_isLoading) _buildLoadingState()
              else if (_errorMessage.isNotEmpty) _buildErrorState()
              else if (_milkHistory.isEmpty) _buildEmptyState()
              else _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }
}