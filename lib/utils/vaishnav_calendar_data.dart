import 'package:flutter/material.dart';

enum VaishnavEventType {
  ekadashi,
  festival,
  appearance,
  disappearance,
  special,
}

class VaishnavEvent {
  final String name;
  final String description;
  final VaishnavEventType type;
  final Color color;

  VaishnavEvent({
    required this.name,
    required this.description,
    required this.type,
    required this.color,
  });
}

class VaishnavCalendarData {
  static Map<DateTime, List<VaishnavEvent>> get events {
    return {
      // January 2025
      DateTime(2025, 1, 11): [
        VaishnavEvent(
          name: "Pausha Putrada Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 1, 26): [
        VaishnavEvent(
          name: "Shat-tila Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // February 2025
      DateTime(2025, 2, 10): [
        VaishnavEvent(
          name: "Jaya Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 2, 24): [
        VaishnavEvent(
          name: "Vijaya Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // March 2025
      DateTime(2025, 3, 12): [
        VaishnavEvent(
          name: "Amalaki Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 3, 14): [
        VaishnavEvent(
          name: "Holi Festival",
          description: "Festival of colors celebrating divine love",
          type: VaishnavEventType.festival,
          color: Colors.pink,
        ),
      ],
      DateTime(2025, 3, 26): [
        VaishnavEvent(
          name: "Papamochani Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // April 2025
      DateTime(2025, 4, 10): [
        VaishnavEvent(
          name: "Kamada Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 4, 13): [
        VaishnavEvent(
          name: "Ram Navami",
          description: "Appearance day of Lord Rama",
          type: VaishnavEventType.appearance,
          color: Colors.blue,
        ),
      ],
      DateTime(2025, 4, 25): [
        VaishnavEvent(
          name: "Varuthini Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // May 2025
      DateTime(2025, 5, 9): [
        VaishnavEvent(
          name: "Mohini Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 5, 12): [
        VaishnavEvent(
          name: "Akshaya Tritiya",
          description: "Auspicious day for spiritual activities",
          type: VaishnavEventType.special,
          color: Colors.green,
        ),
      ],
      DateTime(2025, 5, 24): [
        VaishnavEvent(
          name: "Apara Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // June 2025
      DateTime(2025, 6, 8): [
        VaishnavEvent(
          name: "Nirjala Ekadashi",
          description: "Most important Ekadashi - complete fast",
          type: VaishnavEventType.ekadashi,
          color: Colors.deepOrange,
        ),
      ],
      DateTime(2025, 6, 22): [
        VaishnavEvent(
          name: "Yogini Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // July 2025
      DateTime(2025, 7, 7): [
        VaishnavEvent(
          name: "Sayana Ekadashi",
          description: "Beginning of Chaturmasya period",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 7, 21): [
        VaishnavEvent(
          name: "Kamika Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // August 2025
      DateTime(2025, 8, 5): [
        VaishnavEvent(
          name: "Shravana Putrada Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 8, 16): [
        VaishnavEvent(
          name: "Krishna Janmashtami",
          description: "Appearance day of Lord Krishna",
          type: VaishnavEventType.appearance,
          color: Colors.indigo,
        ),
      ],
      DateTime(2025, 8, 19): [
        VaishnavEvent(
          name: "Aja Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // September 2025
      DateTime(2025, 9, 3): [
        VaishnavEvent(
          name: "Parsva Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 9, 7): [
        VaishnavEvent(
          name: "Radhastami",
          description: "Appearance day of Srimati Radharani",
          type: VaishnavEventType.appearance,
          color: Colors.pink,
        ),
      ],
      DateTime(2025, 9, 18): [
        VaishnavEvent(
          name: "Indira Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // October 2025
      DateTime(2025, 10, 2): [
        VaishnavEvent(
          name: "Papankusha Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 10, 17): [
        VaishnavEvent(
          name: "Rama Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 10, 20): [
        VaishnavEvent(
          name: "Diwali",
          description: "Festival of lights",
          type: VaishnavEventType.festival,
          color: Colors.amber,
        ),
      ],

      // November 2025
      DateTime(2025, 11, 1): [
        VaishnavEvent(
          name: "Gopashtami",
          description: "Celebration of Lord Krishna as cowherd",
          type: VaishnavEventType.festival,
          color: Colors.green,
        ),
        VaishnavEvent(
          name: "Haribodhini Ekadashi",
          description: "End of Chaturmasya - Lord Vishnu awakens",
          type: VaishnavEventType.ekadashi,
          color: Colors.deepOrange,
        ),
      ],
      DateTime(2025, 11, 15): [
        VaishnavEvent(
          name: "Utthana Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],

      // December 2025
      DateTime(2025, 12, 1): [
        VaishnavEvent(
          name: "Mokshada Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
      DateTime(2025, 12, 15): [
        VaishnavEvent(
          name: "Saphala Ekadashi",
          description: "Fasting day for purification",
          type: VaishnavEventType.ekadashi,
          color: Colors.orange,
        ),
      ],
    };
  }

  static List<VaishnavEvent> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  static bool hasEventsForDay(DateTime day) {
    return events.containsKey(DateTime(day.year, day.month, day.day));
  }

  static String getEventTypeDescription(VaishnavEventType type) {
    switch (type) {
      case VaishnavEventType.ekadashi:
        return "Fasting Day - Observe Ekadashi vrata";
      case VaishnavEventType.festival:
        return "Festival - Celebrate with devotion";
      case VaishnavEventType.appearance:
        return "Appearance Day - Honor the divine appearance";
      case VaishnavEventType.disappearance:
        return "Disappearance Day - Remember with reverence";
      case VaishnavEventType.special:
        return "Special Day - Auspicious for spiritual practices";
    }
  }
} 