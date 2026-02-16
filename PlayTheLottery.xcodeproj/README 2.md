# PlayTheLottery

**PlayTheLottery** is a complete app for fans of the most popular Brazilian lottery games, such as Mega-Sena, Lotofácil, Quina, and Lotomania. It streamlines the process of generating bets, organizing favorite picks, checking draw history, and tracking upcoming contests—all in a modern, accessible, and responsive interface.

---

## Product Overview

### Core Features

- **Lottery Number Generator**  
  Instantly generate unique, valid, and randomized bets for Mega-Sena, Lotofácil, Quina, and Lotomania. Users can customize the amount of numbers according to each game’s official rules.

- **Favorites**  
  Mark any generated combination as a favorite for quick access and future reference.

- **Draw History**  
  Explore previous results by game and contest number, view the drawn numbers, contest details, and whether the jackpot rolled over.

- **Upcoming Contests**  
  Stay up to date with real-time info about the next draws, including estimated prizes, dates, and contest numbers. Users receive notifications about today's contests.

- **Easy Sharing**  
  Share generated bets directly via WhatsApp using a friendly, ready-to-send format.

---

## Target Audience

- Lottery players wanting to automate their betting process.
- Users tracking statistics, results, and prize estimates.
- People who wish to organize and revisit their favorite bets.

---

## Technical Details

- **SwiftUI-first UI**: Entire interface built with SwiftUI for high performance, fluid animations, and accessibility support.
- **MVVM architecture**: Clear separation of presentation and logic using Observable ViewModels.
- **Persistence**: UserDefaults is used for local cache and storing favorite number entries.
- **Networking**: Asynchronous HTTP requests to public APIs for real-time lottery results and contest data.
- **Local Notifications**: Daily reminders for upcoming draws and prizes.
- **Accessibility**: Dynamic Type, color/contrast adjustments, accessibility labeling, and VoiceOver support baked in.
- **Responsive/adaptive design**: Fully supports iPhone and iPad, adjusting layout and touch targets for any device.

---

## Screens and Navigation

- **SplashView**: Initial loading screen.
- **MainMenuView**: Main menu with navigation to Number Generator, Favorites, Draw History, and Upcoming Contests.
- **GeneratingNumbersView**: Customizable number generation, favoriting, and sharing.
- **FavoriteNumbersView**: List and manage saved favorite number sets.
- **HistoryView**: Search/filter and inspect past draw results.
- **NextContestsView**: See details for upcoming draws, estimated prizes, and notification scheduling.

---

## How does the Number Generator Work?

The user selects a game and, if desired, adjusts the number of bets (within each game’s official range). The algorithm generates unique numbers, sorts them, and displays them visually as “balls” for easier review and favoriting.

---

## Persistence and Caching

- Favorites and cached results are stored locally using UserDefaults.
- Contest results and prize estimates are refreshed as needed or when the local cache expires.
- All user interactions remain smooth and responsive, even with slow connections.

---

## APIs

Results, upcoming draws, and estimates are fetched from public endpoints (e.g. `https://api.guidi.dev.br/loteria/`).

---

## Extensibility

The modular SwiftUI architecture makes it easy to add new lottery games, new features (such as widgets, themes, or advanced statistics), or improve sharing channels.

---

## Example Usage

- **Generating a Bet:**  
  Select a lottery game from the menu, choose how many numbers to generate, tap to view the results, and optionally mark as favorite or share.
- **Viewing History:**  
  Use the Draw History tab to filter previous results by game or contest number.
- **Managing Favorites:**  
  Visit the Favorites section to see, organize, and delete your saved bets.

---

## Installation

1. **Requirements:**
   - Xcode 15 or later
   - iOS 16.0 or later

2. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/PlayTheLottery.git
