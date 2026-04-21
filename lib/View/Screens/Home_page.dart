import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Controller/Home_controller.dart';
import '../../utils/colers.dart' as color;
import '../../utils/colers.dart';
import 'Service/Attendance/Attendance.dart';
import 'Dashboard.dart';
import 'Profile/Profile.dart';
import 'Service/Service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: primary_color,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
        ),
        child: WillPopScope(
      onWillPop: ()async{
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit?'),
            content: Text('Do you want to exit this screen?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Exit'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: Scaffold(
        bottomNavigationBar: Obx(() {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              BottomNavigationBar(
                onTap: (index) {
                  controller.setmenuindex(index);
                  controller.pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
                currentIndex: controller.menuindex.value,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: color.primary_color,
                backgroundColor: Colors.white,

                unselectedItemColor: Colors.grey,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home,
                      color: (controller.menuindex == 0) ? color.primary_color : color.gray,),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(icon: Icon(Icons.calendar_month,
                    color: (controller.menuindex == 1) ? color.primary_color : color.gray,),
                    label: "Attendance",
                  ),

                  // BottomNavigationBarItem(
                  //   icon: Icon(Icons.shopping_cart,color: (controller.menuindex == 2) ? color.primary_color : color.button_color,),
                  //   label: "Cart",
                  // ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_history,color: (controller.menuindex == 2) ? color.primary_color : color.gray,),
                    label: "My Work",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person,color: (controller.menuindex == 3) ? color.primary_color : color.gray,),
                    label: "Profile",
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: MediaQuery.of(context).size.width / 4 * controller.menuindex.value + 20,
                child: Container(
                  width: MediaQuery.of(context).size.width / 4 - 40,
                  height: 2,
                  color: color.primary_color,
                ),
              ),
            ],
          );
        }),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller.pageController,
          onPageChanged: (val){
            controller.menuindex.value= val;
          },
          children: [Dashboard(), Attendance(), Services(), Profile()],
        ),
      ),
    ));
  }
  void _showProfileDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Controllers for text fields
            final TextEditingController fullNameController = TextEditingController();
            final TextEditingController dobController = TextEditingController();
            final TextEditingController genderController = TextEditingController();
            final TextEditingController aadharController = TextEditingController();
            final TextEditingController panController = TextEditingController();
            final TextEditingController contactController = TextEditingController();
            final TextEditingController alternateController = TextEditingController();
            final TextEditingController designationController = TextEditingController();
            final TextEditingController departmentController = TextEditingController();
            final TextEditingController joiningDateController = TextEditingController();

            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  // Handle bar for dragging
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title with close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Profile Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Information Section
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
                            controller: dobController,
                            label: "Date of Birth",
                            icon: Icons.cake,
                            hint: "DD MMM YYYY",
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownField(
                            value: genderController.text,
                            label: "Gender",
                            icon: Icons.wc,
                            items: ["Male", "Female", "Other"],
                            onChanged: (value) {
                              setState(() {
                                genderController.text = value;
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

                          const SizedBox(height: 24),
                          // Contact Information Section
                          _buildSectionHeader("Contact Information"),
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

                          const SizedBox(height: 24),
                          // Employment Details Section
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
                          // Save button
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[700],
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Save all data
                                    Get.snackbar(
                                      "Success",
                                      "Profile updated successfully!",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Save Changes",
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {});
  }

// Helper widget for section header
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
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
            prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
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
              value: value,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              isExpanded: true,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
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
