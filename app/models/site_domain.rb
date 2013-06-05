class SiteDomain < ActiveRecord::Base
  acts_as_search_domain

  VALID_UPLOAD_FILE_CONTENT_TYPE = %w(text/csv text/comma-separated-values application/vnd.ms-excel)
  MAX_DOCS_PER_CRAWL = 1000
  INVALID_FILE_FORMAT_MESSAGE = 'Invalid file format; please upload a csv file (.csv).'
  BLACKLISTED_EXTENSION_REGEXP = Regexp.new("\.#{IndexedDocument::BLACKLISTED_EXTENSIONS.join('|')}$", true)
  validate :domain_coverage, if: Proc.new { |site_domain| site_domain.domain.present? and site_domain.affiliate.present? }
  before_save :set_site_name

  def self.process_file(affiliate, file)
    if file.blank? or !VALID_UPLOAD_FILE_CONTENT_TYPE.include? file.content_type
      return { :success => false, :error_message => INVALID_FILE_FORMAT_MESSAGE }
    end

    site_domain_hash = ActiveSupport::OrderedHash.new
    begin
      CSV.parse(file.read, :skip_blanks => true) do |row|
        site_domain_hash[row[0]] = row[1] unless row[0].blank?
      end
    rescue
      return { :success => false, :error_message => INVALID_FILE_FORMAT_MESSAGE }
    end
    added_site_domains = affiliate.add_site_domains(site_domain_hash)
    added_site_domains.count > 0 ? {:success => true, :added => added_site_domains.count} : {:success => false, :error_message => 'No domains uploaded; please check your file and try again.'}
  end

  def populate(max_docs = MAX_DOCS_PER_CRAWL)
    get_frontier(max_docs).each { |link| affiliate.indexed_documents.create(:url => link) }
  end

  def get_frontier(max_docs)
    return [] if domain.starts_with?('.')
    start_page = infer_start_page_from_domain
    return [] if start_page.nil?
    queue, robots, frontier = [], {}, Set.new
    parsed_start_page_url = URI.parse(start_page)
    path_prefix = URI.parse("http://#{domain}/").path
    marked = Set.new [start_page]
    queue.push start_page
    while queue.any? and frontier.size < max_docs
      url = queue.pop
      begin
        current_url = URI.parse(url)
        next if url_disallowed?(current_url, robots)
        file = open(url)
        if file.content_type =~ /html/
          get_links_from_html_file(file, current_url, parsed_start_page_url, path_prefix).each do |link|
            unless marked.include?(link)
              queue.push link
              marked.add link
            end
          end
        end
        frontier.add url
      rescue Exception => e
        Rails.logger.warn "Trouble fetching #{url}: #{e}"
      end
    end
    frontier.sort
  end

  def url_disallowed?(current_url, robots)
    robots[current_url.host] = Robot.update_for(current_url.host) unless robots.has_key?(current_url.host)
    robots[current_url.host].present? and robots[current_url.host].disallows?(current_url.path)
  end

  def infer_start_page_from_domain
    open("http://#{domain}/").base_uri.to_s
  rescue
    open("http://www.#{domain}/").base_uri.to_s rescue nil
  end

  def get_links_from_html_file(file, current_url, parsed_start_page_url, path_prefix)
    doc = Nokogiri::HTML(file)
    links = doc.css('a').collect do |hlink|
      hlink['href'].squish.gsub(/#.*/, '') rescue nil
    end.uniq.compact.collect do |link|
      link_url = process_link(current_url, link)
      if link_url.present?
        link_url.to_s if link_url.scheme == "http" and link_url.host =~ /#{parsed_start_page_url.host}/i and
          link_url.path =~ /#{path_prefix}/i and link_url != current_url and !link_url.to_s.include?('?') and
          !(BLACKLISTED_EXTENSION_REGEXP.match(link_url.path))
      end
    end
    links.uniq.compact
  end

  def process_link(current_url, link)
    link_url = URI.parse(link)
    link_url = URI.merge_unless_recursive(current_url, link_url) if link_url.relative?
    link_url
  rescue
    nil
  end

  protected

  def set_site_name
    self.site_name = domain if site_name.blank?
  end

  def domain_coverage
    existing = self.affiliate.site_domains.detect do |existing_site_domain|
      existing_domain_str, existing_path_str = existing_site_domain.domain.split '/', 2
      existing_domain_str.insert(0, '.') unless existing_domain_str.start_with?('.')
      (existing_path_str ||= '').insert 0, '/'

      new_domain_str, new_path_str = domain.split '/', 2
      new_domain_str.insert(0, '.') unless new_domain_str.start_with?('.')
      (new_path_str ||= '').insert 0, '/'

      next if id == existing_site_domain.id

      new_domain_str.end_with?(existing_domain_str) and
          new_path_str.start_with?(existing_path_str)
    end
    errors.add(:base, "'#{self.domain}' is already covered by your existing site domain '#{existing.domain}'") if existing
  end
end
