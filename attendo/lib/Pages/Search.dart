import 'package:flutter/material.dart';

class SearchFunctionality extends StatefulWidget {
  @override
  _SearchFunctionalityState createState() => _SearchFunctionalityState();
}

class _SearchFunctionalityState extends State<SearchFunctionality> {
  final List<String> items = [
    'Apple',
    'Banana',
    'Grapes',
    'Orange',
    'Pineapple',
    'Strawberry'
  ];

  String selectedQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SearchAnchor.bar(
          
          suggestionsBuilder: (context, controller) {
            // Filter items based on controller's query
            final query = controller.value.text;
            final suggestions = items
                .where(
                    (item) => item.toLowerCase().contains(query.toLowerCase()))
                .toList();

            // Map each suggestion to a ListTile
            return suggestions.map((suggestion) {
              return ListTile(
                title: Text(suggestion),
                onTap: () {
                  setState(() {
                    selectedQuery = suggestion;
                  });
                  controller.clear(); // Close search on selection
                },
              );
            });
          },
        ),
      ),
      body: Center(
        child: Text(
          selectedQuery.isEmpty
              ? 'No item selected'
              : 'Selected Item: $selectedQuery',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
