import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:wavee/services/themeServices.dart';
import 'package:wavee/ui/home_screen/view/homePage.dart';
import 'package:wavee/utils/bottomBar.dart';
import 'package:wavee/utils/const.dart';
import 'package:wavee/utils/customAppBar.dart';

class SuppliersView extends StatefulWidget {
  int? selected;

  SuppliersView({super.key, this.selected});

  @override
  State<SuppliersView> createState() => _SuppliersViewState();
}

class _SuppliersViewState extends State<SuppliersView> {
  final List<Map<String, dynamic>> options = [
    {"title": "My Suppliers", "icon": Icons.groups_2_outlined},
    {"title": "Pending", "icon": Icons.hourglass_top_rounded},
    {"title": "Approved", "icon": Icons.verified_outlined},
  ];
  int selectedValue = 0;

  // Static supplier data for listing
  final List<Map<String, dynamic>> mySuppliers = [
    {
      'id': 1,
      'companyName': 'Tech Solutions Inc.',
      'contactName': 'John Doe',
      'email': 'john@techsolutions.com',
      'phone': '+1 234 567 8901',
      'category': 'Electronics',
      'categoryDetails': 'High-quality electronic components and devices',
      'status': 'approved',
      'profilePhoto':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'id': 2,
      'companyName': 'Green Foods Ltd.',
      'contactName': 'Jane Smith',
      'email': 'jane@greenfoods.com',
      'phone': '+1 987 654 3210',
      'category': 'Food & Beverage',
      'categoryDetails': 'Organic food products and beverages',
      'status': 'pending',
      'profilePhoto':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'id': 3,
      'companyName': 'Furniture World',
      'contactName': 'Mike Johnson',
      'email': 'mike@furnitureworld.com',
      'phone': '+1 555 123 4567',
      'category': 'Furniture',
      'categoryDetails': 'Modern home and office furniture',
      'status': 'approved',
      'profilePhoto':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'id': 4,
      'companyName': 'Auto Parts Pro',
      'contactName': 'Sarah Wilson',
      'email': 'sarah@autopartspro.com',
      'phone': '+1 444 555 6666',
      'category': 'Automotive',
      'categoryDetails': 'Genuine auto parts and accessories',
      'status': 'pending',
      'profilePhoto':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
    {
      'id': 5,
      'companyName': 'Medical Supplies Co.',
      'contactName': 'Dr. Robert Brown',
      'email': 'robert@medsupplies.com',
      'phone': '+1 777 888 9999',
      'category': 'Medical',
      'categoryDetails': 'Medical equipment and supplies',
      'status': 'approved',
      'profilePhoto':
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=580&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    },
  ];

  List<Map<String, dynamic>> get filteredSuppliers {
    if (selectedValue == 0) {
      return mySuppliers;
    } else if (selectedValue == 1) {
      return mySuppliers.where((s) => s['status'] == 'pending').toList();
    } else {
      return mySuppliers.where((s) => s['status'] == 'approved').toList();
    }
  }

  void _showSupplierDetails(Map<String, dynamic> supplier) {
    final theme = Provider.of<ThemeController>(context, listen: false);
    final isDark = theme.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xff1A1A1A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              supplier['profilePhoto'],
                            ),
                            backgroundColor: Colors.grey[300],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Center(
                          child: Text(
                            supplier['companyName'],
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontFamily: AppConstants.manropeBold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  supplier['status'] == 'approved'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              supplier['status'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color:
                                    supplier['status'] == 'approved'
                                        ? Colors.green
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        _buildDetailRow(
                          Icons.business,
                          "Company Name",
                          supplier['companyName'],
                        ),
                        _buildDetailRow(
                          Icons.person,
                          "Contact Person",
                          supplier['contactName'],
                        ),
                        _buildDetailRow(
                          Icons.email,
                          "Email",
                          supplier['email'],
                        ),
                        _buildDetailRow(
                          Icons.phone,
                          "Phone",
                          supplier['phone'],
                        ),
                        _buildDetailRow(
                          Icons.category,
                          "Category",
                          supplier['category'],
                        ),
                        _buildDetailRow(
                          Icons.description,
                          "Category Details",
                          supplier['categoryDetails'],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey[600]),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[500],
                    fontFamily: AppConstants.manrope,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontFamily: AppConstants.manrope,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = theme.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff1A1A1A) : const Color(0xFFF0F2F5),
      floatingActionButton: FloatingActionButton(
        // onPressed: _navigateToAddRequest,
        onPressed: () {},
        child: const Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: BottomBar(selected: 4),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 6.h),
              TitleBar(
                back: () {
                  Get.to(HomePage(selected: 1,userName: '',));
                },
                title: "My Suppliers",
                drawerCallback: () {},
              ),
              SizedBox(height: 3.h),

              SizedBox(
                height: 5.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: options.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final isSelected = selectedValue == index;

                    return GestureDetector(
                      onTap: () {
                        if (selectedValue != index) {
                          setState(() {
                            selectedValue = index;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color:
                              !isSelected
                                  ? (isDark
                                      ? Colors.grey.shade900
                                      : Colors.white)
                                  : Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              options[index]["icon"],
                              size: 18.sp,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black54),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              options[index]["title"],
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily:
                                    isSelected
                                        ? AppConstants.manropeBold
                                        : AppConstants.manropeBold,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 2.h),
              // Supplier list
              Expanded(
                child:
                    filteredSuppliers.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 40.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                selectedValue == 0
                                    ? "No suppliers found"
                                    : selectedValue == 1
                                    ? "No pending requests"
                                    : "No approved suppliers",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                  fontFamily: AppConstants.manrope,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredSuppliers.length,
                          padding: EdgeInsets.zero,

                          itemBuilder: (context, index) {
                            final supplier = filteredSuppliers[index];
                            return GestureDetector(
                              onTap: () => _showSupplierDetails(supplier),
                              child: Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? const Color(0xff2A2A2A)
                                          : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                        supplier['profilePhoto'],
                                      ),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    SizedBox(width: 3.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            supplier['companyName'],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontFamily:
                                                  AppConstants.manropeBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Text(
                                            supplier['category'],
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: Colors.grey[600],
                                              fontFamily: AppConstants.manrope,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 12.sp,
                                                color: Colors.grey[500],
                                              ),
                                              SizedBox(width: 1.w),
                                              Expanded(
                                                child: Text(
                                                  supplier['contactName'],
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: Colors.grey[500],
                                                    fontFamily:
                                                        AppConstants.manrope,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            supplier['status'] == 'approved'
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.orange.withOpacity(
                                                  0.2,
                                                ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        supplier['status'] == 'approved'
                                            ? "Approved"
                                            : "Pending",
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          color:
                                              supplier['status'] == 'approved'
                                                  ? Colors.green
                                                  : Colors.orange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ).paddingOnly(left: 3.w, right: 3.w),
        ],
      ),
    );
  }
}
