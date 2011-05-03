class SearchController < ApplicationController

  before_filter :gather_options

  def gather_options
    @search_options = ActiveDocument::MarkLogicSearchOptions.new
    @search_options.range_constraints["Region"] = {"namespace" => "http://wits.nctc.gov", "element" => "Region", "type" => "xs:string", "collation" => "http://marklogic.com/collation/"}
    @search_options.range_constraints["Facility Type"] = {"namespace" => "http://wits.nctc.gov", "element" => "FacilityType", "type" => "xs:string", "collation" => "http://marklogic.com/collation/"}
  end

  def index
    start = params[:start]
    if start.nil?
      start = 1
    end
    @query = params[:query]
    if @query.nil? : @query = "" end
    @results = ActiveDocument::Finder.search(@query, start, 10, @search_options)
    @facets = @results.facets
    @pairs = ActiveDocument::Finder.co_occurrence("Region", "http://wits.nctc.gov", "FacilityType", "http://wits.nctc.gov", @query)
  end

  def show_results
    @incident = Incident.load(params[:uri])
    @query = params[:query]
  end

  def show_raw
    headers["Content-Type"] = "application/xhtml+xml; charset=utf-8"
    @incident = Incident.load(params[:uri])
    @query = params[:query]
    render :layout => false
  end

  def edit
    @incident = Incident.load(params[:uri])
  end

  def update
    @incident = Incident.load(params[:incident][:uri])
    @incident.Subject = params[:incident][:Subject]
    @incident.save
    redirect_to :action => "index"
  end

end
