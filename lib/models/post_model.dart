// To parse this JSON data, do
//
//     final postModel = postModelFromJson(jsonString);

import 'dart:convert';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
    bool? success;
    List<DataPost>? data;
    String? message;

    PostModel({
        this.success,
        this.data,
        this.message,
    });

    factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataPost>.from(json["data"]!.map((x) => DataPost.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataPost {
    int? id;
    String? title;
    String? content;
    String? slug;
    int? status;
    String? foto;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataPost({
        this.id,
        this.title,
        this.content,
        this.slug,
        this.status,
        this.foto,
        this.createdAt,
        this.updatedAt,
    });

    factory DataPost.fromJson(Map<String, dynamic> json) => DataPost(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        slug: json["slug"],
        status: json["status"],
        foto: json["foto"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "slug": slug,
        "status": status,
        "foto": foto,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
