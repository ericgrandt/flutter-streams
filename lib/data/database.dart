import 'dart:io';
import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stream_post/models/note_model.dart';

class DBProvider {
	// Create a singleton
	DBProvider._();

	static final DBProvider db = DBProvider._();
	Database _database;

	Future<Database> get database async {
		if (_database != null) {
			return _database;
		}

		_database = await initDB();
		return _database;
	}

	initDB() async {
        // Get the location of our apps directory. This is where files for our app, and only our app, are stored.
		// Files in this directory are deleted when the app is deleted.
		Directory documentsDir = await getApplicationDocumentsDirectory();
		String path = join(documentsDir.path, 'app.db');

		return await openDatabase(path, version: 1, onOpen: (db) async {
		}, onCreate: (Database db, int version) async {
			// Create the note table
			await db.execute('''
				CREATE TABLE note(
					id INTEGER PRIMARY KEY,
					contents TEXT DEFAULT ''
				)
			''');
		});
	}

	/*
	 * Note Table
	 */
	newNote(Note note) async {
		final db = await database;
		var res = await db.insert('note', note.toJson());

		return res;
	}

	getNotes() async {
		final db = await database;
		var res = await db.query('note');
		List<Note> notes = res.isNotEmpty ? res.map((note) => Note.fromJson(note)).toList() : [];

		return notes;
	}

	getNote(int id) async {
		final db = await database;
		var res = await db.query('note', where: 'id = ?', whereArgs: [id]);

		return res.isNotEmpty ? Note.fromJson(res.first) : null;
	}

	updateNote(Note note) async {
		final db = await database;
		var res = await db.update('note', note.toJson(), where: 'id = ?', whereArgs: [note.id]);

		return res;
	}

	deleteNote(int id) async {
		final db = await database;

		db.delete('note', where: 'id = ?', whereArgs: [id]);
	}
}