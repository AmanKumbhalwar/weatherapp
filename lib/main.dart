import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      home: WeatherApp(),
    );
  }
}

IconData getWeatherIcon(double temperature) {
  if (temperature >= 25.0) {
    return Icons.wb_sunny; // Hot and sunny
  } else if (temperature >= 10.0) {
    return Icons.wb_cloudy; // Cloudy
  } else {
    return Icons.ac_unit; // Cold or snow
  }
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String cityName = '';
  double temperature = 0.0;
  String description = '';

  // Function to fetch weather data
  Future<void> fetchWeatherData() async {
    final Uri uri = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=${dotenv.env['API_KEY']}',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        temperature = (data['main']['temp'] - 273.15);
        description = data['weather'][0]['description'];
      });
    } else {
      print('API Request Failed with Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Stack(
        children: [
          // Background Image (Replace with your background image)
          Image.asset(
            'assets/Weather.jpeg', // Replace with your background image path
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Container for UI Elements
          Container(
            color: Colors.transparent, // Transparent background
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Text Input for City Name
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter a city name',
                            contentPadding: EdgeInsets.all(16.0),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.7),
                          ),
                          onChanged: (value) {
                            setState(() {
                              cityName = value;
                            });
                          },
                        ),
                        // Elevated Button to Fetch Weather
                        ElevatedButton(
                          onPressed: () {
                            fetchWeatherData();
                          },
                          child: Text('Get Weather'),
                        ),
                        // Weather Card
                        Card(
                          elevation: 4.0, // Add shadow to the card
                          margin: EdgeInsets.all(
                              16.0), // Add spacing around the card
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  getWeatherIcon(
                                      temperature), // Use the function to determine the icon
                                  size: 48.0,
                                ),
                                SizedBox(
                                    height:
                                        16.0), // Add spacing between the icon and text
                                Text(
                                  'Temperature: ${temperature.toStringAsFixed(2)}°C',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight:
                                        FontWeight.bold, // Customize text style
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        8.0), // Add spacing between text lines
                                Text(
                                  'Description: $description',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontStyle: FontStyle
                                        .italic, // Customize text style
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
