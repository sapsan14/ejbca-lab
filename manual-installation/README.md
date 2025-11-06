# Manual Installation Guide: EJBCA 9.2.0 with SoftHSM

Complete step-by-step guide for manually installing EJBCA 9.2.0 Enterprise Edition with eIDAS support on Ubuntu with MariaDB and SoftHSM2.

## 📋 Overview

This guide walks you through installing EJBCA from scratch on a fresh Ubuntu system. This method provides the most control and understanding of the EJBCA architecture.

### Components Installed

- **EJBCA:** 9.2.0 Enterprise Edition with eIDAS support
- **Application Server:** WildFly 35.0.1.Final
- **Java Runtime:** OpenJDK 17
- **Database:** MariaDB 10.11
- **Hardware Token:** SoftHSM2 (PKCS#11 compatible)

## 🎯 Prerequisites

- Ubuntu 22.04 LTS (or compatible)
- Root or sudo access
- At least 4GB RAM (8GB recommended)
- 20GB+ free disk space
- Network connectivity for downloads
- EJBCA 9.2.0 Enterprise Edition ZIP file (`ejbca_ee_9_2_0_eIDAS.zip`)

## 📦 System Requirements

### Minimum Requirements
- **CPU:** 2 cores
- **RAM:** 4GB
- **Disk:** 20GB free space
- **OS:** Ubuntu 22.04 LTS

### Recommended Requirements
- **CPU:** 4+ cores
- **RAM:** 8GB+
- **Disk:** 50GB+ free space
- **OS:** Ubuntu 22.04 LTS

## 🚀 Installation Steps

### Step 1: Create System User

Create a dedicated user for EJBCA:

```bash
sudo useradd -r -m -d /opt/ejbca -s /bin/bash ejbca
sudo chown -R ejbca:ejbca /opt/ejbca
```

### Step 2: Install Dependencies

Install required packages:

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk ant unzip mariadb-server wget softhsm2
```

**Packages installed:**
- `openjdk-17-jdk` - Java Development Kit 17
- `ant` - Apache Ant build tool
- `unzip` - Archive extraction
- `mariadb-server` - MariaDB database server
- `wget` - File download utility
- `softhsm2` - Software HSM implementation

### Step 3: Prepare Directories

Create necessary directories:

```bash
sudo mkdir -p /opt/ejbca/wildfly
sudo mkdir -p /opt/ejbca/src
sudo chown -R ejbca:ejbca /opt/ejbca
```

### Step 4: Configure MariaDB

Start and enable MariaDB:

```bash
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation
```

Create EJBCA database and user:

```bash
sudo mysql -u root -p
```

Execute the following SQL commands:

```sql
CREATE DATABASE ejbca CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'ejbca'@'localhost' IDENTIFIED BY 'ChangeMe123!';
GRANT ALL PRIVILEGES ON ejbca.* TO 'ejbca'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

⚠️ **Security Note:** Replace `ChangeMe123!` with a strong password in production!

### Step 5: Download and Extract WildFly

Download WildFly 35.0.1.Final:

```bash
sudo -u ejbca bash <<EOF
cd /opt/ejbca/wildfly
wget https://github.com/wildfly/wildfly/releases/download/35.0.1.Final/wildfly-35.0.1.Final.tar.gz
tar -xzf wildfly-35.0.1.Final.tar.gz
chown -R ejbca:ejbca wildfly-35.0.1.Final
EOF
```

### Step 6: Set Environment Variables

Configure environment variables for the ejbca user:

```bash
sudo -u ejbca bash <<EOF
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /home/ejbca/.bashrc
echo 'export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final' >> /home/ejbca/.bashrc
echo 'export EJBCA_HOME=/opt/ejbca/src/ejbca_ee_9_2_0_eIDAS' >> /home/ejbca/.bashrc
source /home/ejbca/.bashrc
EOF
```

**Environment variables:**
- `JAVA_HOME` - Java installation path
- `APPSRV_HOME` - WildFly installation directory
- `EJBCA_HOME` - EJBCA source directory

### Step 7: Extract EJBCA Source

Extract the EJBCA distribution:

```bash
sudo -u ejbca bash <<EOF
cd /opt/ejbca/src
unzip /path/to/ejbca_ee_9_2_0_eIDAS.zip
mv ejbca_ee_9_2_0_eIDAS app
ln -snf /opt/ejbca/src/app /opt/ejbca/src/ejbca_ee_9_2_0_eIDAS
chown -R ejbca:ejbca /opt/ejbca/src
EOF
```

⚠️ **Note:** Replace `/path/to/ejbca_ee_9_2_0_eIDAS.zip` with the actual path to your EJBCA ZIP file.

### Step 8: Configure WildFly Remoting

Configure WildFly HTTP remoting connector:

```bash
sudo -u ejbca bash <<EOF
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final

\$APPSRV_HOME/bin/jboss-cli.sh --connect '/subsystem=remoting/http-connector=http-remoting-connector:write-attribute(name=connector-ref,value=remoting)'
\$APPSRV_HOME/bin/jboss-cli.sh --connect '/socket-binding-group=standard-sockets/socket-binding=remoting:add(port=4447,interface=management)'
\$APPSRV_HOME/bin/jboss-cli.sh --connect '/subsystem=undertow/server=default-server/http-listener=remoting:add(socket-binding=remoting,enable-http2=true)'
\$APPSRV_HOME/bin/jboss-cli.sh --connect ':reload'
EOF
```

Wait for reload to complete:

```bash
sudo -u ejbca bash <<EOF
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final
\$APPSRV_HOME/bin/jboss-cli.sh --connect --command=":read-attribute(name=server-state)"
EOF
```

Expected output: `"running"`

Verify ports are listening:

```bash
sudo ss -tlnp | grep -E '8080|8443|9990|4447'
```

### Step 9: Start WildFly

Start WildFly server:

```bash
sudo -u ejbca bash <<EOF
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final
nohup \$APPSRV_HOME/bin/standalone.sh > /home/ejbca/wildfly35.log 2>&1 &
sleep 15
ss -tlnp | grep -E '8080|8443|9990|4447'
EOF
```

### Step 10: Configure MariaDB JDBC Driver

Download and install MariaDB JDBC driver:

```bash
sudo -u ejbca bash <<EOF
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final
cd \$APPSRV_HOME/standalone/deployments
wget https://repo1.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/3.3.3/mariadb-java-client-3.3.3.jar
EOF
```

Test database connection:

```bash
sudo -u ejbca bash <<EOF
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final
\$APPSRV_HOME/bin/jboss-cli.sh --connect --command="data-source test-connection-in-pool --name=EjbcaDS"
EOF
```

Expected output: `true`

### Step 11: Install and Configure SoftHSM2

#### 11a. Install SoftHSM2

```bash
sudo apt install -y softhsm2
```

Check available slots:

```bash
softhsm2-util --show-slots
```

Example token storage location: `/var/lib/softhsm/tokens/`

#### 11b. Initialize Token

Initialize a SoftHSM token:

```bash
sudo -u ejbca softhsm2-util --init-token --slot 0 --label ejbcaToken --pin 1234 --so-pin 123456
```

If slot 0 is in use, try slot 1:

```bash
sudo -u ejbca softhsm2-util --init-token --slot 1 --label ejbcaToken --pin 1234 --so-pin 123456
```

⚠️ **Security Note:** Use strong PINs in production!

#### 11c. Locate SoftHSM Library

Find the SoftHSM library path:

```bash
find /usr/lib -name "libsofthsm2.so"
```

Example path: `/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so`

#### 11d. Configure EJBCA to Use SoftHSM

Edit EJBCA properties:

```bash
sudo -u ejbca nano $EJBCA_HOME/conf/ejbca.properties
```

Find and set the following properties:

```properties
ca.token.classpath=org.cesecore.keys.token.Pkcs11CryptoToken
ca.token.name=SoftHSM
ca.token.pin=1234
ca.token.p11.lib=/usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so
ca.token.p11.slot=0
```

Save and exit (Ctrl+X, Y, Enter).

### Step 12: Build and Initialize EJBCA

Build EJBCA:

```bash
sudo -u ejbca bash <<EOF
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final
export EJBCA_HOME=/opt/ejbca/src/ejbca_ee_9_2_0_eIDAS

cd \$EJBCA_HOME
ant clean deployear
EOF
```

Initialize EJBCA:

```bash
sudo -u ejbca bash <<EOF
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export APPSRV_HOME=/opt/ejbca/wildfly/wildfly-35.0.1.Final
export EJBCA_HOME=/opt/ejbca/src/ejbca_ee_9_2_0_eIDAS

cd \$EJBCA_HOME
ant runinstall
EOF
```

Expected output: `BUILD SUCCESSFUL`

## ✅ Verification

### Verify Web Interfaces

Access the EJBCA web interfaces:

- **Administration Interface:** https://127.0.0.1:8443/ejbca/adminweb
- **RA (Registration Authority) Interface:** https://127.0.0.1:8443/ejbca/ra

### Import SuperAdmin Certificate

Import the SuperAdmin certificate for accessing the admin interface:

**Certificate location:** `/opt/ejbca/src/ejbca_ee_9_2_0_eIDAS/p12/superadmin.p12`

**Import into browser:**
1. Open browser certificate settings
2. Import the `superadmin.p12` file
3. Use the default password (check EJBCA documentation)
4. Access the admin web interface

### Check Service Status

Verify all services are running:

```bash
# Check WildFly
sudo ss -tlnp | grep -E '8080|8443|9990|4447'

# Check MariaDB
sudo systemctl status mariadb

# Check SoftHSM
softhsm2-util --show-slots
```

## 📝 Port Reference

| Port | Service | Description |
|------|---------|-------------|
| 8080 | HTTP | WildFly HTTP port |
| 8443 | HTTPS | WildFly HTTPS port (EJBCA web interfaces) |
| 9990 | Management | WildFly management console |
| 4447 | Remoting | WildFly HTTP remoting connector |
| 3306 | MySQL/MariaDB | Database port |

## 🔧 Troubleshooting

> 📖 **For detailed troubleshooting guide covering JNDI issues, mTLS configuration, and Elytron setup, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

### WildFly Won't Start

1. Check Java version: `java -version` (should be 17)
2. Check logs: `tail -f /home/ejbca/wildfly35.log`
3. Verify ports are not in use: `sudo ss -tlnp | grep -E '8080|8443'`
4. Check permissions: `ls -la /opt/ejbca`

### Database Connection Issues

1. Verify MariaDB is running: `sudo systemctl status mariadb`
2. Test connection: `mysql -u ejbca -p ejbca`
3. Check JDBC driver: `ls -la $APPSRV_HOME/standalone/deployments/mariadb-java-client-*.jar`
4. Review EJBCA configuration: `cat $EJBCA_HOME/conf/database.properties`

### SoftHSM Issues

1. Verify token exists: `softhsm2-util --show-slots`
2. Check library path: `find /usr/lib -name "libsofthsm2.so"`
3. Verify permissions: `ls -la /var/lib/softhsm/tokens/`
4. Test token access: `pkcs11-tool --module /usr/lib/x86_64-linux-gnu/softhsm/libsofthsm2.so -L`

### Build Issues

1. Verify environment variables: `echo $EJBCA_HOME $APPSRV_HOME $JAVA_HOME`
2. Check Ant installation: `ant -version`
3. Review build logs for specific errors
4. Ensure EJBCA source is complete and extracted correctly

## 🔐 Security Hardening

For production deployments, consider:

1. **Strong Passwords:** Change all default passwords
2. **Firewall:** Restrict access to necessary ports only
3. **SSL/TLS:** Use proper certificates (not self-signed)
4. **HSM:** Use hardware HSM instead of SoftHSM
5. **Backup:** Implement regular database backups
6. **Updates:** Keep EJBCA and dependencies updated
7. **Monitoring:** Set up logging and monitoring
8. **Access Control:** Limit admin access to authorized personnel

## 📚 Next Steps

After successful installation:

1. Configure certificate profiles
2. Set up RA (Registration Authority) users
3. Create certificate templates
4. Configure OCSP responders
5. Set up backup procedures
6. Configure monitoring and alerting

## 🆘 Support

For issues and questions:

- Review EJBCA documentation: https://doc.primekey.com/ejbca
- Check EJBCA forums and community
- Review WildFly documentation: https://www.wildfly.org/documentation/
- Check MariaDB documentation: https://mariadb.com/docs/

---

**Installation complete!** EJBCA 9.2.0 is now installed and running on WildFly 35 with MariaDB and SoftHSM2.

