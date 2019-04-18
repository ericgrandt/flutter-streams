import 'package:flutter/material.dart';
import 'package:stream_post/data/blocs/bloc_provider.dart';
import 'package:stream_post/data/blocs/notes_bloc.dart';
import 'package:stream_post/data/blocs/view_note_bloc.dart';
import 'package:stream_post/models/note_model.dart';
import 'package:stream_post/view_note.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Notes',
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			// We want to provide our NotesPage with the NotesBloc so we
			// can retrieve it from within the NotesPage later
			home: BlocProvider(
				bloc: NotesBloc(),
				child: NotesPage(title: 'Notes'),
			),
		);
	}
}

class NotesPage extends StatefulWidget {
	NotesPage({
		Key key,
		this.title
	}) : super(key: key);

	final String title;

	@override
	_NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
	NotesBloc _notesBloc;

	@override
	void initState() {
		super.initState();

		// Thanks to the BlocProvider providing this page with the NotesBloc,
		// we can simply use this to retrieve it.
		_notesBloc = BlocProvider.of<NotesBloc>(context);
	}

	void _addNote() async {
		Note note = new Note(contents: '');

		// Add this newly created note to the add note stream. Doing this
		// will trigger the listener in `notes_bloc.dart` and call `_handleAddNote`.
		_notesBloc.inAddNote.add(note);
	}

	void _navigateToNote(Note note) async {
		// Push ViewNotePage, and store any return value in update. This will
		// be used to tell this page to refresh the note list after one is deleted.
		// If a note isn't deleted, this will be set to null and the note list will
		// not be refreshed.
		bool update = await Navigator.of(context).push(
			MaterialPageRoute(
				// Once again, use the BlocProvider to pass the ViewNoteBloc
				// to the ViewNotePage
				builder: (context) => BlocProvider(
					bloc: ViewNoteBloc(),
					child: ViewNotePage(
						note: note,
					),
				),
			),
		);

		// If update was set, get all the notes again
		if (update != null) {
			_notesBloc.getNotes();
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title),
			),
			body: Container(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Expanded(
							// The streambuilder allows us to make use of our streams and display
							// that data on our page. It automatically updates when the stream updates.
							// Whenever you want to display stream data, you'll use the StreamBuilder.
							child: StreamBuilder<List<Note>>(
								stream: _notesBloc.notes,
								builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
									// Make sure data exists and is actually loaded
									if (snapshot.hasData) {
										// If there are no notes (data), display this message.
										if (snapshot.data.length == 0) {
											return Text('No notes');
										}

										List<Note> notes = snapshot.data;

										return ListView.builder(
											itemCount: snapshot.data.length,
											itemBuilder: (BuildContext context, int index) {
												Note note = notes[index];

												return GestureDetector(
													onTap: () {
														_navigateToNote(note);
													},
													child: Container(
														height: 40,
														child: Text(
															'Note ' + note.id.toString(),
															style: TextStyle(
																fontSize: 18
															),
														),
													),
												);
											},
										);
									}

									// If the data is loading in, display a progress indicator
									// to indicate that. You don't have to use a progress
									// indicator, but the StreamBuilder has to return a widget.
									return Center(
										child: CircularProgressIndicator(),
									);
								},
							),
						),
					],
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _addNote,
				child: Icon(Icons.add),
			),
		);
	}
}