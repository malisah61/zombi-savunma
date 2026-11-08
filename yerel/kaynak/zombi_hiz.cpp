#include "zombi_hiz.h"

#include <godot_cpp/core/class_db.hpp>

#include <algorithm>
#include <cmath>

using namespace godot;

void ZombiHiz::_bind_methods() {
	ClassDB::bind_method(D_METHOD("suru", "poz", "yaricap", "bayrak", "genislik", "yukseklik", "hucre", "guc", "itme_max", "kalkan_mesafe"), &ZombiHiz::suru);
	ClassDB::bind_method(D_METHOD("segment_aday", "a", "b", "poz", "yaricap", "pay"), &ZombiHiz::segment_aday);
	ClassDB::bind_method(D_METHOD("surum"), &ZombiHiz::surum);
}

// oyun.gd > _suru_isle ile birebir aynı kural (aynı ızgara, aynı komşu sırası, aynı kalkan seçimi)
PackedFloat32Array ZombiHiz::suru(const PackedVector2Array &poz, const PackedFloat32Array &yaricap, const PackedInt32Array &bayrak,
		double genislik, double yukseklik, double hucre, double guc, double itme_max, const Vector2 &km) {
	const int n = (int)poz.size();
	PackedFloat32Array sonuc;
	sonuc.resize(n * 3);
	if (n == 0 || yaricap.size() < n || bayrak.size() < n) {
		return sonuc;
	}
	const Vector2 *P = poz.ptr();
	const float *R = yaricap.ptr();
	const int32_t *B = bayrak.ptr();
	float *S = sonuc.ptrw();
	const int sutun = (int)std::ceil(genislik / hucre) + 1;
	const int satir = (int)std::ceil((yukseklik + 240.0) / hucre) + 1;
	bas.assign(sutun * satir, -1);
	sonraki.assign(n, -1);
	auto hx = [&](float x) { return std::clamp((int)(x / hucre), 0, sutun - 1); };
	auto hy = [&](float y) { return std::clamp((int)((y + 240.0) / hucre), 0, satir - 1); };
	for (int i = 0; i < n; i++) {
		if (B[i] & 1) {
			continue;
		}
		const int c = hy(P[i].y) * sutun + hx(P[i].x);
		sonraki[i] = bas[c];
		bas[c] = i;
	}
	for (int i = 0; i < n; i++) {
		S[i * 3] = 0.0f;
		S[i * 3 + 1] = 0.0f;
		S[i * 3 + 2] = -1.0f;
		if (B[i] & 1) {
			continue;
		}
		const bool kosucu = (B[i] & 4) != 0;
		double ix = 0.0, iy = 0.0;
		int kalkan = -1;
		const int cx = hx(P[i].x), cy = hy(P[i].y);
		for (int dy = -1; dy < (kosucu ? 3 : 2); dy++) {  // koşucu önündeki (aşağıdaki) zırhlıyı da arar
			const int yy = cy + dy;
			if (yy < 0 || yy >= satir) {
				continue;
			}
			for (int dx = -1; dx < 2; dx++) {
				const int xx = cx + dx;
				if (xx < 0 || xx >= sutun) {
					continue;
				}
				for (int j = bas[yy * sutun + xx]; j >= 0; j = sonraki[j]) {
					if (j == i) {
						continue;
					}
					const double fx = P[i].x - P[j].x, fy = P[i].y - P[j].y;
					const double en_az = (R[i] + R[j]) * 0.8;
					const double d2 = fx * fx + fy * fy;
					if (d2 < en_az * en_az && d2 > 0.01) {
						const double d = std::sqrt(d2);
						const double k = (en_az - d) / en_az / d;
						ix += fx * k;
						iy += fy * k;
					}
					if (kosucu && kalkan < 0 && (B[j] & 8) && std::fabs(fx) < km.x && -fy > 20.0 && -fy < km.y) {
						kalkan = j;
					}
				}
			}
		}
		if (!(B[i] & 2)) {  // boss itilmez, ama başkalarını iter
			ix *= guc;
			iy *= guc;
			const double l = std::sqrt(ix * ix + iy * iy);
			if (l > itme_max && l > 0.0) {
				ix *= itme_max / l;
				iy *= itme_max / l;
			}
			S[i * 3] = (float)ix;
			S[i * 3 + 1] = (float)iy;
		}
		S[i * 3 + 2] = (float)kalkan;
	}
	return sonuc;
}

PackedInt32Array ZombiHiz::segment_aday(const Vector2 &a, const Vector2 &b, const PackedVector2Array &poz,
		const PackedFloat32Array &yaricap, double pay) const {
	PackedInt32Array sonuc;
	const int n = std::min((int)poz.size(), (int)yaricap.size());
	const Vector2 *P = poz.ptr();
	const float *R = yaricap.ptr();
	const double abx = b.x - a.x, aby = b.y - a.y, l2 = abx * abx + aby * aby;
	const double minx = std::min(a.x, b.x), maxx = std::max(a.x, b.x), miny = std::min(a.y, b.y), maxy = std::max(a.y, b.y);
	for (int i = 0; i < n; i++) {
		const double r = R[i] + pay;
		if (P[i].x < minx - r || P[i].x > maxx + r || P[i].y < miny - r || P[i].y > maxy + r) {
			continue;  // hızlı ön eleme
		}
		double t = l2 > 0.0 ? ((P[i].x - a.x) * abx + (P[i].y - a.y) * aby) / l2 : 0.0;
		t = std::clamp(t, 0.0, 1.0);
		const double qx = a.x + abx * t - P[i].x, qy = a.y + aby * t - P[i].y;
		if (qx * qx + qy * qy < r * r) {
			sonuc.push_back(i);
		}
	}
	return sonuc;
}
