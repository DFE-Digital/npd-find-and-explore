# frozen_string_literal: true

PgSearch.multisearch_options = {
  using: {
    trigram: {},
    dmetaphone: {},
    tsearch: { prefix: true, dictionary: :english }
  }
}
