## Docker deployment for Laravel project
### Prereqs
- Docker and Docker composer
- Php and Composer
- Postgresql

### Instructions
1. Install php and Composer(global installation)
- Create laravel project
    composer create-project laravel/laravel <Project name>
    Configure database:
        'default' => env('DB_CONNECTION', 'psql')
        Add below content to .env file in root folder
        ```
            DB_CONNECTION=pgsql
            DB_HOST=127.0.0.1
            DB_PORT=5432
            DB_DATABASE=laraveltodos
            DB_USERNAME=postgres
            DB_PASSWORD=postgres
            DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/laraveltodos
        ```
    - Create app:
        php artisan make:model Todo -a
    - Modify app/Models/Todo.php file with below content
        ```php
        <?php

            namespace App\Models;

            use Illuminate\Database\Eloquent\Concerns\HasUuids;
            use Illuminate\Database\Eloquent\Factories\HasFactory;
            use Illuminate\Database\Eloquent\Model;

            class Todo extends Model
            {
                use HasFactory;
                use HasUuids;

                protected $table = 'todos';
                protected $primaryKey = 'id';
                protected $fillable = ['name', 'status'];
                protected $casts = ["id" => "string"];
            }
        ```
    - Create app/Models/TodoResponse.php file and add below content
        ```php
        <?php

            namespace App\Models;

            class TodoResponse
            {
                public bool $success;
                public string $message;
                public $payload;

                public function __construct(bool $success, string $message, $payload)
                {
                    $this->success = $success;
                    $this->message = $message;
                    $this->payload = $payload;
                }

                public function to_json()
                {
                    $res = [
                    "success" => $this->success,
                    "message" => $this->message,
                    "payload" => $this->payload
                    ];
                    return $res;
                }
            }
        ```
    - Update Todo table migration file
        ```php
        <?php

            use Illuminate\Database\Migrations\Migration;
            use Illuminate\Database\Schema\Blueprint;
            use Illuminate\Support\Facades\Schema;

            return new class extends Migration
            {
                /**
                * Run the migrations.
                *
                * @return void
                */
                public function up()
                {
                    Schema::create('todos', function (Blueprint $table) {
                        $table->uuid("id");
                        $table->string("name");
                        $table->boolean("status");
                        $table->timestamps();
                    });
                }

                /**
                * Reverse the migrations.
                *
                * @return void
                */
                public function down()
                {
                    Schema::dropIfExists('todos');
                }
            };
        ```
    - Update app/http/Controllers/TodoController.php file
    ```php
        <?php

        namespace App\Http\Controllers;

        use App\Http\Controllers\Controller;
        use App\Models\Todo;
        use App\Models\TodoResponse;
        use Ramsey\Uuid\Uuid;

        class TodoController extends Controller
        {
            public function index()
            {
                try {
                    $todos = Todo::orderBy("updated_at", "desc")->get();
                    $res = new TodoResponse(true, "Got todos", $todos);
                    return response($res->to_json(), 200, ["Content-Type" => "application/json"]);
                } catch (\Exception $e) {
                    $res = new TodoResponse(false, "Invalid request", $e->getMessage());
                    return response($res->to_json(), 500, ["Content-Type" => "application/json"]);
                }
            }

            public function store()
            {
                try {
                    $todo = new Todo();
                    $todo->id = Uuid::uuid4();
                    $todo->name = request("name");
                    $todo->status = request("status");
                    $data = $todo->saveOrFail();

                    if (!$data) {
                        $res = new TodoResponse(false, "Invalid request", null);
                        return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                    }
                    $res = new TodoResponse(true, "Created todo", $todo);
                    return response($res->to_json(), 201, ["Content-Type" => "application/json"]);
                } catch (\Exception $e) {
                    $res = new TodoResponse(false, "Invalid request", $e->getMessage());
                    return response($res->to_json(), 500, ["Content-Type" => "application/json"]);
                }
            }

            public function show($id)
            {
                try {
                    $todo = Todo::query()->where("id", "=", $id)->get();

                    if (!count($todo)) {
                        $res = new TodoResponse(false, "Invalid request", null);
                        return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                    }
                    $res = new TodoResponse(true, "Got todo", $todo);
                    return response($res->to_json(), 200, ["Content-Type" => "application/json"]);
                } catch (\Exception $e) {
                    $res = new TodoResponse(false, "Invalid request", $e->getMessage());
                    return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                }
            }

            public function update($id)
            {
                try {
                    $todo = Todo::query()->where("id", "=", $id)->get();

                    if (!count($todo)) {
                        $res = new TodoResponse(false, "Invalid request", null);
                        return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                    }

                    $updated_todo = new Todo();
                    $updated_todo->id = $id;
                    $updated_todo->name = request("name");
                    $updated_todo->status = request("status");

                    $result = Todo::query()->where("id", "=", $id)->update([
                        'id' => $id,
                        'name' => $updated_todo->name,
                        'status' => $updated_todo->status
                    ]);

                    if (!$result) {
                        $res = new TodoResponse(false, "Invalid request", null);
                        return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                    }

                    $res = new TodoResponse(true, "Updated todo", $updated_todo);
                    return response($res->to_json(), 201, ["Content-Type" => "application/json"]);
                } catch (\Exception $e) {
                    $res = new TodoResponse(false, "Invalid request", $e->getMessage());
                    return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                }
            }

            public function delete($id)
            {
                try {
                    $todo = Todo::query()->where('id', "=", $id);

                    if (!count($todo->get())) {
                        $res = new TodoResponse(false, "Invalid request", null);
                        return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                    }

                    $result = $todo->delete();

                    if (!$result) {
                        $res = new TodoResponse(false, "Invalid request", null);
                        return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                    }

                    $res = new TodoResponse(true, "Deleted todo", $todo);
                    return response($res->to_json(), 200, ["Content-Type" => "application/json"]);
                } catch (\Exception $e) {
                    $res = new TodoResponse(false, "Invalid request", $e->getMessage());
                    return response($res->to_json(), 400, ["Content-Type" => "application/json"]);
                }
            }
        }

    ```
    - Modify route routes/web.php
    ```php
        <?php

        use Illuminate\Support\Facades\Route;
        use App\Http\Controllers\TodoController;
        use App\Models\TodoResponse;

        /*
        |--------------------------------------------------------------------------
        | API Routes
        |--------------------------------------------------------------------------
        |
        | Here is where you can register API routes for your application. These
        | routes are loaded by the RouteServiceProvider within a group which
        | is assigned the "api" middleware group. Enjoy building your API!
        |
        */

        Route::get("/v1", function () {
            $res = new TodoResponse(true, "Message received", null);
            return response($res->to_json(), 200, ["Content-Type" => "application/json"]);
        });

        Route::get("/v1/todos", [TodoController::class, "index"])->name("todos.index");
        Route::get("/v1/todos/{id}", [TodoController::class, "show"])->name("todos.show");
        Route::post("/v1/todos", [TodoController::class, "store"])->name("todos.store");
        Route::put("/v1/todos/{id}", [TodoController::class, "update"])->name("todos.update");
        Route::delete("/v1/todos/{id}", [TodoController::class, "delete"])->name("todos.delete");
    ```
    - Start server
        php artisan serve --host 0.0.0.0:8000

2. Install postgresql and configure (You can verify with telnet)
    - Login to postgres 
        For PC: sudo -U postgres psql
        For container: sudo su postgres psql
    - Create database
        CREATE DATABASE laraveltodos;
    - Run migrate command
        php artisan migrate
    - Check the database and tables
        ```sql
            \c laravaltodos
            \d
            \d todos
            \dt todos
            SELECT * FROM todos;
        ```
    - 
3. Install docker and docker compose
    - Create Dockerfile in project root folder
    ```Dockerfile
        FROM php:8.1.16-zts-bullseye

        # Install system dependencies
        RUN apt-get update && apt-get install -y \
        git \
        curl \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        zip \
        unzip \
        libpq-dev

        # Clear cache
        RUN apt-get clean && rm -rf /var/lib/apt/lists/*

        # Install PHP extensions for postgres
        RUN docker-php-ext-install pdo pdo_pgsql
        RUN docker-php-ext-install mbstring exif pcntl bcmath gd

        # Get latest Composer
        COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

        WORKDIR /app
        COPY . .
        RUN composer install --prefer-dist --no-dev --optimize-autoloader --no-interaction

        ENV APP_ENV=production
        ENV APP_DEBUG=false
        ENV DB_PG_CONNECTION=pgsql
        ENV DB_PG_HOST=db
        ENV DB_PG_PORT=5432
        ENV DB_PG_DATABASE=laraveltodos
        ENV DB_PG_USERNAME=postgres
        ENV DB_PG_PASSWORD=postgres

        EXPOSE 8000

        CMD [ "sh", "-c", "./startup.sh" ]
    ```
    - Create Docker Compose file
    ```yaml
        services:
        api:
            container_name: api
            build:
            context: .
            image: api
            restart: always
            ports:
            - "8000:8000"
            env_file: ./.env
            volumes:
            - .:/api
            depends_on:
            - postgres

        postgres:
            container_name: db
            image: postgres:15.1-bullseye
            hostname: postgres
            ports:
            - "5432:5432"
            environment:
            - POSTGRES_PASSWORD=postgres
            - POSTGRES_USER=postgres
            - POSTGRES_DB=laraveltodos
            volumes:
            - data:/var/lib/postgresql/data
            restart: always

        volumes:
        data: {}
    ```
    - Update .env file 
    ```
        DB_CONNECTION=pgsql
        # DB_HOST=127.0.0.1
        DB_HOST=db
        DB_PORT=5432
        DB_DATABASE=laraveltodos
        DB_USERNAME=postgres
        DB_PASSWORD=postgres
        # DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/
        DATABASE_URL=postgresql://postgres:postgres@db:5432/
    ```
    - Create startup.sh file in project root
    ```bash
        #! /usr/bin/env sh
        php artisan config:cache
        php artisan route:cache
        sleep 15
        php artisan migrate
        php artisan serve --host=$(hostname -i) --port=8000
    ```
        - Give execute permission to file
            chmod +x ./*.sh
    - Build docker compose 
        docker compose up -d --build --remove-orphans -V
    - Shutdown the containers
        docker-compose down -v