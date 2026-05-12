import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
  ];

  // ─── General ───
  String get appName => _t('Inggo', 'Inggo');
  String get loading => _t('Chargement...', 'Loading...');
  String get error => _t('Erreur', 'Error');
  String get success => _t('Succès', 'Success');
  String get cancel => _t('Annuler', 'Cancel');
  String get confirm => _t('Confirmer', 'Confirm');
  String get save => _t('Enregistrer', 'Save');
  String get delete => _t('Supprimer', 'Delete');
  String get retry => _t('Réessayer', 'Retry');
  String get close => _t('Fermer', 'Close');
  String get next => _t('Suivant', 'Next');
  String get back => _t('Retour', 'Back');
  String get done => _t('Terminé', 'Done');
  String get skip => _t('Passer', 'Skip');
  String get ok => _t('OK', 'OK');
  String get yes => _t('Oui', 'Yes');
  String get no => _t('Non', 'No');
  String get or => _t('ou', 'or');

  // ─── Auth ───
  String get welcome => _t('Bienvenue', 'Welcome');
  String get welcomeSubtitle => _t('Votre moto-taxi à Djibouti', 'Your moto-taxi in Djibouti');
  String get login => _t('Connexion', 'Login');
  String get register => _t('Inscription', 'Register');
  String get phoneNumber => _t('Numéro de téléphone', 'Phone number');
  String get phoneHint => _t('77 00 00 00', '77 00 00 00');
  String get sendOtp => _t('Envoyer le code', 'Send code');
  String get otpTitle => _t('Vérification', 'Verification');
  String get otpSubtitle => _t('Entrez le code envoyé au', 'Enter the code sent to');
  String get verifyOtp => _t('Vérifier', 'Verify');
  String get resendOtp => _t('Renvoyer le code', 'Resend code');
  String get otpSent => _t('Code envoyé', 'Code sent');
  String get otpExpired => _t('Code expiré', 'Code expired');
  String get otpResendIn => _t('Renvoyer dans', 'Resend in');
  String get invalidOtp => _t('Code invalide', 'Invalid code');
  String get chooseRole => _t('Choisissez votre profil', 'Choose your profile');
  String get iAmClient => _t('Je suis client', 'I am a client');
  String get iAmDriver => _t('Je suis chauffeur', 'I am a driver');
  String get fullName => _t('Nom complet', 'Full name');
  String get nameHint => _t('Ahmed Mohamed', 'Ahmed Mohamed');

  // ─── Driver Registration ───
  String get driverRegister => _t('Inscription chauffeur', 'Driver registration');
  String get plateNumber => _t('Numéro de plaque', 'Plate number');
  String get vehicleColor => _t('Couleur du véhicule', 'Vehicle color');
  String get idCard => _t('Carte d\'identité', 'ID card');
  String get driverLicense => _t('Permis de conduire', 'Driver license');
  String get vehiclePhoto => _t('Photo du véhicule', 'Vehicle photo');
  String get uploadDocument => _t('Télécharger un document', 'Upload document');
  String get pendingVerification => _t('En attente de vérification', 'Pending verification');
  String get pendingVerificationMsg => _t('Votre profil est en cours de vérification. Vous serez notifié une fois approuvé.', 'Your profile is being verified. You will be notified once approved.');

  // ─── Home Client ───
  String get home => _t('Accueil', 'Home');
  String get bookRide => _t('Réserver une course', 'Book a ride');
  String get whereTo => _t('Où allez-vous ?', 'Where to?');
  String setDestination(String label) => _t('Destination: $label', 'Destination: $label');

  // ─── Search ───
  String get searchDestination => _t('Rechercher une destination', 'Search destination');
  String get searchPickup => _t('Rechercher un point de départ', 'Search pickup');
  String get selectOnMap => _t('Sélectionner sur la carte', 'Select on map');
  String get noResults => _t('Aucun résultat', 'No results');
  String get popularPlaces => _t('Lieux populaires', 'Popular places');
  String get recentSearches => _t('Recherches récentes', 'Recent searches');

  // ─── Booking ───
  String get rideSummary => _t('Récapitulatif', 'Ride summary');
  String get pickup => _t('Départ', 'Pickup');
  String get dropoff => _t('Arrivée', 'Dropoff');
  String get price => _t('Prix', 'Price');
  String get paymentMethod => _t('Mode de paiement', 'Payment method');
  String get confirmBooking => _t('Confirmer la réservation', 'Confirm booking');
  String get cash => _t('Espèces', 'Cash');
  String get comingSoon => _t('Bientôt disponible', 'Coming soon');

  // ─── Ride Status ───
  String get searchingDriver => _t('Recherche d\'un chauffeur...', 'Searching for a driver...');
  String get driverFound => _t('Chauffeur trouvé !', 'Driver found!');
  String get driverOnTheWay => _t('Le chauffeur arrive', 'Driver is on the way');
  String get rideInProgress => _t('Course en cours', 'Ride in progress');
  String get rideCompleted => _t('Course terminée', 'Ride completed');
  String get rideCancelled => _t('Course annulée', 'Ride cancelled');
  String get noDriverFound => _t('Aucun chauffeur trouvé', 'No driver found');
  String get tryAgain => _t('Réessayer', 'Try again');
  String get cancelRide => _t('Annuler la course', 'Cancel ride');
  String get cancelReason => _t('Raison de l\'annulation', 'Cancellation reason');
  String get freeCancellation => _t('Annulation gratuite', 'Free cancellation');

  // ─── End Trip ───
  String get rateDriver => _t('Notez votre chauffeur', 'Rate your driver');
  String get leaveReview => _t('Laisser un avis (optionnel)', 'Leave a review (optional)');
  String get addTip => _t('Ajouter un pourboire', 'Add a tip');
  String get noTip => _t('Pas de pourboire', 'No tip');
  String get thankYou => _t('Merci !', 'Thank you!');

  // ─── Driver Home ───
  String get goOnline => _t('Se connecter', 'Go online');
  String get goOffline => _t('Se déconnecter', 'Go offline');
  String get youAreOnline => _t('Vous êtes en ligne', 'You are online');
  String get youAreOffline => _t('Vous êtes hors ligne', 'You are offline');
  String get newRideRequest => _t('Nouvelle demande de course', 'New ride request');
  String get accept => _t('Accepter', 'Accept');
  String get decline => _t('Refuser', 'Decline');
  String get navigateToPickup => _t('Aller au départ', 'Navigate to pickup');
  String get navigateToDropoff => _t('Aller à l\'arrivée', 'Navigate to dropoff');
  String get arriveAtPickup => _t('Arrivé au départ', 'Arrived at pickup');
  String get startRide => _t('Démarrer la course', 'Start ride');
  String get completeRide => _t('Terminer la course', 'Complete ride');
  String get collectCash => _t('Collecter les espèces', 'Collect cash');
  String get cashCollected => _t('Espèces collectées', 'Cash collected');

  // ─── Earnings ───
  String get earnings => _t('Revenus', 'Earnings');
  String get todayEarnings => _t('Revenus du jour', 'Today\'s earnings');
  String get weekEarnings => _t('Revenus de la semaine', 'Week earnings');
  String get monthEarnings => _t('Revenus du mois', 'Month earnings');
  String get totalRides => _t('Courses totales', 'Total rides');
  String get totalEarnings => _t('Revenus totaux', 'Total earnings');

  // ─── History ───
  String get history => _t('Historique', 'History');
  String get noRides => _t('Aucune course', 'No rides');
  String get rideDetails => _t('Détails de la course', 'Ride details');

  // ─── Favorites ───
  String get favorites => _t('Favoris', 'Favorites');
  String get addFavorite => _t('Ajouter un favori', 'Add favorite');
  String get favoriteLabel => _t('Nom du lieu', 'Place name');
  String get home2 => _t('Maison', 'Home');
  String get work => _t('Travail', 'Work');
  String get other => _t('Autre', 'Other');

  // ─── Profile ───
  String get profile => _t('Profil', 'Profile');
  String get editProfile => _t('Modifier le profil', 'Edit profile');
  String get changePhoto => _t('Changer la photo', 'Change photo');
  String get changePhone => _t('Changer le téléphone', 'Change phone');
  String get language => _t('Langue', 'Language');
  String get french => _t('Français', 'French');
  String get english => _t('Anglais', 'English');
  String get logout => _t('Déconnexion', 'Logout');
  String get logoutConfirm => _t('Voulez-vous vous déconnecter ?', 'Do you want to logout?');

  // ─── Settings ───
  String get settings => _t('Paramètres', 'Settings');
  String get notifications => _t('Notifications', 'Notifications');
  String get about => _t('À propos', 'About');
  String get privacyPolicy => _t('Politique de confidentialité', 'Privacy policy');
  String get termsOfService => _t('Conditions d\'utilisation', 'Terms of service');
  String get support => _t('Support', 'Support');
  String get version => _t('Version', 'Version');

  // ─── Support ───
  String get faq => _t('Questions fréquentes', 'FAQ');
  String get contactUs => _t('Nous contacter', 'Contact us');
  String get callUs => _t('Nous appeler', 'Call us');
  String get sendMessage => _t('Envoyer un message', 'Send message');

  // ─── Notifications ───
  String get noNotifications => _t('Aucune notification', 'No notifications');
  String get markAllRead => _t('Tout marquer comme lu', 'Mark all as read');

  // ─── Driver Home ───
  String get online => _t('En ligne', 'Online');
  String get offline => _t('Hors ligne', 'Offline');
  String get goOnlinePrompt => _t('Activez-vous pour recevoir des courses', 'Go online to receive ride requests');
  String get rides => _t('Courses', 'Rides');

  // ─── Driver Ride ───
  String get goToPickup => _t('Aller au départ', 'Go to pickup');
  String get arrivedAtPickup => _t('Arrivé au départ', 'Arrived at pickup');
  String get rideInProgressLabel => _t('Course en cours', 'Ride in progress');
  String get completeRideLabel => _t('Terminer la course', 'Complete ride');
  String get loadRide => _t('Chargement de la course...', 'Loading ride...');
  String get back => _t('Retour', 'Back');

  // ─── Client Trip ───
  String get driverOnTheWayLabel => _t('Votre chauffeur arrive', 'Your driver is on the way');
  String get driverEnRoute => _t('Chauffeur en route', 'Driver en route');
  String get callDriver => _t('Appeler', 'Call');
  String get cancelRideLabel => _t('Annuler', 'Cancel');
  String get driverPhoneUnavailable => _t('Numéro de téléphone du chauffeur non disponible.', 'Driver phone number unavailable.');
  String get unableToMakeCall => _t('Impossible de lancer l\'appel.', 'Unable to make call.');

  // ─── Searching ───
  String get searchingDriverLabel => _t('Recherche d\'un chauffeur...', 'Searching for a driver...');
  String get pleaseWait => _t('Veuillez patienter...', 'Please wait...');
  String get noDriverFoundTitle => _t('Aucun chauffeur trouvé', 'No driver found');
  String get noDriverFoundMessage => _t('Désolé, aucun chauffeur n\'est disponible pour le moment. Veuillez réessayer.', 'Sorry, no driver is available at the moment. Please try again.');
  String get cancelSearch => _t('Annuler', 'Cancel');

  // ─── Documents ───
  String get insurance => _t('Assurance', 'Insurance');
  String get yourDocuments => _t('Vos documents', 'Your documents');
  String get submitForVerification => _t('Soumettez vos documents pour vérification', 'Submit your documents for verification');
  String get takePhoto => _t('Prendre une photo', 'Take a photo');
  String get chooseFromGallery => _t('Choisir depuis la galerie', 'Choose from gallery');
  String get uploadSuccess => _t('Document envoyé avec succès', 'Document uploaded successfully');
  String get uploading => _t('Envoi en cours...', 'Uploading...');
  String get notSubmittedYet => _t('Non soumis', 'Not submitted');
  String get pendingVerificationLabel => _t('En attente de vérification', 'Pending verification');
  String get accountVerified => _t('Votre compte est vérifié et actif', 'Your account is verified and active');
  String get underReview => _t('Vos documents sont en cours d\'examen par l\'équipe', 'Your documents are under review');
  String get submitAllRequired => _t('Veuillez soumettre tous les documents requis', 'Please submit all required documents');
  String get submitColon => _t('Soumettre :', 'Submit:');

  // ─── Earnings ───
  String get totalEarningsLabel => _t('Revenus totaux', 'Total earnings');
  String get details => _t('Détails', 'Details');
  String get pricePerRide => _t('Prix par course', 'Price per ride');
  String get yourEarningPerRide => _t('Votre gain/course', 'Your earning/ride');
  String get commission50 => _t('Commission (50%)', 'Commission (50%)');
  String get rideHistory => _t('Historique des courses', 'Ride history');
  String get noCompletedRides => _t('Aucune course terminée', 'No completed rides');

  // ─── Verification ───
  String get awaitingVerification => _t('En attente de vérification', 'Awaiting verification');
  String get verificationMessage => _t('Votre profil est en cours de vérification. Vous serez redirigé automatiquement une fois approuvé par notre équipe.', 'Your profile is being verified. You will be redirected automatically once approved.');
  String get verificationLogoutHint => _t('Vous pouvez également vous déconnecter et attendre la vérification. Vous serez redirigé automatiquement à votre prochaine connexion.', 'You can also log out and wait for verification. You will be redirected automatically on your next login.');
  String get understood => _t('Compris', 'Understood');
  String get profileApproved => _t('Votre profil a été approuvé ! Bienvenue.', 'Your profile has been approved! Welcome.');

  // ─── Settings ───
  String get newRideRequests => _t('Nouvelles demandes de course', 'New ride requests');
  String get pushNotifications => _t('Recevoir les notifications push', 'Receive push notifications');

  // ─── Privacy ───
  String get privacyPolicyLink => _t('Politique de confidentialité', 'Privacy policy');

  // ─── Documents ───
  String get documents => _t('Documents', 'Documents');
  String get uploadPhoto => _t('Prendre une photo', 'Take a photo');
  String get uploadGallery => _t('Choisir de la galerie', 'Choose from gallery');
  String get submitDocument => _t('Soumettre', 'Submit');
  String get notSubmitted => _t('Non soumis', 'Not submitted');
  String get awaitingVerification => _t('En attente de vérification', 'Awaiting verification');
  String get verified => _t('Vérifié', 'Verified');
  String get accountStatus => _t('Statut du compte', 'Account status');
  String get missingDocuments => _t('Documents manquants', 'Missing documents');
  String get verificationInProgress => _t('En cours de vérification', 'Verification in progress');
  String get submitAllDocs => _t('Veuillez soumettre tous les documents requis', 'Please submit all required documents');

  // ─── Privacy Policy ───
  String get privacyPolicyTitle => _t('Politique de confidentialité', 'Privacy Policy');
  String get lastUpdated => _t('Dernière mise à jour : Janvier 2025', 'Last updated: January 2025');

  // ─── Offline ───
  String get noConnection => _t('Pas de connexion internet', 'No internet connection');
  String get checkConnection => _t('Vérifiez votre connexion et réessayez', 'Check your connection and try again');

  // ─── Errors ───
  String get errorGeneric => _t('Une erreur est survenue', 'An error occurred');
  String get errorNetwork => _t('Erreur réseau', 'Network error');
  String get errorAuth => _t('Erreur d\'authentification', 'Authentication error');
  String get errorLocation => _t('Impossible d\'obtenir votre position', 'Unable to get your location');
  String get errorLocationPermission => _t('Autorisation de localisation refusée', 'Location permission denied');
  String get errorPhoneRequired => _t('Numéro de téléphone requis', 'Phone number required');
  String get errorNameRequired => _t('Nom requis', 'Name required');
  String get errorInvalidPhone => _t('Numéro invalide', 'Invalid phone number');

  // ─── Payment Methods ───
  String get payCash => _t('Payer en espèces', 'Pay with cash');
  String get payWaafi => _t('Payer avec Waafi', 'Pay with Waafi');
  String get payDMoney => _t('Payer avec D-Money', 'Pay with D-Money');
  String get payCacPay => _t('Payer avec CAC Pay', 'Pay with CAC Pay');
  String get paySabaPay => _t('Payer avec Saba Pay', 'Pay with Saba Pay');
  String get payDahabplus => _t('Payer avec Dahabplus', 'Pay with Dahabplus');

  String _t(String fr, String en) {
    return locale.languageCode == 'fr' ? fr : en;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
