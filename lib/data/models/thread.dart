class Thread {
  final int id;
  final String title;
  final String? prefix;
  final String? starterName;
  final int replyCount;
  final int viewCount;
  final String lastPostDate;
  final String postDate;

  Thread({
    required this.id,
    required this.title,
    this.prefix,
    this.starterName,
    required this.replyCount,
    required this.viewCount,
    required this.lastPostDate,
    required this.postDate,
  });

  // Factory constructor to create a Thread from JSON
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] as int,
      title: json['title'] as String,
      prefix: json['prefix'] as String?,
      starterName: json['starter_name'] as String?,
      replyCount: json['reply_count'] as int,
      viewCount: json['view_count'] as int,
      lastPostDate: json['last_post_date'] as String,
      postDate: json['post_date'] as String,
    );
  }

  // Convert Thread to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'prefix': prefix,
      'starter_name': starterName,
      'reply_count': replyCount,
      'view_count': viewCount,
      'last_post_date': lastPostDate,
      'post_date': postDate,
    };
  }
}
