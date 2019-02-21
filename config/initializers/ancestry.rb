module Ancestry
  # Setting the pattern this way silences the warning when
  # we overwrite a constant
  send :remove_const, :ANCESTRY_PATTERN

  # Change the Ancestry validation pattern to match UUIDS (instead of integers)
  # see: https://github.com/stefankroes/ancestry/wiki/Usage-with-UUID's
  const_set :ANCESTRY_PATTERN, /\A[\w\-]+(\/[\w\-]+)*\z/
end
