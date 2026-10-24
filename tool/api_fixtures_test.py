"""
Records real /api/admin/ responses as JSON fixtures for the dashboard's model
tests (test/api_contract_test.dart). Run from the API repo:

  cp ../safarichap_admin/tool/api_fixtures_test.py apps/adminpanel/tests/test_zz_fixtures.py
  ADMIN_FIXTURES_DIR=../safarichap_admin/test/fixtures \
    DJANGO_SETTINGS_MODULE=config.settings.test .venv/bin/python manage.py test apps.adminpanel.tests.test_zz_fixtures
  rm apps/adminpanel/tests/test_zz_fixtures.py
"""
import json
import os
from unittest import mock

from rest_framework.test import APIClient

from apps.adminpanel.models import Role
from apps.adminpanel.tests.test_modules import AdminBase
from apps.bookings.models import Booking
from apps.userauth.models import KycDocument


class RecordFixtures(AdminBase):
    def save(self, name, path, method='get', body=None):
        res = getattr(self.client, method)(path, body, format='json') if body is not None else getattr(self.client, method)(path)
        self.assertLess(res.status_code, 300, (path, res.data))
        out = os.environ.get('ADMIN_FIXTURES_DIR', 'fixtures')
        os.makedirs(out, exist_ok=True)
        with open(os.path.join(out, f'{name}.json'), 'w') as f:
            json.dump(json.loads(res.content), f, indent=2, ensure_ascii=False)
        return res

    def test_record(self):
        goal = self.active_goal()
        self.pay(goal, goal.total_amount, ref='FIXTUREPAY0001')
        goal2 = self.active_goal()
        self.pay(goal2, 100000, ref='FIXTUREPAY0002')
        self.app.post(f'/api/goals/{goal2.uuid}/cancel/', {}, format='json')
        self.app.post('/api/users/kyc/', {'document_type': 'passport', 'document_number': 'AB123456'}, format='json')
        booking = Booking.objects.get(goal=goal)
        self.client.post('/api/admin/fx-rates/', {'from_currency': 'USD', 'numerator': 2650}, format='json')
        self.client.post('/api/admin/roles/', {'name': 'Auditor', 'permissions': ['audit.view']}, format='json')
        with self.captureOnCommitCallbacks(execute=True):
            self.client.post('/api/admin/broadcasts/', {'title': 'Hi', 'message': 'News', 'audience': 'all'}, format='json')

        self.save('me', '/api/admin/me/')
        self.save('permissions', '/api/admin/permissions/')
        self.save('roles', '/api/admin/roles/')
        self.save('staff', '/api/admin/staff/')
        self.save('audit_logs', '/api/admin/audit-logs/')
        self.save('users', '/api/admin/users/')
        self.save('user_detail', f'/api/admin/users/{self.customer.uuid}/')
        self.save('kyc', '/api/admin/kyc/')
        self.save('goals', '/api/admin/goals/')
        self.save('goal_detail', f'/api/admin/goals/{goal2.uuid}/')
        self.save('payments', '/api/admin/payments/')
        payment = goal.payments.first()
        self.save('payment_detail', f'/api/admin/payments/{payment.uuid}/')
        self.save('refunds', '/api/admin/refunds/')
        self.save('bookings', '/api/admin/bookings/')
        self.save('booking_detail', f'/api/admin/bookings/{booking.uuid}/')
        self.save('operators', '/api/admin/operators/')
        self.save('destinations', '/api/admin/destinations/')
        self.save('refund_policies', '/api/admin/refund-policies/')
        self.save('itineraries', '/api/admin/itineraries/')
        self.save('itinerary_detail', f'/api/admin/itineraries/{self.itinerary.uuid}/')
        self.save('fx_current', '/api/admin/fx-rates/current/')
        self.save('fx_rates', '/api/admin/fx-rates/')
        self.save('settings', '/api/admin/settings/')
        self.save('notifications', '/api/admin/notifications/')
        self.save('broadcasts', '/api/admin/broadcasts/')
        self.save('stats', '/api/admin/stats/?days=30')
