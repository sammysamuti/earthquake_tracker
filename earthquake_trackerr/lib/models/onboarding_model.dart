class OnboardingModel {
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<OnboardingModel> onboardingPages = [
 OnboardingModel(
    image: 'assets/images/first.jpg',
    title: 'Stay Informed\nAbout Earthquakes',
    description:
        'Get real-time updates on recent\nearthquakes happening globally.',
  ),
  OnboardingModel(
    image: 'assets/images/second.jpg',
    title: 'Receive Instant Alerts',
    description:
        'Get notified immediately when an\nearthquake occurs near you.',
  ),
  OnboardingModel(
    image: 'assets/images/third.jpg',
    title: 'Analyze and Prepare',
    description:
        'Use our app to analyze earthquake\npatterns and plan for safety.',
  ),

];
