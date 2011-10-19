class Facets
  
  @facets = Hash.new
  @results_document.xpath("/search:response/search:facet").each do |facet|
    name = facet.xpath("./@name").to_s
    detail = Hash.new
    @facets[name] = detail
    facet.xpath("search:facet-value").each do |facet_value|
      detail[facet_value.xpath("./@name").to_s] = facet_value.xpath("./@count").to_s
    end
  end
end