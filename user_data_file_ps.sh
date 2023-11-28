#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y
#Prometheus, GitHub deposundan önceden derlenmiş bir binary dosya olarak indirilir https://prometheus.io/download/
sudo wget https://github.com/prometheus/prometheus/releases/download/v2.44.0/prometheus-2.44.0.linux-amd64.tar.gz
#Arşivlenen Prometheus dosyalarını çıkar
sudo tar xvfz prometheus-*.tar.gz
#(OPTINAL)Dosyalar çıkarıldıktan sonra arşivi silin veya depolama için farklı bir konuma taşıyın
rm prometheus-*.tar.gz
#Prometheus'un kullanması için iki yeni dizin oluşturun. Dizin /etc/prometheusPrometheus yapılandırma dosyalarını saklar. Dizin /var/lib/prometheusuygulama verilerini tutar.
sudo mkdir /etc/prometheus /var/lib/prometheus
#Çıkarılan klasörün ana dizinine gidin prometheus. yerine gerçek dizinin adını yazın prometheus-2.37.6.linux-amd64
cd prometheus-2.44.0.linux-amd64
#prometheusve promtool dizinlerini  /usr/local/bin/ dizinine taşıyın. Bu, Prometheus'u tüm kullanıcılar için erişilebilir kılar.
sudo mv prometheus promtool /usr/local/bin/
#prometheus.yml YAML yapılandırma dosyasını  /etc/prometheus dizine taşıyın
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
#consolesve dizinleri console_librariesözelleştirilmiş konsollar oluşturmak için gerekli kaynakları içerir. ihtiyaç duyulması halinde bu dosyalar da etc/prometheus dizine taşınmalıdır .Bu dizinler taşındıktan sonra orijinal dizinde yalnızca LICENSE ve NOTICE dosyaları kalır. Bu belgeleri başka bir konuma yedekleyin ve prometheus-releasenum.linux-amd64dizini silin.
sudo mv consoles/ console_libraries/ /etc/prometheus/
#Prometheus'un başarıyla kurulduğunu doğrulayın
prometheus --version
#Prometheus'u Service Olarak Yapılandırma
#Bir prometheus kullanıcısi oluşturun . Aşağıdaki komut bir sistem kullanıcısı oluşturur
sudo useradd -rs /bin/false prometheus
#Önceki bölümde oluşturulan iki dizinin sahipliğini yeni prometheus kullanıcısina atayın .
sudo chown -R prometheus:prometheus /etc/prometheus/ /var/lib/prometheus/
#Prometheus'un bir service olarak çalışmasına izin vermek için prometheus.service dosyasini oluşturun:
cat << 'EOF' > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.listen-address=0.0.0.0:9090 \
    --web.enable-lifecycle \
    --log.level=info

[Install]
WantedBy=multi-user.target
EOF
#Daemon'u yeniden yükleyin
sudo systemctl daemon-reload
#( OPTINAL ) prometheus Service i, sistem önyüklendiğinde otomatik olarak başlayacak şekilde  yapılandırmak için systemctl enable kullanın. Bu komut eklenmezse Prometheus'un manuel olarak başlatılması gerekir.
sudo systemctl enable prometheus
# prometheus service i başlatın ve status active olduğundan emin olmak için komutu gözden geçirin
sudo systemctl start prometheus
# http://local_ip_addr:9090 den web arayüzüne ve kontrol paneline erişebilirsin

#Prometheus'u İstemcileri(node's) İzleyecek Şekilde Yapılandırma

#Prometheus'u çalıştıran monitoring serverde prometheus.yml i düzenleme
#targets: izlenecek IP adreslerinin parantez içine alınmış virgulle ayrilmis bir listesi
#localhost:9100 local server i izler
sudo bash -c "cat << EOF > /etc/prometheus/prometheus.yml
# scrape_configs bölümünü bul ve düzenle
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Yeni bir scrape job ekle
  - job_name: 'remote_collector'
    scrape_interval: 10s
    static_configs:
      - targets: ['${private_ip_value}:9100']
EOF"
#Prometheus'u hemen yenilemek için prometheus servisini yeniden başlatın
sudo systemctl restart prometheus
#http://local_ip_addr:9090 den web arayüzünden ve kontrol panelinenden STATUS ve TARGET lar secilebilir. arayuzden remote_collector ile 9100 İstatistikleri inceleyebilirsin

#Grafana Server  Kurulumu ve Deployu
#apt kullanarak gerekli bazı yardımcı programları yükleyin
sudo apt-get install -y apt-transport-https software-properties-common
#Grafana GPG key i içe aktarın.
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
#Grafana "stabil sürümu"  ekleyin
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
#Yeni Grafana paketi de dahil olmak üzere depodaki paketleri güncelleyin
sudo apt-get update
#Grafana'nın açık kaynaklı sürümünü yükleyin
sudo apt-get install grafana -y
#systemctl Daemon'u yeniden yükleyin
sudo systemctl daemon-reload
#Grafana sunucusunu etkinleştirin ve başlatın. systemctl enable kullanmak sunucuyu, sistem önyüklendiğinde Grafana'yı başlatacak şekilde yapılandırır.
sudo systemctl enable grafana-server.service
sudo systemctl start grafana-server
#Grafana sunucusunun durumunu doğrulamak ve active durumunda olduğundan emin olmak istersen sudo systemctl status grafana-server kullanabilirsin
