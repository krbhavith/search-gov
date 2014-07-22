module Admin::FormColumnsHelper
  def affiliate_agency_form_column(record, options)
    agency_options = Agency.all.collect do |agency|
      [agency.friendly_name, agency.id]
    end

    select :record, :agency, agency_options, options.merge(include_blank: '- select -', selected: record.agency_id)
  end
end
