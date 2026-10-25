import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/safari_logo.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/core/utils/locale_manager.dart';
import 'package:safarichap_admin/src/core/utils/theme_manager.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';

import 'admin_section.dart';
import 'shell_controller.dart';

/// Side navigation + top bar around the current page ([child], from the
/// router's ShellRoute). [location] is the URL path; it picks the highlighted
/// section, the title and the browser tab title.
class ShellScreen extends StatelessWidget {
  final String location;
  final Widget child;
  const ShellScreen({super.key, required this.location, required this.child});

  static const _wideBreakpoint = 1000.0;

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find();
    final sections = AdminSection.values
        .where((s) => session.can(s.permission))
        .toList();
    final current = AdminSection.fromLocation(location);

    return Title(
      title: current == null
          ? "SafariChap Admin"
          : '${current.label} · SafariChap Admin',
      color: safariChapColors.secondaryColor!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _wideBreakpoint;
          return Scaffold(
            drawer: wide
                ? null
                : Drawer(
                    child: _SideNav(
                      sections: sections,
                      current: current,
                      extended: true,
                      inDrawer: true,
                    ),
                  ),
            body: Row(
              children: [
                if (wide)
                  Obx(
                    () => _SideNav(
                      sections: sections,
                      current: current,
                      extended: Get.find<ShellController>().railExtended.value,
                    ),
                  ),
                if (wide) const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(showMenu: !wide, title: current?.label ?? ''),
                      const Divider(height: 1),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  final List<AdminSection> sections;
  final AdminSection? current;
  final bool extended;
  final bool inDrawer;
  const _SideNav({
    required this.sections,
    required this.current,
    required this.extended,
    this.inDrawer = false,
  });

  @override
  Widget build(BuildContext context) {
    final ShellController shell = Get.find();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark
        ? safariChapColors.primaryColor!
        : safariChapColors.secondaryColor!;

    final children = <Widget>[];
    String? group;
    for (final section in sections) {
      if (extended && section.group != group) {
        group = section.group;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 6),
            child: Text(
              group.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      children.add(
        Builder(
          builder: (context) {
            final selected = current == section;
            final item = Material(
              color: selected
                  ? safariChapColors.primaryColor!.withValues(alpha: 0.22)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  shell.select(section);
                  if (inDrawer) Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: extended ? 12 : 0,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: extended
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(
                        section.icon,
                        size: 20,
                        color: selected
                            ? selectedColor
                            : scheme.onSurfaceVariant,
                      ),
                      if (extended) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            section.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? selectedColor
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              // Collapsed rail shows icons only, so name the section on hover.
              child: extended
                  ? item
                  : Tooltip(message: section.label, child: item),
            );
          },
        ),
      );
    }

    return Container(
      width: extended ? 232 : 72,
      color: isDark ? null : safariChapColors.surfaceColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                extended ? 20 : 0,
                18,
                extended ? 12 : 0,
                8,
              ),
              child: Row(
                mainAxisAlignment: extended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  const SafariLogo(size: 32),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text.rich(
                        overflow: TextOverflow.ellipsis,
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            const TextSpan(text: "Safari"),
                            TextSpan(
                              text: "Chap",
                              style: TextStyle(
                                color: safariChapColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: children,
              ),
            ),
            if (!inDrawer)
              IconButton(
                tooltip: extended ? "Collapse".tr : "Expand".tr,
                icon: Icon(
                  extended
                      ? Icons.keyboard_double_arrow_left
                      : Icons.keyboard_double_arrow_right,
                ),
                onPressed: shell.toggleRail,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showMenu;
  final String title;
  const _TopBar({required this.showMenu, required this.title});

  @override
  Widget build(BuildContext context) {
    final SessionController session = Get.find();
    final ThemeManager themeManager = sl();
    final LocaleManager localeManager = sl();
    final me = session.me.value;
    if (me == null) return const SizedBox(height: 60);

    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (showMenu)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            PopupMenuButton<Locale>(
              tooltip: "Language".tr,
              icon: const Icon(Icons.translate),
              onSelected: localeManager.changeLocale,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: LocaleManager.english,
                  child: Text("English"),
                ),
                PopupMenuItem(
                  value: LocaleManager.swahili,
                  child: Text("Kiswahili"),
                ),
              ],
            ),
            IconButton(
              tooltip: "Dark mode".tr,
              icon: Icon(
                themeManager.isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              onPressed: () =>
                  themeManager.toggleTheme(isDark: !themeManager.isDark),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              tooltip: me.user.displayName,
              offset: const Offset(0, 48),
              onSelected: (value) {
                if (value == 'signout') session.signOut();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        me.user.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (me.user.email != null)
                        Text(
                          me.user.email!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        me.roles.map((r) => r.name).join(', '),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'signout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 18),
                      const SizedBox(width: 8),
                      Text("Sign out".tr),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 17,
                backgroundColor: safariChapColors.secondaryColor,
                child: Text(
                  me.user.displayName.characters.first.toUpperCase(),
                  style: TextStyle(
                    color: safariChapColors.onSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
