
module WikipediaWrapper

  # Base Wikipedia error class
  class WikipediaError < StandardError

    def initialize(error)
      @error = error
    end

    def message
      "An unexpected error occured: \"#{@error}\". Please report it on GitHub (github.com/sykaeh/wikipedia_wrapper)!"
    end

  end

  # Exception raised when no Wikipedia matched a query.
  class PageError < WikipediaError

    def initialize(term, pageid: false)
      @pageid = page
      @term = term
    end

    def message
      if @pageid
        "Page id \"#{@term}\" does not match any pages. Try another id!"
      else
        "\"#{@term}\" does not match any pages. Try another query!"
      end
    end

  end

  # Exception raised when more than one Wikipedia article matched a query.
  class MultiplePagesError < WikipediaError

    def initialize(page_titles, term, pageid: false)
      @pages = page_titles
      @pageid = pageid
      @term = term
    end

    def message
      if @pageid
        "Page id \"#{@term}\" matches #{@pages.length} pages: \n#{@pages.join(', ')}"
      else
        "\"#{@term}\" matches #{@pages.length} pages: \n#{@pages.join(', ')}"
      end
    end

  end


  # Exception raised when a page resolves to a Disambiguation page.
  #
  # The `options` property contains a list of titles
  # of Wikipedia pages that the query may refer to.
  #
  # @note `options` does not include titles that do not link to a valid Wikipedia page.
  class DisambiguationError < WikipediaError

    def initialize(title, may_refer_to)
      @title = title
      @options = may_refer_to
    end

    def message
      "\"#{@title}\" may refer to: \n#{@options.join(', ')}"
    end

  end


  # Exception raised when a page title unexpectedly resolves to a redirect.
  class RedirectError < WikipediaError

    def initialize(title)
      @title = title
    end

    def message
      "\"#{@title}\" resulted in a redirect. Set the redirect property to True to allow automatic redirects."
    end

  end

  # Exception raised when a request to the Mediawiki servers times out.
  class HTTPTimeoutError < WikipediaError

    def initialize(query)
      @query = query
    end

    def message
      "Searching for \"#{@query}\" resulted in a timeout. Try again in a few seconds, and make sure you have rate limiting set to True."
    end

  end

end
