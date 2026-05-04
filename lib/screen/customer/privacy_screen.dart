import 'package:flutter/material.dart';
import '../shared/widgets/profile_scaffold.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScaffold(
      title: 'Privacy Policy',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Text(
                      'Inggo – Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121212),
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Owner: InnGroup SARL\nCountry: Republic of Djibouti\nLast Updated: Wednesday, 7 January',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _p('This Privacy Policy describes how Inggo collects, uses, processes, stores, protects, and discloses personal data of Users and Partner Drivers who use the mobile application Inggo.'),

            _h2('1. Publisher Identification'),
            _bullet('Corporate Entity: InnGroup SARL'),
            _bullet('Application Name: Inggo'),
            _bullet('Business Activity: On-demand connection platform for motorized two-wheeled transport'),
            _bullet('Country: Republic of Djibouti'),
            _bullet('Head Office: Gabode 5, Djibouti'),
            _bullet('Contact: admin@inngroupsarl.com'),

            _h2('2. Personal Data Collected'),
            _h3('2.1 Data Provided by Users'),
            _bullet('Full name, Phone number, Email address'),
            _bullet('Optional profile photo'),
            _bullet('Payment and billing information'),
            _h3('2.2 Data Provided by Partner Drivers'),
            _bullet('Full name, Phone number, Email, Profile photo'),
            _bullet('Government-issued ID, Valid driving license'),
            _bullet('Vehicle details, Banking details'),
            _h3('2.3 Data Collected Automatically'),
            _bullet('GPS location data (during active rides)'),
            _bullet('IP address and device identifiers'),
            _bullet('Application usage data and interaction logs'),

            _h2('3. Purpose and Legal Basis'),
            _bullet('Connecting Users with nearby Partner Drivers'),
            _bullet('Calculating fares based on distance, time, and route'),
            _bullet('Processing payments and Partner Driver payouts'),
            _bullet('Sending service-related communications'),
            _bullet('Improving application performance through analytics'),

            _h2('4. Data Sharing and Disclosure'),
            _p('InnGroup SARL does not sell personal data to third parties. Data may be shared only with trusted technical service providers and public authorities when legally required.'),

            _h2('5. Data Retention and Deletion'),
            _p('Personal data are retained for as long as the account remains active. Upon deletion, data are securely erased or anonymized.'),

            _h2('6. Data Security Measures'),
            _bullet('Encryption of data in transit and at rest'),
            _bullet('Secure HTTPS communications'),
            _bullet('Access restrictions to authorized personnel'),
            _bullet('Regular security audits'),

            _h2('7. User Rights'),
            _bullet('Access, correct, or delete personal data'),
            _bullet('Object to certain processing activities'),
            _bullet('Request data portability'),
            _bullet('Withdraw consent at any time'),
            _p('All requests: admin@inngroupsarl.com'),

            _h2('8. Account Deletion'),
            _p('Accounts may be deleted through the application or by email. Deletion processed within 30 calendar days.'),

            _h2('9. Cookies and Similar Technologies'),
            _p('Inggo may use cookies solely for functionality, analytics, security, and optimization.'),

            _h2('10. Policy Updates'),
            _p('InnGroup SARL reserves the right to update this Privacy Policy at any time. Users will be informed of significant changes.'),

            _h2('11. Contact Information'),
            _bullet('Company: InnGroup SARL'),
            _bullet('Country: Republic of Djibouti'),
            _bullet('Email: admin@inngroupsarl.com'),

            _h2('Governing Law'),
            _p('This Privacy Policy is governed by the laws of the Republic of Djibouti.'),
          ],
        ),
      ),
    );
  }

  static Widget _h2(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Container(
        padding: const EdgeInsets.only(bottom: 5),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF121212),
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }

  static Widget _h3(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF121212),
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  static Widget _p(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
          height: 1.6,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  static Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF757575))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
                height: 1.6,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
