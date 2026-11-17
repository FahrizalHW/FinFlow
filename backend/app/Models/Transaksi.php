<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaksi extends Model
{
    protected $table = 'transaksi';

    protected $primaryKey = 'id_transaksi';

    protected $fillable = [
        'id_user',
        'id_kategori',
        'nama_transaksi',
        'jenis_transaksi',
        'tanggal_transaksi',
        'nominal',
        'catatan',
    ];

    protected function casts(): array
    {
        return [
            'tanggal_transaksi' => 'date',
            'nominal' => 'decimal:2',
        ];
    }

    // Transaksi dimiliki oleh satu user
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_user', 'id_user');
    }

    // Transaksi dimiliki oleh satu kategori
    public function kategori(): BelongsTo
    {
        return $this->belongsTo(
            Kategori::class,
            'id_kategori',
            'id_kategori'
        );
    }
}
