class SearchController < ApplicationController

  def initialize
    @search_options = ActiveDocument::SearchOptions.new
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

end
