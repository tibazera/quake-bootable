# Quake Bootable BR

Um Linux pronto para jogar **QuakeWorld** que roda direto do pendrive, sem instalar nada no seu Windows.
Você liga o PC pelo pendrive e já cai num desktop com tudo funcionando, focado em **desempenho**.

Baseado no [quake-bootable do ciscon](https://github.com/ciscon/quake-bootable), adaptado para jogadores brasileiros.

## O que vem nele

- **unezQuake** (última versão do [dusty-qw/unezquake](https://github.com/dusty-qw/unezquake)) com config, texturas, mapas e HUD já configurados
- **Google Chrome** e **Discord** (app oficial, com compartilhamento de tela)
- **Mesa** (driver de vídeo AMD/Intel) mais recente, direto do Debian unstable
- Driver **NVIDIA** incluso
- Tudo em **português**, teclado **ABNT2** e horário de **Brasília**
- Visual moderno: tema escuro roxo (Orchis), ícones Papirus, fonte Inter

### Ajustes de desempenho

- CPU sempre no modo `performance`, mitigações de segurança da CPU desligadas (mais FPS)
- Jogo roda com prioridade alta e GameMode
- Mouse sem aceleração (raw input)
- Rede ajustada para menos jitter (fq + bbr), Wi-Fi sem economia de energia
- Compositor desligado no X11 (menos input lag)
- Discord roda com prioridade menor que o jogo

## O que você precisa

- Um **pendrive de 8 GB ou mais** (USB 3.0 recomendado; tudo nele será apagado)
- PC 64 bits (qualquer processador Intel/AMD dos últimos ~12 anos)
- Placa de vídeo AMD, Intel ou NVIDIA (série 16xx/20xx ou mais nova)

---

## Passo a passo: rodar pelo pendrive (recomendado)

### 1. Baixe a imagem

Vá na página de [**Releases**](../../releases/latest) e baixe **todas as partes** do arquivo:

```
quake_bootable-br-full-amd64.zip
quake_bootable-br-full-amd64.z01
quake_bootable-br-full-amd64.z02
...
```

O GitHub não aceita arquivos maiores que 2 GB, por isso o zip vem dividido. Coloque todas as partes na **mesma pasta**.

### 2. Extraia o arquivo .img

Instale o [7-Zip](https://www.7-zip.org/) (gratuito), clique com o botão direito no arquivo **`.zip`** e escolha
**7-Zip → Extrair aqui**. Ele junta as partes sozinho e gera o arquivo `quake_bootable-full-amd64.img` (cerca de 7 GB).

> O Windows Explorer não sabe abrir zip dividido. Use o 7-Zip.

### 3. Grave no pendrive

1. Baixe o [**Rufus**](https://rufus.ie/pt_BR/) (pode usar a versão portátil).
2. Conecte o pendrive.
3. No Rufus:
   - **Dispositivo**: escolha o seu pendrive (confira o tamanho para não apagar o disco errado!)
   - **Seleção de boot**: clique em **SELECIONAR** e escolha o arquivo `.img`
4. Clique em **INICIAR**. Se perguntar o modo de gravação, escolha **Gravar em modo Imagem DD**.
5. Confirme que os dados do pendrive serão apagados e espere terminar.

Alternativa: o [balenaEtcher](https://etcher.balena.io/) também funciona (Flash from file → escolher o pendrive → Flash).

### 4. Desligue o Secure Boot na BIOS

O Linux deste projeto não é assinado para o Secure Boot, então ele precisa estar desligado.

1. Reinicie o PC e entre na BIOS (geralmente **Del** ou **F2** ao ligar).
2. Procure **Secure Boot** (costuma ficar em *Boot* ou *Security*) e coloque em **Disabled**.
   - Na ASUS: *Boot → Secure Boot → OS Type → **Other OS***
3. Salve e saia (**F10**).

Isso não afeta o Windows; ele continua funcionando normalmente.

### 5. Dê boot pelo pendrive

Com o pendrive conectado, ligue o PC e aperte a tecla do **menu de boot** repetidamente:

| Placa-mãe / marca | Tecla |
|---|---|
| ASUS | F8 |
| Gigabyte, Dell, Lenovo, Acer | F12 |
| MSI, ASRock | F11 |
| HP | F9 |

Escolha o pendrive na lista (se aparecer duas vezes, escolha a opção com **UEFI**).

### 6. Pronto!

Na primeira vez o boot demora um pouco mais (ele se ajusta ao tamanho do pendrive). Depois você cai direto na área de trabalho.

- Clique no ícone do **unezQuake** na barra ou na área de trabalho para jogar
- Usuário: `quakeuser` / senha: `quakeuser`
- Para voltar ao Windows é só tirar o pendrive e reiniciar

---

## Instalar num SSD (opcional, para deixar fixo)

Rodar num SSD deixa o boot e o carregamento de mapas mais rápidos. O jeito mais simples é **usar um SSD só para ele**
(um SSD extra, NVMe ou SATA). O processo é o mesmo do pendrive, só que gravando no SSD.

> **Atenção:** tudo no SSD escolhido será apagado. Nunca escolha o disco onde está o seu Windows.

### Opção A: gravar pelo Windows (SSD num case/adaptador USB)

1. Coloque o SSD num case ou adaptador USB e conecte no PC.
2. Abra o Rufus. Se o SSD não aparecer, abra **Mostrar propriedades avançadas do drive** e marque **Listar discos USB**.
3. Grave o `.img` do mesmo jeito do passo 3 acima.
4. Instale o SSD dentro do PC.

### Opção B: gravar a partir do próprio pendrive (SSD já instalado no PC)

1. Dê boot pelo pendrive normalmente.
2. Deixe o arquivo `.img` num lugar acessível (outro pendrive ou uma partição do Windows, que aparece no gerenciador de arquivos).
3. Abra o terminal e descubra o nome do SSD:
   ```
   lsblk -d -o NAME,SIZE,MODEL
   ```
   Ele vai aparecer como `nvme1n1`, `sdb` etc. Confira pelo **tamanho e modelo**.
4. Grave (troque `/caminho/do/arquivo.img` e `nvme1n1` pelos seus):
   ```
   sudo dd if=/caminho/do/arquivo.img of=/dev/nvme1n1 bs=8M status=progress conv=fsync
   ```
5. Desligue, tire o pendrive e ligue o PC. No primeiro boot o sistema cresce para ocupar o SSD inteiro.

### Escolher entre Windows e Linux

Com os dois instalados, aperte a tecla do menu de boot (tabela acima) ao ligar e escolha o disco.
Ou entre na BIOS e defina qual disco inicia primeiro.

---

## Dicas

### X11 ou Wayland?

O sistema entra sozinho no **X11** (recomendado para jogar, menor input lag).
Para usar o **Wayland** (melhor com vários monitores de taxas diferentes, ex.: 360 Hz + 240 Hz):
saia da sessão e, na tela de login, escolha **Quake-bootable (Wayland)**.

### Taxa de atualização do monitor

Confira em **Configurações → Monitor** se o seu monitor está na taxa máxima (144/240/360 Hz).
No jogo, use `vid_displayfrequency 360` (troque pela taxa do seu monitor) e `vid_restart`.

### Comandos úteis no terminal

| Comando | O que faz |
|---|---|
| `quake` | Abre o jogo |
| `update-quake` | Atualiza o unezQuake para a última versão |
| `quakepreset` | Troca a pasta de configurações (qw) |
| `browser` | Abre o Chrome |
| `sudo apt update && sudo apt upgrade` | Atualiza o sistema |
| `passwd` | Troca a senha |

### Usar a sua própria config

Seus arquivos ficam em `/home/quakeuser/quake`:
- configs: `quake/ezquake/configs/`
- texturas, skins, mapas: `quake/qw/`

Basta copiar seus arquivos do Windows (`C:\unezquake` ou `C:\nQuake`) para essas pastas.
Dentro do jogo, `cfg_save` salva suas alterações.

---

## Problemas comuns

- **Tela vermelha falando de Secure Boot**: desligue o Secure Boot (passo 4).
- **O pendrive não aparece no menu de boot**: tente outra porta USB (de preferência na traseira do PC) e confira se gravou em modo DD.
- **NVIDIA antiga (série 10xx ou anterior)**: esta imagem usa o driver novo; use a imagem `full-old_nvidia` do projeto original do ciscon.
- **Sem internet no Wi-Fi**: clique no ícone de rede na barra e escolha a sua rede.

---

## Gerar a imagem você mesmo

Precisa de um Linux (ou WSL2 com Debian):

```
pwsh sync-unezquake.ps1          # no Windows: copia C:\unezquake para quake-user/
sudo ./create_image.sh           # no Linux: gera output/quake_bootable-full-amd64.img
```

Variáveis opcionais: `XANMOD=1` (kernel XanMod, CPU com AVX2), `BUILDTYPE=min`, `KEEPAPIKEY=1`.

O readme original em inglês está em [readme-en.md](readme-en.md).
