import * as vscode from 'vscode';

export class FruitItem extends vscode.TreeItem {
	constructor(
		public readonly label: string,
		public readonly collapsibleState: vscode.TreeItemCollapsibleState,
		public readonly command?: vscode.Command
	) {
		super(label, collapsibleState);
	}
}

export class FruitDataProvider implements vscode.TreeDataProvider<FruitItem> {
	private _onDidChangeTreeData: vscode.EventEmitter<FruitItem | undefined | null | void> = new vscode.EventEmitter<FruitItem | undefined | null | void>();
	readonly onDidChangeTreeData: vscode.Event<FruitItem | undefined | null | void> = this._onDidChangeTreeData.event;

	getTreeItem(element: FruitItem): vscode.TreeItem {
		return element;
	}

	getChildren(element?: FruitItem): Thenable<FruitItem[]> {
		if (element) {
			return Promise.resolve(this.getFruits(element.label));
		} else {
			return Promise.resolve(this.getTypes());
		}
	}

	private getTypes(): FruitItem[] {
		return [
			new FruitItem('Citrus', vscode.TreeItemCollapsibleState.Collapsed),
			new FruitItem('Berries', vscode.TreeItemCollapsibleState.Collapsed)
		];
	}

	private getFruits(type: string): FruitItem[] {
		const fruits = {
			citrus: ['Orange', 'Lemon', 'Grapefruit'],
			berries: ['Strawberry', 'Blueberry', 'Raspberry']
		};

		//  array of fruit items
		let result: FruitItem[] = [];
		if (type === 'Citrus') {
			result = fruits.citrus.map( 
				(fruit: string) => new FruitItem(fruit, vscode.TreeItemCollapsibleState.None)
			);

		} else if (type === 'Berries') {
			result = fruits.berries.map(
				(fruit: string) => new FruitItem(fruit, vscode.TreeItemCollapsibleState.None)
			);
		}
		return result;
	}
}

export function activate(context: vscode.ExtensionContext) {
	const fruitDataProvider = new FruitDataProvider();
	vscode.window.registerTreeDataProvider('sampleTreeView', fruitDataProvider);
}
