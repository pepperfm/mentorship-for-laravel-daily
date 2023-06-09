composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
composer require spatie/laravel-ray --dev
php artisan ray:publish-config --docker
composer remove laravel-sail
composer remove laravel/sail
composer u -W
