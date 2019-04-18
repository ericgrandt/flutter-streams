import 'package:flutter/material.dart';
import 'package:stream_post/data/blocs/bloc_provider.dart';
import 'package:stream_post/data/blocs/view_note_bloc.dart';
import 'package:stream_post/models/note_model.dart';

class ViewNotePage extends StatefulWidget {
	ViewNotePage({
		Key key,
		this.note
	}) : super(key: key);

	final Note note;

	@override
	_ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
	ViewNoteBloc _viewNoteBloc;
	TextEditingController _noteController = new TextEditingController();

	@override
	void initState() {
		super.initState();

		_viewNoteBloc = BlocProvider.of<ViewNoteBloc>(context);
		_noteController.text = widget.note.contents;
	}

	void _saveNote() async {
		widget.note.contents = _noteController.text;

		// Add the updated note to the save note stream. This triggers the function
		// we set in the listener.
		_viewNoteBloc.inSaveNote.add(widget.note);
	}

	void _deleteNote() {
		// Add the note id to the delete note stream. This triggers the function
		// we set in the listener.
		_viewNoteBloc.inDeleteNote.add(widget.note.id);

		// Wait for `deleted` to be set before popping back to the main page. This guarantees there's no
		// mismatch between what's stored in the database and what's being displayed on the page.
		// This is usually only an issue with more database heavy actions, but it's a good thing to
		// add regardless.
		_viewNoteBloc.deleted.listen((deleted) {
			if (deleted) {
				// Pop and return true to let the main page know that a note was deleted and that
				// it has to update the notes list.
				Navigator.of(context).pop(true);
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Note ' + widget.note.id.toString()),
				actions: <Widget>[
					IconButton(
						icon: Icon(Icons.save),
						onPressed: _saveNote,
					),
					IconButton(
						icon: Icon(Icons.delete),
						onPressed: _deleteNote,
					),
				],
			),
			body: Container(
				child: TextField(
					maxLines: null,
					controller: _noteController,
				),
			),
		);
	}
}