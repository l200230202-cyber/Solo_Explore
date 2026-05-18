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
        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            // Menghubungkan ke user yang kasih rating
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            // Menghubungkan ke warung/kuliner (Asumsi nama tabelnya 'culinaries')
            $table->foreignId('culinary_id')->constrained('culinaries')->onDelete('cascade');
            
            $table->integer('stars')->default(5); // 1-5 bintang
            $table->text('comment'); // Isi ulasan
            
            // Kolom untuk balasan admin (Biar fitur 'Balas Ulasan' kamu jalan)
            $table->text('reply')->nullable(); 
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ratings');
    }
};