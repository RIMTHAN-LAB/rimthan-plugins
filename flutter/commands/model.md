Create a new data model for Flutter with JSON serialization.

Please generate:

1. Dart class with proper typing
2. JSON serialization (toJson/fromJson or json_serializable)
3. Equatable implementation for value equality
4. Immutable implementation with copyWith method
5. Unit tests for serialization and equality

Model specifications:
- Name: {{name}}
- Location: lib/models/{{name}}.dart
- Use json_serializable annotations if available
- Include validation logic
- Add comprehensive documentation
- Make immutable (final fields)
- Include unit tests in test/models/{{name}}_test.dart

The model should include:
- Proper null safety
- Factory constructors for JSON parsing
- Error handling for invalid data
- toString() implementation for debugging
- Equality and hashCode overrides
