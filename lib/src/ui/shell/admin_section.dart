import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dashboard sections in side-navigation order. [permission] is the view
/// code the section needs; sections the staff member can't view are hidden.
enum AdminSection {
  overview(
    'Overview',
    Icons.space_dashboard_outlined,
    'reports.view',
    'Dashboard',
  ),
  users('Customers', Icons.people_alt_outlined, 'users.view', 'Customers'),
  kyc('KYC review', Icons.badge_outlined, 'kyc.view', 'Customers'),
  goals('Goals', Icons.savings_outlined, 'goals.view', 'Operations'),
  payments('Payments', Icons.payments_outlined, 'payments.view', 'Operations'),
  refunds(
    'Refunds',
    Icons.currency_exchange_outlined,
    'refunds.view',
    'Operations',
  ),
  bookings(
    'Bookings',
    Icons.confirmation_number_outlined,
    'bookings.view',
    'Operations',
  ),
  itineraries('Trips', Icons.map_outlined, 'catalogue.view', 'Catalogue'),
  operators(
    'Operators',
    Icons.business_outlined,
    'catalogue.view',
    'Catalogue',
  ),
  destinations(
    'Destinations',
    Icons.place_outlined,
    'catalogue.view',
    'Catalogue',
  ),
  refundPolicies(
    'Refund policies',
    Icons.policy_outlined,
    'catalogue.view',
    'Catalogue',
  ),
  notifications(
    'Notifications',
    Icons.campaign_outlined,
    'notifications.view',
    'System',
  ),
  fx('FX rates', Icons.show_chart_outlined, 'fx.view', 'System'),
  settings('Settings', Icons.tune_outlined, 'settings.view', 'System'),
  staff('Staff', Icons.admin_panel_settings_outlined, 'staff.view', 'Access'),
  roles('Roles', Icons.key_outlined, 'roles.view', 'Access'),
  audit('Audit log', Icons.history_outlined, 'audit.view', 'Access');

  const AdminSection(this._label, this.icon, this.permission, this._group);
  final String _label;
  final IconData icon;
  final String permission;
  final String _group;

  String get label => _label.tr;
  String get group => _group.tr;
}
