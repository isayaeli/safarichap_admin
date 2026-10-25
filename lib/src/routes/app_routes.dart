/// URLs of pages outside the side-nav sections, and of detail pages.
/// Section list URLs are `AdminSection.path`.
// ignore: avoid_classes_with_only_static_members
class AppRoutes {
  static const signIn = '/sign-in';
  static const loading = '/loading';
  static const noAccess = '/no-access';

  static String customer(String uuid) => '/customers/$uuid';
  static String goal(String uuid) => '/goals/$uuid';
  static String payment(String uuid) => '/payments/$uuid';
  static String booking(String uuid) => '/bookings/$uuid';
  static const newTrip = '/trips/new';
  static String trip(String uuid) => '/trips/$uuid';
}
