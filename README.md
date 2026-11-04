# 💸 FinFlow

### *Manage your money, flow with confidence.*

<p align="center">
  Aplikasi pencatatan keuangan pribadi berbasis mobile untuk membantu pengguna mencatat pemasukan, pengeluaran, dan memantau kondisi keuangan dengan lebih mudah.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Laravel-REST%20API-FF2D20?logo=laravel&logoColor=white" alt="Laravel" />
  <img src="https://img.shields.io/badge/Database-MySQL-4479A1?logo=mysql&logoColor=white" alt="MySQL" />
  <img src="https://img.shields.io/badge/Status-In%20Development-orange" alt="In Development" />
</p>

---

## ✨ About FinFlow

FinFlow adalah project aplikasi pencatatan keuangan yang dikembangkan menggunakan **Flutter sebagai frontend** dan **Laravel sebagai backend** melalui REST API.

Project ini dikembangkan secara kolaboratif agar setiap anggota tim dapat mengerjakan bagian frontend dan backend secara terstruktur.

### 🎯 Project Goals

- Mencatat pemasukan dan pengeluaran.
- Mengelola kategori transaksi.
- Menampilkan ringkasan kondisi keuangan.
- Melihat riwayat transaksi.
- Memisahkan frontend dan backend agar mudah dikembangkan dan dipelihara.

> Fitur-fitur di atas merupakan rencana pengembangan dan belum tentu seluruhnya sudah diimplementasikan.

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter & Dart | Mobile application |
| Laravel 12 | Backend REST API |
| MySQL | Database |
| Git & GitHub | Version control dan kolaborasi |

## 📂 Project Structure

```text
FinFlow/
├── frontend/          # Flutter mobile application
│   ├── lib/            # Dart source code
│   ├── test/           # Flutter tests
│   ├── android/        # Android configuration
│   └── pubspec.yaml    # Flutter dependencies
│
├── backend/            # Laravel REST API
│   ├── app/            # Application logic
│   ├── routes/          # API routes
│   ├── database/        # Migrations and seeders
│   └── composer.json   # PHP dependencies
│
└── README.md
```

## 🚀 Getting Started

### Prerequisites

Install the following tools before running the project:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [PHP](https://www.php.net/downloads)
- [Composer](https://getcomposer.org/)
- [MySQL](https://dev.mysql.com/downloads/)
- [Git](https://git-scm.com/)

### 1. Clone the Repository

```bash
git clone https://github.com/FahrizalHW/FinFlow.git
cd FinFlow
```

### 2. Setup Backend — Laravel

```bash
cd backend
composer install
```

Create your local environment configuration:

**Windows CMD**
```cmd
copy .env.example .env
```

**Linux / macOS / WSL**
```bash
cp .env.example .env
```

Generate the application key:

```bash
php artisan key:generate
```

Configure your database credentials in `backend/.env`. Create the corresponding MySQL database before running migrations.

When the database is ready:

```bash
php artisan migrate
php artisan serve
```

The development API server will normally run at:

`http://127.0.0.1:8000`

### 3. Setup Frontend — Flutter

Open another terminal from the project root:

```bash
cd frontend
flutter pub get
flutter run
```

Make sure an Android emulator or a connected Android device is available.

### 4. API Connection

The Flutter application will communicate with Laravel through HTTP requests and JSON responses.

For local development, the API address depends on the device:

- **Web or desktop on the same computer:** `http://127.0.0.1:8000`
- **Android Emulator:** `http://10.0.2.2:8000`
- **Physical Android device:** use your computer's local IP address, with both devices connected to the same network.

The API base URL should be configured in the frontend rather than scattered throughout the application.

## 🌿 Git Workflow

To keep the `main` branch stable, every team member should work on a separate branch.

### Create a Feature Branch

```bash
git switch main
git pull origin main
git switch -c feature/your-feature
```

### Commit and Push Changes

```bash
git add .
git commit -m "feat: describe your changes"
git push -u origin feature/your-feature
```

After pushing, open a Pull Request on GitHub and request a review before merging into `main`.

### Keep Your Branch Updated

```bash
git switch main
git pull origin main
git switch feature/your-feature
git merge main
```

Resolve any merge conflicts before continuing your work.

### Branch Naming Convention

| Prefix | Usage |
|---|---|
| `feature/` | New features |
| `fix/` | Bug fixes |
| `docs/` | Documentation |
| `refactor/` | Code improvements |

Examples: `feature/transaction-ui`, `feature/transaction-api`, `fix/login-validation`.

## 🤝 Team Collaboration

- Frontend and backend development should follow an agreed API contract.
- Use consistent naming for endpoints, request fields, and response fields.
- Never commit `.env`, passwords, API secrets, or other credentials.
- Pull the latest changes before starting new work.
- Test your changes before opening a Pull Request.
- Keep commits focused and use descriptive commit messages.

## 📌 Development Status

- [x] Initialize Flutter project
- [x] Initialize Laravel project
- [x] Create repository structure
- [ ] Define database schema
- [ ] Define REST API contract
- [ ] Develop frontend UI
- [ ] Implement backend endpoints
- [ ] Integrate Flutter with Laravel API
- [ ] Test application functionality

## 📄 License

No license has been selected yet. Until a license is added, the project should not be assumed to grant others permission to reuse, distribute, or modify its code.

---

<p align="center">
  <b>FinFlow</b> — Take control of your financial flow. 💜
</p>
