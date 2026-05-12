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

  // ─── Additional keys for hardcoded French replacement ───
  String get driver => _t('Chauffeur', 'Driver');
  String get totalPrice => _t('Prix total', 'Total price');
  String get yourEarning => _t('Votre gain', 'Your earning');
  String get commission => _t('Commission', 'Commission');
  String get backToHome => _t('Retour à l\'accueil', 'Back to home');
  String get replace => _t('Remplacer', 'Replace');
  String get application => _t('Application', 'Application');
  String get appDescription => _t('Moto-taxi à Djibouti', 'Moto-taxi in Djibouti');
  String get allRightsReserved => _t('Tous droits réservés', 'All rights reserved');
  String get collectReminder => _t('N\'oubliez pas de collecter les', 'Don\'t forget to collect');
  String get fromClient => _t('du client.', 'from the client.');
  String get rideAcceptFailed => _t('Impossible d\'accepter cette course. Elle a peut-être été prise par un autre chauffeur.', 'Could not accept this ride. It may have been taken by another driver.');
  String get rideUpdateFailed => _t('Erreur lors de la mise à jour du statut.', 'Error updating ride status.');
  String get rideCompleteFailed => _t('Erreur lors de la finalisation de la course.', 'Error completing the ride.');
  String get notAuthenticated => _t('Non authentifié', 'Not authenticated');
  String get rideAlreadyAccepted => _t('Cette course a déjà été acceptée par un autre chauffeur.', 'This ride has already been accepted by another driver.');
  String get profileUpdated => _t('Profil mis à jour', 'Profile updated');
  String get ridesCount => _t('courses', 'rides');
  String get profileUpdateError => _t('Impossible de charger les lieux. Tirez vers le bas pour réessayer.', 'Unable to load places. Pull down to retry.');
  String get loginTitle => _t('Connexion', 'Login');
  String get email => _t('Email', 'Email');
  String get password => _t('Mot de passe', 'Password');
  String get loginButton => _t('Se connecter', 'Sign in');
  String get noAccount => _t('Pas de compte ?', 'No account?');
  String get createAccount => _t('Créer un compte', 'Create account');
  String get logoutTitle => _t('Déconnexion', 'Logout');
  String get logoutMessage => _t('Voulez-vous vraiment vous déconnecter ?', 'Do you really want to log out?');
  String get registerTitle => _t('Inscription', 'Register');
  String get alreadyHaveAccount => _t('Déjà un compte ?', 'Already have an account?');

  // ─── Ride Status Labels (for RideStatusBadge) ───
  String get statusPending => _t('En attente', 'Pending');
  String get statusSearching => _t('Recherche...', 'Searching...');
  String get statusAccepted => _t('Acceptée', 'Accepted');
  String get statusInProgress => _t('En cours', 'In progress');
  String get statusCompleted => _t('Terminée', 'Completed');
  String get statusCancelled => _t('Annulée', 'Cancelled');

  // ─── Payment Display Names ───
  String get paymentCash => _t('Espèces', 'Cash');
  String get paymentWaafi => _t('Waafi', 'Waafi');
  String get paymentDMoney => _t('DMoney', 'DMoney');
  String get paymentCacPay => _t('CacPay', 'CacPay');
  String get paymentSabaPay => _t('SabaPay', 'SabaPay');
  String get paymentDahabplus => _t('Dahab+', 'Dahab+');

  // ─── Verification status in documents screen ───
  String get verifiedLabel => _t('Vérifié', 'Verified');
  String get verificationInProgressLabel => _t('En cours de vérification', 'Verification in progress');
  String get missingDocumentsLabel => _t('Documents manquants', 'Missing documents');

  // ─── Position selected on map ───
  String get currentPosition => _t('Position actuelle', 'Current position');
  String get selectedPosition => _t('Position sélectionnée', 'Selected position');

  // ─── New keys for full localization ───
  String get fieldRequired => _t('Champ requis', 'Required');
  String get payment => _t('Paiement', 'Payment');
  String get phone => _t('Téléphone', 'Phone');
  String get address => _t('Adresse', 'Address');
  String get gender => _t('Sexe', 'Gender');
  String get male => _t('Homme', 'Male');
  String get female => _t('Femme', 'Female');
  String get country => _t('Pays', 'Country');
  String get fatherName => _t('Nom du père', 'Father\'s name');
  String get grandfatherName => _t('Nom du grand-père', 'Grandfather\'s name');
  String get whoAreYou => _t('Qui êtes-vous ?', 'Who are you?');
  String get yourName => _t('Votre Nom', 'Your name');
  String get yourNameHint => _t('Votre nom', 'Your name');
  String get security => _t('Sécurité', 'Security');
  String get confirmPassword => _t('Confirmer le mot de passe', 'Confirm password');
  String get repeatPasswordHint => _t('Répétez le mot de passe', 'Repeat password');
  String get distance => _t('Distance', 'Distance');
  String get estimatedDuration => _t('Durée estimée', 'Estimated duration');
  String get city => _t('Ville', 'City');
  String get contact => _t('Contact', 'Contact');
  String get website => _t('Site web', 'Website');
  String get getStarted => _t('Commencer', 'Get started');
  String get createMyAccount => _t('Créer mon compte', 'Create my account');
  String get becomeDriver => _t('Devenir Conducteur', 'Become a Driver');
  String get submitMyDossier => _t('Soumettre mon dossier', 'Submit my application');
  String get dossierSubmitted => _t('Dossier soumis !', 'Application submitted!');
  String get dossierVerificationPending => _t('Votre dossier est en cours de vérification.\nVous serez notifié dès validation.', 'Your application is being verified.\nYou will be notified once approved.');
  String get passenger => _t('Passager', 'Passenger');
  String get conductor => _t('Conducteur', 'Driver');
  String get orderRide => _t('Commandez une course', 'Order a ride');
  String get joinFleet => _t('Rejoignez la flotte Inggo', 'Join the Inggo fleet');
  String get joinFleet4Steps => _t('Rejoignez la flotte Inggo en 4 étapes.', 'Join the Inggo fleet in 4 steps.');
  String get forgotPassword => _t('Mot de passe oublié ?', 'Forgot password?');
  String get forgotPasswordTitle => _t('Mot de passe oublié', 'Forgot password');
  String get forgotPasswordMessage => _t('Entrez votre adresse email. Un lien de réinitialisation vous sera envoyé.', 'Enter your email address. A reset link will be sent.');
  String get resetEmailSent => _t('Email de réinitialisation envoyé !', 'Reset email sent!');
  String get send => _t('Envoyer', 'Send');
  String get noFavorites => _t('Aucun favori', 'No favorites');
  String get addFavoriteHint => _t('Appuyez sur + pour ajouter un lieu favori', 'Tap + to add a favorite place');
  String get favoriteDeleted => _t('Favori supprimé', 'Favorite deleted');
  String get favoriteAdded => _t('Favori ajouté', 'Favorite added');
  String get add => _t('Ajouter', 'Add');
  String get rideCompletedExclamation => _t('Course terminée !', 'Ride completed!');
  String get accountCreatedSuccess => _t('Votre compte Inggo a été créé avec succès.', 'Your Inggo account has been created successfully.');
  String get tooManyAttempts => _t('Trop de tentatives. Réessayez plus tard.', 'Too many attempts. Try again later.');
  String get fixErrorsFirst => _t('Corrigez les erreurs avant de continuer', 'Fix errors before continuing');
  String get loginSuccess => _t('Connexion réussie !', 'Login successful!');
  String get loginSubtitle => _t('Connectez-vous pour continuer', 'Sign in to continue');
  String get loginError => _t('Erreur de connexion', 'Login error');
  String get incorrectCredentials => _t('Identifiants incorrects', 'Incorrect credentials');
  String get invalidEmailOrPassword => _t('Email ou mot de passe incorrect', 'Invalid email or password');
  String get confirmEmailFirst => _t('Confirmez votre email avant de vous connecter', 'Confirm your email before signing in');
  String get emailHint => _t('votre.email@exemple.com', 'your.email@example.com');
  String get emailValid => _t('Adresse email valide', 'Valid email address');
  String get passwordHint => _t('Entrez votre mot de passe', 'Enter your password');
  String get passwordValid => _t('Mot de passe conforme', 'Password valid');
  String get otpAutoSend => _t('Un code sera envoyé automatiquement.', 'A code will be sent automatically.');
  String get otpSentTo => _t('Code envoyé au', 'Code sent to');
  String get otpSendError => _t('Erreur d\'envoi. Réessayez.', 'Send error. Try again.');
  String get phoneVerified => _t('Numéro vérifié !', 'Phone verified!');
  String get phoneVerifiedWith => _t('Numéro vérifié :', 'Phone verified:');
  String get otpIncorrect => _t('Code incorrect. Réessayez.', 'Incorrect code. Try again.');
  String get enterVerificationCode => _t('Entrez le code de vérification', 'Enter verification code');
  String get personalInfo => _t('Informations personnelles', 'Personal information');
  String get fullNameHint => _t('Votre nom complet', 'Your full name');
  String get atLeast6Chars => _t('Au moins 6 caractères', 'At least 6 characters');
  String selectGender => _t('Sélectionnez un genre', 'Select a gender');
  String get passwordsDiffer => _t('Les mots de passe sont différents', 'Passwords do not match');
  String get errorEmailRequired => _t('Email requis', 'Email required');
  String get errorEmailInvalidFormat => _t('Format email invalide', 'Invalid email format');
  String get errorPasswordRequired => _t('Mot de passe requis', 'Password required');
  String get errorPasswordMinLength => _t('Minimum 6 caractères', 'Minimum 6 characters');
  String get plateNumberRequired => _t('Numéro de plaque requis', 'Plate number required');
  String get allDocsRequired => _t('Tous les documents sont requis', 'All documents are required');
  String get acceptTerms => _t('Acceptez les conditions', 'Accept the terms');
  String get acceptAllTerms => _t('Acceptez toutes les conditions', 'Accept all terms');
  String get pleaseCorrectErrors => _t('Veuillez corriger les erreurs.', 'Please correct the errors.');
  String get verifyYourNumber => _t('Vérifiez votre numéro', 'Verify your number');
  String get verifyNumberToContinue => _t('Vérifiez votre numéro pour continuer', 'Verify your number to continue');
  String get enterAndVerifyNumber => _t('Saisissez et vérifiez votre numéro', 'Enter and verify your number');
  String get errorInvalidFormat => _t('Format invalide', 'Invalid format');
  String get documentAlreadyAdded => _t('Document déjà ajouté', 'Document already added');
  String get deleteAndRetry => _t('Supprimer et reprendre', 'Delete and retry');
  String get keep => _t('Conserver', 'Keep');
  String get accountCreationError => _t('Erreur création compte', 'Account creation error');
  String get motorcyclePhoto => _t('Photo de la moto', 'Motorcycle photo');
  String get yourMotorcycle => _t('Votre Moto', 'Your Motorcycle');
  String get vehicleInfoHint => _t('Renseignez les informations de votre véhicule et téléchargez vos documents.', 'Enter your vehicle information and upload your documents.');
  String get yourDocumentsCap => _t('Vos Documents', 'Your Documents');
  String get allDocsRequiredHint => _t('Tous les documents sont requis pour vérifier votre dossier.', 'All documents are required to verify your application.');
  String get documentAdded => _t('Document ajouté', 'Document added');
  String get tapToAdd => _t('Appuyez pour ajouter', 'Tap to add');
  String get conditions => _t('Conditions', 'Terms');
  String get iAcceptThe => _t('J\'accepte les ', 'I accept the ');
  String get termsOfUse => _t('Conditions Générales d\'Utilisation', 'Terms of Use');
  String get iAcceptTheFem => _t('J\'accepte la ', 'I accept the ');
  String get dossierUnderReview => _t('Votre dossier sera examiné par notre équipe. Vous serez notifié dès que votre compte sera activé.', 'Your application will be reviewed by our team. You will be notified once your account is activated.');
  String get appNameVtc => _t('Inggo VTC', 'Inggo VTC');
  String get aboutDescription => _t('Inggo est la première application de moto-taxi à Djibouti. Nous connectons les passagers avec des chauffeurs fiables et vérifiés pour des déplacements rapides, sûrs et abordables dans la ville de Djibouti. Notre mission est de rendre le transport urbain accessible à tous.', 'Inggo is the first moto-taxi app in Djibouti. We connect passengers with reliable and verified drivers for fast, safe and affordable rides in Djibouti city. Our mission is to make urban transport accessible to everyone.');
  String get destinationMapLabel => _t('Destination', 'Destination');
  String get yourDriverMapLabel => _t('Votre chauffeur', 'Your driver');
  String get cancelReasonClient => _t('Client a annulé', 'Client cancelled');
  String get unableToMakePhoneCall => _t('Impossible de lancer l\'appel téléphonique.', 'Unable to make phone call.');
  String get noMessagingApp => _t('Aucune application de messagerie disponible.', 'No messaging app available.');
  String get faqPriceQuestion => _t('Combien coûte une course ?', 'How much does a ride cost?');
  String get faqPriceAnswer => _t('Le prix est fixe : 250 FDJ par course, quel que soit le trajet dans Djibouti ville.', 'Fixed price: 250 FDJ per ride, regardless of the route within Djibouti city.');
  String get faqPaymentQuestion => _t('Comment payer ?', 'How to pay?');
  String get faqPaymentAnswer => _t('Pour le moment, seul le paiement en espèces est disponible. Les paiements mobiles arrivent bientôt.', 'For now, only cash payment is available. Mobile payments coming soon.');
  String get faqDriverQuestion => _t('Comment devenir chauffeur ?', 'How to become a driver?');
  String get faqDriverAnswer => _t('Inscrivez-vous en tant que chauffeur, soumettez vos documents et attendez la vérification.', 'Sign up as a driver, submit your documents and wait for verification.');
  String get faqCancelQuestion => _t('Puis-je annuler une course ?', 'Can I cancel a ride?');
  String get faqCancelAnswer => _t('Oui, vous pouvez annuler gratuitement dans les 2 premières minutes après la confirmation.', 'Yes, you can cancel for free within the first 2 minutes after confirmation.');
  String get favoriteLabelHint => _t('Ex: Maison, Travail...', 'E.g. Home, Work...');
  String get addressHint => _t('Ex: Quartier Haramous...', 'E.g. Haramous district...');
  String get chooseOnMap => _t('Choisir sur la carte', 'Choose on map');
  String get positionSelectedOnMap => _t('Position sélectionnée sur la carte', 'Position selected on map');
  String get markAllReadShort => _t('Tout lire', 'Mark all read');
  String get newRideRequestExclamation => _t('Nouvelle demande !', 'New request!');
  String get userFallback => _t('Utilisateur', 'User');
  String get joinCommunity3 => _t('Rejoignez la communauté Inggo en 3 étapes.', 'Join the Inggo community in 3 steps.');
  String get contactAndSecurity => _t('Coordonnées & Sécurité', 'Contact & Security');
  String get creatingBooking => _t('Création en cours...', 'Creating booking...');
  String get errorWithDetail => _t('Erreur', 'Error');
  String get categoryOther => _t('autre', 'other');
  String get destinationFallback => _t('Destination', 'Destination');
  String get confirmBookingPrice => _t('Confirmer la réservation', 'Confirm booking');
  String get iAcknowledgeRead => _t('Je reconnais avoir lu et accepté les ', 'I acknowledge having read and accepted the ');
  String get cgu => _t('CGU', 'Terms');
  String get andThe => _t(' et la ', ' and the ');
  String get ofInggo => _t(' d\'Inggo.', ' of Inggo.');
  String get errorNameRequired => _t('Le nom est requis', 'Name is required');

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
