// Zombi Savunma — C++ hızlandırıcı (GDExtension).
// Çok zombi ve mermi olduğunda GDScript'te yavaşlayan iki işi yapar:
//   suru()          : zombilerin birbirini itmesi (ızgara ile komşu arama) + koşucunun zırhlı arkasına saklanması
//   segment_aday()  : bu karede mermi yolunun değebileceği zombiler
// GDScript bu sınıf yoksa (eklenti yüklenemezse) aynı işi eski yoldan yapar; oyun bozulmaz.
#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>

#include <vector>

namespace godot {

class ZombiHiz : public RefCounted {
	GDCLASS(ZombiHiz, RefCounted)

	std::vector<int> bas, sonraki;  // ızgara: her hücrenin ilk zombisi ve bağlı liste (yeniden kullanılır)

protected:
	static void _bind_methods();

public:
	// bayrak bitleri: 1 ölü, 2 boss, 4 kalkan arayan koşucu, 8 zırhlı
	// dönüş: zombi başına 3 sayı: itme.x, itme.y, kalkan indeksi (-1 yoksa)
	PackedFloat32Array suru(const PackedVector2Array &poz, const PackedFloat32Array &yaricap, const PackedInt32Array &bayrak,
			double genislik, double yukseklik, double hucre, double guc, double itme_max, const Vector2 &kalkan_mesafe);
	// a→b doğru parçasına (yarıçap + pay) içinde kalan zombilerin indeksleri, küçükten büyüğe
	PackedInt32Array segment_aday(const Vector2 &a, const Vector2 &b, const PackedVector2Array &poz,
			const PackedFloat32Array &yaricap, double pay) const;
	String surum() const { return "1"; }
};

} // namespace godot
