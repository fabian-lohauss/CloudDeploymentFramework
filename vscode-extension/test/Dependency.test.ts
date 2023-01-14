import { Dependency } from "../src/Dependency";
import * as vscode from 'vscode';

test('create dependency', () => {
  expect(new Dependency('moduleName', 'version', vscode.TreeItemCollapsibleState.Collapsed)).not.toBeNull();
});