# KIV/DCE - task 1
## Zadání
Implementujte architekturu s konfigurovatelným počtem backendů a
jedním load balancerem (např. NGINX). K implementaci použijte nástrojů
Terraform, Ansible a Docker, jako cloudovou službu využijte univerzitní
instanci OpenNebula na nuada.zcu.cz. Backend i loadbalancer realizujte
v podobě kontejnerů, které bude možno sestavit a publikovat v
repozitáři na Github (viz Github Actions).

## Implementace a popis fungování
Systém se skládá ze dvou částí - aplikace a load balanceru.

- **Aplikace**: Jednoduchá python/flask aplikace, která na endpointu /find/{service_name} vyhledává podrobnosti o službách (využit example z KIV/DS Demo3). Počet instancí aplikace je možné (v souladu se zadáním) jednoduše konfigurovat. Na Github actions je implementován skript, který zajistí build aplikace a uložení image do github repozitáře na ghcr.io/vlc3k/kiv-dce-ex01:main.
- **Load balancer**: Zajišťuje distribuci zátěže mezi aplikacemi. V této implementaci byl jako load balancer použit nginx.

Terraform zajistí vytvoření infrastruktury (virtuální servery - jeden pro každou instanci aplikace a jeden navíc pro load balancer). Na každý takto vytvořený server přidá ssh public key pro následný přístup (pomocí private key), vytvoří uživatele podle definice ve variables a pro zvýšení bezpečnosti zakáže přístup k ssh pomocí hesla.

Pomocí Ansible se pak spolehlivě nasadí aplikační vrstva - na load balancer se podle šablony vytvoří config (kde v režimu load balanceru budou všechny aplikační instance), u aplikačních nodů se nainstaluje docker a v něm se spustí výše zmíněná aplikace.

Aplikace není náročná, pro její běh není potřeba velkých prostředků, ale při testování se ukázalo, že s 1 GB paměti nabíhá (stažení a spuštění docker image) výrazně déle, než se 2 GB paměti. Proto v inicializaci doporučuji 2 GB.

## Prerekvizity k nasazení systému ##
- Terraform (https://developer.hashicorp.com/terraform/install)
- Ansible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- Prostor v clusteru OpenNebula vhodný ke spuštění této aplikace

## Nasazení:
### 1) Naklonování repozitáře
```
git clone https://github.com/vlc3k/kiv-dce-ex01.git
cd kiv-dce-ex01
```
### 2) Vytvoření infrastruktury pomocí HashiCorp Terraform
Přejděte do složky **/infra** a proveďte inicializaci terraformu
```
terraform init
```
**Upravte proměnné v souboru terraform.tfvars**:
```
one_username      = "{OpenNebula username}"
one_password      = "{OpenNebula password/token}"
one_endpoint      = "{OpenNebula RPC2 endpoint}"

vm_ssh_pubkey     = "{SSH public key (will be used for accessing created virtual servers)}"
vm_ssh_privkey_path = "{path to SSH private key (will be used for accessing created virtual servers)}"

vm_image_name = "{image name for vm, default: Ubuntu Minimal 24.04}"
vm_image_url = "{url for selected image, default: https://marketplace.opennebula.io//appliance/44077b30-f431-013c-b66a-7875a4a4f528/download/0}"

vm_admin_user = "{vm user, default: appuser}"
vm_app_count = {count of application instances, default: 2}
```

Vytvoření plánu nasazení přes Terraform
```
terraform plan
```

Aplikování nasazení přes Terraform
```
terraform apply
+ následné potvrzení
```

### 3) Příprava a instalace aplikace/loadbalanceru pomocí Ansible
Přejděte do složky **/infra/ansible**

Po úspěšném doběhnutí `terraform apply` by v této složce měl být vytvořený soubor inventory.ini, ve kterém jsou uvedené IP adresy vytvořených virtuálních serverů. Pro nasazení potom použijte příkaz:

```
ansible-playbook -i inventory.ini cluster.yml
```

### 4) Ověření funkčnosti
Po nasazení bude na adrese loadbalanceru `http://{loadbalancer}:80` dostupná nasazená aplikace. Ve spodní části stránky se zobrazuje Served by: {appNodeId}, podle čehož je možné ověřit, že load balancer požadavky balancuje a v odbavování se jednotlivé aplikační instance střídají.

### 5) Smazání infrastruktury
Pro smazání vytvořené infrastuktury je možné v adresáři **/infra** provést příkaz
```
terraform destroy
```