import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class OnboardingController extends GetxController {
  late PageController pageController;
  final currentPage = 0.obs;
  final storage = GetStorage();
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    currentPage.value = 0;
    startAutoScroll();
  }

  void startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (pageController.hasClients && pageController.positions.length == 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  void updatePageIndex(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (pageController.positions.length == 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    storage.write('seen_onboarding', true);
    Get.toNamed('login-page');
  }

  void finishOnboarding() {
    storage.write('seen_onboarding', true);
    Get.toNamed('login-page');
  }

  @override
  void onClose() {
    stopAutoScroll();
    pageController.dispose();
    super.onClose();
  }
}
