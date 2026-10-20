# Vibe App Icon Style Guide

Quy chuẩn icon chung cho mọi app dòng **Vibe**: VibeShot, VibeScreen, VibeNote, VibePhoto và các app sau này.
Icon được vẽ hoàn toàn bằng code CoreGraphics (không dùng ảnh AI), nên tái tạo được, sắc nét, dễ chỉnh.

Có 2 bộ dùng chung một lưới và một bảng màu theo app. Chỉ chọn **một** bộ cho cả dòng sản phẩm.

| Bộ | Script | Output |
|---|---|---|
| Apple native (phẳng, glyph trắng) | `render-apple-native.swift` | `apple-native/` |
| Material (skeuomorphic nhẹ: giấy, kính, kim loại) | `render-material.swift` | `material/` |

```bash
cd assets/design/vibe-icons/material && swift ../render-material.swift .
cd assets/design/vibe-icons/apple-native && swift ../render-apple-native.swift .
```

## 1. Phần chung cho cả hai bộ

### Lưới (canvas 1024 × 1024)

| Thành phần | Giá trị |
|---|---|
| Plate (squircle) | `x=100, y=100, 824×824`, bo góc `185` (grid icon macOS) |
| Vùng an toàn của vật thể | khoảng `190…834`; phần chính nằm trong `250…774` |
| Bóng plate | offset `0,-10…-12`, blur `24…28`, đen `28–35%` |
| Highlight viền plate | 3 px, trắng 35–45% ở cạnh trên, mờ dần xuống dưới |

### Màu riêng của từng app (plate gradient dọc, trên → dưới)

| App | Native | Material | Ý nghĩa |
|---|---|---|---|
| VibeShot | `#5AB0FF → #0A6CF0` | `#6FB6FF → #1C6FD8` | xanh dương: chụp, tốc độ |
| VibeScreen | `#8C86FF → #5146E0` | `#9C97FF → #5146D6` | chàm: hệ thống, màn hình |
| VibeNote | `#FFD54A → #FFA00A` | `#FFD979 → #F0A21C` | vàng hổ phách: ghi chép |
| VibePhoto | `#5FDB8A → #1FAE5B` | `#7EDFA0 → #239E5A` | xanh lá: ảnh, thiên nhiên |

App mới phải lấy một hue **chưa dùng**, ví dụ đỏ `#FF6B6B → #E03131`, teal `#4FD1C5 → #0F9488`,
hồng `#FF8AC2 → #E0458F` hoặc graphite `#8E949E → #4B515B`.
Giữ công thức: màu trên sáng hơn màu dưới khoảng 15–20% về độ sáng, cùng hue.

### Nguyên tắc

1. Mỗi icon là **một vật thể / ẩn dụ duy nhất**, nhận ra được ở 32 px.
2. Không có chữ, không có logo bên thứ ba, không dùng neon/glow, không dùng gradient tím-hồng "kiểu AI".
3. Ánh sáng luôn **chiếu từ trên xuống**: highlight ở cạnh trên, bóng đổ xuống dưới.

## 2. Bộ Apple native

- Glyph **trắng đặc**, nét 60 px, đầu nét bo tròn, bo góc khung 60–72 px.
- Bóng glyph duy nhất: offset `0,-8`, blur 18, đen 18%.
- Chi tiết thứ cấp dùng **ink** của app (màu đậm hơn plate), độ đậm 35–100%.
- Không thêm texture, không thêm bóng kính.

## 3. Bộ Material

Mỗi icon là một **đồ vật thật nằm trên mặt bàn màu** (plate). Primitives trong `render-material.swift`:

| Primitive | Dùng cho |
|---|---|
| `objectShadow(lift:)` | bóng 2 lớp: lớp contact (offset 6, blur 10, 35%) + lớp ambient (offset 30, blur 60, 30%); `lift` 0.1–1 theo độ cao của vật |
| `grain(amount:)` | thớ giấy / lớp phủ mờ (giấy 0.05–0.07, da hoặc băng dính 0.12–0.15, plate 0.05) |
| `brushedMetal` | nhôm xước: gradient nền cộng các vệt mảnh theo một trục |
| `bevel` | cạnh vát: viền trên sáng, viền dưới tối |
| `glassGloss` | dải phản chiếu chéo trên kính hoặc bề mặt bóng |

### Bảng vật liệu

| Vật liệu | Màu / thông số |
|---|---|
| Giấy | `#FFFDF5 → #FAF3DD`, grain 0.07, kẻ dòng `#7FB2E5` 75%, lề đỏ `#E5484D` |
| Nhôm | `#F4F5F7 → #D3D6DC → #BFC3CB` + vệt xước |
| Chrome | `#FFFFFF, #C9CDD5, #8C929E, #E9ECF1, #9DA3AE` (các dải xen kẽ) |
| Kính đen / màn hình | viền màn hình `#0E0F13`, gloss 16% |
| Men bóng (điểm nhấn) | `#FFB45E → #FF6A3D → #E8452A` + bevel + gloss 35% |
| Gỗ / chì | gỗ `#F4D3A6 → #C48A4C`, ruột chì `#6B6B72 → #2A2A30` |

### Bộ icon hiện có

| App | Native | Material |
|---|---|---|
| VibeShot | 4 góc khung chụp + tia sét trắng | tấm kính khói, 4 góc chrome, tia sét men cam |
| VibeScreen | màn hình trắng + 3 thanh trượt | màn hình nhôm, giao diện kính mờ với 3 thanh trượt màu |
| VibeNote | trang giấy gấp góc + dòng chữ + con trỏ | tập giấy kẻ dòng có gáy da khâu chỉ, chữ viết tay, bút chì |
| VibePhoto | khung ảnh + núi + mặt trời | 2 tấm polaroid ảnh hoàng hôn, có băng dính washi |

## 4. Quy trình tạo icon cho app mới

1. Chọn **một** ẩn dụ: bộ native dùng dạng SF Symbol, bộ Material dùng một đồ vật thật trên bàn làm việc
   (ví dụ VibeVoice: micro nhôm; VibeKey: phím bàn phím).
2. Chọn một hue chưa dùng (mục 1), giữ đúng công thức gradient.
3. Thêm hàm `func vibeXxx(_ ctx: CGContext)` vào script tương ứng. Chỉ dùng các primitive có sẵn,
   không tự chế hiệu ứng mới. Thêm app vào mảng `icons`.
4. Render rồi so cạnh các icon cũ ở cỡ 512 px và 32 px.
5. Kiểm tra trước khi dùng:
   - [ ] Plate, bo góc và bóng plate đúng thông số.
   - [ ] Vật thể nằm trong vùng an toàn.
   - [ ] Ánh sáng chiếu từ trên, bóng đổ xuống dưới.
   - [ ] Ở 32 px vẫn nhận ra icon.
   - [ ] Không có glow hoặc neon.
6. Xuất `.icns` bằng `sips` + `iconutil` (16, 32, 128, 256, 512 và các bản @2x), như trong `scripts/build-app.sh`.

## 5. Icon menu bar (status item)

Icon menu bar **không** dùng icon app thu nhỏ. Nó là bản đơn sắc của chính glyph trong icon app.

- Vẽ bằng code trong `MenuBarIcon.make()` (`NSImage(size:flipped:)` cỡ **18×18 pt**) và đặt `isTemplate = true`, để macOS tự đổi màu theo menu bar sáng/tối và trạng thái được chọn.
- Nét chính `1.7 pt`, nét phụ (track, đường kẻ) `1.1 pt`, đầu nét bo tròn. Glyph cách mép khoảng `2 pt`.
- Bỏ bớt chi tiết khi thu nhỏ (ví dụ VibeScreen chỉ còn 2 thanh trượt). Điểm nhấn của icon app (tia sét, núm trượt) vẽ khối đặc.
- Không dùng màu, không dùng SF Symbol khác với glyph của app, không load `.icns` vào status item.
- Ví dụ: `VibeShot/VibeShot/MenuBar/MenuBarIcon.swift`, `VibeScreen/.../Features/MenuBarIcon.swift`.
