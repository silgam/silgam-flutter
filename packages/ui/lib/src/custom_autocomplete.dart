import 'package:flutter/material.dart';

class CustomAutocomplete<T extends Object> extends StatelessWidget {
  const CustomAutocomplete({
    super.key,
    required this.optionsBuilder,
    required this.fieldViewBuilder,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.onSelected,
    this.initialValue,
  });

  final AutocompleteOptionsBuilder<T> optionsBuilder;
  final AutocompleteFieldViewBuilder fieldViewBuilder;
  final AutocompleteOptionToString<T> displayStringForOption;
  final AutocompleteOnSelected<T>? onSelected;
  final TextEditingValue? initialValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<T>(
          optionsBuilder: optionsBuilder,
          fieldViewBuilder: fieldViewBuilder,
          displayStringForOption: displayStringForOption,
          onSelected: onSelected,
          initialValue: initialValue,
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxHeight: 200, maxWidth: constraints.maxWidth),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);

                    return ListTile(
                      title: Text(displayStringForOption(option)),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
