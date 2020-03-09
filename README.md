# Plugin for `acme.sh` using levigo's ACME-API

This plugin provides dns-01 validation on [levigo's nameservers](https://hosting.levigo.de/) for usage with [Let's-Encrypt](https://letsencrypt.org/).


## Preparation

* Reqest a levigo ACME-API account using [levigo's user support](https://levigo.de/support/).
  * You can get multiple accounts restricted to different hostnames/domains or for the use on different hosts.

* Install `acme.sh` from `github.com`.
  * You may choose other folders than in the example given below.
  * It is vital to supply a email address so [Let's-Encrypt](https://letsencrypt.org/) can reach you if there is an issue with one of your certificates 
e.g. your certificates are not being renewed.
```bash
sudo apt install git socat
cd /tmp/
git clone https://github.com/Neilpang/acme.sh.git
cd acme.sh/
sudo ./acme.sh --install \
               --home /opt/acme.sh \
               --config-home /etc/acme.sh \
               --cert-home /etc/acme.sh/certs \
               --accountemail "<your-email@example.com>"
```


## Installation

Place the `dns_levigo.sh`-plugin-script in the `acme.sh` plugin folder (in the example given above `/opt/acme.sh/dnsapi/`) and adjust the file's rights.


## Usage

First you need to provide your levigo ACME-API credentials. Either by editing the header of the `dns_levigo.sh`-script or by exporting the variables:
```bash
export LEVIGO_USER=<your-username>
export LEVIGO_PASS=<your-password>
```

Afterwards, you are ready to issue Let's-Encrypt certificates:


### Single Host 3072-bit RSA-certificate
```bash
sudo acme.sh --home /opt/acme.sh --config-home /etc/acme.sh/ \
             --issue --keylength 3072 --dns dns_levigo \
             --domain myhost.example.com
```


### Multihost 384-bit ECDSA-certificate
```bash
sudo acme.sh --home /opt/acme.sh --config-home /etc/acme.sh/ \
             --issue --keylength ec-384 --dns dns_levigo \
             --domain www.example.com --doman example.com
```


### Wildcard 384-bit ECDSA-certifcate + 4096-bit RSA-certificate
```bash
sudo acme.sh --home /opt/acme.sh --config-home /etc/acme.sh/ \
             --issue --keylength ec-384 --dns dns_levigo \
             --domain *.example.com
sudo acme.sh --home /opt/acme.sh --config-home /etc/acme.sh/ \
             --issue --keylength 4096   --dns dns_levigo \
             --domain *.example.com
```

Please refer to the respective website for further infomation about the usage of the [`acme.sh`-script](https://acme.sh/) or [Let's-Encrypt](https://letsencrypt.org/).


## Check the installation

Your newly generated certificates can be found in the folder `/etc/acme.sh/certs`.

The installation script should have modified the `crontab`. This is necessary to renew your certificates when needed.
You can check this by issuing `sudo crontab -e`.
A line like the example below should have been added to your `crontab` and may be edited to your needs.
```bash
41 0 * * * "/opt/acme.sh"/acme.sh --cron --home "/opt/acme.sh/" --config-home "/etc/acme.sh/" > /dev/null
```

You may also modify the configuration file `/etc/acme.sh/account.conf` to your needs. E.g. enable logging or auto-upgrade of the `acme.sh`-script.
