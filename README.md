# Recipeasy

Recipeasy is a SwiftUI-based iOS recipe management app that combines the best of traditional recipe organization with modern AI capabilities. Built with a focus on user experience and data privacy, it empowers home cooks to create, manage, and share their culinary adventures.

## Philosophy

I built Recipeasy out of a desire to bridge the gap between traditional recipe management and modern AI capabilities. While there are many recipe apps available, I found that most either focus too heavily on social features or treat AI as a gimmick rather than a thoughtful assistant.

The core principles that guide Recipeasy's development:

- **Privacy First**: Your recipes are yours. All data is stored locally using SwiftData, and AI features are optional.
- **Thoughtful AI Integration**: AI isn't just a buzzword - it's a tool that should genuinely enhance the cooking experience.
- **Focused User Experience**: Every feature serves a purpose. No social feeds, no ads, just cooking.
- **Open Source Community**: By making Recipeasy open source, we can build a community of food lovers who code.

## Features

### Core Functionality
- Create and manage recipes with detailed ingredients and steps
- Add photos to recipes and individual cooking steps
- Track cooking times and step durations
- Mark recipe difficulty levels
- Document your cooking attempts with photos and notes

### AI Integration
- Generate complete recipes from text descriptions
- Import recipes from websites automatically
- Smart ingredient parsing and step organization
- Optional - use your own OpenAI API key or subscribe for integrated service

### Technical Highlights
- SwiftData for robust local data management
- Widget support for random recipe suggestions
- Deep linking support for recipe sharing
- Print-friendly recipe formatting
- Dynamic UI with dark mode support

## Getting Started

### Prerequisites
- Xcode 16.0+
- iOS 18.0+
- Swift 6.0+
- Optional: OpenAI API key for AI features

### Installation

1. Clone the repository
```bash
git clone https://github.com/simonerlic/recipeasy.git
```

2. Open the project in Xcode
```bash
cd recipeasy
open Recipeasy.xcodeproj
```

3. Set up your signing certificate in Xcode

4. If using AI features, add your OpenAI API key:
   - Create a new file called `Config.xcconfig`
   - Add your API key: `OPENAI_API_KEY = your_api_key_here`
   - Or use the in-app subscription service

5. Build and run!

## Contributing

I welcome contributions of all kinds! Whether you're fixing bugs, improving documentation, or proposing new features, here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow SwiftUI best practices
- Maintain code documentation
- Keep the UI consistent with existing design
- Consider accessibility in all changes

## License

This project is licensed under the Mozilla Public License 2.0 - see the LICENSE file for details.

## Acknowledgments

- Thanks to the SwiftUI and SwiftData teams for the amazing frameworks
- OpenAI for their powerful API
- The open source community for inspiration and support
- All contributors who help make Recipeasy better

## Support

If you enjoy using Recipeasy or find the code helpful, consider:
- Starring the repository
- Reporting bugs
- Suggesting new features
- Contributing to the codebase

---

Built with ❤️ by Simon
