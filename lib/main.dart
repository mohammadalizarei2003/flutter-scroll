import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لیست اسکرول‌پذیر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'customFont',
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: ScrollableListPage(),
      ),
    );
  }
}

class ScrollableListPage extends StatefulWidget {
  const ScrollableListPage({super.key});

  @override
  State<ScrollableListPage> createState() => _ScrollableListPageState();
}

class _ScrollableListPageState extends State<ScrollableListPage> {
  // Initialize a list with 20 initial items
  // Each item is named "آیتم اولیه" (Initial Item) followed by its index+1
  final List<String> _items = List.generate(
    20,
    (index) => 'آیتم اولیه ${index + 1}',
  );

  // Create a Random number generator for generating random items/positions
  final Random _random = Random();

  // Create a scroll controller to manage the ListView's scroll position
  final ScrollController _scrollController = ScrollController();

  // Boolean flag to track if auto-scroll is enabled (default false)
  bool _autoScroll = false;

  // Variable to store the index of the last added item (nullable)
  int? _lastAddedIndex;

  // Function to add a new item to the list
  void _addItem() {
    // Generate a new item with random number (0-999)
    final newItem = 'آیتم جدید ${_random.nextInt(1000)}';
    int insertIndex;

    // Determine insertion position - random index if list not empty
    if (_items.isEmpty) {
      insertIndex = 0;
    } else {
      insertIndex = _random.nextInt(_items.length);
    }

    // Save current scroll position before adding new item
    final double previousScrollOffset = _scrollController.offset;
    // Save maximum scroll extent before adding new item
    final double previousMaxScrollExtent =
        _scrollController.position.maxScrollExtent;

    // Update state - insert new item and record its index
    setState(() {
      _items.insert(insertIndex, newItem);
      _lastAddedIndex = insertIndex;
    });

    // Handle scroll behavior based on auto-scroll setting
    if (_autoScroll) {
      // Auto-scroll enabled - scroll to new item's position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Calculate target scroll position (72px per item)
        final double newOffset = insertIndex * 72.0;
        // Animate scroll to new position (clamped to valid range)
        _scrollController.animateTo(
          newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      // Auto-scroll disabled - maintain scroll position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Get new max scroll extent after item addition
        final double newMaxScrollExtent =
            _scrollController.position.maxScrollExtent;
        // Calculate difference in scrollable area
        final double delta = newMaxScrollExtent - previousMaxScrollExtent;
        // Calculate new scroll position:
        // If new item was inserted above visible area, adjust by item height (72px)
        // Otherwise maintain same visual position
        final double newOffset =
            previousScrollOffset +
            (insertIndex <= (_scrollController.offset / 72.0).floor()
                ? 72.0
                : 0);

        // Jump to new position (clamped to valid range)
        _scrollController.jumpTo(newOffset.clamp(0.0, newMaxScrollExtent));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar with title styled using theme
      appBar: AppBar(
        title: Text(
          'لیست اسکرول‌پذیر',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),

      // Main body content with padding
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Control row containing buttons and info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add Item button with custom styling
                ElevatedButton(
                  onPressed: _addItem, // Calls the add item function
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.deepPurple, // Purple background
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners
                      ),
                    ),
                  ),
                  child: Text(
                    'افزودن', // 'Add' in Persian
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text
                    ),
                  ),
                ),

                // Auto-scroll toggle row
                Row(
                  children: [
                    Text(
                      'اسکرول خودکار',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Checkbox(
                      value: _autoScroll,
                      onChanged: (value) {
                        setState(() {
                          _autoScroll = value!; // Toggle auto-scroll state
                        });
                      },
                    ),
                  ],
                ),

                // Item count display
                Text(
                  'تعداد: ${_items.length}', // 'Count: X' in Persian
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Notification when new item is added (only shown when not auto-scrolling)
            if (!_autoScroll && _lastAddedIndex != null)
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Text(
                  'آیتم جدید در موقعیت ${_lastAddedIndex! + 1} اضافه شد',
                  // 'New item added at position X'
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple, // Green success message
                  ),
                ),
              ),

            Divider(),
            // Horizontal divider line

            // The scrollable list area
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // Connect scroll controller
                padding: EdgeInsets.symmetric(vertical: 20), // Vertical padding
                itemCount: _items.length, // Number of items
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    // Item spacing
                    padding: EdgeInsets.all(10),
                    // Inner padding
                    height: 72,
                    // Fixed height for each item
                    decoration: BoxDecoration(
                      color:
                          _lastAddedIndex == index
                              ? Colors
                                  .deepPurple
                                  .shade400 // Highlight new items
                              : Colors.deepPurple.shade50, // Normal color
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Rounded corners
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Item text
                        Text(
                          _items[index],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                _lastAddedIndex == index
                                    ? Colors
                                        .white // White text for highlighted items
                                    : Colors.black, // Black text otherwise
                          ),
                        ),

                        Text(
                          'موقعیت : ${index + 1}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                _lastAddedIndex == index
                                    ? Colors
                                        .white // White text for highlighted items
                                    : Colors.black, // Black text otherwise
                          ),
                        ),
                        // Empty space if not new item
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
