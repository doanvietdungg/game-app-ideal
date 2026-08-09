# Monorepo Restructuring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the existing Laravel backend codebase into a `backend/` subdirectory and update Docker and Nginx configurations to point to `./backend` so that the root remains clean for the upcoming `mobile/` Flutter app.

**Architecture:** Monorepo architecture where backend and mobile codebases live in parallel subdirectories. The Docker Compose configuration stays at the root for easy orchestration.

**Tech Stack:** Docker, Nginx, Laravel, Git.

## Global Constraints
- Do not move `.git`, `.gitignore`, or `docs/` directories.
- All Docker Compose operations must remain runnable from the repository root.
- Ensure the Laravel backend can be fully migrated and seeded, and tests pass after restructuring.

---

### Task 1: Restructure Directories

Create the `backend/` directory and move all Laravel files into it, keeping git-related files and documentation at the root.

**Files:**
- Create: `backend/` (directory)
- Modify: `.gitignore` (update paths)

- [ ] **Step 1: Create the backend directory**
  Run: `mkdir -p backend`

- [ ] **Step 2: Move Laravel files and folders to backend/**
  Run commands to move all files to `backend/` except `.git`, `docs`, `backend`, and git configurations:
  ```bash
  mv app bootstrap config database public resources routes src storage tests docker artisan composer.json composer.lock package.json package-lock.json postcss.config.js tailwind.config.js vite.config.js phpunit.xml .editorconfig .env .env.example .npmrc backend/
  ```

- [ ] **Step 3: Update root .gitignore**
  Update `.gitignore` to ignore backend node_modules, vendor, storage, and build assets:
  Modify: `.gitignore`
  ```
  /backend/node_modules
  /backend/vendor
  /backend/storage/*.key
  /backend/public/storage
  /backend/public/build
  /backend/.env
  /backend/.phpunit.result.cache
  ```

- [ ] **Step 4: Commit directory move**
  ```bash
  git add .
  git commit -m "refactor(monorepo): move Laravel backend files to backend/ directory"
  ```

---

### Task 2: Update Docker & Web Server Configuration

Update the root `docker-compose.yml` to mount `./backend` instead of `.` and reference the correct directories.

**Files:**
- Modify: `docker-compose.yml`

- [ ] **Step 1: Modify docker-compose.yml paths**
  Change build context and volume paths to `./backend`:
  ```yaml
  name: kidtime

  services:
    app:
      build:
        context: ./backend
        dockerfile: docker/php/Dockerfile
      container_name: kidtime-app
      restart: unless-stopped
      working_dir: /var/www
      volumes:
        - ./backend:/var/www
      networks:
        - kidtime-net

    web:
      image: nginx:alpine
      container_name: kidtime-web
      restart: unless-stopped
      ports:
        - "8000:80"
      volumes:
        - ./backend:/var/www
        - ./backend/docker/nginx/conf.d/app.conf:/etc/nginx/conf.d/default.conf
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

- [ ] **Step 2: Rebuild and restart Docker containers**
  Run: `docker compose down && docker compose up -d --build`
  Expected: Containers rebuild and start successfully.

- [ ] **Step 3: Run migrations and seeders to verify database connection**
  Run: `docker compose exec -T app php artisan migrate:fresh --seed`
  Expected: Database migrated and seeded successfully.

- [ ] **Step 4: Run test suite to verify everything passes**
  Run: `docker compose exec -T app php artisan test`
  Expected: All 15 tests pass.

- [ ] **Step 5: Commit**
  ```bash
  git add docker-compose.yml .gitignore
  git commit -m "refactor(docker): update Compose and conf paths for backend/ directory"
  ```
