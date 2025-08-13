// To parse this JSON data, do
//
//     final bukuModel = bukuModelFromJson(jsonString);

import 'dart:convert';

BukuModel bukuModelFromJson(String str) => BukuModel.fromJson(json.decode(str));

String bukuModelToJson(BukuModel data) => json.encode(data.toJson());

class BukuModel {
    bool? success;
    List<DataBuku>? data;
    String? message;

    BukuModel({
        this.success,
        this.data,
        this.message,
    });

    factory BukuModel.fromJson(Map<String, dynamic> json) => BukuModel(
        success: json["success"],
        data: json["data"] == null ? [] : List<DataBuku>.from(json["data"]!.map((x) => DataBuku.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class DataBuku {
    int? id;
    String? kodeBuku;
    String? judul;
    String? penulis;
    String? penerbit;
    int? tahunTerbit;
    int? stok;
    int? kategoriId;
    String? cover;
    DateTime? createdAt;
    DateTime? updatedAt;

    DataBuku({
        this.id,
        this.kodeBuku,
        this.judul,
        this.penulis,
        this.penerbit,
        this.tahunTerbit,
        this.stok,
        this.kategoriId,
        this.cover,
        this.createdAt,
        this.updatedAt,
    });

    factory DataBuku.fromJson(Map<String, dynamic> json) => DataBuku(
        id: json["id"],
        kodeBuku: json["kode_buku"],
        judul: json["judul"],
        penulis: json["penulis"],
        penerbit: json["penerbit"],
        tahunTerbit: json["tahun_terbit"],
        stok: json["stok"],
        kategoriId: json["kategori_id"],
        cover: json["cover"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "kode_buku": kodeBuku,
        "judul": judul,
        "penulis": penulis,
        "penerbit": penerbit,
        "tahun_terbit": tahunTerbit,
        "stok": stok,
        "kategori_id": kategoriId,
        "cover": cover,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
