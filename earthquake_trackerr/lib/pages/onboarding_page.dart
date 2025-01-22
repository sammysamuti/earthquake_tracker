import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:earthquake_trackerr/controllers/onboarding_controller.dart';
import 'package:earthquake_trackerr/models/onboarding_model.dart';

class OnboardingView extends GetView<OnboardingController> {
   static String route = 'onboarding-page';
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Language selector
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               
                ),
              ),
            ),

            // PageView with infinite scroll
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.updatePageIndex,
                itemCount:
                    1000000, // Set to a large number to simulate infinite scroll
                itemBuilder: (context, index) {
                  final page = onboardingPages[index % onboardingPages.length];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image with specific size
                      SizedBox(
                        height: Get.height * 0.4,
                        child: Image.asset(
                          page.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Custom Dots Indicator
                      SizedBox(
                        height: 30, // Space for the outer circle
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              List.generate(onboardingPages.length, (index) {
                            return Obx(() {
                              bool isActive = index ==
                                  (controller.currentPage.value %
                                      onboardingPages.length);
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Dot
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.blue
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    // Outer circle (only shows for active dot)
                                    if (isActive)
                                      Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            });
                          }),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Updated Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Updated Skip button
                  Container(
                    height: 50, // Increased height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: controller.skipOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40), // Wider padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Updated Next/Get Started button
                  Container(
                    height: 50, // Increased height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => TextButton(
                          onPressed: controller.currentPage.value %
                                      onboardingPages.length ==
                                  onboardingPages.length - 1
                              ? controller.finishOnboarding
                              : controller.nextPage,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40), // Wider padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            controller.currentPage.value %
                                        onboardingPages.length ==
                                    onboardingPages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
