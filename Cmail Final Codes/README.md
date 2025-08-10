# 📧 CMail - Native iOS Email Generator

A professional email generator app for academic cold emails to professors, built with Swift and SwiftUI. This native iOS app helps students create personalized, professional emails for research opportunities, internships, and academic collaborations.

## 🎯 **Features**

- ✅ **Email Generator**: Create personalized cold emails with customizable fields
- ✅ **Writing Styles**: Add your own email examples to train the AI on your writing style
- ✅ **Saved Emails**: Store and manage your generated emails
- ✅ **Native iOS**: Built with Swift and SwiftUI for optimal performance
- ✅ **Dark Theme**: Professional dark UI with modern design
- ✅ **Real AI Integration**: Uses your Gemini API key for personalized email generation

## 🔑 **Your API Configuration**

Your Gemini API key is already configured:
- **API Key**: `AIzaSyC22BwxkjtNnTqjD4P79XIADPn5KkG13EY`
- **Model**: Gemini 1.5 Flash
- **Status**: ✅ Ready to use

## 📱 **App Screens**

### **1. Email Generator**
- Fill in professor details (name, university, lab)
- Add research topic and opportunity type
- Include project details if applicable
- Describe the email purpose
- Generate personalized emails with real AI

### **2. Writing Styles**
- Add 5-30 examples of your past emails
- The AI learns your writing style from these examples
- More examples = better personalized results
- Edit or remove examples as needed

### **3. Saved Emails**
- Save emails you like for future use
- Edit saved emails directly in the app
- Delete emails you no longer need
- All data persists locally

## 🚀 **How to Run**

### **In Xcode:**
1. **Open the project**: Double-click `CMail.xcodeproj`
2. **Select your device**: Choose iPhone simulator or your device
3. **Build and Run**: Press ⌘+R or click the Play button
4. **Test the app**: All features are ready to use

### **On Your iPhone:**
1. **Connect your iPhone** to your Mac
2. **Select your device** in Xcode
3. **Build and Run** (⌘+R)
4. **Trust the developer** on your iPhone if prompted

## 🏗️ **Project Structure**

```
CMail/
├── CMail/
│   ├── CMailApp.swift              # Main app entry point
│   ├── ContentView.swift           # Main tab navigation
│   ├── EmailGeneratorView.swift    # Email creation form
│   ├── WritingStylesView.swift     # Writing style management
│   ├── SavedEmailsView.swift       # Saved emails view
│   ├── GeminiService.swift         # AI integration (your API key)
│   ├── Models.swift                # Data models
│   ├── Stores.swift                # Data management
│   └── Assets.xcassets            # App icons and images
├── CMail.xcodeproj                # Xcode project file
└── README.md                      # This file
```

## 🎨 **Design Features**

- **Native iOS**: Built with Swift and SwiftUI
- **Dark Theme**: Professional dark UI with blue accents
- **Touch Optimized**: Native iOS interactions
- **Responsive Design**: Works on all iPhone sizes
- **Accessibility**: Full VoiceOver support

## 🔧 **Technical Details**

### **Architecture**
- **Frontend**: SwiftUI with native iOS components
- **Navigation**: TabView with NavigationView
- **Storage**: UserDefaults for local data persistence
- **Networking**: URLSession for API calls
- **State Management**: ObservableObject with @Published

### **Key Features**
- **Real AI Integration**: Uses your Gemini API key
- **Async/Await**: Modern Swift concurrency
- **Error Handling**: Comprehensive error messages
- **Loading States**: Native iOS activity indicators
- **Form Validation**: Input validation and error handling

## 📊 **Usage Guide**

### **Getting Started**
1. **Open in Xcode**: Double-click `CMail.xcodeproj`
2. **Build and Run**: Press ⌘+R
3. **Add writing styles**: Add 5-30 email examples
4. **Generate emails**: Fill form and generate personalized emails

### **Email Generation Process**
1. Fill in professor details (optional)
2. Add research topic and opportunity type
3. Include project details if available
4. Describe the email purpose
5. Click "Generate Email" for AI-powered content
6. Save or copy the generated email

### **Writing Style Training**
1. Go to "Writing Styles" tab
2. Add examples of your past emails
3. The AI learns your writing style
4. Generate emails that match your tone
5. More examples = better results

## 🎯 **API Integration**

Your app uses the Gemini API with:
- **Model**: Gemini 1.5 Flash
- **System Instructions**: Custom prompts for email generation
- **Writing Style Learning**: AI adapts to your examples
- **Error Handling**: Graceful API error handling

## 🚨 **Troubleshooting**

### **If the app doesn't build:**
1. **Check Xcode version**: Use Xcode 15 or later
2. **Check iOS version**: Target iOS 16.0 or later
3. **Clean build folder**: Product → Clean Build Folder
4. **Restart Xcode**: Close and reopen Xcode

### **If API calls fail:**
1. **Check internet**: Ensure you have internet connection
2. **Check API key**: Verify the API key is correct
3. **Check quota**: Free tier has usage limits
4. **Wait and retry**: API might be temporarily unavailable

### **If data doesn't persist:**
1. **Check permissions**: App needs UserDefaults access
2. **Restart app**: Close and reopen the app
3. **Check storage**: Ensure device has enough storage

## 🎉 **Ready to Use**

Your native iOS CMail app is now complete with:
- ✅ **Real AI integration** with your API key
- ✅ **Native iOS performance** with Swift and SwiftUI
- ✅ **All original features** from your web app
- ✅ **Professional UI** with dark theme
- ✅ **Local data storage** for writing styles and saved emails

**Next Steps:**
1. Open the project in Xcode
2. Build and run on your device
3. Add your writing style examples
4. Generate your first AI-powered email
5. Enjoy your personalized email generator!

The app will work seamlessly on your iPhone, providing a native experience while maintaining all the functionality you built in your web version.

## 📞 **Support**

For issues and questions:
1. Check the troubleshooting section above
2. Ensure your API key is working
3. Verify Xcode and iOS versions
4. Test on different devices if needed

---

**Built with ❤️ using Swift, SwiftUI, and Gemini AI** 