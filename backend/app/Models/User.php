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

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    // Relasi ke kategori
    public function kategori(): HasMany
    {
        return $this->hasMany(Kategori::class, 'id_user', 'id_user');
    }

    // Relasi ke transaksi
    public function transaksi(): HasMany
    {
        return $this->hasMany(Transaksi::class, 'id_user', 'id_user');
    }
}
