import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/sign_up_controller.dart';
import '../../utils/widgets/custom_elevated_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final FocusNode roleFocus = FocusNode();

    return GetBuilder<SignUpController>(
      builder: (controller) => Scaffold(
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Let\'s Register to start journey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Name',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: controller.nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            hintText: 'Enter your name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Role',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          focusNode: roleFocus,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_rounded),
                            hintText: 'Select a user role',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 10),
                              child: DropdownButtonFormField<String>(
                                value: controller.selectedRole,
                                icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded),
                                decoration: const InputDecoration.collapsed(
                                  hintText: 'Select an User Role',
                                ),
                                onChanged: (String? newValue) {
                                  controller.selectedRole = newValue!;
                                },
                                onTap: () => roleFocus.unfocus(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select a role';
                                  }
                                  return null;
                                },
                                items: <String>[
                                  'User',
                                  'Driver',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: controller.emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.mail),
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.password),
                              hintText: 'Enter your password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(controller.isVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: controller.changePasswordVisibility,
                              ),
                            ),
                            obscureText: controller.isVisible.value,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your password';
                              } else if (value.length < 8) {
                                return 'The password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirm Password',
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Obx(
                          () => TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.password),
                              hintText: 'Enter your password again',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(controller.isVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: controller.changePasswordVisibility,
                              ),
                            ),
                            obscureText: controller.isVisible.value,
                            validator: (value) {
                              if (value!.isEmpty ||
                                  value != controller.passwordController.text) {
                                return 'The password does not match';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Obx(
                      () => CustomElevatedButton(
                        onPressed: controller.submitForm,
                        isLoading: controller.isLoading.value,
                        label: 'Register',
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          child: const Text('Login'),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/login',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
