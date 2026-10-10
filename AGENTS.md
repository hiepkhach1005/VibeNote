# MacPad - AI Project Rules

## Mục tiêu

Xây dựng một trình soạn thảo văn bản và mã nguồn native trên macOS bằng Swift/AppKit. Sản phẩm lấy cảm hứng từ nhóm tính năng của Notepad++, nhưng không sao chép tên, logo, thương hiệu, mã nguồn hoặc tài sản độc quyền của Notepad++.

## Parity source of truth

- Read `docs/ai/MASTER_PROMPT.md` for the complete implementation process.
- Read `docs/parity/FEATURE_PARITY_MATRIX.md` before choosing a feature.
- Read `docs/parity/MENU_PARITY_MATRIX.md` before adding or moving a command.
- Update `docs/parity/FEATURE_TRACKER.csv` and `docs/parity/IMPLEMENTATION_LOG.md` after each parity slice.
- Use `skills/macpad-editor/SKILL.md` for normal editor/domain/UI work.
- Use `skills/macpad-liquid-glass/SKILL.md` only for Liquid Glass/material/chrome work.

## Quy tắc bắt buộc

1. Đọc `docs/ai/PROJECT_STATE.md`, `FEATURE_MATRIX.md`, `ARCHITECTURE.md`, `BACKLOG.md`, `KNOWN_ISSUES.md` và các entry gần nhất trong `SESSION_LOG.md` trước khi làm việc.
2. Kiểm tra `git status` và bảo toàn thay đổi của người dùng.
3. Ưu tiên AppKit, TextKit 2, NSDocument, NSSplitViewController, native menus, native dialogs và SF Symbols.
4. Không dùng Electron, React, webview hoặc UI web cho editor.
5. Không triển khai Plugin System và tối ưu hiệu năng chuyên sâu trong phase hiện tại.
6. Không được đánh dấu feature là DONE nếu chưa có acceptance criteria, test phù hợp và cập nhật feature matrix.
7. Không để TODO quan trọng mà không ghi trong `BACKLOG.md`.
8. Không xóa dữ liệu hoặc file của người dùng bằng thao tác không thể phục hồi.
9. Không làm mất dữ liệu khi mở, đổi encoding, reload hoặc đóng file chưa lưu.
10. Sau mỗi vertical slice phải build/test và cập nhật tài liệu trạng thái.
11. Giữ cấu trúc và luồng thao tác quen thuộc của Notepad++, nhưng dùng Command shortcut và component native macOS.
12. Dùng Liquid Glass có tiết chế cho chrome/navigation; không phủ Liquid Glass lên vùng code/text chính.
13. MacPad chỉ được chạy một application instance; mọi tài liệu mở thêm phải đi vào các tab trong cùng cửa sổ MacPad.

## Quy ước code

- Swift rõ ràng, type-safe, ưu tiên value semantics ở domain model.
- Tách UI, domain, persistence và service.
- Mọi command quan trọng phải có menu, shortcut, validation và test.
- Tất cả màu sắc phải hỗ trợ Light/Dark Mode.
- Không hard-code shortcut nếu có thể đưa vào command/shortcut registry.
- Dùng tiếng Anh cho code, tên file và API; dùng tiếng Việt hoặc tiếng Anh rõ ràng cho tài liệu.

## Kiểm tra tối thiểu

```bash
swift build
swift test
```

Nếu môi trường không hỗ trợ một lệnh, ghi rõ trong `SESSION_LOG.md`, không giả vờ đã kiểm tra.

## Kết thúc phiên

Cập nhật `PROJECT_STATE.md`, `SESSION_LOG.md`, `FEATURE_MATRIX.md`, `BACKLOG.md` và `KNOWN_ISSUES.md` khi cần. Báo cáo task đã làm, file thay đổi, build/test và việc tiếp theo.
