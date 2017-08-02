CREATE TABLE "Library" (
	`name`	TEXT NOT NULL,
	`duration`	TEXT,
	`effect`	TEXT,
	`rarity`	INTEGER,
	`itemType`	INTEGER,
	PRIMARY KEY(`name`)
);
CREATE TABLE "Item" (
	`id`	TEXT NOT NULL UNIQUE,
	`name`	TEXT,
	`rarity`	INTEGER,
	`description`	TEXT,
	`isUsed`	INTEGER,
	`dateAdded`	INTEGER,
	PRIMARY KEY(`id`)
);
