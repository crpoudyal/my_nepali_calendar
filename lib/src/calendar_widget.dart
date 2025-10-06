import 'package:flutter/material.dart';
import 'src.dart';

// typedef OnDateSelected = void Function(NepaliDateTime date);

class NepaliCalendar<T> extends StatefulWidget {
  final NepaliDateTime? initialDate;
  final List<CalendarEvent<T>>? eventList;
  final bool Function(CalendarEvent<T> event)? checkIsHoliday;
  final NepaliCalendarStyle calendarStyle;
  final OnDateSelected? onMonthChanged;
  final OnDateSelected? onDayChanged;
  final NepaliCalendarController? controller;

  final Widget? Function(NepaliDateTime date, PageController pageController)?
      headerBuilder;
  final Widget? Function(
    BuildContext context,
    int index,
    NepaliDateTime date,
    CalendarEvent<T> event,
  )? eventBuilder;

  final Color? eventColor;
  final Color? holidayColor;

  const NepaliCalendar({
    super.key,
    this.initialDate,
    this.eventList,
    this.checkIsHoliday,
    this.calendarStyle = const NepaliCalendarStyle(),
    this.onMonthChanged,
    this.onDayChanged,
    this.controller,
    this.headerBuilder,
    this.eventBuilder,
    this.eventColor,
    this.holidayColor,
  }) : assert(
          eventList == null || checkIsHoliday != null,
          'checkIsHoliday must be provided when eventList is not null',
        );

  @override
  State<NepaliCalendar> createState() => _NepaliCalendarState<T>();
}

class _NepaliCalendarState<T> extends State<NepaliCalendar<T>> {
  late final PageController _pageController;
  late NepaliDateTime _currentDate;
  late NepaliDateTime _selectedDate;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate ?? NepaliDateTime.now();
    _selectedDate = _currentDate;
    _currentPageIndex =
        ((_currentDate.year - CalendarUtils.calenderyearStart) * 12) +
            _currentDate.month -
            1;
    _pageController = PageController(initialPage: _currentPageIndex);

    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _pageController.dispose();
    super.dispose();
  }

  void _updateSelectedDate(NepaliDateTime newDate) {
    final prevDate = _selectedDate;
    _selectedDate = newDate;

    if (prevDate.year != newDate.year || prevDate.month != newDate.month) {
      widget.onMonthChanged?.call(_selectedDate);
    } else if (prevDate.day != newDate.day) {
      widget.onDayChanged?.call(_selectedDate);
    }
    setState(() {}); // Refresh UI for selection changes
  }

  void _onPageChanged(int pageIndex) {
    final year = CalendarUtils.calenderyearStart + (pageIndex ~/ 12);
    final month = (pageIndex % 12) + 1;
    final newDate = NepaliDateTime(year: year, month: month);

    _currentDate = newDate;
    _updateSelectedDate(newDate);
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = CalendarUtils.nepaliYears.length * 12;

    return PageView.builder(
      controller: _pageController,
      itemCount: totalPages,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final year = CalendarUtils.calenderyearStart + (index ~/ 12);
        final month = (index % 12) + 1;

        return Column(
          children: [
            Card(
              elevation: 0,
              child: Column(
                children: [
                  widget.headerBuilder?.call(_selectedDate, _pageController) ??
                      CalendarHeader(
                        selectedDate: _selectedDate,
                        pageController: _pageController,
                        calendarStyle: widget.calendarStyle,
                      ),
                  CalendarMonthView<T>(
                    year: year,
                    month: month,
                    selectedDate: _selectedDate,
                    eventList: widget.eventList,
                    calendarStyle: widget.calendarStyle,
                    onDaySelected: (date) => _updateSelectedDate(date),
                  ),
                ],
              ),
            ),
            Flexible(
              child: EventList<T>(
                eventList: widget.eventList,
                selectedDate: _selectedDate,
                itemBuilder: (context, i, event) =>
                    widget.eventBuilder?.call(context, i, _selectedDate, event),
                eventColor: widget.eventColor,
                holidayColor: widget.holidayColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class NepaliCalendarController {
  _NepaliCalendarState? _state;

  void _attach(_NepaliCalendarState state) => _state = state;
  void _detach() => _state = null;

  void jumpToDate(NepaliDateTime date) {
    if (_state == null) return;

    final pageIndex =
        ((date.year - CalendarUtils.calenderyearStart) * 12) + date.month - 1;

    _state!._pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    _state!._updateSelectedDate(date);
  }

  void jumpToToday() => jumpToDate(NepaliDateTime.now());

  NepaliDateTime? get selectedDate => _state?._selectedDate;
}
