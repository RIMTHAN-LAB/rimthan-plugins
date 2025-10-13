Create a new database model following team conventions.

Please generate:

1. Model definition (Sequelize/TypeORM/Prisma/Mongoose based on project)
2. TypeScript interfaces and types
3. Validation rules and constraints
4. Database migration file
5. Model tests

Model specifications:
- Name: {{name}}
- Location: src/models/{{name}}.ts
- Include proper relationships (foreign keys, associations)
- Add validation (field-level and model-level)
- Create appropriate indexes
- Write migration files
- Include comprehensive unit tests

Additional features to include:
- Timestamps (createdAt, updatedAt)
- Soft deletes (deletedAt) if applicable
- Proper field types with TypeScript
- Foreign key constraints
- Unique constraints where needed
- Default values
- Hooks/lifecycle methods if needed

Migration file should:
- Be reversible (up and down methods)
- Include proper field types
- Set up indexes
- Define constraints
- Handle data transformation if needed

Tests should cover:
- Model creation and validation
- Relationships and associations
- Custom methods and scopes
- Error handling for invalid data
