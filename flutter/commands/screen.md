Create a new Flutter screen/page following team conventions.

Please generate:

1. Screen widget with Scaffold
2. State management setup (Provider/Riverpod/Bloc based on project)
3. Navigation integration
4. Loading and error states
5. Widget tests

Screen specifications:
- Name: {{name}}Screen
- Location: lib/screens/{{name}}/
- Include AppBar with proper title
- Add navigation handling (with proper routing)
- Implement responsive layout (mobile, tablet, desktop)
- Include accessibility labels and semantics
- Add proper error handling

Additional files to create:
- {{name}}_screen.dart - Screen widget
- {{name}}_controller.dart or {{name}}_viewmodel.dart - Business logic
- {{name}}_screen_test.dart - Screen tests

Follow clean architecture principles and separation of concerns.
