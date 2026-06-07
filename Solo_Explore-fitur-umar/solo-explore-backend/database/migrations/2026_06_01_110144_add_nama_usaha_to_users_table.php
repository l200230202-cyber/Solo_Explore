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
        Schema::table('users', function (Blueprint $table) {
            // Menambahkan kolom nama_usaha setelah kolom name, dibuat nullable agar user biasa tidak eror
            $table->string('nama_usaha')->nullable()->after('name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) { // 🟢 Sudah diperbaiki dari 'Border' ke 'Blueprint'
            $table->dropColumn('nama_usaha');
        });
    }
};