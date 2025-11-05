# 🧪 PKI Лаборатория: EJBCA + Smallstep CA на Google Cloud (Terraform + Docker)

Этот лабораторный проект разворачивает и изучает **PKI-инфраструктуру** на облаке Google Cloud с помощью **EJBCA Community Edition** и лёгкой альтернативы **Smallstep CA**.

Он включает всё: от настройки окружения и деплоя Terraform до полного удаления ресурсов.  
✅ Всё в одном файле, с командами copy/paste.

---

## 📋 Содержание

1. [Предварительные требования](#предварительные-требования)  
2. [Установка инструментов](#установка-инструментов)  
3. [Настройка Google Cloud](#настройка-google-cloud)  
4. [Создание VM вручную (альтернатива Terraform)](#создание-vm-вручную-альтернатива-terraform)  
5. [Деплой через Terraform](#деплой-через-terraform)  
6. [Развёртывание EJBCA](#развёртывание-ejbca)  
7. [Проверка работы контейнеров](#проверка-работы-контейнеров)  
8. [Лёгкая альтернатива: Smallstep CA](#лёгкая-альтернатива-smallstep-ca)  
9. [Очистка и предотвращение расходов](#очистка-и-предотвращение-расходов)  
10. [Полезные ссылки](#полезные-ссылки)

---

## 🧾 Предварительные требования

- 🌐 Аккаунт Google Cloud (с активированным **Free Tier** или **Free Trial**).  
- 🐧 Базовые знания Linux, SSH и Docker.  
- 🛠️ Установленные инструменты: `git`, `terraform`, `gcloud`, `docker`.  
- 💰 Примерный бюджет: **0 €**, если удалить всё после теста.

---

## 🛠️ Установка инструментов

### 1. Google Cloud SDK

```bash
sudo apt update
sudo apt install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
sudo apt update && sudo apt install -y google-cloud-sdk
```

**🔐 Авторизация:**
```bash
gcloud init
```

### 2. Terraform

```bash
sudo apt-get update && sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform_1.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform -version
```

### 3. Docker и Compose

```bash
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker && sudo systemctl start docker
```

### 4. Git

```bash
sudo apt install -y git
```

---

## ☁️ Настройка Google Cloud

**Создай или выбери проект:**
```bash
gcloud projects create my-pki-lab
gcloud config set project my-pki-lab
```

**Включи Compute Engine:**
```bash
gcloud services enable compute.googleapis.com
```

**Проверь аутентификацию:**
```bash
gcloud auth list
```

---

## 🖥️ Создание VM вручную (альтернатива Terraform)

```bash
gcloud compute instances create ejbca-vm \
  --zone=us-central1-a \
  --machine-type=e2-micro \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-size=30GB \
  --tags=http-server,https-server
```

**🔗 SSH подключение:**
```bash
gcloud compute ssh ejbca-vm --zone us-central1-a
```

---

## 🏗️ Деплой через Terraform

Проект включает полную конфигурацию Terraform со следующими компонентами:

- 🌐 **Резервирование статического IP** для постоянного доступа
- 🔥 **Правила файрвола** для SSH, HTTP, HTTPS и портов EJBCA
- 🚀 **VM со скриптом инициализации**, который автоматически устанавливает Docker и разворачивает EJBCA
- 🔄 **Caddy reverse proxy** для HTTPS терминации

### Быстрый старт

1. 🚀 **Инициализация Terraform:**
```bash
terraform init
```

2. 👀 **Просмотр плана:**
```bash
terraform plan
```

3. 🏗️ **Развёртывание инфраструктуры:**
```bash
terraform apply -auto-approve
```

4. 🔍 **Проверка IP адреса:**
```bash
gcloud compute instances list
```

### Файлы конфигурации

- 📄 `main.tf` - Основная конфигурация Terraform
- 🔧 `variables.tf` - Определения переменных
- ⚙️ `terraform.tfvars` - Ваши конкретные значения
- 🚀 `startup.sh` - Скрипт инициализации VM

---

### Выбор типа CA (EJBCA или Smallstep)

Перед запуском Terraform выберите, какую CA развернуть: EJBCA или Smallstep CA.

Откройте или создайте файл `terraform.tfvars` и укажите значения, включая `ca_type`:

```hcl
project      = "my-pki-lab"
region       = "us-central1"
zone         = "us-central1-a"
machine_type = "e2-micro"
ssh_key      = "ваш_публичный_ssh_ключ"
ca_type      = "ejbca"   # выберите "ejbca" или "step"
```

- "ejbca" — развёртывание EJBCA Community Edition
- "step" — развёртывание лёгкой Smallstep CA

Советы:
- Для VM с ≤1 ГБ RAM лучше использовать "step".
- Для полноценного EJBCA на GCP требуется минимум 2 ГБ RAM и 2 vCPU.

---

## 🔐 Развёртывание EJBCA

После деплоя Terraform, EJBCA будет автоматически настроен с:

- 🗄️ **База данных MariaDB** для данных EJBCA
- 🐳 **Контейнер EJBCA Community Edition**
- 🔄 **Caddy reverse proxy** с автоматическим HTTPS
- 🌐 **Автогенерированный домен** через nip.io

### Доступ к EJBCA

1. 🌐 **Получи публичный IP:**
```bash
terraform output ip_address
```

2. 🌍 **Доступ через браузер:**
```
https://<IP_ADDRESS>.nip.io
```

3. 🔑 **Учётные данные администратора EJBCA по умолчанию:**
   - 👤 Имя пользователя: `admin`
   - 🔐 Пароль: `admin` (смени немедленно!)

### Управление контейнерами

**📊 Проверка статуса контейнеров:**
```bash
sudo docker compose ps
```

**📋 Просмотр логов:**
```bash
sudo docker compose logs ejbca
sudo docker compose logs caddy
```

**🔄 Перезапуск сервисов:**
```bash
sudo docker compose restart
```

---

## ✅ Проверка работы контейнеров

**🔍 Проверь, что контейнеры запущены:**
```bash
docker compose logs ejbca | tail
docker compose logs caddy | tail
```

**⚠️ Если Caddy жалуется на домен:**
```bash
export DOMAIN=localhost
docker compose up -d
```

**🧪 Тест подключения к EJBCA:**
```bash
curl -vk https://localhost:8443/ejbca/adminweb
```

---

## 🚀 Лёгкая альтернатива: Smallstep CA

Если EJBCA не помещается в e2-micro, можно развернуть Smallstep CA, который работает даже при 512 МБ RAM.

### Установка

```bash
curl -fssl https://smallstep.com/install | sh
sudo mv ~/.step/bin/step /usr/local/bin/
```

### Инициализация

```bash
step ca init
```

Отвечай на вопросы, например:
```
✔ Name: Smallstep CA
✔ DNS or IP: localhost
✔ Provisioner: anton@sokolov.ee
✔ Save password: no
```

### Запуск CA

```bash
step ca start
```

**С веб-интерфейсом:**
```bash
step ca start --ui
```

### Использование

**💚 Проверка здоровья:**
```bash
step ca health
```

**📜 Выдача сертификата:**
```bash
step ca certificate example.com example.crt example.key
```

**🌐 Доступ к веб-интерфейсу:**
```
http://localhost:9000/ui
```

---

## 🧹 Очистка и предотвращение расходов

### 1. 🛑 Остановка VM

```bash
gcloud compute instances stop ejbca-vm --zone=us-central1-a
```

### 2. 🗑️ Удаление VM и диска

```bash
gcloud compute instances delete ejbca-vm --zone=us-central1-a --quiet
gcloud compute disks delete ejbca-vm --zone=us-central1-a --quiet
```

### 3. ✅ Проверка, что ничего не осталось

```bash
gcloud compute instances list
gcloud compute disks list
```

### 4. 🏗️ Если использовался Terraform

```bash
terraform destroy -auto-approve
```

### 5. 🗂️ Удаление проекта (опционально)

```bash
gcloud projects delete my-pki-lab
```

---

## 🔗 Полезные ссылки

- 🔗 [EJBCA CE на GitHub](https://github.com/Keyfactor/ejbca-ce)
- 📚 [Документация Smallstep CA](https://smallstep.com/docs)
- 🏗️ [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- 💰 [Google Cloud Free Tier](https://cloud.google.com/free)

---

## 📝 Примечания

- 💰 **Стоимость**: Эта лаборатория использует ресурсы Google Cloud Free Tier
- 🔒 **Безопасность**: Смени пароли по умолчанию немедленно
- 💾 **Резервное копирование**: Рассмотрите резервное копирование данных EJBCA перед очисткой
- 📊 **Мониторинг**: Проверяйте Google Cloud Console на предмет неожиданных расходов

---

*Этот README.md — полный сценарий лаборатории PKI: от деплоя EJBCA до лёгкой CA, Terraform и безопасного завершения без счетов.*
