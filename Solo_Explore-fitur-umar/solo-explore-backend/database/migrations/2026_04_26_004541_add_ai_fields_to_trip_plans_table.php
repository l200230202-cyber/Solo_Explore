<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('trip_plans', function (Blueprint $table) {
            $table->string('name')->nullable()->after('user_id');
            $table->decimal('budget', 12, 2)->nullable()->after('end_date');
            $table->boolean('ai_generated')->default(false)->after('status');
            $table->text('ai_itinerary')->nullable()->after('ai_generated');
        });
    }

    public function down(): void
    {
        Schema::table('trip_plans', function (Blueprint $table) {
            $table->dropColumn(['name', 'budget', 'ai_generated', 'ai_itinerary']);
        });
    }
};
