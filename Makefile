setup:
	rails db:drop db:create db:rollback db:migrate
	rails db:seed
run-rswag:
	SWAGGER_DRY_RUN=false rails rswag PATTERN="spec/controllers/*"