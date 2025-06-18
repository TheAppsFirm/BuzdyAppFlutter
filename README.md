# Buzdy

A comprehensive Flutter application that combines YouTube video downloading capabilities with cryptocurrency tracking, business directory features, and product discovery. Buzdy serves as an all-in-one platform for media consumption, financial market monitoring, and business exploration.

## 🚀 Features

### 📱 Core Functionality
- **Multi-tab Navigation**: Crypto tracking, Business directory, Products catalog, and YouTube feed
- **User Authentication**: Complete registration and login system with profile management
- **Responsive Design**: Optimized for both mobile and tablet devices

### 🎥 YouTube Integration
- **Built-in WebView** to browse YouTube seamlessly
- **Video Download**: Download highest quality muxed streams when available
- **Smart Merging**: Automatically merge separate video and audio streams using `ffmpeg_kit_flutter_new`
- **Progress Tracking**: Real-time download progress with visual indicators
- **Local Storage**: Videos saved in app directory with gallery export option
- **Video Management**: Comprehensive saved videos screen with bulk operations
- **Multi-format Support**: Handle various YouTube video formats and qualities

### 💰 Cryptocurrency Features
- **Live Market Data**: Real-time cryptocurrency prices and market information
- **Interactive Bubble Chart**: Innovative bubble visualization showing market performance
- **Advanced Filtering**: Filter by timeframe, market cap, rank, price changes, and more
- **Coin Analysis**: AI-powered investment analysis and security checks
- **TradingView Integration**: Professional charts with full-screen viewing
- **Market Insights**: Comprehensive coin details including performance metrics

### 🏢 Business Directory
- **Global Coverage**: Browse banks and merchants worldwide
- **Location-based Search**: Filter by country and city
- **Detailed Profiles**: Complete business information with images and contact details
- **Review System**: Rating and review functionality
- **Pagination Support**: Efficient loading of large datasets

### 🛍️ Product Catalog
- **Product Discovery**: Browse products from various merchants and banks
- **Category Filtering**: Filter by merchant type, bank products, etc.
- **Product Details**: Comprehensive product information with ratings
- **Image Gallery**: Carousel display of product images

## 🛠️ Technical Architecture

### State Management
- **Provider Pattern**: Centralized state management with `Provider`
- **MVVM Architecture**: Clean separation of concerns with ViewModels
- **Repository Pattern**: Abstracted data access layer

### Networking
- **RESTful API Integration**: Clean API service architecture with error handling
- **HTTP Client**: Custom implementation with comprehensive logging
- **Response Mapping**: Robust data model mapping with error handling

### Media & Storage
- **Video Processing**: YouTube video extraction and processing
- **FFmpeg Integration**: Video/audio merging capabilities
- **Local Storage**: Efficient file management system
- **Permission Handling**: Comprehensive permission management for media access

### UI/UX
- **Material Design 3**: Modern Material You design principles
- **Custom Components**: Reusable UI components and widgets
- **Animations**: Smooth transitions and micro-interactions
- **Responsive Layout**: Adaptive design for different screen sizes

## 📦 Key Dependencies

```yaml
dependencies:
  flutter: ^3.0.0
  provider: ^6.0.0
  get: ^4.6.0
  http: ^0.13.0
  
  # Media & Video
  youtube_explode_dart: ^2.0.2
  youtube_player_flutter: ^8.1.0
  video_player: ^2.8.0
  ffmpeg_kit_flutter_new: ^1.6.1
  video_thumbnail: ^0.5.0
  
  # Storage & Permissions
  path_provider: ^2.1.2
  permission_handler: ^11.3.0
  image_gallery_saver_plus: ^4.0.1
  shared_preferences: ^2.0.0
  
  # UI & Design
  flutter_inappwebview: ^5.8.0
  carousel_slider: ^4.2.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^2.7.0
  
  # Networking & Data
  dropdown_textfield: ^1.0.8
  google_fonts: ^6.1.0
  flutter_easyloading: ^3.0.5
  
  # Utils
  share_plus: ^7.0.0
  image_picker: ^1.0.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/buzdy.git
   cd buzdy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Platform-specific setup**

   **Android Configuration:**
   
   Add FFmpeg Maven repository in `android/build.gradle`:
   ```gradle
   allprojects {
       repositories {
           google()
           mavenCentral()
           maven { url 'https://artifacts.arthenica.com/release' }
       }
   }
   ```
   
   Add permissions in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
       android:maxSdkVersion="28" />
   <uses-permission android:name="android.permission.INTERNET" />
   ```

   **iOS Configuration:**
   
   Add permissions in `ios/Runner/Info.plist`:
   ```xml
   <key>NSPhotoLibraryAddUsageDescription</key>
   <string>This app needs access to save videos to your photo library.</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>This app needs access to your photo library to save videos.</string>
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration
Update the base API URL in `lib/network/network_api_services.dart`:
```dart
final String _baseUrl = "https://api.buzdy.com";
```

### YouTube API Keys
Configure YouTube API keys in the appropriate service files for full functionality.

### Environment Setup
Create environment-specific configurations for different deployment targets.

## 📱 App Structure

```
lib/
├── core/                   # Core utilities and constants
│   ├── colors.dart        # App color scheme
│   ├── text_styles.dart   # Typography definitions
│   ├── theme.dart         # App theme configuration
│   └── utils.dart         # Utility functions
├── data/                  # Data layer
│   ├── models/           # Data models
│   ├── network/          # Network services
│   └── repositories/     # Repository implementations
├── domain/               # Business logic layer
│   ├── entities/        # Domain entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
├── presentation/         # UI layer
│   ├── screens/         # App screens
│   ├── widgets/         # Reusable widgets
│   └── viewmodels/      # State management
├── services/            # External services
└── utils/               # Helper utilities
```

## 🎯 Key Features Deep Dive

### Video Download System
- **Smart Quality Selection**: Automatically selects highest available quality
- **Fallback Merging**: Uses FFmpeg when muxed streams aren't available
- **Progress Tracking**: Real-time download progress with percentage indicators
- **Gallery Integration**: Seamless saving to device gallery
- **Bulk Operations**: Select and manage multiple videos simultaneously

### Cryptocurrency Bubble Chart
- **Real-time Data**: Live market data from multiple sources
- **Interactive Visualization**: Touch-enabled bubble chart with zoom capabilities
- **Advanced Filtering**: Multiple filter options for precise market analysis
- **Performance Indicators**: Visual representation of price changes and market trends

### Business Directory
- **Global Search**: Search businesses by country, city, and type
- **Detailed Profiles**: Complete business information with contact details
- **Image Galleries**: Multiple images with carousel navigation
- **Review System**: User ratings and review functionality

## 🔍 Debugging Video Downloads

If video downloads fail, use the debug function to inspect available streams:

```dart
await VideoDownloader.debugAvailableStreams('YOUR_VIDEO_ID');
```

This prints comprehensive stream information to help diagnose issues with specific videos.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue in the GitHub repository
- Check the [documentation](docs/) for detailed guides
- Review the code examples in the repository

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- YouTube Explode Dart for video extraction capabilities
- FFmpeg team for video processing tools
- Material Design team for design guidelines
- Contributors and the open-source community

---

**Made with ❤️ using Flutter**
