"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const Dependency_1 = require("../src/Dependency");
const vscode = require("vscode");
test('create dependency', () => {
    expect(new Dependency_1.Dependency('moduleName', 'version', vscode.TreeItemCollapsibleState.Collapsed)).not.toBeNull();
});
//# sourceMappingURL=Dependency.test.js.map