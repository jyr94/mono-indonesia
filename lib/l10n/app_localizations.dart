import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('id'));
  }

  static const _strings = {
    'id': {
      'appName': 'Monopoli Indonesia',
      'play': 'Main',
      'playLocal': 'Main lokal (2 pemain)',
      'quickMatch': 'Cepat Match',
      'joinRoom': 'Gabung Room',
      'joinRoomDesc': 'Gabung dengan kode room',
      'createRoom': 'Buat Room',
      'createRoomDesc': 'Buat room online',
      'startGame': 'Mulai',
      'rollDice': 'Lempar Dadu',
      'buy': 'Beli',
      'buildHouse': 'Bangun',
      'auction': 'Lelang',
      'endTurn': 'Akhiri Giliran',
      'pass': 'Lewati',
      'roomCode': 'Kode Room',
      'invite': 'Undang',
      'chat': 'Obrolan',
      'settings': 'Pengaturan',
      'playerName': 'Nama Pemain',
      'enterRoomCode': 'Masukkan Kode Room',
      'join': 'Gabung',
      'waitingForPlayers': 'Menunggu pemain...',
      'waitingForHost': 'Menunggu host memulai permainan...',
      'backToMenu': 'Kembali ke Menu',
      'lobby': 'Lobi',
      'copyCode': 'Salin Kode',
      'codeCopied': 'Kode room disalin!',
      'needTwoPlayers': 'Minimal 2 pemain untuk memulai',
      'winner': 'Pemenang!',
      'gameInfo': 'Info Permainan',
      'online': 'Online',
      'money': 'Uang',
      'properties': 'Properti',
      'utilities': 'Utilitas',
      'host': 'Host',
      'you': 'Kamu',
      'roomNotFound': 'Room tidak ditemukan atau sudah penuh',
      'roomDeleted': 'Room telah dihapus',
      'createRoomFailed': 'Gagal membuat room',
      'joinFailed': 'Gagal bergabung',
      'enterName': 'Masukkan nama terlebih dahulu',
      'tooFast': 'Terlalu cepat! Tunggu sebentar.',
      'timeUp': 'Waktu habis! Giliran dilewati.',
      'enterNameOrCode': 'Masukkan kode 6 karakter',
      'waitingTurn': 'Menunggu giliran pemain lain...',
      'yourTurn': 'Giliran Anda!',
      'rollPrompt': 'Lempar dadu!',
      'chooseAction': 'Pilih aksi',
      'buyProperty': 'Beli properti?',
      'auctionInProgress': 'Lelang sedang berlangsung...',
      'buildPhase': 'Bangun rumah',
      'turnEnded': 'Giliran berakhir',
      'login': 'Masuk',
      'guest': 'Tamu',
      'signInGoogle': 'Masuk dengan Google',
      'signOut': 'Keluar',
      'profile': 'Profil',
      'gamesPlayed': 'Permainan dimainkan',
      'gamesWon': 'Permainan menang',
      'sound': 'Suara',
      'bgm': 'Musik Latar',
      'sfx': 'Efek Suara',
    },
    'en': {
      'appName': 'Monopoly Indonesia',
      'play': 'Play',
      'playLocal': 'Local play (2 players)',
      'quickMatch': 'Quick Match',
      'joinRoom': 'Join Room',
      'joinRoomDesc': 'Join with room code',
      'createRoom': 'Create Room',
      'createRoomDesc': 'Create online room',
      'startGame': 'Start',
      'rollDice': 'Roll Dice',
      'buy': 'Buy',
      'buildHouse': 'Build',
      'auction': 'Auction',
      'endTurn': 'End Turn',
      'pass': 'Pass',
      'roomCode': 'Room Code',
      'invite': 'Invite',
      'chat': 'Chat',
      'settings': 'Settings',
      'playerName': 'Player Name',
      'enterRoomCode': 'Enter Room Code',
      'join': 'Join',
      'waitingForPlayers': 'Waiting for players...',
      'waitingForHost': 'Waiting for host to start...',
      'backToMenu': 'Back to Menu',
      'lobby': 'Lobby',
      'copyCode': 'Copy Code',
      'codeCopied': 'Room code copied!',
      'needTwoPlayers': 'Need at least 2 players',
      'winner': 'Winner!',
      'gameInfo': 'Game Info',
      'online': 'Online',
      'money': 'Money',
      'properties': 'Properties',
      'utilities': 'Utilities',
      'host': 'Host',
      'you': 'You',
      'roomNotFound': 'Room not found or full',
      'roomDeleted': 'Room has been deleted',
      'createRoomFailed': 'Failed to create room',
      'joinFailed': 'Failed to join',
      'enterName': 'Enter your name first',
      'tooFast': 'Too fast! Wait a moment.',
      'timeUp': 'Time is up! Turn skipped.',
      'enterNameOrCode': 'Enter 6-character code',
      'waitingTurn': 'Waiting for other players...',
      'yourTurn': 'Your turn!',
      'rollPrompt': 'Roll the dice!',
      'chooseAction': 'Choose action',
      'buyProperty': 'Buy property?',
      'auctionInProgress': 'Auction in progress...',
      'buildPhase': 'Build houses',
      'turnEnded': 'Turn ended',
      'login': 'Login',
      'guest': 'Guest',
      'signInGoogle': 'Sign in with Google',
      'signOut': 'Sign Out',
      'profile': 'Profile',
      'gamesPlayed': 'Games Played',
      'gamesWon': 'Games Won',
      'sound': 'Sound',
      'bgm': 'Background Music',
      'sfx': 'Sound Effects',
    },
  };

  String _t(String key) {
    return _strings[locale.languageCode]?[key] ??
        _strings['id']?[key] ??
        key;
  }

  String get appName => _t('appName');
  String get play => _t('play');
  String get playLocal => _t('playLocal');
  String get joinRoom => _t('joinRoom');
  String get joinRoomDesc => _t('joinRoomDesc');
  String get createRoom => _t('createRoom');
  String get createRoomDesc => _t('createRoomDesc');
  String get startGame => _t('startGame');
  String get rollDice => _t('rollDice');
  String get buy => _t('buy');
  String get buildHouse => _t('buildHouse');
  String get auction => _t('auction');
  String get endTurn => _t('endTurn');
  String get pass => _t('pass');
  String get roomCode => _t('roomCode');
  String get chat => _t('chat');
  String get playerName => _t('playerName');
  String get enterRoomCode => _t('enterRoomCode');
  String get join => _t('join');
  String get waitingForPlayers => _t('waitingForPlayers');
  String get waitingForHost => _t('waitingForHost');
  String get backToMenu => _t('backToMenu');
  String get lobby => _t('lobby');
  String get copyCode => _t('copyCode');
  String get codeCopied => _t('codeCopied');
  String get needTwoPlayers => _t('needTwoPlayers');
  String get winner => _t('winner');
  String get gameInfo => _t('gameInfo');
  String get host => _t('host');
  String get you => _t('you');
  String get roomNotFound => _t('roomNotFound');
  String get enterName => _t('enterName');
  String get tooFast => _t('tooFast');
  String get timeUp => _t('timeUp');
  String get waitingTurn => _t('waitingTurn');
  String get backToMenuAction => _t('backToMenu');
  String get login => _t('login');
  String get guest => _t('guest');
  String get signInGoogle => _t('signInGoogle');
  String get signOut => _t('signOut');
  String get profile => _t('profile');
  String get sound => _t('sound');
  String get bgm => _t('bgm');
  String get sfx => _t('sfx');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
