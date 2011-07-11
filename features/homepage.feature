Feature: Homepage
  In order to get government-related information
  As a site visitor
  I want to be able to search for information

  Scenario: Visiting the home page
    Given I am on the homepage
    Then I should not see "ROBOTS" meta tag
    And I should see a link to "USA.gov" with url for "http://www.usa.gov/index.shtml" in the homepage header
    And I should see a link to "FAQs" with url for "http://answers.usa.gov/"
    And I should see a link to "E-mail USA.gov" with url for "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/ask.php"
    And I should see a link to "Chat" with url for "http://answers.usa.gov/cgi-bin/gsa_ict.cfg/php/enduser/chat.php"
    And I should see "GOVERNMENT" in the search navigation
    And I should see a link to "Change Text Size" with url for "http://www.usa.gov/About/Change_Text.shtml"
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should see a link to "Share" with url for "http://www.addthis.com/bookmark.php" in the connect section
    And I should see a link to "USA.gov" with url for "http://www.usa.gov/index.shtml" in the homepage footer
    And I should see a link to "Website Policies" with url for "http://www.usa.gov/About/Important_Notices.shtml"
    And I should see a link to "Privacy" with url for "http://www.usa.gov/About/Privacy_Security.shtml"
    And I should see "USASearch Program"
    And I should see "Affiliate Program"
    And I should see "APIs and Web Services"
    And I should see "Search.USA.gov" in the homepage tagline

  Scenario: A typical popular search from the home page
    Given I am on the homepage
    When I fill in "query" with "visa lottery"
    And I submit the search form
    Then I should be on the search page
    And I should see "Results 1-10"
    And I should see "visa lottery"
    And I should see 10 search results
    And I should see "Next"
    And I should see "Connect with USASearch" in the connect section
    And I should see a link to "Twitter" with url for "http://twitter.com/usasearch" in the connect section
    And I should see a link to "Mobile" with url for "http://m.usa.gov" in the connect section
    And I should see a link to "Our Blog" with url for "http://searchblog.usa.gov" in the connect section
    And I should see a link to "Share" with url for "http://www.addthis.com/bookmark.php" in the connect section

  Scenario: A nonsense search from the home page
    Given I am on the homepage
    When I fill in "query" with "kjdfgkljdhfgkldjshfglkjdsfhg"
    And I submit the search form
    Then I should see "Sorry, no results found for 'kjdfgkljdhfgkldjshfglkjdsfhg'. Try entering fewer or broader query terms."

  Scenario: Doing a blank search from the home page
    Given I am on the homepage
    When I submit the search form
    Then I should be on the homepage

  Scenario: Search with a blank query on an affiliate page
    Given the following Affiliates exist:
      | display_name     | name             | contact_email         | contact_name        |
      | bar site         | bar.gov          | aff@bar.gov           | John Bar            |
    When I am on bar.gov's search page
    And I press "Search"
    Then I should see "Please enter search term(s)"
    
  Scenario: Entering a blank advanced search
    When I am on the advanced search page
    And I press "Search"
    Then I should be on the search page
    And I should see "Please enter search term(s)"

  Scenario: A unicode search from the home page
    Given I am on the homepage
    When I fill in "query" with "البيت الأبيض"
    And I submit the search form
    Then I should see "البيت الأبيض"

  Scenario: Visiting the homepage as a Spanish speaker
    Given I am on the homepage
    And I follow "Busque en español"
    Then I should see a link to "GobiernoUSA.gov" with url for "http://www.usa.gov/gobiernousa/index.shtml" in the homepage header
    And I should see a link to "Respuestas" with url for "http://respuestas.gobiernousa.gov/"
    And I should see a link to "Contactos" with url for "http://www.usa.gov/gobiernousa/Contactenos.shtml"
    And I should see "GOBIERNO" in the search navigation
    And I should see a link to "Cambiar el tamaño del texto" with url for "http://www.usa.gov/gobiernousa/Tamano_Texto.shtml"
    And I should not see "Connect with USASearch"
    And I should see a link to "GobiernoUSA.gov" with url for "http://www.usa.gov/gobiernousa/index.shtml" in the homepage footer
    And I should see a link to "Políticas del sitio" with url for "http://www.usa.gov/gobiernousa/Politicas_Sitio.shtml"
    And I should see a link to "Privacidad" with url for "http://www.usa.gov/gobiernousa/Privacidad_Seguridad.shtml"
    And I should see "Móvil"
    And I should see "Buscador.USA.gov" in the homepage tagline
    When I follow "Search in English"
    Then I should be on the homepage

  Scenario: Clicking on the red Buscador.USA.gov button
    Given I am on the homepage
    When I follow "Buscador.USA.gov" in the search navigation
    Then I should be on the homepage
    And I should see "Search in English"

  Scenario: Clicking on the red Search.USA.gov button
    Given I am on the homepage
    When I follow "Buscador.USA.gov" in the search navigation
    When I follow "Search.USA.gov" in the search navigation
    Then I should be on the homepage
    And I should see "Busque en español"

  Scenario: Switching to image search
    Given I am on the search page
    When I fill in "query" with "White House"
    And I press "Search"
    Then I should be on the search page
    When I follow "Images" in the search navigation
    Then I should be on the image search page
    And I should see 30 image results

  Scenario: Clicking on Advanced Search on the homepage
    Given I am on the homepage
    And I follow "Advanced Search"
    Then I should see "Use the options on this page to create a very specific search."

  Scenario: Clicking on Advanced Search on the Spanish homepage
    Given I am on the homepage
    And I follow "Busque en español"
    And I follow "Búsqueda avanzada"
    Then I should see "Use las siguientes opciones para hacer una búsqueda específica."

  Scenario: Visiting homepage and clicking on trending searches
    Given the following Top Searches exist:
    | position  | query                     |
    | 1         | <i>Trending</i> Search 1  |
    | 2         | Trending Search 2         |
    | 3         | Trending Search 3         |
    | 4         |                           |
    | 5         | Trending Search 5         |
    And I am on the homepage
    Then I should see "Search Trends"
    And I should see "<i>Trending</i> Search 1"
    And I should see "Trending Search 2"
    And I should see "Trending Search 3"
    And I should see "Trending Search 5"

  Scenario: Visiting the homepage as a Spanish speaker should not show trending searches
    Given the following Top Searches exist:
    | position  | query              |
    | 1         | Trending Search 1  |
    | 2         | Trending Search 2  |
    | 3         | Trending Search 3  |
    | 4         | Trending Search 4  |
    | 5         | Trending Search 5  |
    And I am on the homepage
    And I follow "Busque en español"
    Then I should not see "Search Trends"
    And I should not see "Trending Search 1"
    And I should not see "Trending Search 2"
    And I should not see "Trending Search 3"
    And I should not see "Trending Search 4"
    And I should not see "Trending Search 5"

  Scenario: Visiting ABOUT USASearch links
    Given I am on the homepage
    When I follow "USASearch Program" in the homepage about section
    Then I should be on the program welcome page

    Given I am on the homepage
    When I follow "Affiliate Program" in the homepage about section
    Then I should be on the affiliates page

    Given I am on the homepage
    When I follow "APIs and Web Services" in the homepage about section
    Then I should be on the api page

    Given I am on the homepage
    When I follow "Search.USA.gov" in the homepage about section
    Then I should be on the searchusagov page

  Scenario: Visiting other verticals from the homepage
    Given I am on the homepage
    When I follow "Images" in the search navigation
    Then I should be on the images page

    Given I am on the homepage
    When I follow "Recalls" in the search navigation
    Then I should be on the recalls page

    Given I am on the homepage
    When I follow "Forms" in the search navigation
    Then I should be on the forms page
