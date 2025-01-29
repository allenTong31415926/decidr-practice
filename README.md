# Decidr Practice

A Ruby on Rails application for managing and searching character data with CSV import capabilities. Built with Rails 8.0, TypeScript, and Bootstrap.

## Application Preview

## Features

- CSV data import with validation
- Real-time search across multiple fields
- Pagination (10 items per page)
- Error tracking with Rollbar

## Technology Stack

- Ruby 3.2.2
- Rails 8.0.1
- PostgreSQL
- TypeScript
- Bootstrap 5.3

## Development Setup

1. Clone the repository
2. Install dependencies:

```bash
bundle install
yarn install
```

3. Database setup:
```bash
bin/rails db:create db:migrate
```

4. Start the development server:
```bash
./bin/dev
```

Visit `http://localhost:3000`

## Testing

Run the test suite:
```bash
bin/rails test
bin/rails test:system
```

## CSV Import Format

The application accepts CSV files with the following columns:
- Name (required, will be split into first_name and last_name)
- Gender (optional: "Male"/"M", "Female"/"F", "Other")
- Species (optional)
- Affiliations (required, comma-separated)
- Location (optional, comma-separated)
- Weapon (optional)
- Vehicle (optional)

Example:
```csv
Name,Gender,Species,Affiliations,Location,Weapon,Vehicle
Luke Skywalker,Male,Human,Rebel Alliance,Tatooine,Lightsaber,X-wing
```

## API Documentation

### Endpoints

- `GET /` - Main page with people listing and search
- `POST /people/csv_upload` - CSV upload endpoint

### Controllers

The application uses method annotations for documentation. Key controllers:

- `PeopleController`: Handles listing, searching, and CSV uploads
- `ApplicationController`: Handles error management and Rollbar integration

## Error Handling

The application uses custom error handling for:
- CSV import errors
- General application errors
- All errors are tracked in Rollbar

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
