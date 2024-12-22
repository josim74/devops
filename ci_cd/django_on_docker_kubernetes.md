# Django with Docker and Kubernetes

## Table of Contents

1. [Overview](#overview)
2. [Dependencies](#dependencies)
3. [Django](#django)
4. [Docker](#docker)
5. [PostgreSQL](#postgresql)
6. [Notes](#notes)
7. [Gunicorn](#gunicorn)
8. [Production Dockerfile](#production-dockerfile)
9. [Static Files](#static-files)
10. [Media Files](#media-files)
11. [Production Update](#production-update)
12. [Conclusion](#conclusion)

---

## Overview
In this CI/CD project, I will develop a Django application from scratch, containerize it, and run it using Docker Compose. The objective is to follow best practices for production-level deployment as closely as possible. Subsequently, I will deploy the application in a Kubernetes cluster using Minikube (a local setup, with an emphasis on production-level best practices). **This documentation serves as an instructional guide, focusing on concise steps rather than detailed explanations.**

## Dependencies
- Django v4.2.3
- Docker v24.0.2
- Python v3.11.4

## Django
1. Project setup
   ```bash
   mkdir django-on-docker && cd django-on-docker
   mkdir app && cd app
   python3 -m venv env
   source env/bin/activate
   (env)$ pip install django==4.2.3
   (env)$ django-admin startproject hello_django .
   (env)$ python manage.py migrate
   (env)$ python manage.py runserver
   ```
   - Check Django welcome screen on 'localhost:8000' and kill the server once done
   - Then exit `deactivate` and remove `rm -rf ./env` the venv. We now have a simple django project to work with

2. Create `django-on-docker/app/requirements.txt` file
   ```bash
   Django==4.2.3
   ```
3. Architecture should look like
   ```bash
   └── app
    ├── hello_django
    │   ├── __init__.py
    │   ├── asgi.py
    │   ├── settings.py
    │   ├── urls.py
    │   └── wsgi.py
    ├── manage.py
    └── requirements.txt
   ```

## Docker
1. Create `django-on-docker/Dockerfile` file
   ```yaml
   # pull official base image
    FROM python:3.11.4-slim-buster

    # set work directory
    WORKDIR /usr/src/app

    # set environment variables
    ENV PYTHONDONTWRITEBYTECODE 1
    ENV PYTHONUNBUFFERED 1

    # install dependencies
    RUN pip install --upgrade pip
    COPY ./requirements.txt .
    RUN pip install -r requirements.txt

    # copy project
    COPY . .
   ```
2. Create `docker-on-docker/docker-compose.yml` file
   ```yaml
    version: '3.8'

    services:
    web:
        build: ./app
        command: python manage.py runserver 0.0.0.0:8000
        volumes:
        - ./app/:/usr/src/app/
        ports:
        - 8000:8000
        env_file:
        - ./.env.dev
   ```
3. Update `app/hello_django/settings.py`
    ```python
    import os # At the top

    SECRET_KEY = os.environ.get("SECRET_KEY")

    DEBUG = bool(os.environ.get("DEBUG", default=0))

    # 'DJANGO_ALLOWED_HOSTS' should be a single string of hosts with a space between each.
    # For example: 'DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]'
    ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS").split(" ")
    ```
4. Create `django-on-docker/.env.dev`
    ```python
    DEBUG=1
    SECRET_KEY=foo
    DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
    ```

5. Build docker image using compose file
    ```bash
    docker-compose build
    ```
6. Run the container once built
    ```bash
    docker-compose up -d
    ```
    - Navigate to http://localhost:8000 to again view the welcome screen
## PostgreSQL
1. Update `django-on-dockr/docker-compose.yml` adding new service `db`
    ```yaml
    version: '3.8'

    services:
    web:
        build: ./app
        command: python manage.py runserver 0.0.0.0:8000
        volumes:
        - ./app/:/usr/src/app/
        ports:
        - 8000:8000
        env_file:
        - ./.env.dev
        depends_on:
        - db
    db:
        image: postgres:15
        volumes:
        - postgres_data:/var/lib/postgresql/data/
        environment:
        - POSTGRES_USER=hello_django
        - POSTGRES_PASSWORD=hello_django
        - POSTGRES_DB=hello_django_dev

    volumes:
    postgres_data:
    ```
2. Update `django-on-docker/.env.dev`
    ```
    DEBUG=1
    SECRET_KEY=foo
    DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
    SQL_ENGINE=django.db.backends.postgresql
    SQL_DATABASE=hello_django_dev
    SQL_USER=hello_django
    SQL_PASSWORD=hello_django
    SQL_HOST=db
    SQL_PORT=5432
    ```
3. Update `app/hello_django/settings.py`
    ```python
    DATABASES = {
        "default": {
            "ENGINE": os.environ.get("SQL_ENGINE", "django.db.backends.sqlite3"),
            "NAME": os.environ.get("SQL_DATABASE", BASE_DIR / "db.sqlite3"),
            "USER": os.environ.get("SQL_USER", "user"),
            "PASSWORD": os.environ.get("SQL_PASSWORD", "password"),
            "HOST": os.environ.get("SQL_HOST", "localhost"),
            "PORT": os.environ.get("SQL_PORT", "5432"),
        }
    }
    ```
4. Update `requirements.txt`
    ```
    Django==4.2.3
    psycopg2-binary==2.9.6
    ```
5. Build and run the two containers 
    ```bash
    docker-compose up -d --build
    ```
6. Run migration
    ```bash
    docker-compose exec web python manage.py migrate --noinput
    ```
    - If you encounter with error `django.db.utils.OperationalError: FATAL:  database "hello_django_dev" does not exist` then remove the volume along with containers. Then re-build, run and apply the migrations
        ```bash
        docker-compose down -v
        docker-compose up -d --build
        docker-compose exec web python manage.py migrate --noinput
        ```
7. Verify the db tables has created
    ```bash
    docker-compose exec db psql --username=hello_django --dbname=hello_django_dev

    # DB commands
    \l                      # list of databases
    \c hello_django_dev     # connect to hello_django_dev db
    \dt                     # list of tables
    ```
8. Check the volume has created
    ```bash
    docker volume inspect django-on-docker_postgres_data
    ```
9. Create `app/entrypoint.sh` to verify postgres is ready before running migrations
    ```bash
    #!/bin/sh

    if [ "$DATABASE" = "postgres" ]
    then
        echo "Waiting for postgres..."

        while ! nc -z $SQL_HOST $SQL_PORT; do
        sleep 0.1
        done

        echo "PostgreSQL started"
    fi

    python manage.py flush --no-input
    python manage.py migrate

    exec "$@"
    ```
    - update the file permission `chmod +x app/entrypoint.sh`
10. Update `django-on-docker/Dockerfile` to copy and run `entrypoint.sh` script
    ```yaml
    # pull official base image
    FROM python:3.11.4-slim-buster

    # set work directory
    WORKDIR /usr/src/app

    # set environment variables
    ENV PYTHONDONTWRITEBYTECODE 1
    ENV PYTHONUNBUFFERED 1

    # install system dependencies
    RUN apt-get update && apt-get install -y netcat

    # install dependencies
    RUN pip install --upgrade pip
    COPY ./requirements.txt .
    RUN pip install -r requirements.txt

    # copy entrypoint.sh
    COPY ./entrypoint.sh .
    RUN sed -i 's/\r$//g' /usr/src/app/entrypoint.sh
    RUN chmod +x /usr/src/app/entrypoint.sh

    # copy project
    COPY . .

    # run entrypoint.sh
    ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
    ```
11. Update `django-on-docker/.env.dev` adding `database` environment variable
    ```python
    DEBUG=1
    SECRET_KEY=foo
    DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
    SQL_ENGINE=django.db.backends.postgresql
    SQL_DATABASE=hello_django_dev
    SQL_USER=hello_django
    SQL_PASSWORD=hello_django
    SQL_HOST=db
    SQL_PORT=5432
    DATABASE=postgres
    ```
12. Test it again
    1. Re-build the images
    2. Run the containers
    3. Try `localhost:8000`
## Notes
1. We can build and run the container without DB as long as DATABASE env not set to `postgres`
    ```bash
    docker build -f ./app/Dockerfile -t hello_django:latest ./app
    docker run -d \
        -p 8006:8000 \
        -e "SECRET_KEY=please_change_me" -e "DEBUG=1" -e "DJANGO_ALLOWED_HOSTS=*" \
        hello_django python /usr/src/app/manage.py runserver 0.0.0.0:8000
    ```
    - Verify welcome page at http://localhost:8006
2. you may want to comment out the database flush and migrate commands in the `entrypoint.sh` script so they don't run on every container start or re-start
    ```bash
    #!/bin/sh

    if [ "$DATABASE" = "postgres" ]
    then
        echo "Waiting for postgres..."

        while ! nc -z $SQL_HOST $SQL_PORT; do
        sleep 0.1
        done

        echo "PostgreSQL started"
    fi

    # python manage.py flush --no-input
    # python manage.py migrate

    exec "$@"
    ```
    - Instead, you can run them manually, after the containers spin up, like so
        ```bash
        docker-compose exec web python manage.py flush --no-input
        docker-compose exec web python manage.py migrate
        ```
## Gunicorn
1. Moving along, for production environments, let's add Gunicorn, a production-grade WSGI server, to the `django-ond-docker/requirements.txt` file
    ```
    Django==4.2.3
    gunicorn==21.2.0
    psycopg2-binary==2.9.6
    ```
2. Since we still want to use Django's built-in server in development, create a new compose file called `docker-compose.prod.yml` for production
    ```yaml
    version: '3.8'

    services:
    web:
        build: ./app
        command: gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000
        ports:
        - 8000:8000
        env_file:
        - ./.env.prod
        depends_on:
        - db
    db:
        image: postgres:15
        volumes:
        - postgres_data:/var/lib/postgresql/data/
        env_file:
        - ./.env.prod.db

    volumes:
    postgres_data:
    ```
    If you have multiple environments, you may want to look at using a [docker-compose.override.yml](https://docs.docker.com/compose/extends/) configuration file
3. Create separate `django-on-docker/env.prod` file for production
    ```python
    DEBUG=0
    SECRET_KEY=change_me
    DJANGO_ALLOWED_HOSTS=localhost 127.0.0.1 [::1]
    SQL_ENGINE=django.db.backends.postgresql
    SQL_DATABASE=hello_django_prod
    SQL_USER=hello_django
    SQL_PASSWORD=hello_django
    SQL_HOST=db
    SQL_PORT=5432
    DATABASE=postgres
    ```
4. Create `django-on-docker/.env.prod.db`
    ```python
    POSTGRES_USER=hello_django
    POSTGRES_PASSWORD=hello_django
    POSTGRES_DB=hello_django_prod
    ```
    It is best practice to add both files in `.gitignore` file
5. Bring down development containers `docker-compose down -v`
6. Then build the production images and spine up the containers
    ```bash
    docker-compose -f docker-compose.prod.yml up -d --build
    ```
    Verify the `hello-django-prod` db and django default tables created. Also check the admin site `http://lohalhost:8000/admin` static files will not load. And you face any issue then check the log `docker-compose -f docker-compose.prod.yml logs -f`
## Production Dockerfile
1. We should not run database flush in production. So create `app/entrypoint.prod.sh`
    ```bash
    #!/bin/sh

    if [ "$DATABASE" = "postgres" ]
    then
        echo "Waiting for postgres..."

        while ! nc -z $SQL_HOST $SQL_PORT; do
        sleep 0.1
        done

        echo "PostgreSQL started"
    fi

    exec "$@"
    ```
    - Update file permission `chmod +x app/entrypoint.prod.sh`
2. Create `Dockerfile.prod` for production
    ```yaml
    ###########
    # BUILDER #
    ###########

    # pull official base image
    FROM python:3.11.4-slim-buster as builder

    # set work directory
    WORKDIR /usr/src/app

    # set environment variables
    ENV PYTHONDONTWRITEBYTECODE 1
    ENV PYTHONUNBUFFERED 1

    # install system dependencies
    RUN apt-get update && \
        apt-get install -y --no-install-recommends gcc

    # lint
    RUN pip install --upgrade pip
    RUN pip install flake8==6.0.0
    COPY . /usr/src/app/
    RUN flake8 --ignore=E501,F401 .

    # install python dependencies
    COPY ./requirements.txt .
    RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


    #########
    # FINAL #
    #########

    # pull official base image
    FROM python:3.11.4-slim-buster

    # create directory for the app user
    RUN mkdir -p /home/app

    # create the app user
    RUN addgroup --system app && adduser --system --group app

    # create the appropriate directories
    ENV HOME=/home/app
    ENV APP_HOME=/home/app/web
    RUN mkdir $APP_HOME
    WORKDIR $APP_HOME

    # install dependencies
    RUN apt-get update && apt-get install -y --no-install-recommends netcat
    COPY --from=builder /usr/src/app/wheels /wheels
    COPY --from=builder /usr/src/app/requirements.txt .
    RUN pip install --upgrade pip
    RUN pip install --no-cache /wheels/*

    # copy entrypoint.prod.sh
    COPY ./entrypoint.prod.sh .
    RUN sed -i 's/\r$//g'  $APP_HOME/entrypoint.prod.sh
    RUN chmod +x  $APP_HOME/entrypoint.prod.sh

    # copy project
    COPY . $APP_HOME

    # chown all the files to the app user
    RUN chown -R app:app $APP_HOME

    # change to the app user
    USER app

    # run entrypoint.prod.sh
    ENTRYPOINT ["/home/app/web/entrypoint.prod.sh"]
    ```
    - Used multi-stage build and created non-root user for better protection
3. Update `docker-compose.prod.yml` file to build with `Dockerfile.prod` file 
    ```yaml
    web:
    build:
        context: ./app
        dockerfile: Dockerfile.prod
    command: gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000
    ports:
        - 8000:8000
    env_file:
        - ./.env.prod
    depends_on:
        - db
    ```
4. Now test it out
    ```bash
    docker-compose -f docker-compose.prod.yml down -v
    docker-compose -f docker-compose.prod.yml up -d --build
    docker-compose -f docker-compose.prod.yml exec web python manage.py migrate --noinput
    ```
## Nginx for reverse proxy and static files
1. Add the service to `docker-compose.prod.yml`
    ```yml
    nginx:
    build: ./nginx
    ports:
        - 1337:80
    depends_on:
        - web
    ```
2. Then create following files in project root
    ```
    └── nginx
        ├── Dockerfile
        └── nginx.conf
    ```
    - Dockerfile
        ```yaml
        FROM nginx:1.25

        RUN rm /etc/nginx/conf.d/default.conf
        COPY nginx.conf /etc/nginx/conf.d
        ```
    - nginx.conf
        ```
        upstream hello_django {
            server web:8000;
        }

        server {

            listen 80;

            location / {
                proxy_pass http://hello_django;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $host;
                proxy_redirect off;
            }

        }
        ```
3. Update `web` service in `docker-compose.prod.yml` with `ports` with `expose`
    ```yaml
    web:
    build:
        context: ./app
        dockerfile: Dockerfile.prod
    command: gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000
    expose:
        - 8000
    env_file:
        - ./.env.prod
    depends_on:
        - db
    ```
    - Now, port 8000 is only exposed internally, to other Docker services. The port will no longer be published to the host machine
4. Test it out again
    ```bash
    docker-compose -f docker-compose.prod.yml down -v
    docker-compose -f docker-compose.prod.yml up -d --build
    docker-compose -f docker-compose.prod.yml exec web python manage.py migrate --noinput
    ```
    - Verify the app is running `http://localhost:1337`
5. Project structure
    ```
    ├── .env.dev
    ├── .env.prod
    ├── .env.prod.db
    ├── .gitignore
    ├── app
    │   ├── Dockerfile
    │   ├── Dockerfile.prod
    │   ├── entrypoint.prod.sh
    │   ├── entrypoint.sh
    │   ├── hello_django
    │   │   ├── __init__.py
    │   │   ├── asgi.py
    │   │   ├── settings.py
    │   │   ├── urls.py
    │   │   └── wsgi.py
    │   ├── manage.py
    │   └── requirements.txt
    ├── docker-compose.prod.yml
    ├── docker-compose.yml
    └── nginx
        ├── Dockerfile
        └── nginx.conf
    ```
6. Bring down the containers 
    ```bash
    docker-compose -f docker-compose.prod.yml down -v
    ```
## Static Files
Since Gunicorn is an application server, it will not serve up static files. So, how should both static and media files be handled in this particular configuration?
1. Update `settings.py`
    ```python
    STATIC_URL = "/static/"
    STATIC_ROOT = BASE_DIR / "staticfiles"
    ```
2. For development
    - Now, any request to `http://localhost:8000/static/*` will be served from the "staticfiles" directory.

    - To test, first re-build the images and spin up the new containers per usual. Ensure static files are still being served correctly at `http://localhost:8000/admin`
3. For production
    - add a volume to the `web` and `nginx` services in `docker-compose.prod.yml` so that each container will share a directory named "staticfiles"
        ```yaml
        version: '3.8'

        services:
        web:
            build:
            context: ./app
            dockerfile: Dockerfile.prod
            command: gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000
            volumes:
            - static_volume:/home/app/web/staticfiles
            expose:
            - 8000
            env_file:
            - ./.env.prod
            depends_on:
            - db
        db:
            image: postgres:15
            volumes:
            - postgres_data:/var/lib/postgresql/data/
            env_file:
            - ./.env.prod.db
        nginx:
            build: ./nginx
            volumes:
            - static_volume:/home/app/web/staticfiles
            ports:
            - 1337:80
            depends_on:
            - web

        volumes:
        postgres_data:
        static_volume:
        ```
    - We need to also create the "/home/app/web/staticfiles" folder in Dockerfile.prod
        ```yaml
        # create the appropriate directories
        ENV HOME=/home/app
        ENV APP_HOME=/home/app/web
        RUN mkdir $APP_HOME
        RUN mkdir $APP_HOME/staticfiles
        WORKDIR $APP_HOME
        ```
        Docker Compose normally mounts named volumes as root. And since we're using a non-root user, we'll get a permission denied error when the collectstatic command is run if the directory does not already exist. To get around this, you can do either -
        1. Create the folder in the Dockerfile ([source](https://github.com/docker/compose/issues/3270#issuecomment-206214034)) `We are using this one`
        2. Change the permissions of the directory after it's mounted ([source](https://stackoverflow.com/a/40510068/1799408))
    - Update nginx configuration to route static file requests to the `staticfiles` folder
        ```
        upstream hello_django {
            server web:8000;
        }

        server {

            listen 80;

            location / {
                proxy_pass http://hello_django;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $host;
                proxy_redirect off;
            }

            location /static/ {
                alias /home/app/web/staticfiles/;
            }

        }
        ```
4. Bring down dev containers `docker-compose down -v` and test the production
    ```bash
    docker-compose -f docker-compose.prod.yml up -d --build
    docker-compose -f docker-compose.prod.yml exec web python manage.py migrate --noinput
    docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --no-input --clear
    ```
    - Any request to `http://localhost:1337/static/*` will be served from the "staticfiles" directory.
    - Navigate to `http://localhost:1337/admin` and ensure the static assets load correctly.
    - You can also verify in the logs -- via `docker-compose -f docker-compose.prod.yml logs -f` that requests to the static files are served up successfully via Nginx
5. Bring down the containers once done
    ```bash
    docker-compose -f docker-compose.prod.yml down -v
    ```
## Media Files
To test out the handling of media files, start by creating a new Django app
1. Bring up the dev env and create `upload` app
    ```bash
    docker-compose up -d --build
    docker-compose exec web python manage.py startapp upload
    ```
2. Add the new app to the INSTALLED_APPS list in `settings.py`
    ```python
    INSTALLED_APPS = [
        "django.contrib.admin",
        "django.contrib.auth",
        "django.contrib.contenttypes",
        "django.contrib.sessions",
        "django.contrib.messages",
        "django.contrib.staticfiles",

        "upload",
    ]
    ```
3. Update `app/upload/views.py`
    ```python
    from django.shortcuts import render
    from django.core.files.storage import FileSystemStorage


    def image_upload(request):
        if request.method == "POST" and request.FILES["image_file"]:
            image_file = request.FILES["image_file"]
            fs = FileSystemStorage()
            filename = fs.save(image_file.name, image_file)
            image_url = fs.url(filename)
            print(image_url)
            return render(request, "upload.html", {
                "image_url": image_url
            })
        return render(request, "upload.html")
    ```
4. Create a `templates` directory and `app/upload/templates/upload.html`
    ```html
    {% block content %}

    <form action="{% url "upload" %}" method="post" enctype="multipart/form-data">
        {% csrf_token %}
        <input type="file" name="image_file">
        <input type="submit" value="submit" />
    </form>

    {% if image_url %}
        <p>File uploaded at: <a href="{{ image_url }}">{{ image_url }}</a></p>
    {% endif %}

    {% endblock %}
    ```
5. Update `app/hello_django/urls.py`
    ```python
    from django.contrib import admin
    from django.urls import path
    from django.conf import settings
    from django.conf.urls.static import static

    from upload.views import image_upload

    urlpatterns = [
        path("", image_upload, name="upload"),
        path("admin/", admin.site.urls),
    ]

    if bool(settings.DEBUG):
        urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    ```
6. Update `app/hell_django/settings.py`
    ```python
    MEDIA_URL = "/media/"
    MEDIA_ROOT = BASE_DIR / "mediafiles"
    ```
7. Test it out
    ```bash
    docker-compose up -d --build
    ```
    - You should be able to upload an image at `http://localhost:8000/` and view at `http://localhost:8000/media/IMAGE_FILE_NAME`

## Production update
1. add another volume to the `web` and `nginx` services
    ```yaml
    version: '3.8'

    services:
    web:
        build:
        context: ./app
        dockerfile: Dockerfile.prod
        command: gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000
        volumes:
        - static_volume:/home/app/web/staticfiles
        - media_volume:/home/app/web/mediafiles
        expose:
        - 8000
        env_file:
        - ./.env.prod
        depends_on:
        - db
    db:
        image: postgres:15
        volumes:
        - postgres_data:/var/lib/postgresql/data/
        env_file:
        - ./.env.prod.db
    nginx:
        build: ./nginx
        volumes:
        - static_volume:/home/app/web/staticfiles
        - media_volume:/home/app/web/mediafiles
        ports:
        - 1337:80
        depends_on:
        - web

    volumes:
    postgres_data:
    static_volume:
    media_volume:
    ```
2. Create the `/home/app/web/mediafiles` folder in Dockerfile.prod
    ```Dockerfile
    # create the appropriate directories
    ENV HOME=/home/app
    ENV APP_HOME=/home/app/web
    RUN mkdir $APP_HOME
    RUN mkdir $APP_HOME/staticfiles
    RUN mkdir $APP_HOME/mediafiles
    WORKDIR $APP_HOME
    ```
3. Update the Nginx config again
    ```
    upstream hello_django {
        server web:8000;
    }

    server {

        listen 80;

        location / {
            proxy_pass http://hello_django;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_redirect off;
        }

        location /static/ {
            alias /home/app/web/staticfiles/;
        }

        location /media/ {
            alias /home/app/web/mediafiles/;
        }

    }
    ```
4. Add the following to `settings.py`
    ```python
    CSRF_TRUSTED_ORIGINS = ["http://localhost:1337"]
    ```
5. Re-build and test
    ```bash
    docker-compose down -v

    docker-compose -f docker-compose.prod.yml up -d --build
    docker-compose -f docker-compose.prod.yml exec web python manage.py migrate --noinput
    docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --no-input --clear
    ```
    - Upload an image at `http://localhost:1337/`
    - Then, view the image at `http://localhost:1337/media/IMAGE_FILE_NAME`
    - If you see `413 Request Entity Too Large` error. Increase the size of client request body in nginx config
        ```
            location / {
            proxy_pass http://hello_django;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_redirect off;
            client_max_body_size 100M;
        }
        ```
## Conclusion
In terms of actual deployment to a production environment, you'll probably want to use a - 
1. Fully managed database service -- like RDS or Cloud SQL -- rather than managing your own Postgres instance within a container.
2. Non-root user for the db and nginx services

## [Next: Deployment in Kubernetes cluster](https://github.com/josim74/devops/blob/main/kubernetes/django_on_kubernetes.md)

