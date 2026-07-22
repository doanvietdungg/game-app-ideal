# Khung cốt truyện chung của chặng Tây Du Ký

> Trạng thái: Bản nháp brainstorming, chưa phải đặc tả cuối cùng.

## Vai trò của tài liệu

Tài liệu này mô tả trục truyện chung của toàn chặng Tây Du Ký và quan hệ giữa các tuyến nhân vật. Chi tiết cung phát triển, ải và phần thưởng riêng của từng nhân vật được đặt trong tài liệu riêng.

## Ý tưởng tổng thể

Tây Du Ký là một chặng lớn trong game. Người dùng trải nghiệm cùng một thế giới và các mốc truyện chính, nhưng mỗi nhân vật có:

- Chương nguồn gốc riêng.
- Khuyết điểm và mục tiêu phát triển riêng.
- Cách nhìn khác nhau về cùng một biến cố.
- Một số ải và phần thưởng riêng.
- Nhiệm vụ ngoài đời phù hợp với chủ đề phát triển của nhân vật.

Các tuyến nhân vật không tạo ra những dòng thời gian mâu thuẫn. Sau chương nguồn gốc, chúng lần lượt hội tụ vào trục thỉnh kinh chung theo thời điểm phù hợp với cốt truyện.

## Trục truyện chung cấp cao

```text
Các chương nguồn gốc riêng
  -> Các nhân vật lần lượt gia nhập hành trình
  -> Đoàn thỉnh kinh được hình thành
  -> Vượt qua các yêu quái và kiếp nạn quan trọng
  -> Mỗi nhân vật đối diện khuyết điểm của chính mình
  -> Hoàn thành hành trình thỉnh kinh
  -> Nhận kết quả và danh vị cuối cùng
```

Không cần chuyển toàn bộ 81 nạn thành 81 ải riêng. Game lựa chọn các hồi và biến cố quan trọng, đặc biệt là những sự kiện có thể tạo ra bài học khác nhau khi nhìn từ từng nhân vật.

## Quan hệ giữa tuyến chung và tuyến riêng

### Chương nguồn gốc

- Mỗi nhân vật bắt đầu bằng một chương riêng để thiết lập hoàn cảnh, năng lực, khuyết điểm và động cơ.
- Chương nguồn gốc có thể có độ dài khác nhau tùy nhân vật.
- Tuyến nguồn gốc của Ngộ Không bắt đầu trước hành trình thỉnh kinh và bao gồm quá trình tích lũy sức mạnh, đại náo thiên cung cùng thời gian bị giam giữ.
- Nguồn gốc của các nhân vật khác chưa được thiết kế chi tiết.

### Trục thỉnh kinh chung

- Sau khi gia nhập đoàn, các nhân vật trải qua cùng những mốc truyện chính.
- Một sự kiện chung có thể tạo ra ải hoặc bài học riêng cho từng nhân vật.
- Ví dụ, cùng một biến cố có thể kiểm tra khả năng tự chủ của Ngộ Không, khả năng chống cám dỗ của Bát Giới, sự kiên trì của Đường Tăng và trách nhiệm của Sa Tăng.

### Chơi lại bằng nhân vật khác

- Người chơi không chỉ xem lại cùng một nội dung với hình ảnh nhân vật khác.
- Các mốc chính vẫn thống nhất, nhưng lời kể, lựa chọn hội thoại, nhiệm vụ ngoài đời và một số ải thay đổi theo tuyến nhân vật.
- Tiến trình và thành tích của mỗi hành trình nhân vật được lưu riêng.

## Các tuyến nhân vật dự kiến

| Nhân vật | Chủ đề phát triển sơ bộ | Trạng thái thiết kế |
| --- | --- | --- |
| Tôn Ngộ Không | Tích lũy sức mạnh, đối diện giới hạn và học cách sử dụng năng lực có mục đích | Đang thiết kế |
| Trư Bát Giới | Chống trì hoãn, quản lý cám dỗ và cải thiện thói quen | Chưa thiết kế |
| Đường Tăng | Kiên trì, học tập và giữ cam kết | Chưa thiết kế |
| Sa Tăng | Trách nhiệm, bền bỉ và hỗ trợ tập thể | Chưa thiết kế |

## Các loại ải dùng chung

Toàn chặng có thể sử dụng ba loại ải:

1. **Ải rèn luyện ngoài đời:** Người dùng thực hiện cam kết, check-in và nộp bằng chứng ở mốc quan trọng.
2. **Ải thuần game:** Người dùng sử dụng năng lực đã mở khóa để chiến đấu hoặc giải quyết tình huống; không cần bằng chứng.
3. **Ải tôi luyện/chuyển hóa:** Gắn với biến cố lớn, yêu cầu thử thách có trọng lượng hơn và trao thay đổi lâu dài cho nhân vật.

Tỷ lệ và cách triển khai ba loại ải có thể khác nhau theo nhân vật và giai đoạn truyện.

## Phạm vi MVP hiện tại

- Phần đã được thiết kế rõ nhất là chương nguồn gốc của Tôn Ngộ Không.
- MVP của tuyến Ngộ Không kết thúc khi nhân vật được gọi lên thiên đình làm quan.
- Tài liệu hiện chưa chốt cách tuyến Trư Bát Giới xuất hiện trong cùng MVP.
- Chi tiết xem tại:
  - `ngo-khong-story-arc.md`: cung truyện dài hạn của Ngộ Không.
  - `ngo-khong-mvp.md`: phạm vi có thể chơi trong MVP.

## Các vấn đề cần thiết kế tiếp

- Chặng Tây Du Ký mở đầu bằng lựa chọn nhân vật hay bằng một đoạn dẫn truyện chung?
- MVP chỉ tập trung vào Ngộ Không hay vẫn có cả tuyến Bát Giới như định hướng ban đầu?
- Những kiếp nạn nào được chọn làm mốc chung của hành trình thỉnh kinh?
- Điều kiện hội tụ và thời điểm gia nhập đoàn của từng nhân vật được thể hiện ra sao?
- Tiến trình nào dùng chung giữa các tuyến và tiến trình nào được lưu riêng?
