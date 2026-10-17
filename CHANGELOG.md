# Changelog

Versões: correção de bug sobe o último número (1.0.1, 1.0.2...), novidade sobe o do meio (1.1, 1.2...).

## 1.0.1 (não lançada)

### Correções
- Pendrive não aparecia no menu de boot e a BIOS acusava "GPT header corruption has been detected" (visto em placa ASUS). A imagem usava tabela GPT, cuja cópia de segurança do cabeçalho ficava no fim da imagem e não no fim do pendrive. A imagem agora usa tabela MBR, que funciona em pendrive de qualquer tamanho. Boot UEFI com Secure Boot e boot legado continuam iguais.

## 1.0.0-br (2026-10-17)

Primeira versão do fork brasileiro.

### Novidades
- unezQuake com configs pessoais, Google Chrome e Discord já instalados.
- Sessão Wayland (labwc) além da XFCE, com compartilhamento de tela no Discord.
- Mesa mais recente do Debian unstable e GameMode para o jogo.
- Visual novo: tema Orchis roxo, papel de parede em todos os monitores, painel estilo dock, fonte Inter.
- Suporte a Flatpak.
- README em português.

### Correções
- Detecção de Wayland, autologin e ordem de boot.
- Scripts com fim de linha LF para funcionar mesmo quando clonados no Windows.
- Chaves de API pessoais ficam fora das imagens.
