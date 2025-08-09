import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SpellcheckWord {
  final String word;
  final int startIndex;
  final int endIndex;
  final List<String> suggestions;

  SpellcheckWord({
    required this.word,
    required this.startIndex,
    required this.endIndex,
    required this.suggestions,
  });
}

class SpellcheckResult {
  final List<SpellcheckWord> misspelledWords;
  final bool isComplete;
  final String? error;

  SpellcheckResult({
    required this.misspelledWords,
    this.isComplete = true,
    this.error,
  });
}

class SpellcheckService {
  static final SpellcheckService _instance = SpellcheckService._internal();
  factory SpellcheckService() => _instance;
  SpellcheckService._internal();

  final Set<String> _dictionary = {};
  bool _isInitialized = false;

  /// Initialize the spellcheck service with a basic English dictionary
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load a basic English word list
      await _loadBasicDictionary();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize spellcheck: $e');
    }
  }

  /// Load a comprehensive English dictionary
  Future<void> _loadBasicDictionary() async {
    // Load from a comprehensive word list API or use a much larger built-in list
    try {
      await _loadFromWordAPI();
    } catch (e) {
      // Fallback to a larger built-in dictionary
      await _loadBuiltInDictionary();
    }
  }

  /// Try to load words from a free dictionary API
  Future<void> _loadFromWordAPI() async {
    try {
      // Use a free word list API - this is a common English word list
      final response = await http.get(
        Uri.parse(
            'https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt'),
        headers: {'Accept': 'text/plain'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final allWords = response.body
            .split('\n')
            .map((word) => word.trim().toLowerCase())
            .where((word) => word.isNotEmpty && word.length > 1)
            .toSet();

        // Filter out some questionable words and very uncommon ones
        final filteredWords = allWords.where((word) {
          // Skip very long words (likely compound or technical terms)
          if (word.length > 15) return false;

          // Skip some known archaic/variant spellings that are commonly misspelled
          const problematicWords = {
            'chese',
            'teh',
            'hte',
            'adn',
            'nad',
            'taht',
            'thta',
            'waht',
            'hwat',
            'recieve',
            'recieved',
            'recieving',
            'seperate',
            'seperated',
            'seperating',
            'definately',
            'occured',
            'occuring',
            'begining',
            'comming',
            'runing',
            'stoped',
            'droped',
            'hoped',
            'planed',
            'prefered',
            'refered',
            'transfered'
          };

          if (problematicWords.contains(word)) return false;

          // Keep most words
          return true;
        }).toSet();

        _dictionary.addAll(filteredWords);
        print(
            'Loaded ${filteredWords.length} words from online dictionary (filtered from ${allWords.length})');
        return;
      }
    } catch (e) {
      print('Failed to load online dictionary: $e');
    }

    // If online loading fails, throw to use fallback
    throw Exception('Online dictionary loading failed');
  }

  /// Fallback to a larger built-in dictionary
  Future<void> _loadBuiltInDictionary() async {
    // Much more comprehensive word list - common English words
    const commonWords = [
      // Basic words
      'the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'i', 'it',
      'for',
      'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at', 'this', 'but', 'his',
      'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or', 'an', 'will', 'my',
      'one', 'all', 'would', 'there', 'their', 'what', 'so', 'up', 'out', 'if',
      'about', 'who', 'get', 'which', 'go', 'me', 'when', 'make', 'can', 'like',
      'time', 'no', 'just', 'him', 'know', 'take', 'people', 'into', 'year',
      'your', 'good', 'some', 'could', 'them', 'see', 'other', 'than', 'then',
      'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also', 'back',
      'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way',
      'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most',
      'us', 'is', 'was', 'are', 'been', 'has', 'had', 'were', 'said', 'each',
      'many', 'very', 'much', 'before', 'right', 'too', 'means', 'old', 'same',
      'tell', 'boy', 'follow', 'came', 'show', 'around', 'three', 'small',
      'set',
      'put', 'end', 'why', 'again', 'turn', 'here', 'off', 'went', 'number',
      'great', 'men', 'every', 'found', 'still', 'between', 'name', 'should',
      'home', 'big', 'air', 'line', 'own', 'under', 'read', 'last', 'never',
      'left', 'along', 'while', 'might', 'next', 'sound', 'below', 'saw',
      'something', 'thought', 'both', 'few', 'those', 'always', 'looked',
      'large', 'often', 'together', 'asked', 'house', 'world', 'going',
      'school', 'important', 'until', 'form', 'food', 'keep', 'children',
      'feet', 'land', 'side', 'without', 'once', 'animal', 'life', 'enough',
      'took', 'sometimes', 'four', 'head', 'above', 'kind', 'began', 'almost',
      'live', 'page', 'got', 'earth', 'need', 'far', 'hand', 'high', 'mother',
      'light', 'country', 'father', 'let', 'night', 'picture', 'being', 'study',
      'second', 'soon', 'story', 'since', 'white', 'ever', 'paper', 'hard',
      'near', 'sentence', 'better', 'best', 'across', 'during', 'today',
      'however', 'sure', 'knew', 'try', 'told', 'young', 'sun', 'thing',
      'whole', 'hear', 'example', 'heard', 'several', 'change', 'answer',
      'room', 'sea', 'against', 'top', 'turned', 'learn', 'point', 'city',
      'play', 'toward', 'five', 'himself', 'usually', 'money', 'seen', 'car',
      'morning', 'long', 'movement', 'yes', 'later', 'ground', 'friend',
      'place', 'become', 'problem', 'complete', 'brought', 'heat', 'nothing',
      'ago', 'stood', 'run', 'round', 'front', 'american', 'space', 'words',
      'question', 'piece', 'friends', 'easy', 'order', 'red', 'door', 'ship',
      'short', 'low', 'hours', 'black', 'products', 'happened', 'measure',
      'remember', 'early', 'waves', 'reached', 'listen', 'wind', 'rock',
      'covered', 'fast', 'hold', 'step', 'passed', 'vowel', 'true', 'hundred',
      'pattern', 'numeral', 'table', 'north', 'slowly', 'map', 'farm', 'pulled',
      'draw', 'voice', 'cold', 'cried', 'plan', 'notice', 'south', 'sing',
      'war', 'fall', 'king', 'town', 'unit', 'figure', 'certain', 'field',
      'travel', 'wood', 'fire', 'upon', 'done', 'english', 'road', 'halt',
      'ten', 'fly', 'gave', 'box', 'finally', 'wait', 'correct', 'quickly',
      'person', 'became', 'shown', 'minutes', 'strong', 'verb', 'stars', 'eat',
      'age', 'dead', 'women', 'used', 'find', 'elements', 'distance', 'heart',
      'sit', 'sum', 'summer', 'wall', 'forest', 'probably', 'legs', 'sat',
      'main', 'winter', 'wide', 'written', 'length', 'reason', 'kept',
      'interest', 'arms', 'brother', 'race', 'present', 'beautiful', 'store',
      'job', 'edge', 'past', 'sign', 'record', 'finished', 'discovered', 'wild',
      'happy', 'beside', 'gone', 'sky', 'grass', 'million', 'west', 'lay',
      'weather', 'root', 'instruments', 'meet', 'third', 'months', 'paragraph',
      'raised', 'represent', 'soft', 'whether', 'clothes', 'flowers', 'shall',
      'teacher', 'held', 'describe', 'drive', 'cross', 'speak', 'force', 'moon',

      // Additional common words
      'able', 'about', 'above', 'accept', 'according', 'account', 'across',
      'action', 'activity', 'actually', 'add', 'address', 'administration',
      'admit', 'adult', 'affect', 'after', 'again', 'against', 'agency',
      'agent', 'agree', 'agreement', 'ahead', 'allow', 'almost', 'alone',
      'along', 'already', 'although', 'always', 'among', 'amount', 'analysis',
      'analyze', 'animal', 'another', 'answer', 'anyone', 'anything', 'appear',
      'apply', 'approach', 'area', 'argue', 'around', 'arrive', 'article',
      'artist', 'assume', 'attack', 'attempt', 'attend', 'attention',
      'attorney',
      'audience', 'author', 'authority', 'available', 'avoid', 'away', 'baby',
      'back', 'bad', 'bag', 'ball', 'bank', 'bar', 'base', 'basic', 'battle',
      'beat', 'beautiful', 'because', 'become', 'bed', 'before', 'begin',
      'behavior', 'behind', 'believe', 'benefit', 'best', 'better', 'between',
      'beyond', 'big', 'bill', 'billion', 'bit', 'black', 'blood', 'blue',
      'board', 'body', 'book', 'born', 'both', 'box', 'boy', 'break', 'bring',
      'brother', 'budget', 'build', 'building', 'business', 'buy', 'call',
      'camera', 'campaign', 'can', 'cancer', 'candidate', 'capital', 'car',
      'card', 'care', 'career', 'carry', 'case', 'catch', 'cause', 'cell',
      'center', 'central', 'century', 'certain', 'certainly', 'chair',
      'challenge',
      'chance', 'change', 'character', 'charge', 'check', 'child', 'choice',
      'choose', 'church', 'citizen', 'city', 'civil', 'claim', 'class', 'clear',
      'clearly', 'close', 'coach', 'cold', 'collection', 'college', 'color',
      'come', 'commercial', 'common', 'community', 'company', 'compare',
      'computer', 'concern', 'condition', 'conference', 'congress', 'consider',
      'consumer', 'contain', 'continue', 'control', 'cost', 'could', 'country',
      'couple', 'course', 'court', 'cover', 'create', 'crime', 'cultural',
      'culture', 'cup', 'current', 'customer', 'cut', 'dark', 'data',
      'daughter',
      'dead', 'deal', 'death', 'debate', 'decade', 'decide', 'decision', 'deep',
      'defense', 'degree', 'democrat', 'democratic', 'describe', 'design',
      'despite', 'detail', 'determine', 'develop', 'development', 'die',
      'difference', 'different', 'difficult', 'dinner', 'direction', 'director',
      'discover', 'discuss', 'discussion', 'disease', 'doctor', 'dog', 'door',
      'down', 'draw', 'dream', 'drive', 'drop', 'drug', 'during', 'each',
      'early', 'east', 'easy', 'eat', 'economic', 'economy', 'edge',
      'education',
      'effect', 'effort', 'eight', 'either', 'election', 'else', 'employee',
      'end', 'energy', 'enjoy', 'enough', 'enter', 'entire', 'environment',
      'environmental', 'especially', 'establish', 'even', 'evening', 'event',
      'ever', 'every', 'everybody', 'everyone', 'everything', 'evidence',
      'exactly', 'example', 'executive', 'exist', 'expect', 'experience',
      'expert', 'explain', 'eye', 'face', 'fact', 'factor', 'fail', 'fall',
      'family', 'far', 'fast', 'father', 'fear', 'federal', 'feel', 'feeling',
      'few', 'field', 'fight', 'figure', 'fill', 'film', 'final', 'finally',
      'financial', 'find', 'fine', 'finger', 'finish', 'fire', 'firm', 'first',
      'fish', 'five', 'floor', 'fly', 'focus', 'follow', 'food', 'foot', 'for',
      'force', 'foreign', 'forget', 'form', 'former', 'forward', 'four', 'free',
      'friend', 'from', 'front', 'full', 'fund', 'future', 'game', 'garden',
      'gas', 'general', 'generation', 'get', 'girl', 'give', 'glass', 'goal',
      'good', 'government', 'great', 'green', 'ground', 'group', 'grow',
      'growth', 'guess', 'gun', 'guy', 'hair', 'half', 'hand', 'hang', 'happen',
      'happy', 'hard', 'have', 'head', 'health', 'hear', 'heart', 'heat',
      'heavy', 'help', 'her', 'here', 'herself', 'high', 'him', 'himself',
      'his', 'history', 'hit', 'hold', 'home', 'hope', 'hospital', 'hot',
      'hotel', 'hour', 'house', 'how', 'however', 'huge', 'human', 'hundred',
      'husband', 'idea', 'identify', 'image', 'imagine', 'impact', 'important',
      'improve', 'include', 'including', 'increase', 'indeed', 'indicate',
      'individual', 'industry', 'information', 'inside', 'instead',
      'institution',
      'interest', 'interesting', 'international', 'interview', 'into',
      'investment',
      'involve', 'issue', 'item', 'its', 'itself', 'job', 'join', 'just',
      'keep', 'key', 'kid', 'kill', 'kind', 'kitchen', 'know', 'knowledge',
      'land', 'language', 'large', 'last', 'late', 'later', 'laugh', 'law',
      'lawyer', 'lay', 'lead', 'leader', 'learn', 'least', 'leave', 'left',
      'leg', 'legal', 'less', 'let', 'letter', 'level', 'lie', 'life', 'light',
      'like', 'likely', 'line', 'list', 'listen', 'little', 'live', 'local',
      'long', 'look', 'lose', 'loss', 'lot', 'love', 'low', 'machine',
      'magazine',
      'main', 'maintain', 'major', 'make', 'man', 'manage', 'management',
      'manager', 'many', 'market', 'marriage', 'material', 'matter', 'may',
      'maybe', 'mean', 'measure', 'media', 'medical', 'meet', 'meeting',
      'member', 'memory', 'mention', 'message', 'method', 'middle', 'might',
      'military', 'million', 'mind', 'minute', 'miss', 'mission', 'model',
      'modern', 'moment', 'money', 'month', 'more', 'morning', 'most', 'mother',
      'mouth', 'move', 'movement', 'movie', 'much', 'music', 'must', 'myself',
      'name', 'nation', 'national', 'natural', 'nature', 'near', 'nearly',
      'necessary', 'need', 'network', 'never', 'new', 'news', 'newspaper',
      'next', 'nice', 'night', 'nine', 'none', 'nor', 'north', 'not', 'note',
      'nothing', 'notice', 'now', 'number', 'occur', 'off', 'offer', 'office',
      'officer', 'official', 'often', 'oil', 'old', 'once', 'one', 'only',
      'onto', 'open', 'operation', 'opportunity', 'option', 'order',
      'organization',
      'other', 'others', 'our', 'out', 'outside', 'over', 'own', 'owner',
      'page', 'pain', 'painting', 'paper', 'parent', 'part', 'participant',
      'particular', 'particularly', 'partner', 'party', 'pass', 'past',
      'patient', 'pattern', 'pay', 'peace', 'people', 'per', 'perform',
      'performance', 'perhaps', 'period', 'person', 'personal', 'phone',
      'physical', 'pick', 'picture', 'piece', 'place', 'plan', 'plant',
      'play', 'player', 'point', 'police', 'policy', 'political', 'politics',
      'poor', 'popular', 'population', 'position', 'positive', 'possible',
      'power', 'practice', 'prepare', 'present', 'president', 'pressure',
      'pretty', 'prevent', 'price', 'private', 'probably', 'problem', 'process',
      'produce', 'product', 'production', 'professional', 'program', 'project',
      'property', 'protect', 'prove', 'provide', 'public', 'pull', 'purpose',
      'push', 'put', 'quality', 'question', 'quickly', 'quite', 'race',
      'radio', 'raise', 'range', 'rate', 'rather', 'reach', 'read', 'ready',
      'real', 'reality', 'realize', 'really', 'reason', 'receive', 'recent',
      'recognize', 'record', 'red', 'reduce', 'reflect', 'region', 'relate',
      'relationship', 'religious', 'remain', 'remember', 'remove', 'report',
      'represent', 'republican', 'require', 'research', 'resource', 'respond',
      'response', 'responsibility', 'rest', 'result', 'return', 'reveal',
      'rich', 'right', 'rise', 'risk', 'road', 'rock', 'role', 'room', 'rule',
      'run', 'safe', 'same', 'save', 'say', 'scene', 'school', 'science',
      'scientist', 'score', 'sea', 'season', 'seat', 'second', 'section',
      'security', 'see', 'seek', 'seem', 'sell', 'send', 'senior', 'sense',
      'series', 'serious', 'serve', 'service', 'set', 'seven', 'several',
      'sex', 'sexual', 'shake', 'share', 'she', 'shoot', 'short', 'shot',
      'should', 'shoulder', 'show', 'side', 'sign', 'significant', 'similar',
      'simple', 'simply', 'since', 'sing', 'single', 'sister', 'sit', 'site',
      'situation', 'six', 'size', 'skill', 'skin', 'small', 'smile', 'social',
      'society', 'soldier', 'some', 'somebody', 'someone', 'something',
      'sometimes', 'son', 'song', 'soon', 'sort', 'sound', 'source', 'south',
      'southern', 'space', 'speak', 'special', 'specific', 'speech', 'spend',
      'sport', 'spring', 'staff', 'stage', 'stand', 'standard', 'star',
      'start', 'state', 'statement', 'station', 'stay', 'step', 'still',
      'stock', 'stop', 'store', 'story', 'strategy', 'street', 'strong',
      'structure', 'student', 'study', 'stuff', 'style', 'subject', 'success',
      'successful', 'such', 'suddenly', 'suffer', 'suggest', 'summer',
      'support',
      'sure', 'surface', 'system', 'table', 'take', 'talk', 'task', 'tax',
      'teach', 'teacher', 'team', 'technology', 'television', 'tell', 'ten',
      'tend', 'term', 'test', 'than', 'thank', 'that', 'their', 'them',
      'themselves', 'then', 'theory', 'there', 'these', 'they', 'thing',
      'think', 'third', 'this', 'those', 'though', 'thought', 'thousand',
      'threat', 'three', 'through', 'throughout', 'throw', 'thus', 'time',
      'today', 'together', 'tonight', 'too', 'top', 'total', 'tough', 'toward',
      'town', 'trade', 'traditional', 'training', 'travel', 'treat',
      'treatment',
      'tree', 'trial', 'trip', 'trouble', 'true', 'truth', 'try', 'turn',
      'two', 'type', 'under', 'understand', 'unit', 'until', 'upon', 'use',
      'used', 'user', 'usually', 'value', 'various', 'very', 'victim', 'view',
      'violence', 'visit', 'voice', 'vote', 'wait', 'walk', 'wall', 'want',
      'war', 'watch', 'water', 'way', 'weapon', 'wear', 'week', 'weight',
      'well', 'west', 'western', 'what', 'whatever', 'when', 'where', 'whether',
      'which', 'while', 'white', 'whole', 'whom', 'whose', 'why', 'wide',
      'wife', 'will', 'win', 'wind', 'window', 'wish', 'with', 'within',
      'without', 'woman', 'wonder', 'word', 'work', 'worker', 'world', 'worry',
      'would', 'write', 'writer', 'wrong', 'yard', 'yeah', 'year', 'yes',
      'yet', 'you', 'young', 'your', 'yourself'
    ];

    // Programming Languages (comprehensive list)
    const programmingLanguages = [
      // Popular languages
      'javascript', 'python', 'java', 'typescript', 'csharp', 'php', 'cpp', 'c',
      'ruby', 'go', 'rust', 'swift', 'kotlin', 'scala', 'dart', 'r', 'matlab',
      'perl', 'lua', 'bash', 'powershell', 'sql', 'html', 'css', 'xml', 'json',

      // Systems languages
      'assembly', 'fortran', 'cobol', 'ada', 'pascal', 'delphi', 'objective',
      'objectivec', 'verilog', 'vhdl', 'systemverilog',

      // Functional languages
      'haskell', 'lisp', 'scheme', 'clojure', 'erlang', 'elixir', 'fsharp',
      'ocaml', 'elm', 'purescript',

      // JVM languages
      'groovy', 'clojure', 'jython', 'jruby',

      // .NET languages
      'vbnet', 'visualbasic', 'fsharp',

      // Web languages
      'coffeescript', 'livescript', 'pug', 'jade', 'stylus', 'less', 'sass',
      'scss',

      // Scripting languages
      'tcl', 'awk', 'sed', 'zsh', 'fish', 'csh', 'ksh',

      // Database languages
      'plsql', 'tsql', 'mysql', 'postgresql', 'sqlite', 'mongodb', 'redis',
      'cassandra', 'couchdb', 'neo4j', 'influxdb',

      // Markup and config
      'yaml', 'toml', 'ini', 'properties', 'dockerfile', 'makefile', 'cmake',
      'gradle', 'maven', 'ant', 'sbt',

      // Specialized languages
      'solidity', 'vyper', 'move', 'cairo', 'ink', 'clarity',
      'graphql', 'sparql', 'cypher', 'gremlin',

      // Template languages
      'jinja', 'handlebars', 'mustache', 'twig', 'smarty', 'velocity',

      // Domain specific
      'latex', 'bibtex', 'postscript', 'prolog', 'datalog', 'minilog',
      'wolfram', 'mathematica', 'maple', 'maxima',
    ];

    // Operating Systems
    const operatingSystems = [
      // Desktop OS
      'windows', 'macos', 'linux', 'ubuntu', 'debian', 'fedora', 'centos',
      'rhel', 'redhat', 'suse', 'opensuse', 'arch', 'manjaro', 'mint',
      'elementary', 'zorin', 'pop', 'kali', 'parrot', 'tails', 'qubes',

      // Unix variants
      'unix', 'solaris', 'aix', 'hpux', 'irix', 'tru64', 'qnx', 'minix',
      'freebsd', 'openbsd', 'netbsd', 'dragonfly',

      // Mobile OS
      'android', 'ios', 'ipados', 'watchos', 'tvos', 'harmonyos', 'tizen',
      'kaios', 'sailfish', 'ubuntu', 'postmarket',

      // Embedded/IoT
      'freertos', 'zephyr', 'contiki', 'riot', 'mynewt', 'nuttx', 'rtems',
      'threadx', 'micrium', 'embos', 'integrity', 'vxworks',

      // Virtualization
      'vmware', 'virtualbox', 'hyperv', 'xen', 'kvm', 'qemu', 'proxmox',
      'citrix', 'parallels',

      // Container OS
      'coreos', 'rancheros', 'photon', 'atomic', 'bottlerocket', 'talos',

      // Gaming/Entertainment
      'steamos', 'batocera', 'recalbox', 'retropie', 'lakka',

      // Historical
      'msdos', 'os2', 'beos', 'haiku', 'amigaos', 'morphos', 'aros',
      'riscos', 'menuetos', 'kolibrios',
    ];

    // Network Protocols and Technologies
    const protocols = [
      // Internet protocols
      'http', 'https', 'ftp', 'ftps', 'sftp', 'ssh', 'telnet', 'smtp', 'pop3',
      'imap', 'dns', 'dhcp', 'ntp', 'snmp', 'ldap', 'ldaps', 'kerberos',

      // Transport protocols
      'tcp', 'udp', 'sctp', 'dccp', 'rtp', 'rtcp', 'srtp', 'quic',

      // Network layer
      'ip', 'ipv4', 'ipv6', 'icmp', 'icmpv6', 'igmp', 'ospf', 'bgp', 'rip',
      'eigrp', 'isis', 'mpls', 'gre', 'ipsec', 'vpn', 'l2tp', 'pptp',

      // Data link protocols
      'ethernet', 'wifi', 'bluetooth', 'zigbee', 'lora', 'lorawan', 'nfc',
      'ppp', 'hdlc', 'frame', 'relay', 'atm', 'sonet', 'sdh',

      // Application protocols
      'websocket', 'webrtc', 'sip', 'rtp', 'rtsp', 'mqtt', 'coap', 'amqp',
      'stomp', 'xmpp', 'irc', 'nntp', 'gopher', 'finger', 'whois',

      // Web protocols
      'soap', 'rest', 'graphql', 'grpc', 'jsonrpc', 'xmlrpc', 'oauth',
      'openid', 'saml', 'jwt', 'cors', 'csrf', 'xss',

      // Security protocols
      'tls', 'ssl', 'dtls', 'wpa', 'wpa2', 'wpa3', 'wep', 'eap', 'radius',
      'tacacs', 'diameter', 'x509', 'pkcs', 'pgp', 'gpg',

      // Routing protocols
      'rip', 'ripv2', 'ospf', 'ospfv3', 'bgp', 'bgpv4', 'eigrp', 'isis',
      'babel', 'olsr', 'aodv', 'dsr', 'batman',

      // Industrial protocols
      'modbus', 'profinet', 'ethercat', 'canbus', 'devicenet', 'profibus',
      'hart', 'foundation', 'fieldbus', 'asi', 'interbus',

      // Blockchain protocols
      'bitcoin', 'ethereum', 'lightning', 'nostr', 'ipfs', 'bittorrent',
      'kad', 'chord', 'pastry', 'tapestry', 'freenet',

      // Streaming protocols
      'hls', 'dash', 'smooth', 'streaming', 'rtmp', 'rtmps', 'webrtc',
      'srt', 'rist', 'zixi', 'udx',
    ];

    // Development Tools and Frameworks
    const devTools = [
      // Version control
      'git', 'svn', 'mercurial', 'bazaar', 'perforce', 'cvs', 'tfs',
      'github', 'gitlab', 'bitbucket', 'sourceforge', 'codeberg',

      // Build tools
      'make', 'cmake', 'ninja', 'bazel', 'buck', 'pants', 'gradle',
      'maven', 'ant', 'sbt', 'leiningen', 'cargo', 'npm', 'yarn', 'pnpm',
      'pip', 'conda', 'poetry', 'pipenv', 'bundler', 'composer', 'nuget',

      // CI/CD
      'jenkins', 'travis', 'circleci', 'appveyor', 'teamcity', 'bamboo',
      'azure', 'devops', 'github', 'actions', 'gitlab', 'drone', 'concourse',

      // Containerization
      'docker', 'podman', 'containerd', 'crio', 'rkt', 'lxc', 'lxd',
      'kubernetes', 'openshift', 'rancher', 'nomad', 'mesos', 'swarm',

      // Cloud platforms
      'aws', 'azure', 'gcp', 'digitalocean', 'linode', 'vultr', 'hetzner',
      'scaleway', 'ovh', 'cloudflare', 'fastly', 'netlify', 'vercel',

      // Monitoring
      'prometheus', 'grafana', 'elasticsearch', 'logstash', 'kibana',
      'splunk', 'datadog', 'newrelic', 'dynatrace', 'appdynamics',

      // Web frameworks
      'react', 'vue', 'angular', 'svelte', 'ember', 'backbone', 'jquery',
      'bootstrap', 'tailwind', 'bulma', 'foundation', 'semantic',
      'express', 'koa', 'fastify', 'hapi', 'nestjs', 'nextjs', 'nuxtjs',
      'gatsby', 'astro', 'remix', 'sveltekit',

      // Backend frameworks
      'django', 'flask', 'fastapi', 'tornado', 'pyramid', 'bottle',
      'rails', 'sinatra', 'hanami', 'spring', 'struts', 'hibernate',
      'laravel', 'symfony', 'codeigniter', 'cakephp', 'zend', 'yii',

      // Testing frameworks
      'jest', 'mocha', 'jasmine', 'karma', 'cypress', 'selenium', 'playwright',
      'puppeteer', 'webdriver', 'junit', 'testng', 'mockito', 'pytest',
      'unittest', 'nose', 'rspec', 'minitest', 'phpunit', 'codeception',

      // Databases
      'mysql', 'postgresql', 'sqlite', 'mariadb', 'oracle', 'sqlserver',
      'mongodb', 'couchdb', 'cassandra', 'dynamodb', 'redis', 'memcached',
      'elasticsearch', 'solr', 'neo4j', 'arangodb', 'orientdb', 'dgraph',
      'influxdb', 'timescaledb', 'clickhouse', 'bigquery', 'snowflake',

      // Message queues
      'rabbitmq', 'kafka', 'activemq', 'artemis', 'pulsar', 'nats',
      'zeromq', 'nanomsg', 'redis', 'sqs', 'servicebus', 'pubsub',
    ];

    // Technical terms and concepts
    const techConcepts = [
      // General programming
      'algorithm', 'data', 'structure', 'array', 'list', 'stack', 'queue',
      'tree', 'graph', 'hash', 'table', 'dictionary', 'set', 'map',
      'object', 'class', 'interface', 'abstract', 'inheritance', 'polymorphism',
      'encapsulation', 'abstraction', 'composition', 'aggregation',
      'function', 'method', 'procedure', 'subroutine', 'lambda', 'closure',
      'variable', 'constant', 'parameter', 'argument', 'return', 'void',
      'boolean', 'string', 'integer', 'float', 'double', 'char', 'byte',
      'pointer', 'reference', 'memory', 'heap', 'stack', 'garbage',
      'collection',

      // Software engineering
      'agile', 'scrum', 'kanban', 'waterfall', 'devops', 'cicd', 'tdd', 'bdd',
      'refactoring', 'debugging', 'profiling', 'optimization', 'performance',
      'scalability', 'reliability', 'availability', 'maintainability',
      'testability', 'usability', 'accessibility', 'security', 'privacy',

      // Architecture patterns
      'mvc', 'mvp', 'mvvm', 'singleton', 'factory', 'observer', 'strategy',
      'decorator', 'adapter', 'facade', 'proxy', 'command', 'state',
      'microservices', 'monolith', 'serverless', 'event', 'driven',
      'domain', 'driven', 'design', 'clean', 'architecture', 'hexagonal',

      // Web development
      'frontend', 'backend', 'fullstack', 'responsive', 'mobile', 'first',
      'progressive', 'web', 'app', 'single', 'page', 'application',
      'server', 'side', 'rendering', 'client', 'side', 'rendering',
      'static', 'site', 'generator', 'jamstack', 'headless', 'cms',

      // Networking
      'client', 'server', 'peer', 'to', 'peer', 'request', 'response',
      'synchronous', 'asynchronous', 'blocking', 'nonblocking',
      'concurrent', 'parallel', 'distributed', 'load', 'balancing',
      'caching', 'cdn', 'proxy', 'reverse', 'proxy', 'firewall',

      // Security
      'authentication', 'authorization', 'encryption', 'decryption',
      'hashing', 'salting', 'digital', 'signature', 'certificate',
      'public', 'key', 'private', 'key', 'symmetric', 'asymmetric',
      'vulnerability', 'exploit', 'malware', 'virus', 'trojan',
      'phishing', 'social', 'engineering', 'penetration', 'testing',

      // Data science
      'machine', 'learning', 'deep', 'learning', 'neural', 'network',
      'artificial', 'intelligence', 'natural', 'language', 'processing',
      'computer', 'vision', 'data', 'mining', 'big', 'data', 'analytics',
      'statistics', 'regression', 'classification', 'clustering',
      'supervised', 'unsupervised', 'reinforcement', 'learning',

      // Blockchain
      'blockchain', 'cryptocurrency', 'bitcoin', 'ethereum', 'smart',
      'contract', 'decentralized', 'consensus', 'proof', 'of', 'work',
      'proof', 'of', 'stake', 'mining', 'wallet', 'transaction',
      'hash', 'merkle', 'tree', 'nonce', 'difficulty', 'fork',

      // Cloud computing
      'infrastructure', 'as', 'a', 'service', 'platform', 'as', 'a', 'service',
      'software', 'as', 'a', 'service', 'function', 'as', 'a', 'service',
      'container', 'as', 'a', 'service', 'backend', 'as', 'a', 'service',
      'virtualization', 'containerization', 'orchestration', 'auto', 'scaling',
      'elastic', 'computing', 'edge', 'computing', 'fog', 'computing',
    ];

    _dictionary.addAll(programmingLanguages);
    _dictionary.addAll(operatingSystems);
    _dictionary.addAll(protocols);
    _dictionary.addAll(devTools);
    _dictionary.addAll(techConcepts);

    _dictionary.addAll(commonWords);

    // Try to load additional words from a web dictionary API (optional)
    try {
      await _loadAdditionalWords();
    } catch (e) {
      // Ignore errors - we have basic dictionary
    }
  }

  /// Load additional words from a web dictionary (optional enhancement)
  Future<void> _loadAdditionalWords() async {
    // This could load from a more comprehensive word list
    // For now, we'll skip this to keep it simple
  }

  /// Check if a word is spelled correctly
  bool isWordCorrect(String word) {
    if (!_isInitialized) {
      return true; // Don't mark as incorrect if not initialized
    }

    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    if (cleanWord.isEmpty) return true;

    // Skip very short words (1-2 characters) as they're often abbreviations
    if (cleanWord.length <= 2) return true;

    final isCorrect = _dictionary.contains(cleanWord);

    // Debug: Log specific words we're testing
    if (cleanWord == 'chese' || cleanWord == 'cheese') {
      print('DEBUG: Checking "$cleanWord" - Found: $isCorrect');
      print('Dictionary size: ${_dictionary.length}');
    }

    return isCorrect;
  }

  /// Get suggestions for a misspelled word
  List<String> getSuggestions(String word) {
    if (isWordCorrect(word)) return [];

    final suggestions = <String>[];
    final cleanWord = word.toLowerCase();

    // Simple suggestion algorithm - find similar words
    for (final dictWord in _dictionary) {
      if (_calculateSimilarity(cleanWord, dictWord) > 0.6) {
        suggestions.add(dictWord);
      }
    }

    // Sort by similarity and return top 5
    suggestions.sort((a, b) => _calculateSimilarity(cleanWord, b)
        .compareTo(_calculateSimilarity(cleanWord, a)));

    return suggestions.take(5).toList();
  }

  /// Calculate similarity between two words (simple Levenshtein-like)
  double _calculateSimilarity(String word1, String word2) {
    if (word1 == word2) return 1.0;
    if (word1.isEmpty || word2.isEmpty) return 0.0;

    final maxLength = word1.length > word2.length ? word1.length : word2.length;
    final distance = _levenshteinDistance(word1, word2);

    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Extract words from markdown text with their positions, ignoring code blocks, links, etc.
  List<Map<String, dynamic>> extractWordsWithPositions(String text) {
    final wordsWithPositions = <Map<String, dynamic>>[];
    final lines = text.split('\n');
    bool inCodeBlock = false;
    int lineStartIndex = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];

      // Skip code blocks
      if (line.trim().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        lineStartIndex += line.length + 1; // +1 for newline
        continue;
      }
      if (inCodeBlock) {
        lineStartIndex += line.length + 1;
        continue;
      }

      // Create a processed version for word extraction but keep original for positions
      String processedLine = line;

      // Skip inline code - replace with spaces to maintain positions
      processedLine =
          processedLine.replaceAllMapped(RegExp(r'`[^`]*`'), (match) {
        return ' ' * match.group(0)!.length;
      });

      // Skip links - keep the text part
      processedLine = processedLine
          .replaceAllMapped(RegExp(r'\[([^\]]*)\]\([^)]*\)'), (match) {
        final linkText = match.group(1) ?? '';
        final padding = ' ' * (match.group(0)!.length - linkText.length);
        return linkText + padding;
      });

      // Skip images - replace with spaces
      processedLine = processedLine
          .replaceAllMapped(RegExp(r'!\[([^\]]*)\]\([^)]*\)'), (match) {
        return ' ' * match.group(0)!.length;
      });

      // Skip headers - remove # symbols but keep text
      processedLine = processedLine.replaceAll(RegExp(r'^#+\s*'), '');

      // Extract words with better word boundary detection
      final wordRegex = RegExp(r'\b[a-zA-Z]+(?:[a-zA-Z]+)?\b');
      final matches = wordRegex.allMatches(processedLine);

      for (final match in matches) {
        final word = match.group(0)!;
        final wordStart = lineStartIndex + match.start;
        final wordEnd = lineStartIndex + match.end;

        // Skip very short words and common contractions
        if (word.length <= 2) continue;

        wordsWithPositions.add({
          'word': word,
          'start': wordStart,
          'end': wordEnd,
          'line': lineIndex,
        });
      }

      lineStartIndex += line.length + 1; // +1 for newline
    }

    return wordsWithPositions;
  }

  /// Extract words from markdown text, ignoring code blocks, links, etc.
  List<String> extractWordsFromMarkdown(String text) {
    return extractWordsWithPositions(text)
        .map((wordData) => wordData['word'] as String)
        .toList();
  }

  /// Perform spellcheck on markdown text
  Future<SpellcheckResult> checkText(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final misspelledWords = <SpellcheckWord>[];
      final wordsWithPositions = extractWordsWithPositions(text);

      for (final wordData in wordsWithPositions) {
        final word = wordData['word'] as String;
        final startIndex = wordData['start'] as int;
        final endIndex = wordData['end'] as int;

        if (!isWordCorrect(word)) {
          final suggestions = getSuggestions(word);
          misspelledWords.add(SpellcheckWord(
            word: word,
            startIndex: startIndex,
            endIndex: endIndex,
            suggestions: suggestions,
          ));
        }
      }

      return SpellcheckResult(misspelledWords: misspelledWords);
    } catch (e) {
      return SpellcheckResult(
        misspelledWords: [],
        isComplete: false,
        error: e.toString(),
      );
    }
  }

  /// Add a word to the personal dictionary
  void addToDictionary(String word) {
    _dictionary.add(word.toLowerCase());
  }

  /// Remove a word from the personal dictionary
  void removeFromDictionary(String word) {
    _dictionary.remove(word.toLowerCase());
  }
}
