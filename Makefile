setup:
	bundle exec rails db:drop db:create db:schema:load db:migrate
	bundle exec rails db:seed