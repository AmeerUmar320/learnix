import 'package:flutter/material.dart';
import 'package:group_chat_app/screens/chat_bot.dart';

class SearchAssistantRow extends StatefulWidget {
  final int userId;
  const SearchAssistantRow({super.key, required this.userId});

  @override
  State<SearchAssistantRow> createState() => _SearchAssistantRowState();
}

class _SearchAssistantRowState extends State<SearchAssistantRow> {
  static const _searchFill  = Color.fromARGB(77, 118, 131, 131);
  static const _accentGreen = Color(0xFFB5FB67);

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const sideMargin = 16.0;
    const buttonSize = 48.0;
    const hitPadding = 16.0;
    const spacing    = 16.0;

    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        left: sideMargin,
        right: sideMargin,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final reservedWidth   = buttonSize + spacing;
          final searchWidth = _isSearching
              ? availableWidth - reservedWidth
              : buttonSize;

          Widget searchBox = AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: searchWidth,
            height: buttonSize,
            decoration: BoxDecoration(
              color: _isSearching ? Colors.white12 : _searchFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search groups...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                          });
                        },
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 48, minHeight: 48
                        ),
                      ),
                    ),
                    onSubmitted: (_) =>
                        setState(() => _isSearching = false),
                  )
                : const Center(
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          );

          if (!_isSearching) {
            searchBox = GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _isSearching = true),
              child: SizedBox(
                width: buttonSize + hitPadding,
                height: buttonSize + hitPadding,
                child: Center(child: searchBox),
              ),
            );
          }

          return Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                searchBox,
                if (!_isSearching) ...[
                  const SizedBox(width: spacing),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatbotScreen(userId: widget.userId),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: buttonSize + hitPadding,
                      height: buttonSize + hitPadding,
                      child: Center(
                        child: Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: _accentGreen, width: 2
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.assistant_rounded,
                            color: _accentGreen,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
