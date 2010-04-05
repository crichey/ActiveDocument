Rails.root.join('Config')

class Incident < ActiveDocument::Base
  default_namespace "http://wits.nctc.gov"
end