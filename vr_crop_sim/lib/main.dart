import 'package:flutter/material.dart';
import 'package:vr_crop_sim/services/crop_services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController _controller;
  String _htmlContent = "";
  final Color backgroundBlack = const Color(0xFF121212);
  final Color cardBlack = const Color(0xFF1E1E1E);
  final TextEditingController moistureController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController sunlightController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();
  final TextEditingController soilPHController = TextEditingController();
  final TextEditingController spacingController = TextEditingController();
  final TextEditingController biomassController = TextEditingController();
  final TextEditingController leafAreaIndexController = TextEditingController();
  final TextEditingController nitrogenController = TextEditingController();
  final TextEditingController phosphorusController = TextEditingController();
  final TextEditingController potassiumController = TextEditingController();
  final TextEditingController windSpeedController = TextEditingController();
  String selectedSoilType = "Loamy";
  String selectedCropType = "Wheat";
  String selectedGrowthStage = "Seedling";
  final CropServices _cropServices = CropServices();
  String? errorMessage;
  String? growthStage;
  double? predictedYield;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            print("WebView error: ${error.description}");
            setState(() {
              errorMessage = "WebView error: ${error.description}";
            });
          },
        ),
      );
    _loadHtmlFromAssets();
  }

  @override
  void dispose() {
    moistureController.dispose();
    tempController.dispose();
    sunlightController.dispose();
    humidityController.dispose();
    rainfallController.dispose();
    soilPHController.dispose();
    spacingController.dispose();
    biomassController.dispose();
    leafAreaIndexController.dispose();
    nitrogenController.dispose();
    phosphorusController.dispose();
    potassiumController.dispose();
    windSpeedController.dispose();
    super.dispose();
  }

  Future<void> _loadHtmlFromAssets() async {
    try {
      String fileText = await rootBundle.loadString('assets/vr_crop.html');
      setState(() {
        _htmlContent = fileText;
        _controller.loadHtmlString(_htmlContent);
        print("Loaded HTML content: ${fileText.substring(0, 100)}...");
      });
    } catch (e) {
      print("❌ Error Loading HTML File: $e");
      setState(() {
        errorMessage = "Failed to load VR simulation: $e";
      });
    }
  }

  void _sendDataToWebView(Map<String, dynamic> data) {
    print("Test");
    try {
      final jsonData = jsonEncode(data);
      // Escape quotes to ensure valid JavaScript string
      final escapedJsonData = jsonData.replaceAll('"', '\\"');
      print("Sending to WebView: $jsonData");
      // Send as a stringified JSON
      _controller.runJavaScript('window.postMessage("$escapedJsonData", "*");');
    } catch (e) {
      print("Error sending data to WebView: $e");
      setState(() {
        errorMessage = "Failed to send data to WebView: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: Scaffold(
        backgroundColor: backgroundBlack,
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Card(
                  color: cardBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "VR Crop Simulation",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 24),
                            ),
                            Text(
                              "Interactive VR environment.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 500,
                            child: _htmlContent.isEmpty
                                ? const Center(child: CircularProgressIndicator())
                                : WebViewWidget(controller: _controller),
                          ),
                        ),
                      ),
                      // Results Container
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Simulation Results",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    growthStage != null
                                        ? "Growth Stage: $growthStage"
                                        : "Growth Stage: Not calculated",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    predictedYield != null
                                        ? "Predicted Yield: ${predictedYield!.toStringAsFixed(2)} kg"
                                        : "Predicted Yield: Not calculated",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 3,
                child: Card(
                  color: cardBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Crop Growth Details",
                        style: TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Enter required values.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                ),
                ExpansionTile(
                  title: Text("Enter Crop Growth Details", style: TextStyle(color: Colors.white)),
                  iconColor: Colors.white,
                  collapsedIconColor: Colors.white,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 224,
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                        TextField(
                        controller: moistureController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Soil Moisture (%)',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter moisture level',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Soil moisture percentage required for growth.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: tempController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Temperature (°C)',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter temperature',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Optimal temperature for crop growth.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: sunlightController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Sunlight Hours',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter hours of sunlight',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Amount of daily sunlight exposure.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: humidityController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Humidity (%)',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter humidity level',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Humidity affects transpiration & crop health.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: rainfallController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Rainfall (mm/week)',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter rainfall amount',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Weekly rainfall determines soil moisture.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedSoilType,
                        decoration: InputDecoration(
                          labelText: "Soil Type",
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        dropdownColor: Colors.black,
                        items: const [
                          DropdownMenuItem(value: 'Clay', child: Text('Clay', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Sandy', child: Text('Sandy', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Loamy', child: Text('Loamy', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Peaty', child: Text('Peaty', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSoilType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: soilPHController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Soil pH Level',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter pH value',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Soil pH affects nutrient availability.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedCropType,
                        decoration: InputDecoration(
                          labelText: "Crop Type",
                          labelStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        dropdownColor: Colors.black,
                        items: const [
                          DropdownMenuItem(value: 'Wheat', child: Text('Wheat', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Rice', child: Text('Rice', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Maize', child: Text('Maize', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Barley', child: Text('Barley', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'Soybean', child: Text('Soybean', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCropType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: spacingController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Spacing Between Plants (cm)',
                          labelStyle: const TextStyle(color: Colors.white),
                          hintText: 'Enter spacing',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          helperText: 'Affects competition for resources.',
                          helperStyle: TextStyle(color: Colors.grey.shade300),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                      controller: biomassController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Biomass (kg/m²)',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter biomass (optional)',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        helperText: 'Crop biomass for yield prediction.',
                        helperStyle: TextStyle(color: Colors.grey.shade300),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: leafAreaIndexController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Leaf Area Index',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter leaf area index (optional)',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        helperText: 'Leaf area for yield prediction.',
                        helperStyle: TextStyle(color: Colors.grey.shade300),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nitrogenController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Nitrogen (ppm)',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter nitrogen level',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        helperText: 'Nitrogen content in soil.',
                        helperStyle: TextStyle(color: Colors.grey.shade300),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phosphorusController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Phosphorus (ppm)',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter phosphorus level',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        helperText: 'Phosphorus content in soil.',
                        helperStyle: TextStyle(color: Colors.grey.shade300),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: potassiumController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Potassium (ppm)',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter potassium level',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        helperText: 'Potassium content in soil.',
                        helperStyle: TextStyle(color: Colors.grey.shade300),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: windSpeedController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Wind Speed (m/s)',
                        labelStyle: const TextStyle(color: Colors.white),
                        hintText: 'Enter wind speed',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        helperText: 'Wind speed affecting crop growth.',
                        helperStyle: TextStyle(color: Colors.grey.shade300),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          errorMessage = null;
                          growthStage = null;
                          predictedYield = null;
                        });

                        // Validate required fields
                        if (tempController.text.isEmpty ||
                            humidityController.text.isEmpty ||
                            soilPHController.text.isEmpty ||
                            nitrogenController.text.isEmpty ||
                            phosphorusController.text.isEmpty ||
                            potassiumController.text.isEmpty ||
                            windSpeedController.text.isEmpty) {
                          setState(() {
                            errorMessage = "Please fill all required fields.";
                          });
                          return;
                        }

                        try {
                          // Validate numeric inputs
                          double.parse(tempController.text);
                          double.parse(humidityController.text);
                          double.parse(soilPHController.text);
                          double.parse(nitrogenController.text);
                          double.parse(phosphorusController.text);
                          double.parse(potassiumController.text);
                          double.parse(windSpeedController.text);
                          if (moistureController.text.isNotEmpty) double.parse(moistureController.text);
                          if (sunlightController.text.isNotEmpty) double.parse(sunlightController.text);
                          if (rainfallController.text.isNotEmpty) double.parse(rainfallController.text);
                          if (spacingController.text.isNotEmpty) double.parse(spacingController.text);
                          if (biomassController.text.isNotEmpty) double.parse(biomassController.text);
                          if (leafAreaIndexController.text.isNotEmpty) double.parse(leafAreaIndexController.text);
                        } catch (e) {
                          setState(() {
                            errorMessage = "Invalid numeric input: $e";
                          });
                          return;
                        }

                        try {
                          // Set today's date for planting_date
                          final today = DateTime.now();
                          final plantingDate =
                              "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

                          final data = {
                            'crop_type': selectedCropType,
                            'soil_type': selectedSoilType,
                            'planting_date': plantingDate,
                            'N': nitrogenController.text.isNotEmpty ? double.parse(nitrogenController.text) : 0.0,
                            'P': phosphorusController.text.isNotEmpty ? double.parse(phosphorusController.text) : 0.0,
                            'K': potassiumController.text.isNotEmpty ? double.parse(potassiumController.text) : 0.0,
                            'Temperature': tempController.text.isNotEmpty ? double.parse(tempController.text) : 0.0,
                            'Humidity': humidityController.text.isNotEmpty ? double.parse(humidityController.text) : 0.0,
                            'Wind_Speed': windSpeedController.text.isNotEmpty ? double.parse(windSpeedController.text) : 0.0,
                            'Soil_pH': soilPHController.text.isNotEmpty ? double.parse(soilPHController.text) : 0.0,
                            'moisture': moistureController.text.isNotEmpty ? double.parse(moistureController.text) : null,
                            'sunlight': sunlightController.text.isNotEmpty ? double.parse(sunlightController.text) : 0.0,
                            'rainfall': rainfallController.text.isNotEmpty ? double.parse(rainfallController.text) : 0.0,
                            'spacing': spacingController.text.isNotEmpty ? double.parse(spacingController.text) : 1.0,
                            'biomass': biomassController.text.isNotEmpty ? double.parse(biomassController.text) : null,
                            'leaf_area_index': leafAreaIndexController.text.isNotEmpty ? double.parse(leafAreaIndexController.text) : null,
                            'growth_stage': selectedGrowthStage,
                          };

                          // Call predictGrowth
                          final predictedGrowthStage = await _cropServices.predictGrowth(
                            moisture: data['moisture'] as double,
                            temperature: data['Temperature'] as double,
                            sunlight: data['sunlight'] as double,
                            humidity: data['Humidity'] as double,
                            rainfall: data['rainfall'] as double,
                            soilPh: data['Soil_pH'] as double,
                            soilType: data['soil_type'] as String,
                            cropType: data['crop_type'] as String,
                            growthStage: data['growth_stage'] as String,
                            plantingDate: data['planting_date'] as String,
                          );

                          // Call predictYield
                          final yieldPrediction = await _cropServices.predictYield(
                            temperature: data['Temperature'] as double,
                            cropType: data['crop_type'] as String,
                            soilType: data['soil_type'] as String,
                            plantingDate: data['planting_date'] as String,
                            nitrogen: data['N'] as double,
                            phosphorus: data['P'] as double,
                            potassium: data['K'] as double,
                            humidity: data['Humidity'] as double,
                            windSpeed: data['Wind_Speed'] as double,
                            soilPh: data['Soil_pH'] as double,
                            biomass: data['biomass'] as double?,
                            leafAreaIndex: data['leaf_area_index'] as double?,
                          );

                          // Update data with predictions
                          data['growth_stage'] = predictedGrowthStage;
                          data['predicted_yield'] = yieldPrediction;

                          // Update state for display
                          setState(() {
                            growthStage = predictedGrowthStage;
                            predictedYield = yieldPrediction;
                          });

                          // Send data to WebView
                          _sendDataToWebView(data);

                        } catch (e) {
                          print("API error: $e");
                          setState(() {
                            errorMessage = "Error: $e";
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: const Text("Calculate"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    ),
    ],
    ),
    ),
    ),
    );
  }
}