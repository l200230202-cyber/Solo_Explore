<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add missing columns to culinaries
        Schema::table('culinaries', function (Blueprint $table) {
            $table->text('facilities')->nullable()->after('price_range');
            $table->text('highlights')->nullable()->after('facilities');
            $table->string('opening_hours')->nullable()->after('highlights');
        });

        // Add missing columns to events
        Schema::table('events', function (Blueprint $table) {
            $table->string('address')->nullable()->after('location');
            $table->decimal('latitude', 10, 8)->nullable()->after('address');
            $table->decimal('longitude', 11, 8)->nullable()->after('latitude');
            $table->decimal('rating', 3, 2)->default(0)->after('images');
            $table->integer('total_reviews')->default(0)->after('rating');
        });
    }

    public function down(): void
    {
        Schema::table('culinaries', function (Blueprint $table) {
            $table->dropColumn(['facilities', 'highlights', 'opening_hours']);
        });

        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn(['address', 'latitude', 'longitude', 'rating', 'total_reviews']);
        });
    }
};
