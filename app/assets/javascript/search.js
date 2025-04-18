/**
 * SearchBox Main JavaScript
 * 
 * Handles real-time search, analytics, and user interaction for the search application.
 */

document.addEventListener('DOMContentLoaded', () => {
  // DOM elements
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  const resultsCount = document.getElementById('count');
  const clearButton = document.getElementById('clear-search');
  const uniqueTermsElem = document.getElementById('unique-terms');
  const articlesFoundElem = document.getElementById('articles-found');
  const totalAppearancesElem = document.getElementById('total-appearances');
  const searchTermsTable = document.getElementById('search-terms')?.querySelector('tbody');
  const resultArticlesTable = document.getElementById('result-articles')?.querySelector('tbody');
  
  // State variables
  let allArticles = [];
  let debounceTimer;
  let searchHistory = [];
  let currentSearchTerm = '';
  let isTyping = false;
  let typingTimer;
  let lastInputTime = 0;
  
  // Analytics data
  let totalSearches = 0;
  let articleAppearances = {};
  let searchTermStats = {};
  let userIdentifier = '';
  
  // Initialize
  init();
  
  /**
   * Initialize the application
   */
  function init() {
    loadAllArticles();
    setupEventListeners();
    processPendingSearches();
  }
  
  /**
   * Set up event listeners
   */
  function setupEventListeners() {
    // Search input handler with debounce
    if (searchInput) {
      searchInput.addEventListener('input', handleSearchInput);
      
      // Handle Escape key to clear search
      searchInput.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
          clearSearch();
        }
      });
    }
    
    // Clear button handler
    if (clearButton) {
      clearButton.addEventListener('click', clearSearch);
    }
    
    // Page visibility change
    window.addEventListener('blur', handlePageVisibilityChange);
    
    // Before unload (page close/refresh) handler
    window.addEventListener('beforeunload', finalizeAnyPendingSearch);
  }
  
  /**
   * Load all articles from the server
   */
  function loadAllArticles() {
    fetch('/articles.json')
      .then(response => response.json())
      .then(articles => {
        allArticles = articles;
        displayArticles(articles);
        
        // Load analytics data from the server
        loadAnalyticsData();
      })
      .catch(error => console.error('Error loading articles:', error));
  }
  
  /**
   * Handle search input with debounce
   */
  function handleSearchInput() {
    clearTimeout(debounceTimer);
    clearTimeout(typingTimer);
    
    // Update the current search term
    currentSearchTerm = searchInput.value.trim();
    
    // If the input is empty, immediately load all articles
    if (currentSearchTerm === '') {
      console.log("Input cleared, loading all articles");
      loadAllArticles();
      updateClearButtonVisibility();
      return;
    }
    
    // Mark as typing
    isTyping = true;
    
    // Set a timer to detect when user stops typing - this makes a search final
    typingTimer = setTimeout(() => {
      isTyping = false;
      
      // If the user has stopped typing, send the final search regardless of length
      if (currentSearchTerm.length > 0) {
        searchArticles(currentSearchTerm, true);
        showFinalSearchNotification(currentSearchTerm);
      } else {
        // If they cleared the input and stopped typing, load all articles
        loadAllArticles();
      }
    }, 1000); // 1 second of no typing means they finished
    
    // Implement debounce for intermediate searches
    const now = Date.now();
    const timeSinceLastInput = now - (lastInputTime || now);
    lastInputTime = now;
    
    // Immediate search for the first keystroke
    if (timeSinceLastInput > 1000 || !window.searchInProgress) {
      searchArticles(currentSearchTerm, false);
    } else {
      // For subsequent keystrokes, debounce
      debounceTimer = setTimeout(() => {
        searchArticles(currentSearchTerm, false);
      }, 300);
    }
    
    updateClearButtonVisibility();
  }
  
  /**
   * Search articles with the given query
   */
  function searchArticles(query, isFinalSearch) {
    // Prevent multiple concurrent searches
    if (window.searchInProgress) {
      console.log("Search already in progress, skipping");
      return;
    }
    
    window.searchInProgress = true;
    
    // Track this search
    trackSearchAttempt(query, isFinalSearch);
    
    return fetch(`/articles/search.json?query=${encodeURIComponent(query)}&is_final=${isFinalSearch}`)
      .then(response => response.json())
      .then(data => {
        displayArticles(data.articles || []);
        window.searchInProgress = false;
        
        // Store user identifier
        if (data.analytics && data.analytics.user_identifier) {
          userIdentifier = data.analytics.user_identifier;
        }
        
        if (isFinalSearch) {
          // Reload analytics data after a final search
          return loadAnalyticsData().then(() => {
            // Highlight analytics section
            highlightAnalyticsSection();
            return data;
          });
        }
        
        return data;
      })
      .catch(error => {
        console.error('Error searching articles:', error);
        searchResults.innerHTML = '<p class="no-results error-message">An error occurred while searching. Please try again.</p>';
        resultsCount.textContent = '0';
        window.searchInProgress = false;
        throw error;
      });
  }
  
  /**
   * Display articles in the results container
   */
  function displayArticles(articles) {
    if (!searchResults) return;
    
    if (articles.length === 0) {
      searchResults.innerHTML = '<p class="no-results">No articles found.</p>';
      if (resultsCount) resultsCount.textContent = '0';
      return;
    }
    
    searchResults.innerHTML = '';
    if (resultsCount) resultsCount.textContent = articles.length;
    
    articles.forEach(article => {
      const articleElement = document.createElement('div');
      articleElement.className = 'article-card';
      articleElement.innerHTML = `
        <h2>${article.title}</h2>
        ${article.author ? `<p class="article-author">By: ${article.author}</p>` : ''}
        ${article.category ? `<p class="article-category">Category: ${article.category}</p>` : ''}
        <div class="article-content">${article.content ? article.content.substring(0, 200) + '...' : ''}</div>
      `;
      searchResults.appendChild(articleElement);
    });
  }
  
  /**
   * Clear the search input and show all articles
   */
  function clearSearch() {
    if (searchInput) {
      searchInput.value = '';
      currentSearchTerm = '';
      
      // Clear any pending timers
      clearTimeout(debounceTimer);
      clearTimeout(typingTimer);
      
      // Load all articles
      loadAllArticles();
      
      // Update clear button visibility
      updateClearButtonVisibility();
      
      // Set focus back to the search input
      searchInput.focus();
    }
  }
  
  /**
   * Update clear button visibility based on search input content
   */
  function updateClearButtonVisibility() {
    if (clearButton) {
      clearButton.style.display = currentSearchTerm ? 'block' : 'none';
    }
  }
  
  /**
   * Track search attempt using a queue
   */
  function trackSearchAttempt(query, isFinal) {
    // Add search to queue
    const searchQueue = window.searchQueue || [];
    searchQueue.push({ query, isFinal, timestamp: Date.now() });
    window.searchQueue = searchQueue;
    
    // For final searches, add to local storage for resilience
    if (isFinal) {
      // Save to local storage for offline resilience
      const savedSearches = JSON.parse(localStorage.getItem('pendingSearches') || '[]');
      savedSearches.push({ query, isFinal, timestamp: Date.now() });
      localStorage.setItem('pendingSearches', JSON.stringify(savedSearches));
      
      // Also track in session
      addToSearchHistory(query);
    }
  }
  
  /**
   * Add search term to history
   */
  function addToSearchHistory(term) {
    if (!searchHistory.includes(term)) {
      searchHistory.push(term);
    }
  }
  
  /**
   * Handle page visibility change (user leaving the page)
   */
  function handlePageVisibilityChange() {
    // When user leaves the page, force any current search to become final
    if (currentSearchTerm && currentSearchTerm.trim() !== '') {
      clearTimeout(typingTimer);
      searchArticles(currentSearchTerm, true);
    }
  }
  
  /**
   * Finalize any pending search before unload
   */
  function finalizeAnyPendingSearch() {
    if (isTyping && currentSearchTerm && currentSearchTerm.trim() !== '') {
      trackSearchAttempt(currentSearchTerm, true);
    }
  }
  
  /**
   * Process any pending searches from local storage
   */
  function processPendingSearches() {
    const pendingSearches = JSON.parse(localStorage.getItem('pendingSearches') || '[]');
    
    if (pendingSearches.length === 0) {
      return;
    }
    
    console.log(`Found ${pendingSearches.length} pending searches to process`);
    
    // Only process final searches
    const finalSearches = pendingSearches.filter(s => s.isFinal);
    
    if (finalSearches.length === 0) {
      // Clear storage if no final searches
      localStorage.removeItem('pendingSearches');
      return;
    }
    
    // Submit to server
    fetch('/articles/process_pending_searches', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: JSON.stringify({ pending_searches: finalSearches })
    })
    .then(response => response.json())
    .then(data => {
      console.log(`Processed ${data.processed} pending searches`);
      // Clear storage
      localStorage.removeItem('pendingSearches');
      // Refresh analytics
      loadAnalyticsData();
    })
    .catch(error => {
      console.error('Error processing pending searches:', error);
    });
  }
  
  /**
   * Load analytics data from the server
   */
  function loadAnalyticsData() {
    return fetch('/articles/analytics.json')
      .then(response => {
        if (!response.ok) {
          throw new Error(`Server responded with status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        // Store user identifier
        if (data.user_identifier) {
          userIdentifier = data.user_identifier;
        }
        
        // Update the UI with data from the server
        updateAnalyticsUI(data);
        return data;
      })
      .catch(error => {
        console.error('Error loading analytics:', error);
        setDefaultAnalyticsValues();
        throw error;
      });
  }
  
  /**
   * Update analytics UI with server data
   */
  function updateAnalyticsUI(data) {
    // Update search terms table
    if (searchTermsTable) {
      updateSearchTermsTable(data.top_searches || []);
    }
    
    // Update article appearances table
    if (resultArticlesTable) {
      updateArticlesTable(data.top_articles || []);
    }
    
    // Update summary metrics
    if (data.stats) {
      if (uniqueTermsElem) uniqueTermsElem.textContent = data.stats.total_unique_searches || '0';
      if (articlesFoundElem) articlesFoundElem.textContent = data.stats.total_articles_found || '0';
      if (totalAppearancesElem) totalAppearancesElem.textContent = data.stats.total_appearances || '0';
    }
  }
  
  /**
   * Update search terms table
   */
  function updateSearchTermsTable(searches) {
    if (!searchTermsTable) return;
    
    searchTermsTable.innerHTML = '';
    
    if (searches.length === 0) {
      const emptyRow = document.createElement('tr');
      const emptyCell = document.createElement('td');
      emptyCell.colSpan = 4;
      emptyCell.textContent = 'No search term statistics available yet';
      emptyCell.className = 'empty-table';
      emptyRow.appendChild(emptyCell);
      searchTermsTable.appendChild(emptyRow);
      return;
    }
    
    searches.forEach(search => {
      const row = document.createElement('tr');
      
      // Term
      const termCell = document.createElement('td');
      termCell.textContent = search.term;
      row.appendChild(termCell);
      
      // Search count
      const countCell = document.createElement('td');
      countCell.textContent = search.search_count;
      row.appendChild(countCell);
      
      // Results count
      const resultsCell = document.createElement('td');
      resultsCell.textContent = search.results_count;
      row.appendChild(resultsCell);
      
      // Last searched
      const timeCell = document.createElement('td');
      timeCell.textContent = formatDate(search.last_searched_at);
      row.appendChild(timeCell);
      
      searchTermsTable.appendChild(row);
    });
  }
  
  /**
   * Update articles table
   */
  function updateArticlesTable(articles) {
    if (!resultArticlesTable) return;
    
    resultArticlesTable.innerHTML = '';
    
    if (articles.length === 0) {
      const emptyRow = document.createElement('tr');
      const emptyCell = document.createElement('td');
      emptyCell.colSpan = 3;
      emptyCell.textContent = 'No article statistics available yet';
      emptyCell.className = 'empty-table';
      emptyRow.appendChild(emptyCell);
      resultArticlesTable.appendChild(emptyRow);
      return;
    }
    
    articles.forEach(article => {
      const row = document.createElement('tr');
      
      // Title
      const titleCell = document.createElement('td');
      titleCell.textContent = article.title;
      row.appendChild(titleCell);
      
      // Category
      const categoryCell = document.createElement('td');
      categoryCell.textContent = article.category || 'Uncategorized';
      row.appendChild(categoryCell);
      
      // Appearances
      const appearancesCell = document.createElement('td');
      appearancesCell.textContent = article.appearances;
      row.appendChild(appearancesCell);
      
      resultArticlesTable.appendChild(row);
    });
  }
  
  /**
   * Set default values for analytics
   */
  function setDefaultAnalyticsValues() {
    if (uniqueTermsElem) uniqueTermsElem.textContent = '0';
    if (articlesFoundElem) articlesFoundElem.textContent = '0';
    if (totalAppearancesElem) totalAppearancesElem.textContent = '0';
    
    if (searchTermsTable) {
      showErrorInTable(searchTermsTable, 4, 'Could not load search analytics');
    }
    
    if (resultArticlesTable) {
      showErrorInTable(resultArticlesTable, 3, 'Could not load article analytics');
    }
  }
  
  /**
   * Show error in table
   */
  function showErrorInTable(table, colSpan, message) {
    table.innerHTML = '';
    const errorRow = document.createElement('tr');
    const errorCell = document.createElement('td');
    errorCell.colSpan = colSpan;
    errorCell.className = 'error-message';
    errorCell.textContent = message;
    errorRow.appendChild(errorCell);
    table.appendChild(errorRow);
  }
  
  /**
   * Show notification when a search is finalized
   */
  function showFinalSearchNotification(term) {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = 'final-search-alert';
    notification.textContent = `Final search: "${term}"`;
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
      notification.remove();
    }, 3000);
  }
  
  /**
   * Highlight the analytics section
   */
  function highlightAnalyticsSection() {
    const analyticsSection = document.getElementById('search-analytics');
    if (analyticsSection) {
      // Scroll to analytics section
      analyticsSection.scrollIntoView({ behavior: 'smooth' });
      
      // Add highlight class
      analyticsSection.classList.add('highlight-analytics');
      
      // Remove highlight class after animation
      setTimeout(() => {
        analyticsSection.classList.remove('highlight-analytics');
      }, 1500);
    }
  }
  
  /**
   * Format date for display
   */
  function formatDate(dateString) {
    if (!dateString) return 'Never';
    
    const date = new Date(dateString);
    
    // Check if date is valid
    if (isNaN(date.getTime())) return 'Invalid date';
    
    // Get time difference in minutes
    const minutesAgo = Math.floor((new Date() - date) / (1000 * 60));
    
    if (minutesAgo < 1) return 'Just now';
    if (minutesAgo < 60) return `${minutesAgo} minute${minutesAgo === 1 ? '' : 's'} ago`;
    
    const hoursAgo = Math.floor(minutesAgo / 60);
    if (hoursAgo < 24) return `${hoursAgo} hour${hoursAgo === 1 ? '' : 's'} ago`;
    
    const daysAgo = Math.floor(hoursAgo / 24);
    if (daysAgo < 7) return `${daysAgo} day${daysAgo === 1 ? '' : 's'} ago`;
    
    return date.toLocaleDateString();
  }
});