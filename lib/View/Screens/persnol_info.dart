import 'package:employee_app/View/Screens/Home_page.dart';
import 'package:employee_app/utils/colers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersnolInfo extends StatefulWidget {
  const PersnolInfo({super.key});

  @override
  State<PersnolInfo> createState() => _PersnolInfoState();
}

class _PersnolInfoState extends State<PersnolInfo> {
  // Step index to track current step (0 = Personal, 1 = Employment, 2 = Bank)
  int currentStep = 0;

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String selectedGender = "Male";
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController alternateController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Emergency Contact Controllers
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyRelationController = TextEditingController();
  final TextEditingController emergencyContactController = TextEditingController();

  // Bank Details Controllers
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController branchLocationController = TextEditingController();

  // PageController for step navigation
  final PageController _pageController = PageController();



  // Navigate to next step
  void nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to previous step
  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Save all data
  void saveData() {
    // Here you can save all data to your backend
    print("Full Name: ${fullNameController.text}");
    print("Date of Birth: ${dobController.text}");
    print("Gender: $selectedGender");
    print("Aadhar: ${aadharController.text}");
    print("PAN: ${panController.text}");
    print("Email: ${emailController.text}");
    print("Contact: ${contactController.text}");
    print("Alternate: ${alternateController.text}");
    print("Emergency Name: ${emergencyNameController.text}");
    print("Emergency Relation: ${emergencyRelationController.text}");
    print("Emergency Contact: ${emergencyContactController.text}");
    print("Designation: ${designationController.text}");
    print("Department: ${departmentController.text}");
    print("Joining Date: ${joiningDateController.text}");
    print("Bank Name: ${bankNameController.text}");
    print("Account Number: ${accountNumberController.text}");
    print("IFSC Code: ${ifscCodeController.text}");
    print("Branch Location: ${branchLocationController.text}");

    Get.snackbar(
      "Success",
      "Profile updated successfully!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    Get.offAll(() => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        automaticallyImplyLeading: false,
        title: Text("Employee Details", style: TextStyle(fontWeight: FontWeight.bold, color: primary_color, fontSize: 18)),
        foregroundColor: primary_color,
        elevation: 0,
        centerTitle: true,

        actions: [
          TextButton(
              onPressed: () {
                Get.offAll(() => HomePage());
              },
              child: Text("Skip", style: TextStyle(color: Colors.black))
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step Indicator
          Column(
            children: [
              // Step Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepDot(0),
                  _buildStepConnector(0),
                  _buildStepDot(1),
                  _buildStepConnector(1),
                  _buildStepDot(2),
                ],
              ),
              const SizedBox(height: 8),
              // Step Labels
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepLabel("Personal", 0),
                  const SizedBox(width: 40),
                  _buildStepLabel("Employment", 1),
                  const SizedBox(width: 40),
                  _buildStepLabel("Bank", 2),
                ],
              ),
            ],
          ),

          // PageView for steps
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              children: [
                // Step 1: Personal Information
                _buildPersonalInfoStep(),

                // Step 2: Employment Details
                _buildEmploymentDetailsStep(),

                // Step 3: Bank Details
                _buildBankDetailsStep(),
              ],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Previous"),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentStep == 2 ? saveData : nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary_color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      currentStep == 2 ? "Save Changes" : "Next",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step Dot Widget
  Widget _buildStepDot(int step) {
    bool isActive = currentStep == step;
    bool isCompleted = currentStep > step;

    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted ? primary_color : Colors.grey[300],
        border: Border.all(
          color: isActive || isCompleted ? primary_color : Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
          "${step + 1}",
          style: TextStyle(
            color: isActive || isCompleted ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Step Connector Line Widget
  Widget _buildStepConnector(int step) {
    bool isActive = currentStep > step;
    return Container(
      width: 65,
      height: 2,
      color: isActive ? primary_color : Colors.grey[300],
    );
  }

  // Step Label Widget
  Widget _buildStepLabel(String label, int step) {
    bool isActive = currentStep == step;
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        color: isActive ? primary_color : Colors.grey[800],
      ),
    );
  }

  // Personal Information Step
  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Personal Information"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: fullNameController,
                  label: "Full Name",
                  icon: Icons.person,
                  hint: "Enter your full name",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emailController,
                  label: "Email Id",
                  icon: Icons.email,
                  hint: "abc@gmail.com",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: contactController,
                  label: "Contact Number",
                  icon: Icons.phone,
                  hint: "+91 XXXXXXXXXX",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: alternateController,
                  label: "Alternate Number",
                  icon: Icons.people,
                  hint: "+91 XXXXXXXXXX",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: dobController,
                  label: "Date of Birth",
                  icon: Icons.cake,
                  hint: "DD MMM YYYY",
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  value: selectedGender,
                  label: "Gender",
                  icon: Icons.wc,
                  items: ["Male", "Female", "Other"],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: aadharController,
                  label: "Aadhar Card",
                  icon: Icons.credit_card,
                  hint: "XXXX-XXXX-XXXX",
                  keyboardType: TextInputType.number,
                  maxLength: 14,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: panController,
                  label: "PAN Card",
                  icon: Icons.card_membership,
                  hint: "ABCDE1234F",
                  textCapitalization: TextCapitalization.characters,
                ),

                // Emergency Contact Section
                const SizedBox(height: 24),
                _buildSubSectionHeader("Emergency Contact"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emergencyNameController,
                  label: "Emergency Contact Name",
                  icon: Icons.person_outline,
                  hint: "Enter emergency contact name",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emergencyRelationController,
                  label: "Relationship",
                  icon: Icons.family_restroom,
                  hint: "e.g., Spouse, Father, Mother, etc.",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: emergencyContactController,
                  label: "Emergency Contact Number",
                  icon: Icons.phone_android,
                  hint: "+91 XXXXXXXXXX",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Employment Details Step
  Widget _buildEmploymentDetailsStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Employment Details"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: designationController,
                  label: "Designation",
                  icon: Icons.work,
                  hint: "Enter your designation",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: departmentController,
                  label: "Department",
                  icon: Icons.business,
                  hint: "Enter your department",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: joiningDateController,
                  label: "Date of Joining",
                  icon: Icons.calendar_today,
                  hint: "DD MMM YYYY",
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bank Details Step
  Widget _buildBankDetailsStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Bank Details"),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: bankNameController,
                  label: "Bank Name",
                  icon: Icons.account_balance,
                  hint: "Enter bank name",
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: accountNumberController,
                  label: "Account Number",
                  icon: Icons.numbers,
                  hint: "Enter account number",
                  keyboardType: TextInputType.number,
                  maxLength: 18,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: ifscCodeController,
                  label: "IFSC Code",
                  icon: Icons.code,
                  hint: "Enter IFSC code",
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: branchLocationController,
                  label: "Branch Location",
                  icon: Icons.location_on,
                  hint: "Enter branch location",
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for section header
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primary_color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primary_color,
          ),
        ),
      ],
    );
  }

  // Helper widget for sub-section header (Emergency Contact)
  Widget _buildSubSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: primary_color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primary_color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  // Helper widget for text form field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade800, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: primary_color, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: maxLength != null ? null : "",
          ),
        ),
      ],
    );
  }

  // Helper widget for dropdown field
  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isNotEmpty ? value : null,
              hint: const Text("Select Gender"),
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              isExpanded: true,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.grey.shade800, size: 20),
                      const SizedBox(width: 12),
                      Text(item),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}