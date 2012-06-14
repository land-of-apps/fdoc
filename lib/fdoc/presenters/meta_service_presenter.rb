# HtmlPresenter for Fdoc::MetaService
class Fdoc::MetaServicePresenter < Fdoc::HtmlPresenter
  attr_reader :meta_service

  def initialize(meta_service, options = {})
    super(options)
    @meta_service = meta_service
  end

  def to_html
    render_erb('meta_service.html.erb')
  end

  def services
    @services ||= meta_service.services.
      sort_by(&:name).
      map do |service|
        Fdoc::ServicePresenter.new(service, options)
      end
  end

  def endpoints
    if !@endpoints
      @endpoints = []
      prefix = nil

      ungrouped_endpoints = meta_service.
                              services.
                              map(&:endpoints).
                              flatten.
                              sort_by(&:endpoint_path)

      ungrouped_endpoints.each do |endpoint|
        presenter = Fdoc::EndpointPresenter.new(endpoint, options)
        presenter.service_presenter = self
        presenter

        current_prefix = presenter.prefix

        @endpoints << [] if prefix != current_prefix
        @endpoints.last << presenter

        prefix = current_prefix
      end
    end

    @endpoints
  end

  def description
    render_markdown(meta_service.description)
  end

  def discussion
    render_markdown(meta_service.discussion)
  end
end
