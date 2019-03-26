migrate-up:
	GO111MODULE=off kallax migrate up --all --dir migrations --dsn "$(DATABASE_URL)"

migration:
	GO111MODULE=off kallax migrate --input ./model/ --out ./migrations --name $(NAME)
