# Instant Searchbox Application

## Overview

The Searchbox application is a real-time search engine designed to track user searches and display analytics. It is built using Ruby on Rails and utilizes PostgreSQL as the database backend. The application is engineered for scalability, capable of handling thousands of requests per hour while ensuring a clean and efficient user experience.


## Project Structure

The project is organized into several key directories and files:

Searchbox-backend/
├── app/               
│   ├── controllers/        
│   │   └── articles_controller.rb 
│   ├── models/            
│   │   ├── article.rb        
│   │   ├── article_view.rb    
│   │   └── search_query.rb   
│   ├── views/                
│   │   └── articles/
│   │       └── index.html.erb   
│   └── ...
├── config/                 
│   ├── database.yml           
│   ├── routes.rb          
│   └── ...
├── db/                       
│   ├── migrate/                 
│   ├── seeds.rb                
│   └── schema.rb               
├── Gemfile                     
├── .env                         
└── README.md                    


## Technologies Used

- Ruby 3
- Ruby on Rails 7.1
- VanillaJS (no JavaScript frameworks)
- PostgreSQL 
- HTML5 & CSS3

## Getting Started

### Prerequisites

- Ruby 3.0.0 or higher
- Rails 7.1 or higher
- PostgreSQL 14 or Higher

## Setup Instructions

To set up the Searchbox application locally, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone `https://github.com/yourusername/searchbox-backend.git`
   cd searchbox-backend
   ```

2. **Install Dependencies**:
   Ensure you have Ruby and Bundler installed, then run:
   ```bash
   bundle install
   ```

3. **Set Up Environment Variables**:
   Create a `.env` file in the root directory and add the following variables:
   ```plaintext
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=password
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5432
   ```

4. **Create the Database**:
   Run the following command to create the database:
   ```bash
   bundle exec rails db:create
   ```

5. **Run Migrations**:
   Apply the database migrations to set up the schema:
   ```bash
   bundle exec rails db:migrate
   ```

6. **Seed the Database**:
   Populate the database with sample data:
   ```bash
   bundle exec rails db:seed
   ```

7. **Start the Rails Server**:
   Launch the application:
   ```bash
   bundle exec rails server
   ```

8. **Access the Application**:
   Open your web browser and navigate to `http://localhost:3000` to view the application.

## Database Schema

The application uses PostgreSQL and includes the following tables:

- **articles**: Stores article data, including title, content, author, and category.
- **search_queries**: Records user search terms, along with user tracking information and search counts.
- **article_views**: Tracks the relationship between articles and search queries, including view counts.

## API Endpoints

The following API endpoints are available in the Searchbox application:

- `GET /articles`  
  Lists all articles.

- `GET /articles/search?query=term`  
  Searches articles by title or content.

- `GET /articles/analytics`  
  Retrieves analytics data for articles.

- `POST /articles/set_user_identifier`  
  Sets the user identifier for tracking searches.

- `POST /articles/process_pending_searches`  
  Processes searches that were stored during offline periods.

- `GET /articles/my_searches`  
  Retrieves the current user's search history.

- `GET /articles/my_top_articles`  
  Retrieves the current user's top articles based on search activity.

- `GET /articles/debug_info`  
  Provides debug information for troubleshooting (remove in production if not needed).

## Search Implementation Details

The application implements client-side instant search with the following features:

- Debounced search to minimize unnecessary API calls
- Real-time results display
- Truncated article previews
- Visual feedback during search

The search is performed against the title and content fields in the database, with case-insensitive matching.

## Functionality

The Searchbox application provides the following key functionalities:

1. **Real-Time Search**: Users can input search queries, and results are displayed dynamically as they type.
2. **Search Analytics**: The application tracks user searches, storing analytics data such as search terms, user identifiers, and IP addresses.
3. **Unique Search Tracking**: The application ensures that only unique searches are recorded per user and IP address, preventing clutter in the analytics database.
4. **Categorized Content**: Includes 30+ sample articles with categories and author metadata.
5. **User-Specific Analytics**: Users can view their search history and analytics data, providing insights into their search behavior.
6. **Error Handling**: The application includes robust error handling to manage exceptions and provide user-friendly error messages.

### Key Components

- **Controllers**: Handle incoming requests and manage the flow of data between models and views.
- **Models**: Define the application's data structure and business logic, including methods for searching and tracking analytics.
- **Views**: Render the user interface, displaying search results and analytics data.

## Testing

The application uses RSpec for testing. To run the test suite, execute:
```bash
bundle exec rspec
```

## Live Link 

[https://searchbox-test.onrender.com/]

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push your branch to your forked repository.
5. Create a pull request.

