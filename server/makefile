debug:
	flask --app flaskr run --debug

run:
	gunicorn --bind 0.0.0.0:5000 wsgi:app

create-db:
	flask --app flaskr create-db