import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _data = [
    OnboardingData(
      image: 'assets/images/onboarding1.png',
      title: 'Explore Upcoming and Nearby Events',
      description:
          'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding2.png',
      title: 'Web Any Event Easily and Quickly with Us',
      description:
          'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding3.png',
      title: 'Sign In to Discover Every Upcoming Event',
      description:
          'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    const Spacer(),
                    Image.asset(
                      _data[index].image,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(48),
                          topRight: Radius.circular(48),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            _data[index].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _data[index].description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(500)),
                                ),
                              ),
                              SmoothPageIndicator(
                                controller: _controller,
                                count: _data.length,
                                effect: const ExpandingDotsEffect(
                                  expansionFactor: 4,
                                  activeDotColor: Colors.white,
                                  dotColor: Colors.white24,
                                  dotHeight: 10,
                                  dotWidth: 10,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (_currentPage == _data.length - 1) {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  } else {
                                    _controller.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                    );
                                  }
                                },
                                child: Text(
                                  _currentPage == _data.length - 1
                                      ? 'Finish'
                                      : 'Next',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
