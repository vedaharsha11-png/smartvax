part of '../app_pages.dart';

class HealthTipsPage extends StatelessWidget {
  const HealthTipsPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Parent health tips',
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageTitle(
            context,
            'Helpful reminders',
            'Short, general information for parents',
          ),
          ...controller.tips.map(
            (tip) => LiquidGlassCard(
              margin: const EdgeInsets.only(bottom: 9),
              onTap: () => pushPage(context, HealthTipPage(tip: tip)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.violet.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.violet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          tip.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.blue),
                ],
              ),
            ),
          ),
          appNotice(
            'General information only. For personalized health questions, speak with a qualified healthcare professional.',
          ),
        ],
      ),
    ),
  );
}

class HealthTipPage extends StatelessWidget {
  const HealthTipPage({super.key, required this.tip});
  final HealthTip tip;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Health tip',
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiquidGlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.pink,
                  size: 45,
                ),
                const SizedBox(height: 12),
                Text(
                  tip.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  tip.body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          appNotice(
            'This is general educational information and is not medical advice.',
          ),
        ],
      ),
    ),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Settings',
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pageTitle(context, 'Preferences', 'Manage your SmartVax account'),
          LiquidGlassCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.settings.remindersEnabled,
                  onChanged: controller.toggleAllReminders,
                  title: const Text(
                    'In-app reminders',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Show reminders while using SmartVax',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.language, color: AppColors.blue),
                  title: const Text(
                    'Language',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'English',
                    style: TextStyle(color: AppColors.secondary),
                  ),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('English is currently available.'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _MenuLink(
            icon: Icons.person_outline,
            label: 'Parent profile',
            onTap: () => pushPage(
              context,
              GuardianFormPage(
                controller: controller,
                guardianId: controller.activeGuardianId,
              ),
            ),
          ),
          _MenuLink(
            icon: Icons.child_care,
            label: 'My children',
            onTap: () =>
                pushPage(context, ChildrenPage(controller: controller)),
          ),
          _MenuLink(
            icon: Icons.help_outline,
            label: 'Help center',
            onTap: () => pushPage(context, HelpPage(controller: controller)),
          ),
          _MenuLink(
            icon: Icons.info_outline,
            label: 'About SmartVax',
            onTap: () => pushPage(context, AboutPage(controller: controller)),
          ),
          const SizedBox(height: 8),
          if (controller.accountRepository == null)
            OutlinedButton.icon(
              onPressed: () async {
                if (await _confirm(
                  context,
                  'Reset sample information?',
                  'All in-session edits will be replaced with the original family information.',
                )) {
                  controller.reset();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Original sample information restored'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset sample information'),
            ),
          const SizedBox(height: 9),
          GradientButton(
            label: 'Log out',
            icon: Icons.logout,
            danger: true,
            onPressed: controller.logout,
          ),
          const SizedBox(height: 11),
          appNotice(
            'Language support currently includes English. Your account preferences synchronize with Cloud Firestore.',
          ),
        ],
      ),
    ),
  );
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) {
    final faqs = <(String, String)>[
      (
        'How do I log in?',
        'Enter a 10-digit number and verify with Firebase. Configured testing numbers use the code set in the Firebase Console and receive no SMS.',
      ),
      (
        'How do I switch children?',
        'Use the child selector on Home or open My children and choose Switch child.',
      ),
      (
        'How do I view vaccination history?',
        'Open Records from the bottom navigation and select a record for its details.',
      ),
      (
        'How do I add a vaccination record?',
        'Open Records, tap the add button, and enter the details shown on the official vaccination card.',
      ),
      (
        'How do I request an appointment?',
        'Open a doctor or center profile, choose Request visit, then save the local request.',
      ),
      (
        'How do reminders work?',
        'Reminders appear inside the app. SmartVax does not schedule operating-system notifications.',
      ),
      (
        'How do I reset sample information?',
        'Open Settings and choose Reset sample information. This restores the original local records.',
      ),
      (
        'Why is no SMS sent?',
        'Sign in with Firebase Phone Authentication. Use the verification code provided by Firebase.',
      ),
      (
        'Where is information stored?',
        'Edits synchronize with your Firebase account. Check the synchronization indicator before closing the application.',
      ),
    ];
    return AppPage(
      title: 'Help center',
      child: _pageScroll(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageTitle(
              context,
              'How can we help?',
              'Answers about using the app',
            ),
            ...faqs.map(
              (faq) => LiquidGlassCard(
                margin: const EdgeInsets.only(bottom: 7),
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  title: Text(
                    faq.$1,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.$2,
                      style: const TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            appNotice(
              'For vaccination decisions, use the official record and consult a qualified healthcare professional.',
            ),
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.controller});
  final SmartVaxController controller;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'About SmartVax',
    child: _pageScroll(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LiquidGlassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const BrandMark(),
                const SizedBox(height: 17),
                Text(
                  'Smart Child Vaccination Tracking System',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Community Service Project',
                  style: TextStyle(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'SmartVax helps families organize children’s vaccination information, upcoming visits, and provider details in one friendly application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.secondary, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LiquidGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader('Project information'),
                _rowLabel('Technology', 'Flutter and Dart'),
                _rowLabel('Connectivity', 'Offline only'),
                _rowLabel('Storage', 'Account-owned Cloud Firestore data'),
                _rowLabel('Household', 'Fictional sample information'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          appNotice(
            'The testing household contains illustrative sample information. It does not replace official vaccination records or advice from healthcare professionals.',
          ),
        ],
      ),
    ),
  );
}
