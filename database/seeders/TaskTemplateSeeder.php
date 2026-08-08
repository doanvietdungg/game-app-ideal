<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use KidTime\Infrastructure\Persistence\Eloquent\TaskModel;

class TaskTemplateSeeder extends Seeder
{
    public function run(): void
    {
        $templates = [
            // Việc nhà
            ['title' => 'Dọn phòng ngủ', 'category' => 'housework', 'stars' => 3, 'icon' => '🛏️', 'verification_mode' => 'photo', 'recurrence' => 'weekly'],
            ['title' => 'Rửa bát', 'category' => 'housework', 'stars' => 2, 'icon' => '🍽️', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Quét nhà', 'category' => 'housework', 'stars' => 2, 'icon' => '🧹', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Gấp quần áo', 'category' => 'housework', 'stars' => 2, 'icon' => '👕', 'verification_mode' => 'photo', 'recurrence' => 'weekly'],
            // Học tập
            ['title' => 'Đọc sách 20 phút', 'category' => 'study', 'stars' => 4, 'icon' => '📖', 'verification_mode' => 'photo', 'recurrence' => 'daily'],
            ['title' => 'Làm bài tập về nhà', 'category' => 'study', 'stars' => 5, 'icon' => '✏️', 'verification_mode' => 'photo', 'recurrence' => 'weekdays'],
            // Vận động
            ['title' => 'Ra ngoài chơi 30 phút', 'category' => 'exercise', 'stars' => 3, 'icon' => '🏃', 'verification_mode' => 'auto', 'recurrence' => 'daily'],
            ['title' => 'Đạp xe', 'category' => 'exercise', 'stars' => 4, 'icon' => '🚴', 'verification_mode' => 'photo', 'recurrence' => 'weekly'],
            // Ăn uống
            ['title' => 'Ăn hết rau trong bữa cơm', 'category' => 'eating', 'stars' => 2, 'icon' => '🥦', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Ăn sáng đúng giờ', 'category' => 'eating', 'stars' => 2, 'icon' => '🍳', 'verification_mode' => 'auto', 'recurrence' => 'daily'],
            // Giấc ngủ
            ['title' => 'Tắt điện thoại trước 9 giờ', 'category' => 'sleep', 'stars' => 3, 'icon' => '📵', 'verification_mode' => 'pin', 'recurrence' => 'daily'],
            ['title' => 'Ngủ đúng giờ quy định', 'category' => 'sleep', 'stars' => 3, 'icon' => '🌙', 'verification_mode' => 'auto', 'recurrence' => 'daily'],
        ];

        foreach ($templates as $t) {
            TaskModel::updateOrCreate(
                ['title' => $t['title'], 'is_template' => true],
                [...$t, 'is_template' => true, 'family_id' => null]
            );
        }
    }
}
