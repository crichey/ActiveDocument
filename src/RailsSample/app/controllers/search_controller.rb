class SearchController < ApplicationController

  def initialize
    @search_options = ActiveDocument::SearchOptions.new
    @search_options.range_constraints["Region"] = {"namespace" => "http://wits.nctc.gov", "element" => "Region"}
    @search_options.range_constraints["Facility Type"] = {"namespace" => "http://wits.nctc.gov", "element" => "FacilityType"}
  end

  def index
    start = params[:start]
    if start.nil?
      start = 1
    end
    @query = params[:query]
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
