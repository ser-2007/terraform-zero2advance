
Project 1 Project Name: "Managing AWS EC2 with Terraform"

Project Objectives:

Learn how to create and manage an EC2 instance in AWS.

Automate infrastructure using Terraform and manage it with code.

Understand essential AWS features like security groups, key pairs, private keys, and Elastic IPs.

Learn about monitoring and security measures when creating an AWS EC2 instance.

Project Steps:

Preparing the Project Infrastructure:

Create an AWS account or use an existing AWS account.
Create a Virtual Private Cloud (VPC) and subnets in AWS.
Setting Up the Terraform Environment:

Install Terraform on your computer.
Configure AWS credentials to interact with AWS.
Creating the Terraform Configuration File:

Create a Terraform configuration file named main.tf.
Creating the EC2 Resource:

Define a resource in the Terraform configuration file that creates an EC2 instance. This resource should have the following properties:
Instance Type
Key Pair
Security Groups
Key Pair
Assignment of a private IP or Elastic IP
Creating the EC2 with Terraform:

Use Terraform commands to create the EC2 instance.
Managing and Updating with Terraform:

Use Terraform to manage and update your EC2 instance.
Security and Monitoring:

Take appropriate security measures to secure your AWS EC2 instance, such as configuring security groups and authentication settings.
Use AWS CloudWatch or monitoring tools like Prometheus and Grafana to monitor your EC2 instance.
Learning and Improvement:

Review documentation and resources to understand and improve the actions and configurations done with Terraform throughout the project.
Once you complete this project, you will have gained basic Terraform skills, learned how to create and manage AWS EC2 instances, and acquired knowledge about security and monitoring. This project serves as a foundation for exploring more complex scenarios and further development.

*Türkce version*

Proje Adı: "Terraform ile AWS EC2 Yönetimi"

Proje Amaçları:

AWS'de bir EC2 örneği oluşturmayı ve yönetmeyi öğrenmek.

Terraform kullanarak altyapıyı otomatikleştirmek ve kodla yönetebilmek.

Güvenlik grupları, anahtar çiftleri, özel anahtarlar ve elastik IP'ler gibi temel AWS özelliklerini yapılandırmayı anlamak.

AWS EC2 örneğini oluştururken izleme ve güvenlik önlemleri almayı öğrenmek.

Proje Adımları:

Proje Altyapısının Hazırlanması:

AWS hesabı oluşturun veya mevcut bir AWS hesabını kullanın.
AWS'de bir VPC (Virtual Private Cloud) ve alt ağlar (subnet) oluşturun.
Terraform Ortamının Hazırlanması:

Terraform'ı bilgisayarınıza yükleyin.
AWS ile etkileşim kurmak için AWS kimlik bilgilerini yapılandırın.
Terraform Konfigürasyon Dosyasının Oluşturulması:

main.tf adında bir Terraform konfigürasyon dosyası oluşturun.
EC2 Kaynağının Oluşturulması:

Terraform konfigürasyon dosyasında, EC2 örneği oluşturan kaynağı tanımlayın. Bu kaynak aşağıdaki özelliklere sahip olmalıdır:
Örnek türü (Instance Type)
Özel anahtar (Key Pair)
Güvenlik grupları (Security Groups)
Özel anahtar (Key Pair)
Özel IP veya elastik IP atanması (Elastic IP)
Terraform ile EC2'nin Oluşturulması:

Terraform komutlarını kullanarak EC2 örneğini oluşturun.
Terraform ile Yönetim ve Güncelleme:

Terraform ile EC2 örneğinizin güncellenmesini ve yönetilmesini uygulayın.
Güvenlik ve İzleme:

AWS EC2 örneğinizin güvenliğini sağlamak için uygun önlemleri alın, örneğin, güvenlik gruplarını ve kimlik doğrulama ayarlarını kontrol edin.
EC2 örneğinizi izlemek için AWS CloudWatch veya Prometheus ve Grafana gibi izleme araçlarını kullanın.
Öğrenme ve İyileştirme:

Proje boyunca Terraform ile yapılan işlemleri ve ayarları anlamak ve iyileştirmek için belgeleri ve kaynakları inceleyin.
Bu projeyi tamamladığınızda, temel Terraform becerileri kazanmış, AWS EC2 örneklerini oluşturup yönetmeyi öğrenmiş olacaksınız. Ayrıca, güvenlik ve izleme konularında temel bilgileri edinmiş olacaksiniz.

STEP1 - KURULUM
Terraform’u indir (https://www.terraform.io/downloads.html)

Aws cli ını indir(yoksa)

main.tf I ve terraform klasörünü burada oluştur. Ayrıca VS Code için Terraform plug-in ini yada HashiCorp Terraform isimli başka bir plug ini kurabilirsin

Cmd: setx AWS_PROFILE user1 user1 isimli kullanıcıyı oluşturur. aws configure --profile "user1" Oluşturulan user1 in bilgilerini girer, region’dur, access key’dir, user key’dir vs. Bunlar zaten AWS accountlarında var. csv dosyasında veya .aws teki .config .credentials ta bulabilirsin Kullanıcı oluşturduktan sonra(aws hesabı zaten var) (.aws/credidentials i ac) aws configure list varolan kullanıcıları döndürür.

Provider ın içine neredeyse hiçbir şey tanımlanmayacak. Terraform böyle olunca .aws den ilgili bilgiyi otomatik olarak çekecek.. Bu credidentials ı tanımlamanın 3 farklı yolu var: _ 1) cmd den tanımlarsın _ 2) main.tf in içindeki providers bloğuna tanımlarsın--ÖNERİLMEZ, GÜVENLİ DEĞİLDİR!!-- * 3) .aws in içindeki credidentials ın içine tanımlarsın. -2. yola göre daha güvenlidir ancak birinci yola göre daha fazla uğraştırır--

Note: If you delete your AWS credentials from provider block, Terraform will automatically search for saved API credentials (for example, in ~/.aws/credentials) or IAM instance profile credentials.

Oncelikle bir proje klasoru olusturarak baslayalim. Klasorde variables.tf dosyasi olustur. Infrastructor icin kullanacagimiz degiskenleri bu dosyada belirtiyoruz.

variable "name" {
    description = "name of the project"
    type = string
}
variable "region" {
    description = "aws region"
}
variable "vpc_cidr_block" {
    description = "vpc cidr block"
}
variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = map(string)
}
variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = map(string)
}

variable "availability_zones" {
  description = "availability zone"
  type        = list(string)
}
variable "security_group_name" {
  description = "security group name"
}
variable "ingress_ports" {
  description = "Ingress ports for security group"
  type        = list(object({
    port        = number
    description = string
  }))
}

variable "ingress_ports_nexp" {
  description = "Ingress ports for security group"
  type        = list(object({
    port        = number
    description = string
  }))
}

variable "egress_ports" {
  description = "Egress ports for security group"
  type        = list(object({
    port        = number
    description = string
  }))
}
variable "ami_owners" {
  description = "ami owners"
}
variable "ami_name" {
  description = "ami name"
}
variable "ami_virtualization-type" {
    description = "ami virtualization type"
}
variable "instance_type" {
    description = "instance type"
}
variable "key_name" {
    description = "key name"
}
variable "user_data_file_ps" {
    description = "user data file for prometheus server"

}
variable "user_data_file_nexp" {
    description = "user data file for node exporter"

}
Ayni dosya yolunda simdi de terraform.tfvars dosyasi olusturup variables.tf dosyasinda tanimladigimiz degiskenlere degerlerini atiyoruz.

name= "project1"
region = "us-east-2"

vpc_cidr_block = "10.0.0.0/16"
availability_zones = ["a","b","c"]
public_subnet_cidr_blocks = {
    "a" = "10.0.10.0/24"
    "b" = "10.0.12.0/24"
    "c" = "10.0.14.0/24"
  }
 private_subnet_cidr_blocks = {
    "a" = "10.0.11.0/24"
    "b" = "10.0.13.0/24"
    "c" = "10.0.15.0/24"
  }


security_group_name = "security-group"
ingress_ports = [{
    port        = 22
    description = "SSH"
  },
  {
    port        = 80
    description = "HTTP"
  },
  {
    port        = 443
    description = "HTTPS"
  },
  {
    port        = 9090
    description = "Prometheus"
  },
  {
    port        = 9100
    description = "Node Exporter"
  },
  {
    port        = 3000
    description = "Grafana"
  }]

ingress_ports_nexp = [{
    port        = 22
    description = "SSH"
  },
  {
    port        = 80
    description = "HTTP"
  },
  {
    port        = 443
    description = "HTTPS"
  },

  {
    port        = 9100
    description = "Node Exporter"
  },
 ]

egress_ports  = [{
    port        = 0
    description = "All traffic"
  }]

ami_owners = "099720109477"
ami_name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
ami_virtualization-type = "hvm"
instance_type = "t2.micro"
key_name = "<key_file_name>"
user_data_file_ps = "user_data_ps.sh"
user_data_file_nexp = "user_data_nexp.sh"
PrometheusGrafana Server icin kullanacagimiz user datayi .sh uzantili bir dosya olusturup duzenliyoruz.

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


Ayni sekilde Node Exporter un user datasi icin yeni bir .sh dosyasi olusturup duzenliyoruz

#!/bin/bash
sudo apt-get update
##İstemciye Node Exporter Kurma ve Yapılandırma
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
#Uygulamayı çıkar
tar xvfz node_exporter-*.tar.gz
#Yürütülebilir usr/local/bin sistem genelinde erişilebilir olacak şekilde taşınsın
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
#Kalan dosyaları kaldır
rm -r node_exporter-1.5.0.linux-amd64*
#Node Exporter'ı çalıştırmanın iki yolu vardır. Komutu kullanılarak terminalden başlatılabilir node_exporter. Veya sistem hizmeti olarak etkinleştirilebilir. Terminalden çalıştırmak daha az kullanışlıdır. Ancak araç yalnızca ara sıra kullanıma yönelikse bu bir sorun olmayabilir. Node Exporter'ı manuel olarak çalıştırmak için `node_exporter` komutunu kullanın. Terminal, istatistik toplama sürecine ilişkin ayrıntıların çıktısını verir.
#Node Exporter'ı bir servis olarak çalıştırmak daha uygundur. Node Exporter'ı bu şekilde çalıştırmak için öncelikle bir node_exporterkullanıcı oluşturun.
sudo useradd -rs /bin/false node_exporter
#systemctl Kullanmak için bir servis dosyası oluşturun . Dosyanın adlandırılması node_exporter.service ve aşağıdaki formatta olması gerekir.
cat << 'EOF' > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
#( OPTIONAL) İstemciyi sürekli olarak izlemeyi düşünüyorsanız, Node Exporter'ı önyükleme sırasında otomatik olarak başlatmak için systemctl enable komutunu kullanın. Bu, 9100 portundaki sistem ölçümlerini sürekli olarak ortaya çıkarır . Node Exporter'ın yalnızca ara sıra kullanılması amaçlanıyorsa aşağıdaki komutu kullanmayın.
sudo systemctl enable node_exporter
#systemctl Daemon yeniden yükleyin, Node Exporter'ı başlatın ve durumunu doğrula. servis active olmalıdır .
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter
#bir web tarayıcısıda http://local_ip_addr:9100 ile, Node Exporter Metricsleri görüntülenir. Metrics Bağlantısina tıklayarak Metrics ve istatistiklerin toplandığını gorebilirsin
AWS VPC ve Alt Aglar Olusturma
AWS Sağlayıcısı Tanımlama
Spesifik bir teknolojiyle veya platformla nasıl konuşulacağını bilir. Seçilen platformun API ının anlaşılmasından sorumludur. (https://registry.terraform.io/browse/providers)

Oncelikle bir proje klasoru olusturarak baslayalim. Klasorde main.tf dosyasi olustur.

provider "aws" {
  region = "${var.region}" # EC2 örneğinin oluşturulacağı AWS bölgesini belirtir.
}
terraform’u yüklediğin directory’yi set ettikten ve main.tf i oluşturduktan sonra;

terraform init
Network Resource lari Tanımlama
"resource type" ve the "resource name" ile altyapı parçalarini tanımliyoruz.

Virtual Private Cloud (VPC) Tanımlama
Resource a ilişkin argümanlari resource block'un içinde tanimliyoruz.

resource "aws_vpc" "vpc-project1" {
  cidr_block = "${var.vpc_cidr_block}"
  tags = {
    Name = "${var.name}-vpc"
  }
}
Public Subnetler Tanımlama
Tanimladigimiz VPC nin altinda Subnetler tanimliyoruz

resource "aws_subnet" "public-subnets-project1" {
  vpc_id                  = aws_vpc.vpc-project1.id
  for_each                = toset(var.availability_zones)
  cidr_block              = var.public_subnet_cidr_blocks[each.value]
  availability_zone       = "${var.region}${each.value}"
  map_public_ip_on_launch = true # public subnetler icin true

  tags = {
    Name = "${var.name}-public-subnet-${upper(each.value)}"
  }
}
Private Subnetler Tanımlama
resource "aws_subnet" "private-subnets-project1" {
  vpc_id                  = aws_vpc.vpc-project1.id
  for_each                = toset(var.availability_zones)
  cidr_block              = var.private_subnet_cidr_blocks[each.value]
  availability_zone       = "${var.region}${each.value}"
  map_public_ip_on_launch = false # private subnetler icin false

  tags = {
    Name = "${var.name}-private-subnet-${upper(each.value)}"
  }
}
Internet Gateway Tanımlama
Bu bloklar, Internet Gateway ve Default Route Table oluşturur. İnternet Gateway, VPC'nin dışındaki trafiği yönlendirmek için kullanılır.

resource "aws_internet_gateway" "gw-project1" {
  vpc_id = aws_vpc.vpc-project1.id
  tags = {
    Name: "${var.name}-igw"
  }
}
Default Route Table Tanımlama
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.vpc-project1.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-project1.id
  }
  tags = {
    Name: "${var.name}-main-rtb"
  }
}
Network Access Control List (NACL) Tanımlama
Bu bloklar, Network ACL (ağ erişim kontrol listesi) ve bu ACL'nin subnetlerle ilişkilendirilmesini sağlar.

resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.vpc-project1.id

  egress = [
    {
      rule_no    = 100
      protocol   = "-1"
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = 0
      to_port    = 0
      icmp_code  = -1
      icmp_type  = -1
      ipv6_cidr_block = null
    }
  ]

  ingress = [
    {
      rule_no       = 100
      protocol      = "-1"
      action        = "allow"
      cidr_block    = "0.0.0.0/0"
      from_port     = 0
      to_port       = 0
      icmp_code     = -1
      icmp_type     = -1
      ipv6_cidr_block = null
    }
  ]

  tags = {
    Name = "${var.name}-public-nacl"
  }
}
NACL'ın Subnet'e Atanması
resource "aws_network_acl_association" "public_subnet_nacl" {
  for_each = toset(var.availability_zones)
  subnet_id      = aws_subnet.public-subnets-project1[each.value].id
  network_acl_id = aws_network_acl.public_nacl.id
}
Route Table ile Subnet Bağlantısını Tanımlama
Bu blok, varsayılan Route Table in Subnetlerle ilişkilendirilmesini sağlar.

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public-subnets-project1[var.availability_zones[count.index]].id
  route_table_id = aws_default_route_table.main-rtb.id
}
EC2 Kaynaklarını Tanımlama
Server İçin Security Group Tanımlama
Bu bloklar, Security Groupları tanımlar. Prometheus/Grafana Server ve Node Exporter icin olmak uzere İki farklı Security Group tanımlanmıştır.

resource "aws_security_group" "sg-project1" {
  name        = "${var.name}-${var.security_group_name}"
  vpc_id      = aws_vpc.vpc-project1.id
  description = "upper(${var.name}) ${var.security_group_name}"

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.port == 0 ? "-1" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = egress.value.description
    }
  }
}
Node Exporter İçin Security Group Tanımlama
resource "aws_security_group" "sg-project1_nexp" {
  name        = "${var.name}-${var.security_group_name}-nexp"
  vpc_id      = aws_vpc.vpc-project1.id
  description = "upper(${var.name}) ${var.security_group_name} for node exporter"

  dynamic "ingress" {
    for_each = var.ingress_ports_nexp
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.port == 0 ? "-1" : "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = egress.value.description
    }
  }
}

Ubuntu AMI Bilgisini Çekme
Bu blok, kullanılacak AMI'yi belirler.

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["${var.ami_owners}"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["${var.ami_virtualization-type}"]
  }
}
Bu bloklar, EC2 örneklerini oluşturur. İlk blok node exporter, ikincisi ise PrometheusGrafana server instance idir.

Node Exporter İçin EC2 Oluşturma
resource "aws_instance" "node_exporter" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "${var.instance_type}"
  subnet_id     = aws_subnet.public-subnets-project1[var.availability_zones[0]].id
  security_groups = [aws_security_group.sg-project1_nexp.id]
  key_name = "${var.key_name}"
  availability_zone = "${var.region}${var.availability_zones[0]}"
  associate_public_ip_address = true
  user_data = file("${var.user_data_file_nexp}")
  tags = {
    Name = "${var.name}-node_exporter"
  }
}
Prometheus Server İçin User Data Şablonu Oluşturma
data "template_file" "user_data_template" {
  template = file("${var.user_data_file_ps}")
  vars = {
    private_ip_value = aws_instance.node_exporter.private_ip
  }
}
Prometheus Server İçin EC2 Oluşturma
resource "aws_instance" "project1-ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "${var.instance_type}"
  subnet_id     = aws_subnet.public-subnets-project1[var.availability_zones[0]].id
  security_groups = [aws_security_group.sg-project1.id]
  key_name = "${var.key_name}"
  availability_zone = "${var.region}${var.availability_zones[0]}"
  associate_public_ip_address = true
  user_data = data.template_file.user_data_template.rendered

  tags = {
    Name = "${var.name}-prometheus_server"
  }
}
Outputlar
PrometheusGrafana ve Node Exporter'ın public IP adreslerini döndürür.

output "prometheus_grafana_instance_ip" {
  value = aws_instance.project1-ec2.public_ip
}

output "node_exporter_instance_ip" {
  value = aws_instance.node_exporter.public_ip
}

terraform init
terrraform apply


![INTANCES ARE UP](image.png)


Sistem ayaga kalktiktan sonra Grafana ve Prometheus u butunlestirecegiz. Geri kalan yapılandırma görevleri Grafana web arayüzü kullanılarak gerçekleştirilebilir.

http://local_ip_addr:3000 Grafana giriş sayfasını görüntüler;

default user name: admin default password : password

password degistirme adimindan sonra Grafana Kontrol Panelini görüntülenir.

1-Prometheus'u veri kaynağı olarak eklemek için Configuration'ı temsil eden dişli sembolüne tıklayın ve ardından Data Sources'u seçin 2-Bir sonraki ekranda Add data source butonunu tıklayın. 3-Data Source olarak Prometheus'u seçin 4-Local Prometheus source için URL'yi http://localhost:9090 olarak ayarlayın. Diğer ayarların çoğu varsayılan değerlerde kalabilir. Ancak buraya varsayılan olmayan bir Timeout değer eklenebilir. 5-Save & Test butonunu kullanarak devam edin 6-Tüm ayarlar doğruysa Grafana, Data source is working seklinde onaylar

Grafana Dashboard Import etme:

1-Ozel bir kontrol paneli oluşturmak için dört kareye benzeyen Dashboard butonuna tıklayın. 2-Ardından + New Dashboard'u seçin (https://grafana.com/docs/grafana/latest/getting-started/build-first-dashboard/) 3-Grafana Dashboard Kütüphanesini ziyaret edin(https://grafana.com/grafana/dashboards/). 4-Arama terimi olarak Node exporter girin. 6-Bir tane Dashboard secin ve ID numarasini not edin veya Copy ID to clipboard i secin 7-Grafana kontrol paneline dönün. Dört kareden oluşan Dashboard simgesini seçin ve + Import'u seçin. 8-Import via grafana.com kismina önceki adımdaki ID yi girin ve Load i secin. 9-Bir sonraki ekranda Import ayrıntılarını onaylayın. Prometheus Vdata source olarak seçin ve Import u tıklayın. 9-Kontrol paneli secilen Dashboard anında etkili olur. Bellek, RAM ve CPU ayrıntıları da dahil olmak üzere istemci node un performans ölçümlerini ve durumunu görüntülenir.


![INTANCES ARE UP](image2.png)