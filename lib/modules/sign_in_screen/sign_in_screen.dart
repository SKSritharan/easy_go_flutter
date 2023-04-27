import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/sign_in_controller.dart';
import '../../utils/widgets/custom_elevated_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GetBuilder<SignInController>(
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
                          'Login',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Let\'s login to start journey',
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
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        child: const Text('Forgot Password'),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 32),
                    Obx(
                      () => CustomElevatedButton(
                        onPressed: controller.submitForm,
                        isLoading: controller.isLoading.value,
                        label: 'Login',
                      )
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account?'),
                        TextButton(
                          child: const Text('Register'),
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            '/register',
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
