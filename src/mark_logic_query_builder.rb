module ActiveDocument

  class MarkLogicQueryBuilder

    def load(uri)
      "fn:doc('#{uri}')"
    end

    def find_by_word(word, root, namespace)
xquery = <<GENERATED
import module namespace search = "http://marklogic.com/appservices/search"at "/MarkLogic/appservices/search/search.xqy";
search:search("#{word}",
<options xmlns="http://marklogic.com/appservices/search">
<searchable-expression
GENERATED
      xquery << "  xmlns:a=\"#{namespace}\"" unless namespace.nil? or namespace.empty?
      xquery << '>/'
      xquery << "a:" unless namespace.nil? or namespace.empty?
      xquery << "#{root}</searchable-expression></options>)"
    end
  end

end