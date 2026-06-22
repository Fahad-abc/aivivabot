class RomanUrduConverter {
  static final Map<String, String> _wordMap = {
    // Pronouns
    'main': 'میں',
    'tum': 'تم',
    'ap': 'آپ',
    'apne': 'اپنے',
    'hum': 'ہم',
    'wo': 'وہ',
    'ye': 'یہ',
    'yeh': 'یہ',
    'woh': 'وہ',

    // Common verbs
    'hai': 'ہے',
    'hain': 'ہیں',
    'tha': 'تھا',
    'thi': 'تھی',
    'they': 'تھے',
    'ho': 'ہو',
    'houn': 'ہوں',
    'karna': 'کرنا',
    'karta': 'کرتا',
    'karti': 'کرتی',
    'karein': 'کریں',
    'kiya': 'کیا',
    'kar': 'کر',
    'karo': 'کرو',

    // Question words
    'kya': 'کیا',
    'kyun': 'کیوں',
    'kaise': 'کیسے',
    'kahan': 'کہاں',
    'kab': 'کب',
    'kitna': 'کتنا',
    'konsa': 'کونسا',

    // Connectives
    'aur': 'اور',
    'ya': 'یا',
    'to': 'تو',
    'agar': 'اگر',
    'lekin': 'لیکن',
    'kyonke': 'کیونکے',
    'phir': 'پھر',
    'warna': 'ورنہ',

    // Prepositions
    'mein': 'میں',
    'par': 'پر',
    'se': 'سے',
    'ko': 'کو',
    'ne': 'نے',
    'ka': 'کا',
    'ki': 'کی',
    'ke': 'کے',

    // Tech terms
    'project': 'پروجیکٹ',
    'app': 'ایپ',
    'application': 'ایپلیکیشن',
    'database': 'ڈیٹابیس',
    'server': 'سرور',
    'api': 'اے پی آئی',
    'flutter': 'فلٹر',
    'firebase': 'فائر بیس',
    'blockchain': 'بلاک چین',
    'smart': 'سمارٹ',
    'contract': 'کانٹریکٹ',
    'security': 'سیکیورٹی',
    'authentication': 'تصدیق',

    // Other common words
    'iska': 'اس کا',
    'uska': 'اس کا',
    'mera': 'میرا',
    'tera': 'تیرا',
    'apna': 'اپنا',
    'koi': 'کوئی',
    'kuch': 'کچھ',
    'sab': 'سب',
    'bahut': 'بہت',
    'thoda': 'تھوڑا',
    'zyada': 'زیادہ',
    'pehle': 'پہلے',
    'baad': 'بعد',
    'andar': 'اندر',
    'bahar': 'باہر',
    'upar': 'اوپر',
    'neeche': 'نیچے',
    'bilkul': 'بالکل',
    'sahi': 'صحیح',
    'galat': 'غلط',
    'asaan': 'آسان',
    'mushkil': 'مشکل',
    'acha': 'اچھا',
    'bura': 'برا',
    'naya': 'نیا',
    'purana': 'پرانا',
  };

  static String convert(String romanText) {
    if (romanText.isEmpty) return '';

    List<String> words = romanText.split(' ');
    List<String> convertedWords = [];

    for (String word in words) {
      String lowerWord = word.toLowerCase();
      String punctuation = '';

      // Handle punctuation
      if (lowerWord.endsWith('.') || lowerWord.endsWith(',') ||
          lowerWord.endsWith('?') || lowerWord.endsWith('!')) {
        punctuation = lowerWord.substring(lowerWord.length - 1);
        lowerWord = lowerWord.substring(0, lowerWord.length - 1);
      }

      // Convert word
      String convertedWord = _wordMap[lowerWord] ?? word;
      convertedWords.add(convertedWord + punctuation);
    }

    return convertedWords.join(' ');
  }
}