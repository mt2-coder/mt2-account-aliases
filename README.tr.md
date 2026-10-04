# Metin2 Account Aliases

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) ·
[Italiano](README.it.md) · [Português](README.pt.md) · [Română](README.ro.md) · **Türkçe**

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases?color=blue)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

*[İngilizce sürümün](README.md) çevirisidir, 4 Ekim 2026 itibarıyla günceldir. Farklılık olması
durumunda İngilizce sürüm esas alınır.*

**Metin2 hesaplarına Gameforge Client'ta okunabilir adlar ver ve onları adlarıyla bul.**

Oyun hesapları asla yeniden adlandırılamaz; Tigerghost sunucusunda launcher onlara
`playerg123456789` gibi otomatik oluşturulmuş kimlikler bile verir. Sayfa başına dört hesap
listelenirken onlarca hesap arasında doğru olanı bulmak tahmin oyununa döner. Bu ücretsiz eklenti,
doğrudan launcher'ın kendi hesap listesinde onlara `main`, `buff` veya `meley1` gibi adlar
vermeni sağlar.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Demoyu YouTube'da izle](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[En son sürümü indir](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
ücretsiz ve açık kaynak ([MIT](LICENSE))

> Resmî olmayan eklenti: Gameforge ile bağlantılı değildir ve Gameforge tarafından
> onaylanmamıştır.

## Ne yapar

Launcher'da, **Ayarlar > Oyun hesabı** bölümünde:

- **Hesaplarına ad ver.** Bir hesap adının yanındaki kalem, o hesaba bir takma ad verir: Enter
  kaydeder, Esc iptal eder, boş bir takma ad onu siler. Önce takma ad, yanında küçük gri harflerle
  gerçek ad görünür; uzun bir takma ad ekranda kısaltılır ve araç ipucunda tam olarak gösterilir.
- **Onları adlarıyla bul.** Launcher'ın kendi arama kutusu (tablonun üstündeki büyüteç) hesapları
  takma adlarıyla da bulur ve sayfaları çalışmaya devam eder.
- **Yedek al.** Sağ alttaki **Manage** düğmesi tüm takma adlarını metin olarak gösterir: yedek
  almak için bu metni kopyala ya da yedeği geri yüklemek veya takma adlarını başka bir bilgisayara
  taşımak için yapıştırıp **Apply** düğmesine bas.

Eklenti ve yükleyicisi yalnızca İngilizcedir: düğmelerin adı **Manage**, **Copy** ve **Apply**'dır
ve yükleyicinin mesajları İngilizce görünür.

## Güvenli mi?

Eklenti tek bir kural üzerine kuruludur: oyununu ya da hesabını asla riske atmamak.

- **Oyuna asla dokunmaz.** Ne `metin2client.exe`'ye, ne oyunun herhangi bir dosyasına, ne de hile
  önleme sistemine. Eklentinin hiçbir parçası oyunun içinde çalışmaz.
- **Yalnızca launcher penceresinin üzerinde bir katmandır.** Launcher'ın arayüzü, tek bir dosyada
  (`resources\frontend.pak`) saklanan bir web sayfasıdır. Eklenti bu sayfaya küçük bir betik
  ekler, başka hiçbir şey yapmaz: launcher programı ve oyunu başlatma şekli tamamen aynı kalır.
- **Hesabına dokunulmaz.** Takma adlar yalnızca senin bilgisayarında bulunur: hesaplarının gerçek
  adları ne bilgisayarında ne de Gameforge'un sunucularında asla değişmez. Eklenti hiçbir ağ
  isteği yapmaz; şifreni, oturumunu veya hesap verilerini asla okumaz, yalnızca ekranda zaten
  görünen hesap adlarını okur.
- **İstediğin zaman geri alabilirsin.** Yükleyici, launcher'ın dosyasını değiştirmeden önce
  yedeğini alır ve `Uninstall.cmd` orijinali bayt bayt geri koyar.
- **Hiçbir şey gizli değil.** `.exe` yok: eklenti, okuyabileceğin tek bir JavaScript dosyasıdır,
  [`src/alias-addon.js`](src/alias-addon.js), yükleyici ise tek bir PowerShell betiğidir,
  [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Her sürüm GitHub tarafından bu herkese
  açık koddan derlenir ve SHA-256 özeti ile bir
  [köken doğrulaması](https://github.com/mt2-coder/mt2-account-aliases/attestations) (provenance
  attestation) ile birlikte gelir.

Eklenti MIT lisansı altında özgür yazılımdır; yani hiçbir garanti olmadan sunulur.

## Kurulum

Windows 10 veya 11, Gameforge Client ve yönetici haklarına ihtiyacın var.

1. `mt2-account-aliases-x.y.z.zip` dosyasını
   [en son sürümden](https://github.com/mt2-coder/mt2-account-aliases/releases/latest) indir ve
   ayıkla.
2. Metin2'yi ve bildirim alanındaki simgesi de dahil Gameforge Client'ı kapat.
3. **`Install.cmd`** dosyasına çift tıkla. Windows sorarsa önce **Çalıştır**'a, sonra **Evet**'e
   tıkla.
4. Launcher'ı başlat ve **Ayarlar > Oyun hesabı** bölümünü aç.

Yükleyici, launcher nereye kurulmuş olursa olsun onu bulur. Gameforge Client 2.8.5.1959 (arayüz
0.486.2) ile denendi.

Takma adlarını launcher yalnızca bu bilgisayarda saklar. Launcher'ın verilerini silen her şey
onları da siler; bu yüzden **Manage** ile bir yedek al.

## Kaldırma

Launcher'ı kapat, sonra **`Uninstall.cmd`** dosyasına çift tıkla: launcher'ın orijinal dosyası
bayt bayt geri gelir. Takma adların launcher'da kayıtlı kalır, yani yeniden kurduğunda geri
gelirler.

## Launcher arayüzünü güncellediğinde

Launcher, eklentinin değiştirdiği bir arayüzü güncelleyemez. Bir güncelleme duyurduğunda veya bir
güncellemeyi uygulayamadığını söylediğinde:

1. Launcher'ı kapat, sonra `Uninstall.cmd` dosyasına çift tıkla.
2. Launcher'ı başlat, güncellenmesine izin ver, sonra kapat.
3. `Install.cmd` dosyasına yeniden çift tıkla.

## Sorun giderme

- **Ne kurulu?** `Status.cmd` sana söyler ve hiçbir şeyi değiştirmez.
- **"Gameforge Client not found".** Ayıklanan klasörde bir komut istemi aç (Dosya Gezgini'nin
  adres çubuğuna `cmd` yaz, sonra Enter'a bas) ve launcher'ın `frontend.pak` dosyasının yolunu
  ver: `Install.cmd -PakPath "D:\Oyunlar\GameforgeClient\resources\frontend.pak"`.
- **Hesap listesinde kalem yok.** `Install.cmd -Diagnostic` komutunu aynı şekilde çalıştır.
  Launcher'ın ana penceresinin sol altında küçük bir etiket belirir ve eklentinin ne kadar
  ilerlediğini gösterir:

  | Etiket | Anlamı |
  | --- | --- |
  | hiç yok | launcher değiştirilmiş sayfayı göstermedi |
  | kırmızı, `script did not run` | sayfa gösteriliyor, ama eklenti hiç çalışmadı |
  | `active - no account on screen`, hesap listesi açıkken | eklenti çalışıyor, ama hiç hesap bulamıyor |
  | `active - 4 account(s) on screen (2 windows)` | hesap listesi bulundu ve takma adlarla tamamlandı |
  | `... error (...): ...` | mesaj neyin başarısız olduğunu söyler |

  `-Diagnostic` olmadan çalıştırılan `Install.cmd` etiketi kaldırır.
- **Launcher başka bir dile geçti.** Bunun eklentiyle hiçbir ilgisi yok: launcher'ın sağ üstündeki
  küre simgesi dili geri ayarlar.

---

## Geliştiriciler ve Gameforge ekipleri için

Teknik bölüm (eklentinin nasıl çalıştığı, bu özelliğin launcher'ın kendisine nasıl eklenebileceği,
testler, sürümler) yalnızca İngilizce olarak mevcuttur:
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Lisans

[MIT](LICENSE). Yalnızca bu depoyu kapsar: `frontend.pak` dahil olmak üzere Gameforge Client ve
dosyaları Gameforge'a ait olmaya devam eder.
