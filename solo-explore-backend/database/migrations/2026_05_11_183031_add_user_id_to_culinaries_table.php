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
        Schema::table('culinaries', function (Blueprint $table) {
            // Kita tambahkan user_id setelah kolom id utama
            // nullable() supaya data lama yang nggak punya user_id nggak error
            // constrained() otomatis nyambungin ke tabel users
            $table->foreignId('user_id')->after('id')->nullable()->constrained('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('culinaries', function (Blueprint $table) {
            // Buat hapus kolomnya kalau kita rollback
            $table->dropForeign(['user_id']);
            $table->dropColumn('user_id');
        });
    }
};