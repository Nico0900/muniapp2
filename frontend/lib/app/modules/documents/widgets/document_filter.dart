import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_theme.dart';

class DocumentFilters extends StatefulWidget {
  final Function(String)? onCategoryChanged;
  final Function(DateTimeRange?)? onDateRangeChanged;
  final Function(double, double)? onSizeRangeChanged;

  const DocumentFilters({
    Key? key,
    this.onCategoryChanged,
    this.onDateRangeChanged,
    this.onSizeRangeChanged,
  }) : super(key: key);

  @override
  State<DocumentFilters> createState() => _DocumentFiltersState();
}

class _DocumentFiltersState extends State<DocumentFilters> {
  String selectedCategory = 'all';
  DateTimeRange? selectedDateRange;
  RangeValues sizeRange = const RangeValues(0, 50);

  final List<Map<String, dynamic>> categories = [
    {'value': 'all', 'label': 'Todos', 'icon': Icons.all_inclusive},
    {'value': 'general', 'label': 'General', 'icon': Icons.folder},
    {
      'value': 'financial',
      'label': 'Financiero',
      'icon': Icons.account_balance
    },
    {'value': 'legal', 'label': 'Legal', 'icon': Icons.gavel},
    {'value': 'technical', 'label': 'Técnico', 'icon': Icons.engineering},
    {
      'value': 'administrative',
      'label': 'Administrativo',
      'icon': Icons.business
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          _buildCategoryFilter(),
          SizedBox(height: 24.h),
          _buildDateRangeFilter(),
          SizedBox(height: 24.h),
          _buildSizeRangeFilter(),
          SizedBox(height: 24.h),
          _buildClearFiltersButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: categories.map((category) {
            final isSelected = selectedCategory == category['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category['value'];
                });
                widget.onCategoryChanged?.call(category['value']);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'],
                      size: 16.sp,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      category['label'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rango de Fechas',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      label: 'Desde',
                      date: selectedDateRange?.start,
                      onTap: () => _selectDateRange(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildDateButton(
                      label: 'Hasta',
                      date: selectedDateRange?.end,
                      onTap: () => _selectDateRange(),
                    ),
                  ),
                ],
              ),
              if (selectedDateRange != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(child: Container()),
                    TextButton(
                      onPressed: _clearDateRange,
                      child: Text(
                        'Limpiar',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _buildQuickDateFilters(),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'Seleccionar',
              style: TextStyle(
                fontSize: 12.sp,
                color:
                    date != null ? AppTheme.textPrimary : AppTheme.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateFilters() {
    final quickFilters = [
      {'label': 'Hoy', 'days': 0},
      {'label': 'Esta semana', 'days': 7},
      {'label': 'Este mes', 'days': 30},
      {'label': '3 meses', 'days': 90},
    ];

    return Wrap(
      spacing: 6.w,
      children: quickFilters.map((filter) {
        return GestureDetector(
          onTap: () => _setQuickDateFilter(filter['days'] as int),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              filter['label'] as String,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tamaño del Archivo',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '${sizeRange.start.toInt()} - ${sizeRange.end.toInt()} MB',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        RangeSlider(
          values: sizeRange,
          min: 0,
          max: 50,
          divisions: 10,
          labels: RangeLabels(
            '${sizeRange.start.toInt()} MB',
            '${sizeRange.end.toInt()} MB',
          ),
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.primaryColor.withOpacity(0.3),
          onChanged: (values) {
            setState(() {
              sizeRange = values;
            });
          },
          onChangeEnd: (values) {
            widget.onSizeRangeChanged?.call(values.start, values.end);
          },
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _clearAllFilters,
        icon: const Icon(Icons.clear_all),
        label: const Text('Limpiar Filtros'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textSecondary,
          side: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      widget.onDateRangeChanged?.call(picked);
    }
  }

  void _setQuickDateFilter(int days) {
    final end = DateTime.now();
    final start = days == 0
        ? DateTime(end.year, end.month, end.day)
        : end.subtract(Duration(days: days));

    setState(() {
      selectedDateRange = DateTimeRange(start: start, end: end);
    });
    widget.onDateRangeChanged?.call(selectedDateRange);
  }

  void _clearDateRange() {
    setState(() {
      selectedDateRange = null;
    });
    widget.onDateRangeChanged?.call(null);
  }

  void _clearAllFilters() {
    setState(() {
      selectedCategory = 'all';
      selectedDateRange = null;
      sizeRange = const RangeValues(0, 50);
    });

    widget.onCategoryChanged?.call('all');
    widget.onDateRangeChanged?.call(null);
    widget.onSizeRangeChanged?.call(0, 50);
  }
}
