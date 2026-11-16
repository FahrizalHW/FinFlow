<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
         Schema::create('kategori', function (Blueprint $table) {
            $table->id('id_kategori');

            $table->unsignedBigInteger('id_user');

            $table->string('nama_kategori');

            $table->enum('jenis_kategori', [
                'pemasukan',
                'pengeluaran'
            ]);

            $table->foreign('id_user')
            ->references('id_user')
            ->on('users')
            ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kategori');
    }
};
