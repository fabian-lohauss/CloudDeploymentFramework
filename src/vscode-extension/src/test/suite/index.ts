import * as path from 'path';
import Mocha from 'mocha';
import { glob } from 'glob';

export function run(): Promise<void> {
	// Create the mocha test
	const mocha = new Mocha({
		ui: 'tdd',
		color: true
	});

	const testsRoot = path.resolve(__dirname, '..');

	return new Promise((resolve, reject) => {
		glob('**/**.test.js', { cwd: testsRoot })
			.then((files) => {
				files.forEach((file) => mocha.addFile(path.resolve(testsRoot, file)));

				try {
					mocha.run((failures) => {
						if (failures > 0) {
							reject(new Error(`${failures} tests failed.`));
							return;
						}

						resolve();
					});
				} catch (err) {
					console.error(err);
					reject(err instanceof Error ? err : new Error(String(err)));
				}
			})
			.catch((err: unknown) => {
				reject(err instanceof Error ? err : new Error(String(err)));
			});
	});
}
