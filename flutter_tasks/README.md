# Flutter Interview Tasks — Submission

5 independent, self-contained tasks, one subfolder each, per the instructions.

## Structure

```
task1_profile_card/         Task 1 — Responsive Profile Card Widget
  profile_card.dart          - ProfileCard widget (the deliverable)
  main.dart                   - demo app showing it at phone/tablet widths, light/dark

task2_counter_undo_redo/    Task 2 — Counter with Undo/Redo
  counter_screen.dart         - CounterScreen (self-contained)

task3_api_fetch/            Task 3 — Fetch and Display API Data
  user_model.dart              - UserModel.fromJson
  user_service.dart            - fetchUsers()
  user_list_screen.dart        - loading / error+retry / list / detail bottom sheet

task4_form_validation/      Task 4 — Multi-Field Form with Validation
  signup_form_screen.dart      - Create Account form
  welcome_screen.dart          - receives name via constructor

task5_todo_persistence/     Task 5 — Simple To-Do List with Local Persistence
  todo_screen.dart              - CRUD UI, swipe-to-delete
  todo_repository.dart          - shared_preferences persistence (JSON-encoded)
```

## Dependencies

Each task only needs what's listed below. If wiring these into one throwaway
Flutter project to try them out, add all of the following to a single
`pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0              # used by Task 3
  shared_preferences: ^2.2.0 # used by Task 5
```

Tasks 1, 2, and 4 use only the Flutter SDK (no state-management package,
per the instructions — Task 2 uses plain `setState`, noted and justified
in a comment at the top of `counter_screen.dart`).

## How each task was verified (manual reasoning, no CI in this environment)

- **Task 1**: stats row uses `Expanded` inside a `Row` with no fixed widths,
  so it can't overflow at 360dp or 800dp; avatar has both `loadingBuilder`
  and `errorBuilder`; all colors/text styles pulled from `Theme.of(context)`.
- **Task 2**: undo/redo implemented as two capped stacks (max 10) around a
  pure `_CounterHistory` class with no widget dependencies; buttons pass
  `null` as `onPressed` when empty, which Flutter automatically greys out.
- **Task 3**: `UserModel.fromJson` isolates all JSON-shape knowledge;
  `UserService` throws a typed `UserFetchException` with a friendly message
  on timeout/non-200/parse failure; `UserListScreen` has three exclusive
  render states (loading/error/loaded) driven by an enum, with a Retry
  button wired straight back to the same fetch call.
- **Task 4**: validators return `null`/`String` and are wired to
  `TextFormField.validator`, so Flutter renders inline error text natively
  (no SnackBars); password validator checks length + at least one digit;
  confirm-password validator compares live against the password
  controller; name is trimmed before both validation and navigation.
- **Task 5**: `TodoRepository` is a plain class with no Flutter imports,
  storing the whole list as one JSON string; every mutation in
  `TodoScreen` (`_addTodo`, `_toggleDone`, `_deleteTodo`) updates in-memory
  state then immediately calls `_persist()`; `Dismissible` is keyed by the
  item's stable `id` (not list index) so swipe gestures track correctly.
