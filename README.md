# Laborator 3 PAM: Fitness App cu Cubit și date JSON

Aplicația din Lab 2 (designul Figma), refăcută pe date încărcate asincron dintr-un fișier JSON,
cu state management prin **Cubit** (`flutter_bloc`).

## Rulare

```
flutter pub get
flutter run            # emulator/telefon
flutter test           # 45 de teste
```

Demonstrarea stării **Error** în aplicație (asset inexistent):

```
flutter run --dart-define=DATA_ASSET=assets/data/missing.json
```

Starea **Empty** apare la filtrele Pilates/Boxing, la o căutare fără rezultat sau la filtrul
„doar favorite” fără favorite.

## Cerințe și unde sunt implementate

| Cerință | Implementare |
|---|---|
| State management | `flutter_bloc` (Cubit): `HomeCubit`, `GymCubit`, `FavoritesCubit` în `lib/cubits/` |
| JSON inclus în proiect | `assets/data/lab_v3.json` (fișierul primit, nemodificat) |
| Încărcare asincronă | `JsonFitnessRepository`: `rootBundle.loadString` (cu o întârziere de 800 ms care simulează rețeaua) |
| Prelucrare asincronă | `jsonDecode` + `fromJson` rulează prin `compute()` într-un isolate separat (pe Android/iOS; pe web, `compute` rulează pe același fir), ca să nu blocheze UI-ul |
| Stări Loading / Success / Empty / Error | `HomeLoading`, `HomeSuccess`, `HomeEmpty`, `HomeError` (`lib/cubits/home/home_state.dart`) |
| Listă de elemente | grila de programe de antrenament (`ProgramCard`) |
| Căutare | `SearchField`, după titlu, fără diferență de majuscule |
| Filtrare | chip-urile din `workoutPrograms.filters` |
| Sortare | `SortMenu`: implicit, titlu A-Z, calorii descrescător, durată crescător |
| Favorite | inimă pe card și pe pagina de detalii, stare comună prin `FavoritesCubit`; butonul „doar favorite” filtrează lista |
| Navigare la detalii | card → `ProgramDetailsScreen`; „Start Now” → `GymDetailScreen` |
| Pull-to-refresh / Retry | `HomeCubit.refresh()` păstrează filtrele, iar dacă eșuează lasă datele pe ecran și afișează un mesaj; `HomeCubit.load()` pentru Retry |

## Arhitectură

```
lib/
  data/      FitnessRepository (interfață) + JsonFitnessRepository (citire JSON)
  models/    modele imutabile cu fromJson; ProgramQuery = căutare + filtru + sortare
  cubits/    home/, gym/, favorites/  (logica de stare, fără UI)
  screens/   home, program_details, gym_detail
  widgets/   componente reutilizabile: ProgramCard, SearchField, SortMenu, FavoriteButton,
             DetailHero, AppNetworkImage, LoadingView / ErrorView / EmptyView ...
  theme/     culori, tipografie, spațieri
```

Fluxul datelor: `JsonFitnessRepository` → `HomeCubit` → `BlocBuilder` în `HomeScreen`.
Ecranele depind de interfața `FitnessRepository`, nu de implementarea JSON, așa că în teste
se folosește un repository fals.

`FavoritesCubit` și `HomeCubit` nu se cunosc între ele. Le leagă `HomeScreen`, printr-un
`BlocListener` care transmite favoritele către `HomeCubit.updateFavorites`.

`HomeSuccess` și `HomeEmpty` moștenesc `HomeReady`, care păstrează datele paginii și filtrele
curente. Astfel, în starea Empty bara de căutare și filtrele rămân pe ecran.

## Observații despre JSON

- Programele nu au câmp de categorie. Un program aparține unui filtru dacă titlul conține
  numele filtrului (`Yoga` → Yoga, `Cardio Training` → Cardio). „Arm Strengthening” apare doar
  la „All Type”, iar Pilates și Boxing afișează starea Empty.
- Imaginea planului „Strong & Fit” (`photo-1581009146145-...`) răspunde cu HTTP 404. Aplicația
  afișează în locul ei un placeholder.
- Favoritele se păstrează doar în memorie, pe durata sesiunii.

## Teste

- `test/data/`: parsarea JSON-ului real și erorile pentru JSON invalid.
- `test/models/`: căutarea, filtrarea și sortarea (`ProgramQuery`).
- `test/cubits/`: tranzițiile de stare (`bloc_test`), inclusiv Error → Retry → Success,
  refresh concurent cu o căutare, refresh eșuat și filtrul de favorite.
- `test/screens/`: Home în stările Loading, Error, Empty și Success, căutarea, sortarea,
  favoritele, Reset, pull-to-refresh eșuat și Gym Details (Success și Error → Retry).
