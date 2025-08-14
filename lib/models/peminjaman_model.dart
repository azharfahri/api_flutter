// To parse this JSON data, do
//
//     final peminjamenModel = peminjamenModelFromJson(jsonString);

import 'dart:convert';

PeminjamenModel peminjamenModelFromJson(String str) => PeminjamenModel.fromJson(json.decode(str));

String peminjamenModelToJson(PeminjamenModel data) => json.encode(data.toJson());

class PeminjamenModel {
    List<DataPeminjam>? data;
    String? message;
    bool? success;

    PeminjamenModel({
        this.data,
        this.message,
        this.success,
    });

    factory PeminjamenModel.fromJson(Map<String, dynamic> json) => PeminjamenModel(
        data: json["data"] == null ? [] : List<DataPeminjam>.from(json["data"]!.map((x) => DataPeminjam.fromJson(x))),
        message: json["message"],
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "success": success,
    };
}

class DataPeminjam {
    int? id;
    int? userId;
    int? bukuId;
    int? stokDipinjam;
    DateTime? tanggalPinjam;
    DateTime? tenggat;
    dynamic tanggalPengembalian;
    String? status;
    DateTime? createdAt;
    DateTime? updatedAt;
    User? user;
    Buku? buku;

    DataPeminjam({
        this.id,
        this.userId,
        this.bukuId,
        this.stokDipinjam,
        this.tanggalPinjam,
        this.tenggat,
        this.tanggalPengembalian,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.user,
        this.buku,
    });

    factory DataPeminjam.fromJson(Map<String, dynamic> json) => DataPeminjam(
        id: json["id"],
        userId: json["user_id"],
        bukuId: json["buku_id"],
        stokDipinjam: json["stok_dipinjam"],
        tanggalPinjam: json["tanggal_pinjam"] == null ? null : DateTime.parse(json["tanggal_pinjam"]),
        tenggat: json["tenggat"] == null ? null : DateTime.parse(json["tenggat"]),
        tanggalPengembalian: json["tanggal_pengembalian"],
        status: json["status"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        buku: json["buku"] == null ? null : Buku.fromJson(json["buku"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "buku_id": bukuId,
        "stok_dipinjam": stokDipinjam,
        "tanggal_pinjam": "${tanggalPinjam!.year.toString().padLeft(4, '0')}-${tanggalPinjam!.month.toString().padLeft(2, '0')}-${tanggalPinjam!.day.toString().padLeft(2, '0')}",
        "tenggat": "${tenggat!.year.toString().padLeft(4, '0')}-${tenggat!.month.toString().padLeft(2, '0')}-${tenggat!.day.toString().padLeft(2, '0')}",
        "tanggal_pengembalian": tanggalPengembalian,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user": user?.toJson(),
        "buku": buku?.toJson(),
    };
}

class Buku {
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

    Buku({
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

    factory Buku.fromJson(Map<String, dynamic> json) => Buku(
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

class User {
    int? id;
    String? name;
    String? email;
    dynamic emailVerifiedAt;
    DateTime? createdAt;
    DateTime? updatedAt;

    User({
        this.id,
        this.name,
        this.email,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
