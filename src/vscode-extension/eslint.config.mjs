import tseslintParser from '@typescript-eslint/parser';
import tseslintPlugin from '@typescript-eslint/eslint-plugin';

export default [
	{
		ignores: ['out/**', 'dist/**', '**/*.d.ts']
	},
	{
		files: ['src/**/*.ts'],
		languageOptions: {
			parser: tseslintParser,
			ecmaVersion: 2015,
			sourceType: 'module'
		},
		plugins: {
			'@typescript-eslint': tseslintPlugin
		},
		rules: {
			'@typescript-eslint/naming-convention': 'warn',
			curly: 'warn',
			eqeqeq: 'warn',
			'no-throw-literal': 'warn',
			semi: ['warn', 'always']
		}
	}
];