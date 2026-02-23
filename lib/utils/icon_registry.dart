                        import 'package:hugeicons/hugeicons.dart';

class IconRegistry {
  static final Map<String, dynamic> iconMap = {
    'food': HugeIcons.strokeRoundedRestaurant01,
    'transport': HugeIcons.strokeRoundedBus01,
    'shopping': HugeIcons.strokeRoundedShoppingBag01,             
    'bills': HugeIcons.strokeRoundedInvoice01,
    'entertainment': HugeIcons.strokeRoundedVideo01,
    'health': HugeIcons.strokeRoundedHospital01,
    'education': HugeIcons.strokeRoundedMortarboard01,
    'other': HugeIcons.strokeRoundedMoreHorizontal,
    'salary': HugeIcons.strokeRoundedBriefcase01,
    'bonus': HugeIcons.strokeRoundedStar,
    'award': HugeIcons.strokeRoundedChampion,
    'investment': HugeIcons.strokeRoundedChartIncrease,
    // Add more icons for user selection
    'home': HugeIcons.strokeRoundedHome01,
    'gift': HugeIcons.strokeRoundedGift,
    'sport': HugeIcons.strokeRoundedBasketball01,
    'travel': HugeIcons.strokeRoundedAirplane01,
    'phone': HugeIcons.strokeRoundedSmartPhone01,
    'internet': HugeIcons.strokeRoundedWifi01,
    'coffee': HugeIcons.strokeRoundedCoffee01,
  };

  static dynamic getIcon(String key) {
    return iconMap[key] ?? HugeIcons.strokeRoundedHelpCircle;
  }

  static String getKey(dynamic icon) {
    // This might be slow if map is large, but for 20 icons it's fine.
    // Also HugeIcon constants are lists, so equality check might be by reference or value?
    // List equality usually requires deep comparison or reference equality.
    // Since we use the constants, reference equality might work if they are static const.
    // However, safest is to store the key explicitly when selecting.
    for (var entry in iconMap.entries) {
      if (entry.value == icon) {
        return entry.key;
      }
    }
    return 'other';
  }
}
