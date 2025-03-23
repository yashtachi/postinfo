import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class AIChatScreen extends StatefulWidget {
  @override
  _AIChatScreenState createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  late AnimationController _typingAnimController;

  // Gemini API key
  final String apiKey = "AIzaSyB3VwYeAKY6FNM-9YEtk13HiV4vkHIeyyU";

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
      reverseDuration: Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Add initial bot message
    _addBotMessage(
        "Hello! I'm your India Post assistant. How can I help you today? You can ask me about tracking your package, postal services, or general inquiries.");
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  // Method to add a user message
  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    // Scroll to the bottom
    _scrollToBottom();

    // Call Gemini AI API
    _getAIResponse(message);
  }

  // Method to add a bot message
  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
    });

    // Scroll to the bottom
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Add a small delay to ensure the list view has been updated
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Method to get response from Gemini AI API
  Future<void> _getAIResponse(String prompt) async {
    try {
      // Format the prompt for post-related context
      String contextualPrompt =
          "You are an AI assistant for India Post. You help users with tracking packages, answering questions about postal services, and general inquiries. The user asks: $prompt";

      // Try to use the Gemini API
      try {
        // Gemini API endpoint
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey');

        // Request body
        final body = jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": contextualPrompt}
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.7,
            "topK": 40,
            "topP": 0.95,
            "maxOutputTokens": 1024,
          }
        });

        // Make the API call
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          // Parse the response
          final data = jsonDecode(response.body);

          // Extract the generated text from the complex response structure
          String responseText = data['candidates'][0]['content']['parts'][0]
                  ['text'] ??
              "I'm having trouble understanding that. Can you please rephrase your question?";

          // Add the bot's response to the chat
          _addBotMessage(responseText);
          return; // Exit the method after successful API call
        } else {
          print(
              'Error from Gemini API: ${response.statusCode} - ${response.body}');
          // Continue to fallback responses
        }
      } catch (e) {
        print('Exception when calling Gemini API: $e');
        // Continue to fallback responses
      }

      // Fallback for when API fails or no internet
      String response = _getFallbackResponse(prompt);
      _addBotMessage(response);
    } catch (e) {
      print('Exception in _getAIResponse: $e');
      _addBotMessage(
          "I'm having some technical difficulties right now. Please try again later.");
    }
  }

  // Provide fallback responses for common questions
  String _getFallbackResponse(String prompt) {
    prompt = prompt.toLowerCase();

    if (prompt.contains('track') && prompt.contains('package')) {
      return "To track your package, you'll need a tracking number. You can enter it on the tracking screen or provide it to me directly. For Hyderabad and Telangana shipments, tracking typically updates within 24 hours.";
    } else if (prompt.contains('office') &&
        (prompt.contains('hour') || prompt.contains('time'))) {
      return "Most post offices in Hyderabad and Telangana are open from 8:00 AM to 5:30 PM Monday through Friday, and 9:00 AM to 1:00 PM on Saturdays. Specific hours may vary by location.";
    } else if (prompt.contains('rate') ||
        prompt.contains('cost') ||
        prompt.contains('price')) {
      return "Shipping rates depend on weight, destination, and service type. For local shipments within Hyderabad, rates start at ₹20 for letters and ₹40 for parcels up to 500g. For detailed pricing, please visit our website or your local post office.";
    } else if (prompt.contains('service') || prompt.contains('offer')) {
      return "India Post offers a wide range of services including letter delivery, parcel shipping, money orders, speed post, insurance, and more. In Hyderabad and Telangana, we also offer specialized regional services for local businesses.";
    } else if (prompt.contains('hyderabad') || prompt.contains('telangana')) {
      return "We have over 100 post offices throughout Hyderabad and 500+ across Telangana. Our Hyderabad GPO is located at Abids Road and serves as the main hub for the entire state.";
    } else if (prompt.contains('delivery') && prompt.contains('time')) {
      return "Delivery times vary by service type. Within Hyderabad, same-day delivery is available for premium services. Standard delivery within Telangana takes 1-2 business days, and nationwide delivery takes 3-7 business days depending on the destination.";
    } else if (prompt.contains('complaint') || prompt.contains('problem')) {
      return "I'm sorry to hear you're experiencing issues. You can file a complaint through our app's complaint section, visit your local post office, or call our customer service at 1800-XXX-XXXX. For Hyderabad-specific issues, you can also contact the regional office at 040-XXXXXXXX.";
    } else if (prompt.contains('hello') ||
        prompt.contains('hi') ||
        prompt == "hey") {
      return "Hello! How can I assist you with India Post services today? I can help with tracking, finding post offices in Hyderabad and Telangana, or answering questions about our services.";
    } else {
      return "I don't have specific information about that. For assistance with India Post services in Hyderabad and Telangana, please call our customer service at 1800-XXX-XXXX or visit your local post office.";
    }
  }

  void _handleSubmit(String text) {
    _textController.clear();
    if (text.trim().isNotEmpty) {
      _addUserMessage(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.support_agent,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat history
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildMessage(message);
                },
              ),
            ),
          ),

          // Bot is typing indicator
          if (_isTyping)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(),
                        _buildTypingDot(),
                        _buildTypingDot(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Text input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, -1),
                  blurRadius: 5,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                // Input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleSubmit,
                    ),
                  ),
                ),

                // Send button
                Container(
                  margin: EdgeInsets.only(left: 4.0),
                  child: FloatingActionButton(
                    onPressed: () => _handleSubmit(_textController.text),
                    child: Icon(Icons.send),
                    backgroundColor: Colors.deepOrange,
                    elevation: 0,
                    mini: true,
                  ),
                ),
              ],
            ),
          ),

          // Suggestion chips
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildSuggestionChip('Track my package'),
                _buildSuggestionChip('Post offices in Hyderabad'),
                _buildSuggestionChip('Shipping rates in Telangana'),
                _buildSuggestionChip('Delivery times'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                color: Colors.grey,
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/home'),
                tooltip: 'Home',
              ),
              IconButton(
                icon: Icon(Icons.track_changes),
                color: Colors.grey,
                onPressed: () => Navigator.of(context).pushNamed('/tracking'),
                tooltip: 'Track',
              ),
              SizedBox(width: 40), // Space for FAB
              IconButton(
                icon: Icon(Icons.dashboard),
                color: Colors.grey,
                onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
                tooltip: 'Dashboard',
              ),
              IconButton(
                icon: Icon(Icons.person),
                color: Colors.grey,
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                tooltip: 'Profile',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.chat),
        onPressed: () {},
        tooltip: 'Chat with Assistant',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTypingDot() {
    return AnimatedBuilder(
      animation: _typingAnimController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.grey.shade200,
      onPressed: () => _handleSubmit(text),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    const userColor = Colors.deepOrange;
    const botColor = Colors.grey;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: Colors.deepOrange.shade100,
              child: Icon(
                Icons.support_agent,
                color: Colors.deepOrange,
                size: 20,
              ),
            ),

          SizedBox(width: 8),

          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? userColor.withOpacity(0.1)
                    : botColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 8),

          if (message.isUser)
            CircleAvatar(
              backgroundColor: Colors.deepOrange.shade400,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
