# Makefile for Antigravity 4-Digit Project

# Varsayılan commit mesajı (make git-upload MSG="...")
MSG ?= "Otomatik güncelleme"
REMOTE ?= origin
BRANCH ?= main
REPO_URL ?= ""

.PHONY: help git-init git-upload clean

help:
	@echo "Kullanılabilir Komutlar:"
	@echo "  make git-init REPO_URL=https://github.com/..."
	@echo "      -> Git'i başlatır, dosyaları ekler ve uzak sunucuyu ayarlar."
	@echo "  make push [MSG=\"Mesaj\"]"
	@echo "      -> Değişiklikleri ekler, commit eder ve pushlar."
	@echo "  make save-login"
	@echo "      -> Kullanıcı adı/şifreyi bir kez sorup kaydeder."
	@echo "  make clean"
	@echo "      -> Xilinx/ISE tarafından oluşturulan gereksiz dosyaları temizler."

git-init:
	@if [ -z "$(REPO_URL)" ]; then echo "HATA: REPO_URL belirtilmedi. Örnek: make git-init REPO_URL=https://..."; exit 1; fi
	git init
	git add .
	git commit -m "İlk kurulum"
	git branch -M $(BRANCH)
	git remote add $(REMOTE) $(REPO_URL)
	@echo "Kurulum tamamlandı! Şimdi 'make git-upload' yapabilirsiniz."

push:
	git add .
	-git commit -m $(MSG)
	git push -u $(REMOTE) $(BRANCH)

save-login:
	git config credential.helper store
	@echo "Şimdi 'make push' yapın. İlk seferde şifre soracak, sonrasında bir daha sormayacak."


clean:
	@echo "Gereksiz dosyalar temizleniyor..."
	rm -rf _xmsgs xst iseconfig _ngo
	rm -f *.lso *.ngc *.ngd *.ncd *.pcf *.bld *.map *.mrp *.par *.bit *.xml *.log *.html *.xrpt *.cmd_log *.prj *.stx *.syr *.xst *.gise *.ise *.restore *.tcl

