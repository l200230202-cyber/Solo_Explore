<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rewards', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();
            $table->string('image')->nullable();
            $table->integer('required_points');
            $table->string('type'); // voucher, workshop, merchandise
            $table->string('value')->nullable(); // e.g., "15%", "Free"
            $table->date('valid_until')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('user_rewards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('reward_id')->constrained()->onDelete('cascade');
            $table->timestamp('claimed_at')->useCurrent();
            $table->timestamp('used_at')->nullable();
            $table->string('status')->default('claimed'); // claimed, used, expired
            $table->string('code')->unique()->nullable(); // Voucher code
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_rewards');
        Schema::dropIfExists('rewards');
    }
};
