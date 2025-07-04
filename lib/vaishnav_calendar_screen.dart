import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:japa_counter/utils/vaishnav_calendar_data.dart';

class VaishnavCalendarScreen extends StatefulWidget {
  const VaishnavCalendarScreen({Key? key}) : super(key: key);

  @override
  State<VaishnavCalendarScreen> createState() => _VaishnavCalendarScreenState();
}

class _VaishnavCalendarScreenState extends State<VaishnavCalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late Map<DateTime, List<VaishnavEvent>> _events;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _events = VaishnavCalendarData.events;
  }

  List<VaishnavEvent> _getEventsForDay(DateTime day) {
    return VaishnavCalendarData.getEventsForDay(day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaishnav Calendar'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<VaishnavEvent>(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red),
              holidayTextStyle: TextStyle(color: Colors.blue),
              selectedDecoration: BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    final events = _getEventsForDay(_selectedDay);
    
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events for this day',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: event.color,
              child: Icon(
                _getEventIcon(event.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              event.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  VaishnavCalendarData.getEventTypeDescription(event.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: event.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  IconData _getEventIcon(VaishnavEventType type) {
    switch (type) {
      case VaishnavEventType.ekadashi:
        return Icons.brightness_2;
      case VaishnavEventType.festival:
        return Icons.celebration;
      case VaishnavEventType.appearance:
        return Icons.star;
      case VaishnavEventType.disappearance:
        return Icons.brightness_3;
      case VaishnavEventType.special:
        return Icons.auto_awesome;
    }
  }
} 