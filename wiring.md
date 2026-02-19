# Bağlantı Şeması (Wiring Diagram)

Bu proje için **iki adet 74HC595** shift register entegresini seri (Daisy-Chain) bağlamanız ve **3461AS** (4-Digit Common Cathode) display'i bu entegrelere bağlamanız gerekmektedir.

## 1. 74HC595 Zincir Bağlantısı (Daisy-Chain)

FPGA'den gelen veriyi önce 1. entegreye, oradan da 2. entegreye aktaracağız.

| Bağlantı Tipi | Kaynak (Basys 2 / FPGA) | Hedef (1. 74HC595 - Segment Sürücü) | Hedef (2. 74HC595 - Digit Seçici) | Not |
|--------------|-------------------------|-------------------------------------|-----------------------------------|-----|
| **Data (SER)**| **DIO (Pin J3 / JA3)**  | **Pin 14 (DS)**                     | ---                               | Veri girişi (İlk entegreye) |
| **Clock (SR)**| **SCLK (Pin B2 / JA1)** | **Pin 11 (SH_CP)**                  | **Pin 11 (SH_CP)**                | Saat sinyali (Paralel) |
| **Latch (RCLK)**| **RCLK (Pin A3 / JA2)**| **Pin 12 (ST_CP)**                  | **Pin 12 (ST_CP)**                | Latch sinyali (Paralel) |
| **Zincir**   | ---                     | **Pin 9 (Q7')**                     | **Pin 14 (DS)**                   | **KRİTİK BAĞLANTI**: 1. entegrenin çıkışı 2. entegrenin girişine |
| **Reset**    | 3.3V (VCC)              | Pin 10 (MR)                         | Pin 10 (MR)                       | Aktif düşük reset, çalışması için VCC'ye bağlayın |
| **Enable**   | GND                     | Pin 13 (OE)                         | Pin 13 (OE)                       | Çıkışları aktif etmek için toprağa bağlayın |

---

## 2. 74HC595 -> 3461AS Display Bağlantısı

### 1. Entegre (Segmentler - Anotlar)
Bu entegre segmentleri sürer. Akım sınırlama direnci (örneğin 330 ohm veya 1k) kullanmanız önerilir.

Kod Mantığı: `shift_data[7:0]` buraya yerleşir.

| 74HC595 (1. Entegre) Pin | 3461AS Display Pin (Segment) | Açıklama |
|--------------------------|------------------------------|----------|
| Pin 15 (Q0)              | A                            | Segment A |
| Pin 1  (Q1)              | B                            | Segment B |
| Pin 2  (Q2)              | C                            | Segment C |
| Pin 3  (Q3)              | D                            | Segment D |
| Pin 4  (Q4)              | E                            | Segment E |
| Pin 5  (Q5)              | F                            | Segment F |
| Pin 6  (Q6)              | G                            | Segment G |
| Pin 7  (Q7)              | DP                           | Nokta (Decimal Point) |

### 2. Entegre (Digit Seçimi - Katotlar)
Bu entegre hangi basamağın yanacağını seçer. Kodumuzda aktif basamak için çıkış **0 (LOW)** yapılır (Common Cathode için).

Kod Mantığı: `shift_data[15:8]` buraya yerleşir.

| 74HC595 (2. Entegre) Pin | 3461AS Display Pin (Digit) | Fonksiyon (Kod varsayımı) |
|--------------------------|----------------------------|---------------------------|
| Pin 15 (Q0)              | D4 (En Sağ / Birler)       | Digit 0 (Birler Basamağı) |
| Pin 1  (Q1)              | D3 (Sağdan 2. / Onlar)     | Digit 1 (Onlar Basamağı)  |
| Pin 2  (Q2)              | D2 (Soldan 2. / Yüzler)    | Digit 2 (Yüzler Basamağı) |
| Pin 3  (Q3)              | D1 (En Sol / Binler)       | Digit 3 (Binler Basamağı) |

*Not: Eğer basamaklarınız ters sırada çalışırsa (örneğin sayılar soldan sağa akarsa), bu bağlantı sırasını veya kodunuzdaki `display_scanner.v` içindeki `scan_idx` eşleşmesini tersine çevirebilirsiniz.*
