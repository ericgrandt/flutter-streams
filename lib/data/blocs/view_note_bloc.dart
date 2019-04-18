import 'dart:async';

import 'package:stream_post/data/blocs/bloc_provider.dart';
import 'package:stream_post/data/database.dart';
import 'package:stream_post/models/note_model.dart';

class ViewNoteBloc implements BlocBase {
	final _saveNoteController = StreamController<Note>.broadcast();
	StreamSink<Note> get inSaveNote => _saveNoteController.sink;

	final _deleteNoteController = StreamController<int>.broadcast();
	StreamSink<int> get inDeleteNote => _deleteNoteController.sink;

	// This bool StreamController will be used to ensure we don't do anything
	// else until a note is actually deleted from the database.
	final _noteDeletedController = StreamController<bool>.broadcast();
	StreamSink<bool> get _inDeleted => _noteDeletedController.sink;
	Stream<bool> get deleted => _noteDeletedController.stream;

	ViewNoteBloc() {
		// Listen for changes to the stream, and execute a function when a change is made
		_saveNoteController.stream.listen(_handleSaveNote);
		_deleteNoteController.stream.listen(_handleDeleteNote);
	}

	@override
	void dispose() {
		_saveNoteController.close();
		_deleteNoteController.close();
		_noteDeletedController.close();
	}

	void _handleSaveNote(Note note) async {
		await DBProvider.db.updateNote(note);
	}

	void _handleDeleteNote(int id) async {
		await DBProvider.db.deleteNote(id);

		// Set this to true in order to ensure a note is deleted
		// before doing anything else
		_inDeleted.add(true);
	}
}