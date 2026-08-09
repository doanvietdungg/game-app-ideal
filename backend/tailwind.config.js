/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.vue',
    ],
    theme: {
        extend: {
            colors: {
                primary: {
                    DEFAULT: '#6C63FF',
                    50: '#f0effe',
                    100: '#e3e0fd',
                    500: '#6C63FF',
                    600: '#5a52e6',
                    700: '#4840cc',
                },
                sky: {
                    DEFAULT: '#48CAE4',
                },
            },
            fontFamily: {
                sans: ['Nunito', 'sans-serif'],
            },
        },
    },
    plugins: [
        require('@tailwindcss/forms'),
    ],
};
