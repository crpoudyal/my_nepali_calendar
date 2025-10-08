import '../src.dart';

/// Utility class for handling month-related operations and data.
///
/// This class provides methods and data for:
/// * Formatting month names in Nepali or English.
/// * Accessing predefined month names in Nepali, English, and abbreviated English formats.
class MonthUtils {
  /// Returns the formatted month name for the given month number.
  ///
  /// - [month]: The month number (1 for January/Baisakh, 12 for December/Chaitra).
  /// - [language]: The language in which the month name should be returned.
  ///   If not provided, defaults to English.
  ///
  /// Throws an [ArgumentError] if the month number is outside the valid range (1-12).
  static String formattedMonth(int month, [Language? language]) {
    if (month < 1 || month > 12) {
      throw ArgumentError('Month must be between 1 and 12.');
    }

    // Determine if the language is English.
    final isEnglish = (language ?? Language.english) == Language.english;

    // Return the month name in the appropriate language.
    if (isEnglish) {
      return _nepaliENMonths[month - 1];
    } else {
      return _nepaliMonths[month - 1];
    }
  }

  /// List of Nepali month names in Nepali script.
  static final List<String> _nepaliMonths = [
    "बैशाख",
    "जेठ",
    "असार",
    "साउन",
    "भदौ",
    "असोज",
    "कार्तिक",
    "मंसिर",
    "पुष",
    "माघ",
    "फागुन",
    "चैत",
  ];

  /// List of Nepali month names in English script.
  static final List<String> _nepaliENMonths = [
    "Baisakh (Apr/May)",
    "Jestha (May/Jun)",
    "Asar (Jun/July)",
    "Shrawan (July/Aug)",
    "Bhadra (Aug/Sept)",
    "Ashoj (Sept/Oct)",
    "Kartik (Oct/Nov)",
    "Mangsir (Nov/Dec)",
    "Poush (Dec/Jan)",
    "Magh (Jan/Feb)",
    "Falgun (Feb/Mar)",
    "Chaitra (Mar/Apr)",
  ];

  /// List of full English month names.
  static final List<String> englishMonths = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  /// List of abbreviated English month names.
  static final List<String> englishMonthsShort = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
}
