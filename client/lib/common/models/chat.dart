class Chat {
  final int id;
  final String name;

  const Chat({required this.id, required this.name});

  Chat.fromJson(Map<String, dynamic> data)
    : id = data['id'] as int,
      name = data['chatName'] as String;
}
