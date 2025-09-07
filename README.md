# Terr-Transit-Gateway-with-VPN-Connection---Hybrid-DNS-Infrastructure
Repo นี้สร้างสถาปัตยกรรม Hybrid Cloud บน AWS โดยใช้ Terraform เพื่อเชื่อมต่อ Cloud VPC กับ On-premises Network ผ่าน AWS Transit Gateway, VPN Connection และ Hybrid DNS Resolution

## 📋 Prerequisites

### Required Resources
- AWS Account with appropriate permissions
- **SSH Key Pair**: สร้าง Key Pair ชื่อ `ssh-key` ใน EC2 Console ก่อนเริ่มต้น

### Important Notes
⚠️ **Best Practices Warning**: โค้ดนี้เป็นตัวอย่างการใช้งาน (Demo) และไม่ได้ใช้ Best Practices ทั้งหมด:
- ควรใช้ AWS CLI สำหรับ Credentials แทนการ hardcode
- Modules ควรถูกแยกประเภทให้ละเอียดมากขึ้น

### EC2 Limitations
- EC2 ทั้งหมดในโปรเจคนี้ใช้ประมาณ 18 vCPUs
- AWS Default Limit: 16 vCPUs สำหรับ EC2 instances
- โค้ดจึงปิดการสร้าง EC2 ใน Cloud VPC C เพื่อไม่ให้เกิน limit
- สามารถ request เพิ่ม limit ผ่าน AWS Support ได้

### Architecture

![Image](https://github.com/user-attachments/assets/28198eca-c92a-4cb2-8b2c-8b94309c1828)


## Deployment Guide

### Stage 1

```bash
cd stage1
terraform init
terraform plan
terraform apply --auto-approve
```
<img width="1590" height="547" alt="Image" src="https://github.com/user-attachments/assets/42a28063-131f-44a9-be99-c3a9f11dcbe3" />
<img width="1902" height="960" alt="Image" src="https://github.com/user-attachments/assets/23a0eb09-28ed-487f-8f52-bc40e9e5f152" />

**หลังจาก Stage 1 เสร็จแล้ว - ทดสอบการเชื่อมต่อ:**
1. SSH เข้า EC2 ใน Cloud VPC Public Subnet
2. สร้าง `ssh-key.pem` ในเครื่อง
3. SSH ไปยัง EC2 ใน Private Subnet B
4. ทดสอบ ping ไปยัง 10.2.x.x (ควรได้)
5. ไม่ได้ทดสอบ ping ไปยัง 10.3.x.x (เพราะปิด EC2 ใน Cloud C เนื่องจาก EC2 Limitations )

<img width="1902" height="950" alt="Image" src="https://github.com/user-attachments/assets/ea43a060-0256-4ac3-8946-ac97203db888" />

**ต่อมา Configure VPN Server (On-premises) :**

ดาวน์โหลด VPN config file จาก AWS Console 

<img width="1578" height="765" alt="Image" src="https://github.com/user-attachments/assets/ba3eaf6e-8836-442f-801f-e4b19c356d07" />

<img width="1587" height="811" alt="Image" src="https://github.com/user-attachments/assets/12216454-cb48-4bc3-a432-132ff1504c04" />

ทำตามขั้นตอนต่อไป

```bash
# SSH เข้า VPN Server IP (On-premises)
ssh ec2-user@<VPN_SERVER_IP>

# ติดตั้ง LibreSwan
sudo yum install libreswan -y

# แก้ไข System Configuration
sudo nano /etc/sysctl.conf
```

เพิ่มบรรทัดต่อไปนี้ใน `/etc/sysctl.conf`:
```
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.accept_source_route = 0
```
Configure IPSec

```bash
# สร้างไฟล์ configuration
sudo nano /etc/ipsec.d/aws.conf
```

เพิ่ม configuration (ลบ `auth=esp` และแก้ไข algorithms):
```
conn Tunnel1
    authby=secret
    auto=start
    left=%defaultroute
    leftid=54.169.117.139
    right=18.141.30.142
    type=tunnel
    ikelifetime=8h
    keylife=1h
    phase2alg=aes256-sha1;modp2048
    ike=aes256-sha1;modp2048
    keyingtries=%forever
    keyexchange=ike
    leftsubnet=10.100.0.0/16
    rightsubnet=10.0.0.0/16
    dpddelay=10
    dpdtimeout=30
    dpdaction=restart_by_peer
```

```bash
# กำหนด Pre-shared Key
sudo nano /etc/ipsec.d/aws.secrets

# เริ่มต้น IPSec Service
sudo systemctl start ipsec.service
```
<img width="1895" height="906" alt="Image" src="https://github.com/user-attachments/assets/632dfe99-d0cb-4b3c-9bd4-097bb5d8d280" />
<img width="1585" height="810" alt="Image" src="https://github.com/user-attachments/assets/f48f7982-2804-498e-8da8-e8ef6b979b67" />

### Stage 2

#### 2.1 Apply Terraform

```bash
cd environments/stage2-dns/
terraform init
terraform plan
terraform apply --auto-approve
```
ทดสอบ ping จาก Cloud Public subnet ไปยัง EC2 Private On-premises B

<img width="1887" height="822" alt="Image" src="https://github.com/user-attachments/assets/135895b2-2de4-4421-9fb2-0fb902063f33" />

**ต่อมา Configure On-premises DNS Server:**

```bash
# SSH ผ่าน VPN Server ไปยัง DNS Server
ssh <DNS_SERVER_IP>

# Update และติดตั้ง BIND
sudo yum update -y
sudo yum -y install bind bind-utils

# สร้าง DNS Zone file
sudo nano /var/named/onprem.com.zone
```

เพิ่มเนื้อหาต่อไปนี้:
```
$TTL 86400
@ 	IN  SOA     ns1.onprem.com. root.onprem.com. (
        2013042201  ;Serial
        3600        ;Refresh
        1800        ;Retry
        604800      ;Expire
        86400       ;Minimum TTL
)
; Specify our two nameservers
    IN  NS  dnsA.onprem.com.
    IN	NS  dnsB.onprem.com.
; Resolve nameserver hostnames to IP
dnsA    IN  A  1.1.1.1
dnsB    IN  A  8.8.8.8
; Define hostname -> IP pairs
@    IN  A  10.100.11.61
app  IN	 A  10.100.11.61
```

Configure BIND

```bash
# Clear และกำหนดค่า named.conf
sudo truncate -s 0 /etc/named.conf
sudo nano /etc/named.conf

# Restart DNS Service
sudo systemctl restart named.service
```

**หมายเหตุ:** หลังจากนี้ให้แก้ไข `/etc/resolv.conf` เพื่อให้ใช้ DNS Server On-premises
 ทดสอบว่า route 53 private , dns onprem ทำงานได้

 <img width="1887" height="945" alt="Image" src="https://github.com/user-attachments/assets/84cd9797-3f64-4837-b5d8-587865e6a8e0" />

 ### Stage 3

```bash
cd stage3/
terraform init
terraform plan
terraform apply --auto-approve
```

<img width="1892" height="958" alt="Image" src="https://github.com/user-attachments/assets/c18b54f8-0963-4e32-a711-26409b1456b8" />

ทำการ Configure DNS Forwarding
แก้ไข DNS Server เพื่อ forward คำขอไปยัง Cloud VPC DNS:

```bash
sudo nano /etc/named.conf
```

เพิ่ม zone forwarding:
```
zone "cloud.com" { 
  type forward; 
  forward only;
  forwarders { 10.0.10.244; 10.0.11.172; }; 
};
```

```bash
sudo systemctl restart named.service
```

ทดสอบ Hybrid DNS
<img width="1910" height="952" alt="Image" src="https://github.com/user-attachments/assets/38a8b5a5-f069-49b1-b37d-efd8c7205662" />

<img width="1887" height="935" alt="Image" src="https://github.com/user-attachments/assets/d15e1a58-b01e-4967-a190-8ce84822f939" />



## 🧹 Cleanup

เมื่อต้องการลบ infrastructure ทั้งหมด ให้ทำตามลำดับย้อนกลับ:

```bash
# Stage 3
cd stage3
terraform destroy --auto-approve

# Stage 2
cd stage2
terraform destroy --auto-approve

# Stage 1
cd stage1
terraform destroy --auto-approve
```
## 📝 Notes

- โปรเจคนี้เหมาะสำหรับการเรียนรู้และทดสอบ Hybrid Cloud Architecture
- สำหรับ Production ควรปรับปรุงตาม AWS Best Practices
- ตรวจสอบ AWS Pricing ก่อน deploy เพื่อหลีกเลี่ยงค่าใช้จ่ายที่ไม่คาดคิด
