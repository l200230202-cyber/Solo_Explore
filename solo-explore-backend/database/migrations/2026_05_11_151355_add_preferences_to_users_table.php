<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Bagian ini akan menambah kolom 'interests' ke tabel users
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Kita simpan minat user dalam format JSON (misal: ["alam", "pedas"])
            // after('email') artinya kolom ini ditaruh setelah kolom email biar rapi
            $table->json('interests')->nullable()->after('email');
        });
    }

    /**
     * Reverse the migrations.
     * Bagian ini untuk menghapus kolom jika migrasi dibatalkan
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('interests');
        });
    }
};