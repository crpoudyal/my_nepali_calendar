import 'package:flutter/material.dart';
import '../src.dart';

class CalendarCell<T> extends StatelessWidget {
  final int day;
  final NepaliDateTime date;
  final NepaliDateTime selectedDate;
  final CalendarEvent<T>? event;
  final OnDateSelected onDaySelected;
  final NepaliCalendarStyle calendarStyle;

  // optional color parameters
  final Color? eventColor;
  final Color? holidayColor;

  const CalendarCell({
    super.key,
    required this.day,
    required this.date,
    required this.selectedDate,
    required this.event,
    required this.onDaySelected,
    required this.calendarStyle,
    this.eventColor,
    this.holidayColor,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = CalendarUtils.isToday(date.toDateTime());
    final isSelected = _isSelectedDate(date);
    final isHoliday = event?.isHoliday ?? false;

    return GestureDetector(
      onTap: () => onDaySelected(date),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _getCellColor(isToday, isSelected),
          border: calendarStyle.showBorder
              ? Border.all(
                  color: _getCellColor(isToday, isSelected)
                      .withValues(alpha: 0.05),
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Center(
              child: Text(
                calendarStyle.language == Language.english
                    ? "$day"
                    : NepaliNumberConverter.englishToNepali(day.toString()),
                style: calendarStyle.cellsStyle.dayStyle.copyWith(
                  color: _getCellTextColor(isToday, isSelected, date.weekday),
                ),
              ),
            ),
            if (calendarStyle.showEnglishDate)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "${date.toDateTime().day}",
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          _getCellTextColor(isToday, isSelected, date.weekday),
                    ),
                  ),
                ),
              ),
            if (event != null)
              Positioned(
                bottom: 5.0,
                child: Icon(
                  Icons.circle,
                  size: 5,
                  color: _getEventColor(isHoliday, isToday, date.weekday),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCellColor(bool isToday, bool isSelected) {
    if (isToday && isSelected) return calendarStyle.cellsStyle.todayColor;
    if (isSelected) {
      return calendarStyle.cellsStyle.selectedColor.withValues(alpha: 0.2);
    }
    if (isToday) return calendarStyle.cellsStyle.todayColor;
    return Colors.transparent;
  }

  Color _getCellTextColor(bool isToday, bool isSelected, int weekday) {
    if (isToday && isSelected) return Colors.white;
    if (isToday) return Colors.white;
    if (weekday == 7) return calendarStyle.cellsStyle.weekDayColor;
    return Colors.black;
  }

  // Use user-provided colors if set
  Color _getEventColor(bool isHoliday, bool isToday, int weekday) {
    if (weekday == 7) {
      return holidayColor ?? calendarStyle.cellsStyle.weekDayColor;
    }
    if (isToday) return Colors.white;
    if (isHoliday) return holidayColor ?? calendarStyle.cellsStyle.weekDayColor;
    return eventColor ?? calendarStyle.cellsStyle.dotColor;
  }

  bool _isSelectedDate(NepaliDateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }
}
