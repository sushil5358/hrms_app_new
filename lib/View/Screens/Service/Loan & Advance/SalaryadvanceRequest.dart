import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controller/Advance_salary_Request_controller.dart';
import '../../../../utils/colers.dart';

class Salaryadvancerequest extends StatefulWidget {
  const Salaryadvancerequest({super.key});

  @override
  State<Salaryadvancerequest> createState() => _SalaryadvancerequestState();
}

class _SalaryadvancerequestState extends State<Salaryadvancerequest> {
  final _formKey = GlobalKey<FormState>();
  AdvanceSalaryRequestController controller = Get.put(
      AdvanceSalaryRequestController());

  // Selected values
  String? _selectedInstallmentMonth;

  // EMI Schedule data
  List<Map<String, dynamic>> _emiSchedule = [];
  bool _showEMISchedule = false;
  double _totalInterest = 0;
  double _totalPayable = 0;
  double _monthlyEMI = 0;

  // Interest rate (example: 12% per annum)
  final double _interestRate = 12.0;

  // Options for dropdowns
  final List<String> _installmentMonths = [
    '1 Month',
    '2 Months',
    '3 Months',
    '4 Months',
    '5 Months',
    '6 Months',
  ];


  @override
  void dispose() {
    controller.amountController.dispose();
    controller.reasonController.dispose();
    controller.dateController.dispose();
    super.dispose();
  }

  Future<DateTime?> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primary_color,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
    if (picked != null) {
      setState(() {
        controller.dateController.text =
        "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _calculateEMISchedule() {
    if (controller.amountController.text.isEmpty ||
        _selectedInstallmentMonth == null) {
      Get.snackbar(
        'Error',
        'Please enter amount and select installment period',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    double principal = double.parse(controller.amountController.text);
    int months = int.parse(_selectedInstallmentMonth!.split(' ')[0]);

    // Calculate EMI
    double monthlyRate = _interestRate / 12 / 100;
    double emi = principal * monthlyRate * Math.pow(1 + monthlyRate, months) /
        (Math.pow(1 + monthlyRate, months) - 1);

    _monthlyEMI = emi;
    _totalPayable = emi * months;
    _totalInterest = _totalPayable - principal;

    // Generate EMI schedule
    _emiSchedule = [];
    double remainingBalance = principal;
    DateTime startDate = DateTime.now();

    for (int i = 1; i <= months; i++) {
      double interestComponent = remainingBalance * monthlyRate;
      double principalComponent = emi - interestComponent;
      remainingBalance -= principalComponent;

      DateTime dueDate = startDate.add(Duration(days: 30 * i));

      _emiSchedule.add({
        'emoNo': i,
        'dueDate': '${dueDate.day}/${dueDate.month}/${dueDate.year}',
        'emiAmount': emi,
        'principalComponent': principalComponent,
        'interestComponent': interestComponent,
        'remainingBalance': remainingBalance > 0 ? remainingBalance : 0,
        'status': i == 1 ? 'Upcoming' : 'Pending',
      });
    }

    setState(() {
      _showEMISchedule = true;
    });
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      controller.advanceSalaryrequest(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salary Advance Request"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary_color, primary_color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primary_color.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Advance Limit',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '₹ 50,000',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: Today',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Form Title
                const Text(
                  'Request Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (_showEMISchedule) {
                        setState(() {
                          _showEMISchedule = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Advance Amount',
                      hintText: 'Enter amount',
                      prefixIcon: const Icon(Icons.currency_rupee),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // // Installment Month Dropdown
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.1),
                //         blurRadius: 5,
                //         offset: const Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: DropdownButtonFormField<String>(
                //     value: _selectedInstallmentMonth,
                //     decoration: InputDecoration(
                //       labelText: 'Installment Months',
                //       hintText: 'Select repayment period',
                //       prefixIcon: const Icon(Icons.calendar_today),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12),
                //         borderSide: BorderSide.none,
                //       ),
                //       filled: true,
                //       fillColor: Colors.white,
                //       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     ),
                //     items: _installmentMonths.map((String month) {
                //       return DropdownMenuItem<String>(
                //         value: month,
                //         child: Text(month),
                //       );
                //     }).toList(),
                //     onChanged: (String? newValue) {
                //       setState(() {
                //         _selectedInstallmentMonth = newValue;
                //         _showEMISchedule = false;
                //       });
                //     },
                //     validator: (value) {
                //       if (value == null) {
                //         return 'Please select installment period';
                //       }
                //       return null;
                //     },
                //   ),
                // ),
                // const SizedBox(height: 16),

                // // Calculate EMI Button
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: _calculateEMISchedule,
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.orange,
                //       foregroundColor: Colors.white,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       padding: const EdgeInsets.symmetric(vertical: 14),
                //     ),
                //     child: const Text(
                //       'Calculate EMI Schedule',
                //       style: TextStyle(
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                //
                // const SizedBox(height: 16),
                //
                // // EMI Schedule Section
                // if (_showEMISchedule) ...[
                //   Container(
                //     padding: const EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.grey.withOpacity(0.1),
                //           blurRadius: 5,
                //           offset: const Offset(0, 2),
                //         ),
                //       ],
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const Text(
                //           'EMI Summary',
                //           style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         const SizedBox(height: 12),
                //         _buildSummaryRow('Loan Amount', '₹${double.parse(_amountController.text).toStringAsFixed(2)}'),
                //         _buildSummaryRow('Interest Rate', '$_interestRate% p.a.'),
                //         _buildSummaryRow('Tenure', _selectedInstallmentMonth!),
                //         const Divider(height: 24),
                //         _buildSummaryRow('Monthly EMI', '₹${_monthlyEMI.toStringAsFixed(2)}', isHighlighted: true),
                //         _buildSummaryRow('Total Interest', '₹${_totalInterest.toStringAsFixed(2)}', color: Colors.orange),
                //         _buildSummaryRow('Total Payable', '₹${_totalPayable.toStringAsFixed(2)}', color: Colors.green, isBold: true),
                //
                //         const SizedBox(height: 16),
                //
                //         // EMI Schedule Table
                //         const Text(
                //           'EMI Schedule',
                //           style: TextStyle(
                //             fontSize: 14,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         const SizedBox(height: 12),
                //
                //         Container(
                //           height: 200,
                //           child: ListView.builder(
                //             shrinkWrap: true,
                //             itemCount: _emiSchedule.length,
                //             itemBuilder: (context, index) {
                //               final emi = _emiSchedule[index];
                //               return Container(
                //                 margin: const EdgeInsets.only(bottom: 8),
                //                 padding: const EdgeInsets.all(12),
                //                 decoration: BoxDecoration(
                //                   color: Colors.grey.shade50,
                //                   borderRadius: BorderRadius.circular(8),
                //                   border: Border.all(color: Colors.grey.shade200),
                //                 ),
                //                 child: Column(
                //                   children: [
                //                     Row(
                //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         Text(
                //                           'EMI #${emi['emoNo']}',
                //                           style: const TextStyle(
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: 13,
                //                           ),
                //                         ),
                //                         Container(
                //                           padding: const EdgeInsets.symmetric(
                //                             horizontal: 8,
                //                             vertical: 2,
                //                           ),
                //                           decoration: BoxDecoration(
                //                             color: emi['status'] == 'Upcoming'
                //                                 ? Colors.blue.withOpacity(0.1)
                //                                 : Colors.grey.withOpacity(0.1),
                //                             borderRadius: BorderRadius.circular(12),
                //                           ),
                //                           child: Text(
                //                             emi['status'],
                //                             style: TextStyle(
                //                               color: emi['status'] == 'Upcoming'
                //                                   ? Colors.blue
                //                                   : Colors.grey,
                //                               fontSize: 10,
                //                               fontWeight: FontWeight.bold,
                //                             ),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                     const SizedBox(height: 8),
                //                     Row(
                //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         Text(
                //                           'Due: ${emi['dueDate']}',
                //                           style: TextStyle(
                //                             fontSize: 11,
                //                             color: Colors.grey.shade600,
                //                           ),
                //                         ),
                //                         Text(
                //                           '₹${emi['emiAmount'].toStringAsFixed(2)}',
                //                           style: const TextStyle(
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: 13,
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                     const SizedBox(height: 4),
                //                     Row(
                //                       children: [
                //                         Expanded(
                //                           child: Text(
                //                             'Principal: ₹${emi['principalComponent'].toStringAsFixed(2)}',
                //                             style: TextStyle(
                //                               fontSize: 10,
                //                               color: Colors.green.shade700,
                //                             ),
                //                           ),
                //                         ),
                //                         Expanded(
                //                           child: Text(
                //                             'Interest: ₹${emi['interestComponent'].toStringAsFixed(2)}',
                //                             style: TextStyle(
                //                               fontSize: 10,
                //                               color: Colors.orange.shade700,
                //                             ),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //               );
                //             },
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                //   const SizedBox(height: 16),
                // ],

                // Required Date Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    return TextFormField(
                      controller: TextEditingController(text: controller
                          .DateText),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await selectDate();
                        if (pickedDate != null) {
                          controller.Rerureddate.value = pickedDate;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Required Date',
                        hintText: 'Select date',
                        prefixIcon: const Icon(Icons.calendar_month),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select required date';
                        }
                        return null;
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),

                // Payment Method Dropdown
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: controller.selectedPaymentMethod == ""
                        ? null
                        : controller.selectedPaymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      hintText: 'Select payment method',
                      prefixIcon: const Icon(Icons.payment),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    items: controller.paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value != null)
                          controller.selectedPaymentMethod = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select payment method';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Reason Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: controller.reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason for Advance',
                      hintText: 'Explain why you need this advance',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Icon(Icons.description),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide a reason';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Submit Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlighted = false, Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlighted ? 14 : 13,
              color: Colors.grey.shade700,
              fontWeight: isHighlighted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlighted ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : (isHighlighted ? FontWeight
                  .bold : FontWeight.normal),
              color: color ?? (isHighlighted ? primary_color : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

// Add this class at the end of the file or import dart:math
class Math {
  static double pow(double x, int exponent) {
    return x.pow(exponent);
  }
}

extension DoublePower on double {
  double pow(int exponent) {
    return exponent == 0 ? 1 : this * this.pow(exponent - 1);
  }
}