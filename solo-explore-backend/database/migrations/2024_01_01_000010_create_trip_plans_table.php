<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trip_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->date('start_date');
            $table->date('end_date');
            $table->integer('total_days')->default(1);
            $table->string('status')->default('draft'); // draft, active, completed
            $table->timestamps();
            $table->softDeletes();
        });

        Schema::create('trip_plan_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trip_plan_id')->constrained()->onDelete('cascade');
            $table->morphs('plannable'); // destination_id or culinary_id
            $table->integer('day_number');
            $table->time('time')->nullable();
            $table->integer('order')->default(0);
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trip_plan_items');
        Schema::dropIfExists('trip_plans');
    }
};
