import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import './controller/bus_detail_controller.dart';

class BusDetailScreen extends StatefulWidget {
  const BusDetailScreen({super.key});

  @override
  State<BusDetailScreen> createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetBuilder<BusDetailController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('EasyGo'),
          actions: [
            IconButton(
              onPressed: () {
                Get.toNamed(AppRoutes.userProfileScreen);
              },
              icon: const Icon(Icons.account_circle),
            ),
          ],
        ),
        body: const Center(
          child: Text('Bus not added yet!, Please add one to continue.'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => addBusDetails(size),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void addBusDetails(size) {
    Get.bottomSheet(
      SingleChildScrollView(
          child: Form(
            child: Container(
              height: size.height * 0.65,
              color: Colors.white,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Your Bus Here',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Bus Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.directions_bus),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'The bus name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Bus Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.directions_bus),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'The bus number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an starting stop';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'From',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.arrow_circle_up),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '6.9336339,79.8526605',
                          child: Text('Colombo'),
                        ),
                        DropdownMenuItem(
                          value: '7.0923857,79.9891625',
                          child: Text('Gampaha'),
                        ),
                        DropdownMenuItem(
                          value: '6.7744328,79.8801515',
                          child: Text('Morattuwa'),
                        ),
                        DropdownMenuItem(
                          value: '6.9346378,79.9814374',
                          child: Text('Kaduwella'),
                        ),
                        DropdownMenuItem(
                          value: '6.9111207,79.7049656',
                          child: Text('Kollupitiya'),
                        ),
                        DropdownMenuItem(
                          value: '6.0329092,80.2131825',
                          child: Text('Galle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      onChanged: (value) {},
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an destination stop';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'To',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.arrow_circle_down),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '6.0329092,80.2131825',
                          child: Text('Galle'),
                        ),
                        DropdownMenuItem(
                          value: '6.9111207,79.7049656',
                          child: Text('Kollupitiya'),
                        ),
                        DropdownMenuItem(
                          value: '6.9346378,79.9814374',
                          child: Text('Kaduwella'),
                        ),
                        DropdownMenuItem(
                          value: '6.7744328,79.8801515',
                          child: Text('Morattuwa'),
                        ),
                        DropdownMenuItem(
                          value: '7.0923857,79.9891625',
                          child: Text('Gampaha'),
                        ),
                        DropdownMenuItem(
                          value: '6.9336339,79.8526605',
                          child: Text('Colombo'),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
