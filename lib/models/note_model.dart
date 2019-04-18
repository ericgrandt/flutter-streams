class Note {
	int id;
	String contents;

	Note({
		this.id,
		this.contents,
	});

	factory Note.fromJson(Map<String, dynamic> json) => new Note(
		id: json["id"],
		contents: json["contents"],
	);

	Map<String, dynamic> toJson() => {
		"id": id,
		"contents": contents,
	};
}