import 'package:flutter/material.dart';
import 'src.dart';

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

class _NepaliCalendarState<T> extends State<NepaliCalendar<T>>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  late NepaliDateTime _selectedDate;
  late int _initialPage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? NepaliDateTime.now();
    _initialPage =
        ((_selectedDate.year - CalendarUtils.calenderyearStart) * 12) +
            _selectedDate.month -
            1;
    _pageController = PageController(initialPage: _initialPage);
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _pageController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onPageChanged(int pageIndex) {
    final year = CalendarUtils.calenderyearStart + (pageIndex ~/ 12);
    final month = (pageIndex % 12) + 1;
    final newDate = NepaliDateTime(year: year, month: month, day: 1);

    // Trigger month change callback
    widget.onMonthChanged?.call(newDate);

    // Update internal date
    setState(() {
      _selectedDate = newDate;
    });
  }

  void _onDaySelected(NepaliDateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    widget.onDayChanged?.call(newDate);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final totalPages = CalendarUtils.nepaliYears.length * 12;

    return Column(
      children: [
        widget.headerBuilder?.call(_selectedDate, _pageController) ??
            CalendarHeader(
              selectedDate: _selectedDate,
              pageController: _pageController,
              calendarStyle: widget.calendarStyle,
            ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPages,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final year = CalendarUtils.calenderyearStart + (index ~/ 12);
              final month = (index % 12) + 1;

              return Column(
                children: [
                  CalendarMonthView<T>(
                    year: year,
                    month: month,
                    selectedDate: _selectedDate,
                    eventList: widget.eventList,
                    calendarStyle: widget.calendarStyle,
                    onDaySelected: _onDaySelected,
                  ),
                  Flexible(
                    child: EventList<T>(
                      eventList: widget.eventList,
                      selectedDate: _selectedDate,
                      itemBuilder: (context, i, event) =>
                          widget.eventBuilder
                              ?.call(context, i, _selectedDate, event) ??
                          Container(),
                      eventColor: widget.eventColor,
                      holidayColor: widget.holidayColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    _state!.setState(() {
      _state!._selectedDate = date;
    });
    _state!.widget.onMonthChanged?.call(date);
  }

  void jumpToToday() => jumpToDate(NepaliDateTime.now());

  NepaliDateTime? get selectedDate => _state?._selectedDate;
}
