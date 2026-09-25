import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'HK'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Media Format Converter'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'The interface updates immediately.'**
  String get languageHint;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageSystem;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A desktop media converter that wraps local FFmpeg.'**
  String get aboutDescription;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ffmpegDocs.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg docs'**
  String get ffmpegDocs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @fileMenu.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileMenu;

  /// No description provided for @aboutMenu.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutMenu;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open files'**
  String get openFile;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @aboutThisApp.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get aboutThisApp;

  /// No description provided for @addConversionTask.
  ///
  /// In en, this message translates to:
  /// **'Add conversion task'**
  String get addConversionTask;

  /// No description provided for @editConversionTask.
  ///
  /// In en, this message translates to:
  /// **'Edit conversion task'**
  String get editConversionTask;

  /// No description provided for @subtitles.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// No description provided for @startAll.
  ///
  /// In en, this message translates to:
  /// **'Start all'**
  String get startAll;

  /// No description provided for @stopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop all'**
  String get stopAll;

  /// No description provided for @clearFinished.
  ///
  /// In en, this message translates to:
  /// **'Clear finished'**
  String get clearFinished;

  /// No description provided for @ffmpegNotDetected.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg was not found. Set its path in Settings first.'**
  String get ffmpegNotDetected;

  /// No description provided for @noMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'No supported media files'**
  String get noMediaFiles;

  /// No description provided for @dropMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Drop audio or video files.'**
  String get dropMediaFiles;

  /// No description provided for @ffmpegReadyStatus.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg ready  ·  {label}'**
  String ffmpegReadyStatus(String label);

  /// No description provided for @notReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get notReady;

  /// No description provided for @queueCount.
  ///
  /// In en, this message translates to:
  /// **'Queue {count}'**
  String queueCount(int count);

  /// No description provided for @runningCount.
  ///
  /// In en, this message translates to:
  /// **'Running {running}/{concurrency}'**
  String runningCount(int running, int concurrency);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'Failed {count}'**
  String failedCount(int count);

  /// No description provided for @convertToVideo.
  ///
  /// In en, this message translates to:
  /// **'Convert to video'**
  String get convertToVideo;

  /// No description provided for @convertToAudio.
  ///
  /// In en, this message translates to:
  /// **'Convert to audio'**
  String get convertToAudio;

  /// No description provided for @convertToFormat.
  ///
  /// In en, this message translates to:
  /// **'Convert to {format}'**
  String convertToFormat(String format);

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'The conversion queue is empty'**
  String get queueEmpty;

  /// No description provided for @queueEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Open files, drop media, or pick a format on the left to add a task.'**
  String get queueEmptyHint;

  /// No description provided for @sourcePath.
  ///
  /// In en, this message translates to:
  /// **'Source: {path}'**
  String sourcePath(String path);

  /// No description provided for @destinationPath.
  ///
  /// In en, this message translates to:
  /// **'Destination: {path}'**
  String destinationPath(String path);

  /// No description provided for @clipRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Clip {start} → {end}'**
  String clipRangeLabel(String start, String end);

  /// No description provided for @subtitleKeepAdd.
  ///
  /// In en, this message translates to:
  /// **'Subtitles: keep {kept} tracks, add {added}'**
  String subtitleKeepAdd(int kept, int added);

  /// No description provided for @openInputFolder.
  ///
  /// In en, this message translates to:
  /// **'Open input folder'**
  String get openInputFolder;

  /// No description provided for @openOutputFolder.
  ///
  /// In en, this message translates to:
  /// **'Open output folder'**
  String get openOutputFolder;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @clip.
  ///
  /// In en, this message translates to:
  /// **'Clip'**
  String get clip;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed {time}'**
  String elapsed(String time);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'ETA {time}'**
  String remaining(String time);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get statusPending;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusRunning.
  ///
  /// In en, this message translates to:
  /// **'Converting'**
  String get statusRunning;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @ffmpegPath.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg path'**
  String get ffmpegPath;

  /// No description provided for @ffmpegPathHintWindows.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to search the app folder first, then PATH and Program Files. Relative paths are resolved from the app folder and stored as entered.'**
  String get ffmpegPathHintWindows;

  /// No description provided for @ffmpegPathHintMacos.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to search the app folder first, then PATH, Homebrew, and /usr/local/bin. Relative paths are resolved from the app folder and stored as entered.'**
  String get ffmpegPathHintMacos;

  /// No description provided for @ffmpegPathHintLinux.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to search the app folder first, then PATH, /usr/bin, and ~/.local/bin. Relative paths are resolved from the app folder and stored as entered.'**
  String get ffmpegPathHintLinux;

  /// No description provided for @useThisPath.
  ///
  /// In en, this message translates to:
  /// **'Use this path'**
  String get useThisPath;

  /// No description provided for @redetect.
  ///
  /// In en, this message translates to:
  /// **'Detect again'**
  String get redetect;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @taskReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get taskReady;

  /// No description provided for @ffmpegNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg not found'**
  String get ffmpegNotFoundTitle;

  /// No description provided for @ffmpegMissingHintWindows.
  ///
  /// In en, this message translates to:
  /// **'Specify or detect a working ffmpeg.exe before converting.'**
  String get ffmpegMissingHintWindows;

  /// No description provided for @ffmpegMissingHintOther.
  ///
  /// In en, this message translates to:
  /// **'Specify or detect a working ffmpeg before converting.'**
  String get ffmpegMissingHintOther;

  /// No description provided for @hardwareAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Hardware acceleration'**
  String get hardwareAcceleration;

  /// No description provided for @hardwareAccelerationHint.
  ///
  /// In en, this message translates to:
  /// **'When enabled, new conversion tasks use hardware acceleration by default. Existing tasks are unchanged.'**
  String get hardwareAccelerationHint;

  /// No description provided for @hardwareDefaultOn.
  ///
  /// In en, this message translates to:
  /// **'On by default for new tasks'**
  String get hardwareDefaultOn;

  /// No description provided for @hardwareAfterGpu.
  ///
  /// In en, this message translates to:
  /// **'Applies to new tasks after a GPU is detected'**
  String get hardwareAfterGpu;

  /// No description provided for @concurrency.
  ///
  /// In en, this message translates to:
  /// **'Task concurrency'**
  String get concurrency;

  /// No description provided for @concurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'How many ffmpeg processes can run at once. Higher values convert faster but use more CPU and disk.'**
  String get concurrencyHint;

  /// No description provided for @renameOnConflict.
  ///
  /// In en, this message translates to:
  /// **'Auto-rename on conflict'**
  String get renameOnConflict;

  /// No description provided for @renameHint.
  ///
  /// In en, this message translates to:
  /// **'Append a number when the output file already exists. {token} is the number; {padded} becomes 01.'**
  String renameHint(String token, String padded);

  /// No description provided for @renamePresetFile.
  ///
  /// In en, this message translates to:
  /// **'file{example}'**
  String renamePresetFile(String example);

  /// No description provided for @useThisRule.
  ///
  /// In en, this message translates to:
  /// **'Use this rule'**
  String get useThisRule;

  /// No description provided for @renameExample.
  ///
  /// In en, this message translates to:
  /// **'Example: video{example}'**
  String renameExample(String example);

  /// No description provided for @pickMediaFiles.
  ///
  /// In en, this message translates to:
  /// **'Select media files'**
  String get pickMediaFiles;

  /// No description provided for @pickSubtitleFiles.
  ///
  /// In en, this message translates to:
  /// **'Select external subtitles'**
  String get pickSubtitleFiles;

  /// No description provided for @pickOutputDirectory.
  ///
  /// In en, this message translates to:
  /// **'Select output folder'**
  String get pickOutputDirectory;

  /// No description provided for @pickFfmpegExe.
  ///
  /// In en, this message translates to:
  /// **'Select ffmpeg.exe'**
  String get pickFfmpegExe;

  /// No description provided for @pickFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'Select ffmpeg'**
  String get pickFfmpeg;

  /// No description provided for @clipTitle.
  ///
  /// In en, this message translates to:
  /// **'Clip  ·  {name}'**
  String clipTitle(String name);

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @minusOneFrame.
  ///
  /// In en, this message translates to:
  /// **'-1 frame'**
  String get minusOneFrame;

  /// No description provided for @plusOneFrame.
  ///
  /// In en, this message translates to:
  /// **'+1 frame'**
  String get plusOneFrame;

  /// No description provided for @currentPosition.
  ///
  /// In en, this message translates to:
  /// **'Position {time}'**
  String currentPosition(String time);

  /// No description provided for @loadingPreview.
  ///
  /// In en, this message translates to:
  /// **'Loading preview…'**
  String get loadingPreview;

  /// No description provided for @clipPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video preview is temporarily unavailable.'**
  String get clipPreviewUnavailable;

  /// No description provided for @inPoint.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inPoint;

  /// No description provided for @outPoint.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outPoint;

  /// No description provided for @timecodeAndFrame.
  ///
  /// In en, this message translates to:
  /// **'{time}  ·  Frame {frame}'**
  String timecodeAndFrame(String time, int frame);

  /// No description provided for @useCurrentFrame.
  ///
  /// In en, this message translates to:
  /// **'Use current frame'**
  String get useCurrentFrame;

  /// No description provided for @clearClip.
  ///
  /// In en, this message translates to:
  /// **'Clear clip'**
  String get clearClip;

  /// No description provided for @applyClip.
  ///
  /// In en, this message translates to:
  /// **'Apply clip'**
  String get applyClip;

  /// No description provided for @clearSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Clear subtitle changes'**
  String get clearSubtitles;

  /// No description provided for @applySubtitles.
  ///
  /// In en, this message translates to:
  /// **'Apply subtitle changes'**
  String get applySubtitles;

  /// No description provided for @subtitleTaskLocked.
  ///
  /// In en, this message translates to:
  /// **'This task cannot be edited while it is running or already finished.'**
  String get subtitleTaskLocked;

  /// No description provided for @subtitleAudioUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Audio tasks do not support embedded subtitles.'**
  String get subtitleAudioUnsupported;

  /// No description provided for @subtitleFormatUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This output format does not support embedded subtitles.'**
  String get subtitleFormatUnsupported;

  /// No description provided for @cannotOpenPreview.
  ///
  /// In en, this message translates to:
  /// **'Cannot open preview: {error}'**
  String cannotOpenPreview(String error);

  /// No description provided for @selectFormat.
  ///
  /// In en, this message translates to:
  /// **'Target format'**
  String get selectFormat;

  /// No description provided for @selectFormatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Choose a target format'**
  String get selectFormatPlaceholder;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @inputFiles.
  ///
  /// In en, this message translates to:
  /// **'Input files'**
  String get inputFiles;

  /// No description provided for @inputFilePath.
  ///
  /// In en, this message translates to:
  /// **'Input file path'**
  String get inputFilePath;

  /// No description provided for @addFiles.
  ///
  /// In en, this message translates to:
  /// **'Add files'**
  String get addFiles;

  /// No description provided for @noFilesYet.
  ///
  /// In en, this message translates to:
  /// **'No files yet. Click Add, or drop them from the home screen.'**
  String get noFilesYet;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get reading;

  /// No description provided for @outputDirectory.
  ///
  /// In en, this message translates to:
  /// **'Output folder'**
  String get outputDirectory;

  /// No description provided for @outputFileName.
  ///
  /// In en, this message translates to:
  /// **'Output file name'**
  String get outputFileName;

  /// No description provided for @outputFileNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. {token}_converted'**
  String outputFileNameExample(String token);

  /// No description provided for @outputFileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Use {token} for the original file name. Conflicts still follow the rename setting.'**
  String outputFileNameHint(String token);

  /// No description provided for @outputNamePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Converted file names'**
  String get outputNamePreviewTitle;

  /// No description provided for @outputNamePreviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add files to preview converted names.'**
  String get outputNamePreviewEmpty;

  /// No description provided for @outputNamePreviewOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original name'**
  String get outputNamePreviewOriginal;

  /// No description provided for @outputNamePreviewConverted.
  ///
  /// In en, this message translates to:
  /// **'Converted name'**
  String get outputNamePreviewConverted;

  /// No description provided for @picture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get picture;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get output;

  /// No description provided for @noPictureProcessing.
  ///
  /// In en, this message translates to:
  /// **'This target does not reprocess the picture.'**
  String get noPictureProcessing;

  /// No description provided for @copyVideoKeepCopy.
  ///
  /// In en, this message translates to:
  /// **'Video stays stream-copied until you change picture or encoder options.'**
  String get copyVideoKeepCopy;

  /// No description provided for @copyVideoWillReencode.
  ///
  /// In en, this message translates to:
  /// **'Changing picture or video options re-encodes the video. Audio stays copied unless you change it.'**
  String get copyVideoWillReencode;

  /// No description provided for @copyVideoEncoderLocked.
  ///
  /// In en, this message translates to:
  /// **'Auto follows the source video codec; you can also pick another encoder.'**
  String get copyVideoEncoderLocked;

  /// No description provided for @copyVideoUnknownCodec.
  ///
  /// In en, this message translates to:
  /// **'Unknown source codec ({codec}). Scaling is unavailable until the codec is recognized.'**
  String copyVideoUnknownCodec(String codec);

  /// No description provided for @copyAudioKeepCopy.
  ///
  /// In en, this message translates to:
  /// **'Audio stays stream-copied until you change audio options.'**
  String get copyAudioKeepCopy;

  /// No description provided for @copyAudioWillReencode.
  ///
  /// In en, this message translates to:
  /// **'Changing audio options re-encodes audio. Video stays copied unless you change the picture.'**
  String get copyAudioWillReencode;

  /// No description provided for @copyAudioEncoderLocked.
  ///
  /// In en, this message translates to:
  /// **'The audio codec stays locked to the source codec.'**
  String get copyAudioEncoderLocked;

  /// No description provided for @copyAudioUnknownCodec.
  ///
  /// In en, this message translates to:
  /// **'Unknown source audio codec ({codec}). Audio processing is unavailable until the codec is recognized.'**
  String copyAudioUnknownCodec(String codec);

  /// No description provided for @resolutionPreset.
  ///
  /// In en, this message translates to:
  /// **'Resolution preset'**
  String get resolutionPreset;

  /// No description provided for @keepAspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Keep aspect ratio'**
  String get keepAspectRatio;

  /// No description provided for @scaleAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Scaling algorithm'**
  String get scaleAlgorithm;

  /// No description provided for @rotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get rotation;

  /// No description provided for @deinterlace.
  ///
  /// In en, this message translates to:
  /// **'Deinterlace'**
  String get deinterlace;

  /// No description provided for @flipHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Flip horizontally'**
  String get flipHorizontal;

  /// No description provided for @flipVertical.
  ///
  /// In en, this message translates to:
  /// **'Flip vertically'**
  String get flipVertical;

  /// No description provided for @noVideoReencode.
  ///
  /// In en, this message translates to:
  /// **'This target does not re-encode video.'**
  String get noVideoReencode;

  /// No description provided for @fixedEncoder.
  ///
  /// In en, this message translates to:
  /// **'This format uses a fixed encoder.'**
  String get fixedEncoder;

  /// No description provided for @defaultFps15.
  ///
  /// In en, this message translates to:
  /// **'Default 15'**
  String get defaultFps15;

  /// No description provided for @hardwareAccel.
  ///
  /// In en, this message translates to:
  /// **'Hardware acceleration'**
  String get hardwareAccel;

  /// No description provided for @hardwareAccelOnHint.
  ///
  /// In en, this message translates to:
  /// **'When on, the GPU is used automatically for decode, filters, and encode.'**
  String get hardwareAccelOnHint;

  /// No description provided for @noGpuEncoder.
  ///
  /// In en, this message translates to:
  /// **'No usable GPU encoder was detected.'**
  String get noGpuEncoder;

  /// No description provided for @encoder.
  ///
  /// In en, this message translates to:
  /// **'Encoder'**
  String get encoder;

  /// No description provided for @hardwarePicksEncoder.
  ///
  /// In en, this message translates to:
  /// **'The GPU encoder is chosen automatically while hardware acceleration is on.'**
  String get hardwarePicksEncoder;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @contentTune.
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get contentTune;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @pixelFormat.
  ///
  /// In en, this message translates to:
  /// **'Pixel format'**
  String get pixelFormat;

  /// No description provided for @encoder8bitOnly.
  ///
  /// In en, this message translates to:
  /// **'This encoder uses 8-bit only.'**
  String get encoder8bitOnly;

  /// No description provided for @rateControl.
  ///
  /// In en, this message translates to:
  /// **'Rate control'**
  String get rateControl;

  /// No description provided for @maxBitrateKbps.
  ///
  /// In en, this message translates to:
  /// **'Max bitrate kbps'**
  String get maxBitrateKbps;

  /// No description provided for @bufsizeKbps.
  ///
  /// In en, this message translates to:
  /// **'Buffer kbps'**
  String get bufsizeKbps;

  /// No description provided for @fpsMode.
  ///
  /// In en, this message translates to:
  /// **'Frame rate mode'**
  String get fpsMode;

  /// No description provided for @keyframeInterval.
  ///
  /// In en, this message translates to:
  /// **'Keyframe interval'**
  String get keyframeInterval;

  /// No description provided for @copyAudioNoProcess.
  ///
  /// In en, this message translates to:
  /// **'Copy mode does not reprocess audio.'**
  String get copyAudioNoProcess;

  /// No description provided for @audioControl.
  ///
  /// In en, this message translates to:
  /// **'Audio control'**
  String get audioControl;

  /// No description provided for @audioBitrateKbps.
  ///
  /// In en, this message translates to:
  /// **'Audio bitrate kbps'**
  String get audioBitrateKbps;

  /// No description provided for @optionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalHint;

  /// No description provided for @amrFixed.
  ///
  /// In en, this message translates to:
  /// **'AMR is fixed at 8000 Hz, mono, 12.2 kbps.'**
  String get amrFixed;

  /// No description provided for @mp3Quality.
  ///
  /// In en, this message translates to:
  /// **'MP3 quality 0-9'**
  String get mp3Quality;

  /// No description provided for @aacQuality.
  ///
  /// In en, this message translates to:
  /// **'AAC quality 1-5'**
  String get aacQuality;

  /// No description provided for @flacCompression.
  ///
  /// In en, this message translates to:
  /// **'FLAC compression 0-12'**
  String get flacCompression;

  /// No description provided for @opusRateMode.
  ///
  /// In en, this message translates to:
  /// **'Opus rate mode'**
  String get opusRateMode;

  /// No description provided for @opusApplicationField.
  ///
  /// In en, this message translates to:
  /// **'Opus application'**
  String get opusApplicationField;

  /// No description provided for @sampleRate.
  ///
  /// In en, this message translates to:
  /// **'Sample rate'**
  String get sampleRate;

  /// No description provided for @followSource.
  ///
  /// In en, this message translates to:
  /// **'Follow source'**
  String get followSource;

  /// No description provided for @sampleRateNote.
  ///
  /// In en, this message translates to:
  /// **'Unsupported sample rates are adjusted to the nearest value.'**
  String get sampleRateNote;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @mono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get mono;

  /// No description provided for @stereo.
  ///
  /// In en, this message translates to:
  /// **'Stereo'**
  String get stereo;

  /// No description provided for @volumeDb.
  ///
  /// In en, this message translates to:
  /// **'Volume (dB)'**
  String get volumeDb;

  /// No description provided for @loudnessSkipsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume is not applied while loudness normalization is on.'**
  String get loudnessSkipsVolume;

  /// No description provided for @loudnessNormalize.
  ///
  /// In en, this message translates to:
  /// **'Loudness normalization'**
  String get loudnessNormalize;

  /// No description provided for @fastStart.
  ///
  /// In en, this message translates to:
  /// **'Optimize for streaming (faststart)'**
  String get fastStart;

  /// No description provided for @keepMetadata.
  ///
  /// In en, this message translates to:
  /// **'Keep metadata'**
  String get keepMetadata;

  /// No description provided for @keepChapters.
  ///
  /// In en, this message translates to:
  /// **'Keep chapters'**
  String get keepChapters;

  /// No description provided for @metadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get metadataTitle;

  /// No description provided for @metadataArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get metadataArtist;

  /// No description provided for @metadataAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get metadataAlbum;

  /// No description provided for @metadataYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get metadataYear;

  /// No description provided for @metadataComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get metadataComment;

  /// No description provided for @qualityPreset.
  ///
  /// In en, this message translates to:
  /// **'Quality preset'**
  String get qualityPreset;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @videoBitrateKbps.
  ///
  /// In en, this message translates to:
  /// **'Video bitrate kbps'**
  String get videoBitrateKbps;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @frameRate.
  ///
  /// In en, this message translates to:
  /// **'Frame rate'**
  String get frameRate;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @detectingGpu.
  ///
  /// In en, this message translates to:
  /// **'Detecting GPU encoders…'**
  String get detectingGpu;

  /// No description provided for @noGpuDetected.
  ///
  /// In en, this message translates to:
  /// **'No usable GPU detected'**
  String get noGpuDetected;

  /// No description provided for @usingGpus.
  ///
  /// In en, this message translates to:
  /// **'Using {names}'**
  String usingGpus(String names);

  /// No description provided for @listSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get listSeparator;

  /// No description provided for @addToQueue.
  ///
  /// In en, this message translates to:
  /// **'Add to queue'**
  String get addToQueue;

  /// No description provided for @saveTask.
  ///
  /// In en, this message translates to:
  /// **'Save task'**
  String get saveTask;

  /// No description provided for @wizardStepFormat.
  ///
  /// In en, this message translates to:
  /// **'1. Choose format'**
  String get wizardStepFormat;

  /// No description provided for @wizardStepParams.
  ///
  /// In en, this message translates to:
  /// **'2. Files and options'**
  String get wizardStepParams;

  /// No description provided for @unknownResolution.
  ///
  /// In en, this message translates to:
  /// **'Unknown resolution'**
  String get unknownResolution;

  /// No description provided for @unknownDuration.
  ///
  /// In en, this message translates to:
  /// **'Unknown duration'**
  String get unknownDuration;

  /// No description provided for @formatCopyCodec.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get formatCopyCodec;

  /// No description provided for @formatDescCopyVideo.
  ///
  /// In en, this message translates to:
  /// **'Keep the source container. Defaults to the source codec, with full options; unchanged streams stay copied'**
  String get formatDescCopyVideo;

  /// No description provided for @formatDescCopyAudio.
  ///
  /// In en, this message translates to:
  /// **'Keep the source container. Defaults to the source codec, with full options; unchanged streams stay copied'**
  String get formatDescCopyAudio;

  /// No description provided for @formatDescMp4.
  ///
  /// In en, this message translates to:
  /// **'General-purpose video with the widest compatibility'**
  String get formatDescMp4;

  /// No description provided for @formatDescMkv.
  ///
  /// In en, this message translates to:
  /// **'Open container for high-quality muxing'**
  String get formatDescMkv;

  /// No description provided for @formatDescWebm.
  ///
  /// In en, this message translates to:
  /// **'Web video with smaller files'**
  String get formatDescWebm;

  /// No description provided for @formatDescMov.
  ///
  /// In en, this message translates to:
  /// **'Common in the Apple ecosystem'**
  String get formatDescMov;

  /// No description provided for @formatDescAvi.
  ///
  /// In en, this message translates to:
  /// **'Legacy video container'**
  String get formatDescAvi;

  /// No description provided for @formatDescGif.
  ///
  /// In en, this message translates to:
  /// **'Animated image for short clips'**
  String get formatDescGif;

  /// No description provided for @formatDescWmv.
  ///
  /// In en, this message translates to:
  /// **'Windows Media video'**
  String get formatDescWmv;

  /// No description provided for @formatDescFlv.
  ///
  /// In en, this message translates to:
  /// **'Flash video container'**
  String get formatDescFlv;

  /// No description provided for @formatDescMpeg.
  ///
  /// In en, this message translates to:
  /// **'MPEG program stream'**
  String get formatDescMpeg;

  /// No description provided for @formatDescTs.
  ///
  /// In en, this message translates to:
  /// **'MPEG transport stream'**
  String get formatDescTs;

  /// No description provided for @formatDescM2ts.
  ///
  /// In en, this message translates to:
  /// **'Blu-ray transport stream'**
  String get formatDescM2ts;

  /// No description provided for @formatDesc3gp.
  ///
  /// In en, this message translates to:
  /// **'Common mobile video'**
  String get formatDesc3gp;

  /// No description provided for @formatDescOgv.
  ///
  /// In en, this message translates to:
  /// **'Open Theora video'**
  String get formatDescOgv;

  /// No description provided for @formatDescWebp.
  ///
  /// In en, this message translates to:
  /// **'Animated WebP image'**
  String get formatDescWebp;

  /// No description provided for @formatDescMp3.
  ///
  /// In en, this message translates to:
  /// **'General-purpose lossy audio'**
  String get formatDescMp3;

  /// No description provided for @formatDescAac.
  ///
  /// In en, this message translates to:
  /// **'Efficient lossy audio'**
  String get formatDescAac;

  /// No description provided for @formatDescM4a.
  ///
  /// In en, this message translates to:
  /// **'AAC audio container'**
  String get formatDescM4a;

  /// No description provided for @formatDescWav.
  ///
  /// In en, this message translates to:
  /// **'Uncompressed PCM audio'**
  String get formatDescWav;

  /// No description provided for @formatDescFlac.
  ///
  /// In en, this message translates to:
  /// **'Lossless compressed audio'**
  String get formatDescFlac;

  /// No description provided for @formatDescOgg.
  ///
  /// In en, this message translates to:
  /// **'Open Vorbis audio'**
  String get formatDescOgg;

  /// No description provided for @formatDescOpus.
  ///
  /// In en, this message translates to:
  /// **'Low-latency efficient audio'**
  String get formatDescOpus;

  /// No description provided for @formatDescAc3.
  ///
  /// In en, this message translates to:
  /// **'Dolby Digital surround'**
  String get formatDescAc3;

  /// No description provided for @formatDescWma.
  ///
  /// In en, this message translates to:
  /// **'Windows Media audio'**
  String get formatDescWma;

  /// No description provided for @formatDescAiff.
  ///
  /// In en, this message translates to:
  /// **'Apple uncompressed PCM'**
  String get formatDescAiff;

  /// No description provided for @formatDescMp2.
  ///
  /// In en, this message translates to:
  /// **'MPEG Audio Layer 2'**
  String get formatDescMp2;

  /// No description provided for @formatDescWv.
  ///
  /// In en, this message translates to:
  /// **'WavPack lossless audio'**
  String get formatDescWv;

  /// No description provided for @formatDescTta.
  ///
  /// In en, this message translates to:
  /// **'True Audio lossless'**
  String get formatDescTta;

  /// No description provided for @formatDescSpx.
  ///
  /// In en, this message translates to:
  /// **'Speex speech codec'**
  String get formatDescSpx;

  /// No description provided for @formatDescAmr.
  ///
  /// In en, this message translates to:
  /// **'Narrowband speech audio'**
  String get formatDescAmr;

  /// No description provided for @formatDescAlac.
  ///
  /// In en, this message translates to:
  /// **'Apple lossless audio'**
  String get formatDescAlac;

  /// No description provided for @formatDescCaf.
  ///
  /// In en, this message translates to:
  /// **'Apple Core Audio'**
  String get formatDescCaf;

  /// No description provided for @presetOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get presetOriginal;

  /// No description provided for @preset1080p.
  ///
  /// In en, this message translates to:
  /// **'1080p'**
  String get preset1080p;

  /// No description provided for @preset720p.
  ///
  /// In en, this message translates to:
  /// **'720p'**
  String get preset720p;

  /// No description provided for @preset480p.
  ///
  /// In en, this message translates to:
  /// **'480p'**
  String get preset480p;

  /// No description provided for @qualitySmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller file'**
  String get qualitySmaller;

  /// No description provided for @qualityStandard.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get qualityStandard;

  /// No description provided for @qualityHigher.
  ///
  /// In en, this message translates to:
  /// **'Higher quality'**
  String get qualityHigher;

  /// No description provided for @encoderH264Software.
  ///
  /// In en, this message translates to:
  /// **'H.264 software'**
  String get encoderH264Software;

  /// No description provided for @encoderH265Software.
  ///
  /// In en, this message translates to:
  /// **'H.265 software'**
  String get encoderH265Software;

  /// No description provided for @encoderH264Nvidia.
  ///
  /// In en, this message translates to:
  /// **'H.264 NVIDIA'**
  String get encoderH264Nvidia;

  /// No description provided for @encoderH265Nvidia.
  ///
  /// In en, this message translates to:
  /// **'H.265 NVIDIA'**
  String get encoderH265Nvidia;

  /// No description provided for @encoderH264Amd.
  ///
  /// In en, this message translates to:
  /// **'H.264 AMD'**
  String get encoderH264Amd;

  /// No description provided for @encoderH265Amd.
  ///
  /// In en, this message translates to:
  /// **'H.265 AMD'**
  String get encoderH265Amd;

  /// No description provided for @encoderH264Intel.
  ///
  /// In en, this message translates to:
  /// **'H.264 Intel'**
  String get encoderH264Intel;

  /// No description provided for @encoderH265Intel.
  ///
  /// In en, this message translates to:
  /// **'H.265 Intel'**
  String get encoderH265Intel;

  /// No description provided for @encoderH264Vaapi.
  ///
  /// In en, this message translates to:
  /// **'H.264 VAAPI'**
  String get encoderH264Vaapi;

  /// No description provided for @encoderH265Vaapi.
  ///
  /// In en, this message translates to:
  /// **'H.265 VAAPI'**
  String get encoderH265Vaapi;

  /// No description provided for @encoderH264Videotoolbox.
  ///
  /// In en, this message translates to:
  /// **'H.264 VideoToolbox'**
  String get encoderH264Videotoolbox;

  /// No description provided for @encoderH265Videotoolbox.
  ///
  /// In en, this message translates to:
  /// **'H.265 VideoToolbox'**
  String get encoderH265Videotoolbox;

  /// No description provided for @encoderVp9.
  ///
  /// In en, this message translates to:
  /// **'VP9'**
  String get encoderVp9;

  /// No description provided for @encoderAv1.
  ///
  /// In en, this message translates to:
  /// **'AV1'**
  String get encoderAv1;

  /// No description provided for @rateQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get rateQuality;

  /// No description provided for @rateVbr.
  ///
  /// In en, this message translates to:
  /// **'Variable bitrate'**
  String get rateVbr;

  /// No description provided for @rateCbr.
  ///
  /// In en, this message translates to:
  /// **'Constant bitrate'**
  String get rateCbr;

  /// No description provided for @speedFastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get speedFastest;

  /// No description provided for @speedFaster.
  ///
  /// In en, this message translates to:
  /// **'Faster'**
  String get speedFaster;

  /// No description provided for @speedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// No description provided for @speedMedium.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get speedMedium;

  /// No description provided for @speedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// No description provided for @speedSlower.
  ///
  /// In en, this message translates to:
  /// **'Slower'**
  String get speedSlower;

  /// No description provided for @speedSlowest.
  ///
  /// In en, this message translates to:
  /// **'Slowest'**
  String get speedSlowest;

  /// No description provided for @tuneFilm.
  ///
  /// In en, this message translates to:
  /// **'Film'**
  String get tuneFilm;

  /// No description provided for @tuneAnimation.
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get tuneAnimation;

  /// No description provided for @tuneGrain.
  ///
  /// In en, this message translates to:
  /// **'Preserve grain'**
  String get tuneGrain;

  /// No description provided for @tuneStillImage.
  ///
  /// In en, this message translates to:
  /// **'Still image'**
  String get tuneStillImage;

  /// No description provided for @tuneFastDecode.
  ///
  /// In en, this message translates to:
  /// **'Easy to decode'**
  String get tuneFastDecode;

  /// No description provided for @tuneZeroLatency.
  ///
  /// In en, this message translates to:
  /// **'Low latency'**
  String get tuneZeroLatency;

  /// No description provided for @pixelYuv420p.
  ///
  /// In en, this message translates to:
  /// **'8-bit 4:2:0'**
  String get pixelYuv420p;

  /// No description provided for @pixelYuv420p10.
  ///
  /// In en, this message translates to:
  /// **'10-bit 4:2:0'**
  String get pixelYuv420p10;

  /// No description provided for @scaleBilinear.
  ///
  /// In en, this message translates to:
  /// **'Bilinear'**
  String get scaleBilinear;

  /// No description provided for @scaleBicubic.
  ///
  /// In en, this message translates to:
  /// **'Bicubic'**
  String get scaleBicubic;

  /// No description provided for @scaleLanczos.
  ///
  /// In en, this message translates to:
  /// **'Lanczos'**
  String get scaleLanczos;

  /// No description provided for @deinterlaceOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get deinterlaceOff;

  /// No description provided for @deinterlaceYadif.
  ///
  /// In en, this message translates to:
  /// **'Deinterlace'**
  String get deinterlaceYadif;

  /// No description provided for @deinterlaceYadifDouble.
  ///
  /// In en, this message translates to:
  /// **'Deinterlace and double rate'**
  String get deinterlaceYadifDouble;

  /// No description provided for @rotationNone.
  ///
  /// In en, this message translates to:
  /// **'No rotation'**
  String get rotationNone;

  /// No description provided for @rotationClockwise.
  ///
  /// In en, this message translates to:
  /// **'90° clockwise'**
  String get rotationClockwise;

  /// No description provided for @rotationHalf.
  ///
  /// In en, this message translates to:
  /// **'180°'**
  String get rotationHalf;

  /// No description provided for @rotationCounterClockwise.
  ///
  /// In en, this message translates to:
  /// **'90° counterclockwise'**
  String get rotationCounterClockwise;

  /// No description provided for @fpsCfr.
  ///
  /// In en, this message translates to:
  /// **'Constant frame rate'**
  String get fpsCfr;

  /// No description provided for @fpsVfr.
  ///
  /// In en, this message translates to:
  /// **'Variable frame rate'**
  String get fpsVfr;

  /// No description provided for @keyframeOneSecond.
  ///
  /// In en, this message translates to:
  /// **'1 second'**
  String get keyframeOneSecond;

  /// No description provided for @keyframeTwoSeconds.
  ///
  /// In en, this message translates to:
  /// **'2 seconds'**
  String get keyframeTwoSeconds;

  /// No description provided for @keyframeFiveSeconds.
  ///
  /// In en, this message translates to:
  /// **'5 seconds'**
  String get keyframeFiveSeconds;

  /// No description provided for @keyframeTenSeconds.
  ///
  /// In en, this message translates to:
  /// **'10 seconds'**
  String get keyframeTenSeconds;

  /// No description provided for @audioRateQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get audioRateQuality;

  /// No description provided for @audioRateBitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get audioRateBitrate;

  /// No description provided for @opusApplicationAudio.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get opusApplicationAudio;

  /// No description provided for @opusApplicationVoip.
  ///
  /// In en, this message translates to:
  /// **'Speech'**
  String get opusApplicationVoip;

  /// No description provided for @opusApplicationLowdelay.
  ///
  /// In en, this message translates to:
  /// **'Low latency'**
  String get opusApplicationLowdelay;

  /// No description provided for @opusVbrOn.
  ///
  /// In en, this message translates to:
  /// **'Variable bitrate'**
  String get opusVbrOn;

  /// No description provided for @opusVbrConstrained.
  ///
  /// In en, this message translates to:
  /// **'Constrained VBR'**
  String get opusVbrConstrained;

  /// No description provided for @opusVbrOff.
  ///
  /// In en, this message translates to:
  /// **'Constant bitrate'**
  String get opusVbrOff;

  /// No description provided for @subtitleNoVideo.
  ///
  /// In en, this message translates to:
  /// **'This file has no video stream, so subtitles cannot be edited.'**
  String get subtitleNoVideo;

  /// No description provided for @subtitleNeedOutput.
  ///
  /// In en, this message translates to:
  /// **'Enter an output folder and file name.'**
  String get subtitleNeedOutput;

  /// No description provided for @existingSubtitles.
  ///
  /// In en, this message translates to:
  /// **'Existing subtitles'**
  String get existingSubtitles;

  /// No description provided for @readingSubtitleTracks.
  ///
  /// In en, this message translates to:
  /// **'Reading subtitle tracks...'**
  String get readingSubtitleTracks;

  /// No description provided for @noEmbeddedSubtitles.
  ///
  /// In en, this message translates to:
  /// **'No embedded subtitles.'**
  String get noEmbeddedSubtitles;

  /// No description provided for @externalSubtitles.
  ///
  /// In en, this message translates to:
  /// **'External subtitles to add'**
  String get externalSubtitles;

  /// No description provided for @addExternalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add external subtitles'**
  String get addExternalSubtitle;

  /// No description provided for @subtitleLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'Language, e.g. chi'**
  String get subtitleLanguageHint;

  /// No description provided for @subtitleTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get subtitleTitleHint;

  /// No description provided for @subtitleOutputHint.
  ///
  /// In en, this message translates to:
  /// **'Uncheck a track to remove it. Subtitles are written into the current task output.'**
  String get subtitleOutputHint;

  /// No description provided for @container.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get container;

  /// No description provided for @webmSubtitleWarning.
  ///
  /// In en, this message translates to:
  /// **'WebM keeps WebVTT text subtitles only; styling is lost.'**
  String get webmSubtitleWarning;

  /// No description provided for @mp4AssWarning.
  ///
  /// In en, this message translates to:
  /// **'MP4/MOV cannot keep ASS styling. Saving as MKV is recommended.'**
  String get mp4AssWarning;

  /// No description provided for @mp4TextWarning.
  ///
  /// In en, this message translates to:
  /// **'MP4/MOV converts text subtitles to mov_text, so styling is lost.'**
  String get mp4TextWarning;

  /// No description provided for @trackIndex.
  ///
  /// In en, this message translates to:
  /// **'Track {index}'**
  String trackIndex(int index);

  /// No description provided for @subtitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get subtitleDefault;

  /// No description provided for @subtitleForced.
  ///
  /// In en, this message translates to:
  /// **'Forced'**
  String get subtitleForced;

  /// No description provided for @subtitleDeleteOnly.
  ///
  /// In en, this message translates to:
  /// **'Can only be removed'**
  String get subtitleDeleteOnly;

  /// No description provided for @errorFfmpegNotFound.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg was not found'**
  String get errorFfmpegNotFound;

  /// No description provided for @errorFfmpegNotFoundSpecify.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg was not found. Set its path in Settings.'**
  String get errorFfmpegNotFoundSpecify;

  /// No description provided for @errorFfmpegFoundFrom.
  ///
  /// In en, this message translates to:
  /// **'Found ffmpeg from {source}'**
  String errorFfmpegFoundFrom(String source);

  /// No description provided for @errorFfmpegInvalidPath.
  ///
  /// In en, this message translates to:
  /// **'That path is invalid and cannot run ffmpeg'**
  String get errorFfmpegInvalidPath;

  /// No description provided for @errorFfmpegUsingSpecified.
  ///
  /// In en, this message translates to:
  /// **'Using the specified ffmpeg'**
  String get errorFfmpegUsingSpecified;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get errorCancelled;

  /// No description provided for @errorConversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion failed'**
  String get errorConversionFailed;

  /// No description provided for @errorCannotStartFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'Cannot start ffmpeg: {error}'**
  String errorCannotStartFfmpeg(String error);

  /// No description provided for @errorFfmpegExitCode.
  ///
  /// In en, this message translates to:
  /// **'ffmpeg exit code {code}'**
  String errorFfmpegExitCode(int code);

  /// No description provided for @errorFfprobeNotFound.
  ///
  /// In en, this message translates to:
  /// **'ffprobe was not found'**
  String get errorFfprobeNotFound;

  /// No description provided for @errorCannotReadMedia.
  ///
  /// In en, this message translates to:
  /// **'Cannot read media info'**
  String get errorCannotReadMedia;

  /// No description provided for @errorEncoderInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Encoder initialization failed'**
  String get errorEncoderInitFailed;

  /// No description provided for @errorEncoderUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This system does not support {vendor} encoders'**
  String errorEncoderUnsupported(String vendor);

  /// No description provided for @errorEncoderNotCompiled.
  ///
  /// In en, this message translates to:
  /// **'This ffmpeg build does not include {vendor} encoders'**
  String errorEncoderNotCompiled(String vendor);

  /// No description provided for @errorEncoderCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check {vendor} encoders: {error}'**
  String errorEncoderCheckFailed(String vendor, String error);

  /// No description provided for @errorEncoderCanInit.
  ///
  /// In en, this message translates to:
  /// **'{vendor} encoder can initialize'**
  String errorEncoderCanInit(String vendor);

  /// No description provided for @errorUnsupportedSourceVideoCodec.
  ///
  /// In en, this message translates to:
  /// **'Cannot re-encode with the source video codec ({codec})'**
  String errorUnsupportedSourceVideoCodec(String codec);

  /// No description provided for @errorUnsupportedSourceAudioCodec.
  ///
  /// In en, this message translates to:
  /// **'Cannot re-encode with the source audio codec ({codec})'**
  String errorUnsupportedSourceAudioCodec(String codec);

  /// No description provided for @ffmpegSourceSettingsPath.
  ///
  /// In en, this message translates to:
  /// **'the path set in Settings'**
  String get ffmpegSourceSettingsPath;

  /// No description provided for @ffmpegSourceManual.
  ///
  /// In en, this message translates to:
  /// **'a manually chosen path'**
  String get ffmpegSourceManual;

  /// No description provided for @ffmpegSourceSystemPath.
  ///
  /// In en, this message translates to:
  /// **'system PATH'**
  String get ffmpegSourceSystemPath;

  /// No description provided for @ffmpegSourceAppDirFfmpeg.
  ///
  /// In en, this message translates to:
  /// **'app folder ffmpeg'**
  String get ffmpegSourceAppDirFfmpeg;

  /// No description provided for @ffmpegSourceAppDirFfmpegBin.
  ///
  /// In en, this message translates to:
  /// **'app folder ffmpeg/bin'**
  String get ffmpegSourceAppDirFfmpegBin;

  /// No description provided for @ffmpegSourceAppDirBin.
  ///
  /// In en, this message translates to:
  /// **'app folder bin'**
  String get ffmpegSourceAppDirBin;

  /// No description provided for @ffmpegSourceAppDir.
  ///
  /// In en, this message translates to:
  /// **'the app folder'**
  String get ffmpegSourceAppDir;

  /// No description provided for @crfFollowsQuality.
  ///
  /// In en, this message translates to:
  /// **'CRF (empty uses the quality preset)'**
  String get crfFollowsQuality;

  /// No description provided for @lockedMobileProfile.
  ///
  /// In en, this message translates to:
  /// **'FLV and 3GP always use Baseline / Level 3.0.'**
  String get lockedMobileProfile;

  /// No description provided for @channelCount.
  ///
  /// In en, this message translates to:
  /// **'{count} channels'**
  String channelCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'HK':
            return AppLocalizationsZhHk();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
