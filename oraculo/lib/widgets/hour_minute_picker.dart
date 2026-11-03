import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// Seletor de Horário com seleção de Hora e Minuto
/// Permite escolher hora (00-23) e minuto (00-59) via dropdowns dedicados,
/// atalhos rápidos de minutos (:00, :15, :30, :45) e através do seletor
/// visual oficial do relógio (showTimePicker).
class HourMinuteSelector extends StatefulWidget {
  final String? initialTime;
  final ValueChanged<String?> onTimeChanged;
  final Color primaryColor;
  final Color secondaryColor;

  const HourMinuteSelector({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
    this.primaryColor = AppTheme.orange,
    this.secondaryColor = AppTheme.lilacContainer,
  });

  @override
  State<HourMinuteSelector> createState() => _HourMinuteSelectorState();
}

class _HourMinuteSelectorState extends State<HourMinuteSelector> {
  int? _selectedHour;
  int? _selectedMinute;

  @override
  void initState() {
    super.initState();
    _parseInitialTime(widget.initialTime);
  }

  @override
  void didUpdateWidget(covariant HourMinuteSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      _parseInitialTime(widget.initialTime);
    }
  }

  void _parseInitialTime(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty || timeStr.toLowerCase().contains('sem')) {
      _selectedHour = null;
      _selectedMinute = null;
      return;
    }
    final parts = timeStr.trim().split(':');
    if (parts.length == 2) {
      final h = int.tryParse(parts[0].trim());
      final m = int.tryParse(parts[1].trim());
      if (h != null && m != null && h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        _selectedHour = h;
        _selectedMinute = m;
        return;
      }
    }
    _selectedHour = null;
    _selectedMinute = null;
  }

  void _updateTime(int? hour, int? minute) {
    setState(() {
      if (hour == null && minute == null) {
        _selectedHour = null;
        _selectedMinute = null;
        widget.onTimeChanged(null);
      } else {
        _selectedHour = hour ?? 12;
        _selectedMinute = minute ?? 0;
        final hStr = _selectedHour!.toString().padLeft(2, '0');
        final mStr = _selectedMinute!.toString().padLeft(2, '0');
        widget.onTimeChanged('$hStr:$mStr');
      }
    });
  }

  Future<void> _pickFromClockDialog(BuildContext context) async {
    final now = TimeOfDay.now();
    final initial = (_selectedHour != null && _selectedMinute != null)
        ? TimeOfDay(hour: _selectedHour!, minute: _selectedMinute!)
        : now;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'SELECIONE O HORÁRIO DO EVENTO',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
      hourLabelText: 'Hora',
      minuteLabelText: 'Minuto',
      builder: (dialogContext, child) {
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF2B2B2B),
              secondary: widget.secondaryColor,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              hourMinuteColor: const Color(0xFFFFF0EA),
              hourMinuteTextColor: widget.primaryColor,
              dialHandColor: widget.primaryColor,
              dialBackgroundColor: const Color(0xFFF7F7F9),
              dialTextColor: const Color(0xFF2B2B2B),
              entryModeIconColor: widget.primaryColor,
              helpTextStyle: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              cancelButtonStyle: ButtonStyle(
                foregroundColor:
                    WidgetStateProperty.all(const Color(0xFF8E8E8E)),
              ),
              confirmButtonStyle: ButtonStyle(
                foregroundColor:
                    WidgetStateProperty.all(widget.primaryColor),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(dialogContext)
                .copyWith(alwaysUse24HourFormat: true),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );

    if (picked != null) {
      _updateTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTime = _selectedHour != null && _selectedMinute != null;
    final formattedTime = hasTime
        ? '${_selectedHour!.toString().padLeft(2, '0')}:${_selectedMinute!.toString().padLeft(2, '0')}'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasTime
              ? widget.primaryColor.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho com ícone, hora formatada e botão do relógio
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20,
                color: hasTime ? widget.primaryColor : const Color(0xFF8E8E8E),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickFromClockDialog(context),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    hasTime
                        ? 'Horário: $formattedTime'
                        : 'Horário (Hora e Minuto):',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: hasTime ? FontWeight.bold : FontWeight.w600,
                      color: hasTime
                          ? const Color(0xFF2B2B2B)
                          : const Color(0xFF666666),
                    ),
                  ),
                ),
              ),
              // Botão Relógio (Time Picker padrão)
              BouncingPressable(
                key: const Key('clock_picker_button'),
                onTap: () => _pickFromClockDialog(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0EA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.primaryColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: widget.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Relógio',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasTime) ...[
                const SizedBox(width: 8),
                BouncingPressable(
                  key: const Key('clear_time_button'),
                  onTap: () => _updateTime(null, null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Linha dos Seletores de Hora e Minuto
          Row(
            children: [
              // Dropdown de Hora
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedHour != null
                          ? widget.primaryColor.withValues(alpha: 0.6)
                          : const Color(0xFFE2E2E6),
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: const Key('hour_picker_dropdown'),
                      value: _selectedHour,
                      hint: const Text(
                        'Hora (--)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E8E),
                        ),
                      ),
                      isExpanded: true,
                      menuMaxHeight: 260,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                      items: List.generate(24, (index) {
                        final hStr = index.toString().padLeft(2, '0');
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            '$hStr h',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        );
                      }),
                      onChanged: (newHour) {
                        _updateTime(newHour, _selectedMinute ?? 0);
                      },
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
              ),

              // Dropdown de Minuto
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMinute != null
                          ? widget.primaryColor.withValues(alpha: 0.6)
                          : const Color(0xFFE2E2E6),
                      width: 1.2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: const Key('minute_picker_dropdown'),
                      value: _selectedMinute,
                      hint: const Text(
                        'Minuto (--)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E8E),
                        ),
                      ),
                      isExpanded: true,
                      menuMaxHeight: 260,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: widget.primaryColor,
                        size: 20,
                      ),
                      items: List.generate(60, (index) {
                        final mStr = index.toString().padLeft(2, '0');
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(
                            '$mStr min',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                        );
                      }),
                      onChanged: (newMinute) {
                        _updateTime(_selectedHour ?? 12, newMinute);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Atalhos rápidos de Minuto (:00, :15, :30, :45)
          Row(
            children: [
              const Text(
                'Atalhos:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8E8E8E),
                ),
              ),
              const SizedBox(width: 8),
              for (final min in [0, 15, 30, 45])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: BouncingPressable(
                    key: Key('quick_minute_$min'),
                    onTap: () {
                      _updateTime(_selectedHour ?? 12, min);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _selectedMinute == min
                            ? widget.primaryColor
                            : const Color(0xFFFFF0EA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedMinute == min
                              ? widget.primaryColor
                              : widget.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        ':${min.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _selectedMinute == min
                              ? Colors.white
                              : widget.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
