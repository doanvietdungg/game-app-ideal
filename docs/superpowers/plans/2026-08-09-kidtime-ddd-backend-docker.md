# KidTime DDD & Clean Architecture Backend (Docker) Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Xây dựng Laravel 11 Backend theo kiến trúc **Domain-Driven Design (DDD) & Clean Architecture**, chạy hoàn toàn trên môi trường **Docker Containers** (PHP 8.3 FPM + Nginx + MySQL 8.0).

**Architecture (Clean Architecture / DDD Layers):**
1. **Domain Layer (`src/Domain`)**: Business Entities, Value Objects, Domain Events, Enums, Repository Interfaces. Độc lập hoàn toàn với framework.
2. **Application Layer (`src/Application`)**: Use Cases, DTOs, Application Services. Điều phối luồng nghiệp vụ.
3. **Infrastructure Layer (`src/Infrastructure`)**: Eloquent Models, Implementations của Repositories, Database Migrations, Services bên ngoài (FCM Push Notification, File Storage).
4. **Presentation Layer (`src/Presentation`)**: API Controllers (v1), Form Requests, API Resources, Web Inertia Controllers.

**Docker Services:**
- `app`: PHP 8.3-FPM (với Composer, pdo_mysql, bcmath, gd, zip)
- `web`: Nginx 1.25 (Reverse proxy cho Web & API)
- `db`: MySQL 8.0 (Port 3306)

---

## Structure Overview

```
/Users/glenfiddich-jace/projects/ideal/
├── docker/
│   ├── nginx/conf.d/app.conf
│   └── php/Dockerfile
├── docker-compose.yml
├── src/
│   ├── Domain/
│   │   ├── Family/
│   │   ├── Child/
│   │   ├── Task/
│   │   └── Reward/
│   ├── Application/
│   │   ├── Family/
│   │   ├── Child/
│   │   ├── Task/
│   │   └── Reward/
│   ├── Infrastructure/
│   │   ├── Persistence/
│   │   │   ├── Eloquent/
│   │   │   └── Repositories/
│   │   └── Notifications/
│   └── Presentation/
│       ├── Api/V1/
│       └── Web/
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   ├── api.php
│   └── web.php
└── composer.json
```

---

## Task 1: Environment Setup — Docker Compose & Laravel Initialization

**Files:**
- Create: `docker/php/Dockerfile`
- Create: `docker/nginx/conf.d/app.conf`
- Create: `docker-compose.yml`
- Create: `.env`
- Initialize: Laravel framework files inside container

- [ ] **Step 1: Create Dockerfile for PHP 8.3**

```dockerfile
# docker/php/Dockerfile
FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
```

- [ ] **Step 2: Create Nginx config**

```nginx
# docker/nginx/conf.d/app.conf
server {
    listen 80;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/public;

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }

    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}
```

- [ ] **Step 3: Create docker-compose.yml**

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: docker/php/Dockerfile
    container_name: kidtime-app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - .:/var/www
    networks:
      - kidtime-net

  web:
    image: nginx:alpine
    container_name: kidtime-web
    restart: unless-stopped
    ports:
      - "8000:80"
    volumes:
      - .:/var/www
      - ./docker/nginx/conf.d/app.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - kidtime-net

  db:
    image: mysql:8.0
    container_name: kidtime-db
    restart: unless-stopped
    environment:
      MYSQL_DATABASE: kidtime
      MYSQL_ROOT_PASSWORD: root
    ports:
      - "3306:3306"
    volumes:
      - dbdata:/var/lib/mysql
    networks:
      - kidtime-net

networks:
  kidtime-net:
    driver: bridge

volumes:
  dbdata:
    driver: local
```

- [ ] **Step 4: Build & Start Docker containers and Initialize Laravel**

Run container setup and install Laravel via composer inside container.

---

## Task 2: Domain Layer — Enums, Value Objects & Entities

**Files:**
- Create: `src/Domain/Family/Entities/Family.php`
- Create: `src/Domain/Family/ValueObjects/FamilyPin.php`
- Create: `src/Domain/Child/Entities/Child.php`
- Create: `src/Domain/Child/Entities/Pet.php`
- Create: `src/Domain/Child/Enums/PetSpecies.php`
- Create: `src/Domain/Child/Enums/PetStage.php`
- Create: `src/Domain/Child/Enums/PetMood.php`
- Create: `src/Domain/Child/ValueObjects/Stars.php`
- Create: `src/Domain/Task/Entities/Task.php`
- Create: `src/Domain/Task/Entities/TaskLog.php`
- Create: `src/Domain/Task/Enums/TaskCategory.php`
- Create: `src/Domain/Task/Enums/VerificationMode.php`
- Create: `src/Domain/Task/Enums/Recurrence.php`
- Create: `src/Domain/Task/Enums/TaskLogStatus.php`
- Create: `src/Domain/Reward/Entities/Reward.php`

---

## Task 3: Infrastructure Layer — Migrations & Eloquent Models & Repositories

**Files:**
- Create: `database/migrations/2026_08_09_000001_create_families_table.php`
- Create: `database/migrations/2026_08_09_000002_create_children_table.php`
- Create: `database/migrations/2026_08_09_000003_create_pets_table.php`
- Create: `database/migrations/2026_08_09_000004_create_tasks_table.php`
- Create: `database/migrations/2026_08_09_000005_create_task_logs_table.php`
- Create: `database/migrations/2026_08_09_000006_create_rewards_table.php`
- Create: `src/Infrastructure/Persistence/Eloquent/FamilyModel.php`
- Create: `src/Infrastructure/Persistence/Eloquent/ChildModel.php`
- Create: `src/Infrastructure/Persistence/Eloquent/PetModel.php`
- Create: `src/Infrastructure/Persistence/Eloquent/TaskModel.php`
- Create: `src/Infrastructure/Persistence/Eloquent/TaskLogModel.php`
- Create: `src/Infrastructure/Persistence/Repositories/EloquentFamilyRepository.php`
- Create: `src/Infrastructure/Persistence/Repositories/EloquentChildRepository.php`
- Create: `src/Infrastructure/Persistence/Repositories/EloquentTaskRepository.php`

---

## Task 4: Application Layer — Use Cases

**Files:**
- Create: `src/Application/Family/UseCases/RegisterFamilyUseCase.php`
- Create: `src/Application/Family/UseCases/LoginParentUseCase.php`
- Create: `src/Application/Family/UseCases/VerifyChildPinUseCase.php`
- Create: `src/Application/Child/UseCases/CreateChildUseCase.php`
- Create: `src/Application/Task/UseCases/SubmitTaskLogUseCase.php`
- Create: `src/Application/Task/UseCases/ApproveTaskLogUseCase.php`
- Create: `src/Application/Task/UseCases/RejectTaskLogUseCase.php`

---

## Task 5: Presentation Layer — API Controllers & PSR-4 Autoloading

**Files:**
- Modify: `composer.json` (add `"App\\": "app/", "KidTime\\": "src/"`)
- Create: `src/Presentation/Api/V1/AuthController.php`
- Create: `src/Presentation/Api/V1/ChildController.php`
- Create: `src/Presentation/Api/V1/TaskController.php`
- Create: `src/Presentation/Api/V1/TaskLogController.php`
- Modify: `routes/api.php`
