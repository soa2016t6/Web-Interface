# frozen_string_literal: true
# class
class SearchEvents
  extend Dry::Monads::Either::Mixin
  extend Dry::Container::Mixin

  register :check_input_valid, lambda { |param|

    if param.nil? || param.empty?
      Left(Error.new('Please enter a valid search'))
    else
      Right(param)
    end
  }
  register :get_search_results, lambda { |term|
    results =
      HTTP.get("#{EventsLocatorInterface.config.WEB_API_URL}/events/search/#{term}")
    if results.nil?
      Left(Error.new(:internal_error, 'Our servers failed - nothing here!'))
    else
      Right(EventsRepresenter.new(Events.new)
                             .from_json(results.body))
    end
  }

  def self.call(params)
    Dry.Transaction(container: self) do
      step :check_input_valid
      step :get_search_results
    end.call(params)
  end
end