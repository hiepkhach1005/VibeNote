# AI Project Memory

Các file trong thư mục này là nguồn trạng thái bền vững của dự án. Không phụ thuộc vào lịch sử chat để biết project đang ở đâu.

## Thứ tự đọc mỗi phiên

1. `PROJECT_STATE.md`
2. `FEATURE_MATRIX.md`
3. `ARCHITECTURE.md`
4. `BACKLOG.md`
5. `KNOWN_ISSUES.md`
6. Các entry mới nhất trong `SESSION_LOG.md`

## Nguyên tắc cập nhật

- `SESSION_LOG.md` là append-only.
- `docs/parity/FEATURE_PARITY_MATRIX.md` là nguồn sự thật chi tiết về mức độ hoàn thành.
- `docs/parity/FEATURE_TRACKER.csv` là bản máy đọc được của parity status.
- `PROJECT_STATE.md` luôn mô tả đúng trạng thái hiện tại sau phiên gần nhất.
- Quyết định kiến trúc được ghi vào `DECISIONS.md`.
- Việc chưa làm phải có trong `BACKLOG.md`.
