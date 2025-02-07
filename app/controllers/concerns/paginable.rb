module Paginable
  extend ActiveSupport::Concern

  def render_paginated(collection, pagination_params, serializer:)
    paginated = JSOM::Pagination::Paginator.new.call(collection, params: pagination_params, base_url: request.url)
    options = {
      meta: paginated.meta.to_h, # Will get total pages, total count, etc.
      links: paginated.links.to_h
    }

    render json: serializer.new(paginated.items, options).serializable_hash, status: :ok
  end
end
