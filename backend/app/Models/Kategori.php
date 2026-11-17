<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Kategori extends Model
{
    protected $table = 'kategori';

    protected $primaryKey = 'id_kategori';

    public $timestamps = false;

    protected $fillable = [
        'id_user',
        'nama_kategori',
        'jenis_kategori',
    ];

    // Relasi ke User
    public function user(): BelongsTo
    {
        return $this->belongsTo(
            User::class,
            'id_user',
            'id_user'
        );
    }

    // Relasi ke Transaksi
    public function transaksi(): HasMany
    {
        return $this->hasMany(
            Transaksi::class,
            'id_kategori',
            'id_kategori'
        );
    }
}
