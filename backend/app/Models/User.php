<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'users';

    protected $primaryKey = 'id_user';

    protected $fillable = [
        'username',
        'password',
        'foto_profil',
    ];

    protected $hidden = [
        'password',
    ];

    // Menambahkan URL foto pada respons JSON user
    protected $appends = [
        'foto_profil_url',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    // Menghasilkan URL foto profil
    public function getFotoProfilUrlAttribute()
    {
        return $this->foto_profil
            ? url('storage/' . $this->foto_profil)
            : null;
    }

    // Relasi ke kategori
    public function kategori(): HasMany
    {
        return $this->hasMany(
            Kategori::class,
            'id_user',
            'id_user'
        );
    }

    // Relasi ke transaksi
    public function transaksi(): HasMany
    {
        return $this->hasMany(
            Transaksi::class,
            'id_user',
            'id_user'
        );
    }
}
