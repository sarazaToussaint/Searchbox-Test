# Instant Article Search Application

This is a fast and responsive article search application built with Ruby on Rails and VanillaJS. It demonstrates how to create a modern search interface without using a JavaScript framework.

## Features

- Instant search as you type
- 100 sample articles with categories and authors
- Search by title or content
- Responsive design
- RESTful API endpoints

## Technologies Used

- Ruby on Rails 7.1
- VanillaJS (no JavaScript frameworks)
- SQLite (development)
- HTML5 & CSS3

## Getting Started

### Prerequisites

- Ruby 3.0.0 or higher
- Rails 7.1 or higher
- SQLite3

### Installation

1. Clone the repository
   ```
   git clone <repository-url>
   cd Searchbox-backend
   ```

2. Install dependencies
   ```
   bundle install
   ```

3. Set up the database
   ```
   rails db:create db:migrate db:seed
   ```

4. Start the server
   ```
   rails server
   ```

5. Visit http://localhost:3000 in your browser

## API Endpoints

- `GET /articles` - List all articles
- `GET /articles/search?query=term` - Search articles by title or content

## Search Implementation Details

The application implements client-side instant search with the following features:

- Debounced search to minimize unnecessary API calls
- Real-time results display
- Truncated article previews
- Visual feedback during search

The search is performed against the title and content fields in the database, with case-insensitive matching.

## License

This project is licensed under the MIT License.
