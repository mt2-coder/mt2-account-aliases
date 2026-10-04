# Metin2 Account Aliases

[English](README.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) ·
[Italiano](README.it.md) · **Português** · [Română](README.ro.md) · [Türkçe](README.tr.md)

[![Latest release](https://img.shields.io/github/v/release/mt2-coder/mt2-account-aliases?color=blue)](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)
[![License: MIT](https://img.shields.io/github/license/mt2-coder/mt2-account-aliases)](LICENSE)
[![Tests](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml/badge.svg)](https://github.com/mt2-coder/mt2-account-aliases/actions/workflows/tests.yml)
[![Provenance: attested](https://img.shields.io/badge/provenance-attested-brightgreen)](https://github.com/mt2-coder/mt2-account-aliases/attestations)

*Tradução da [versão em inglês](README.md), atualizada a 4 de outubro de 2026. Em caso de
diferença, prevalece a versão em inglês.*

**Dá nomes legíveis às tuas contas de Metin2 no Gameforge Client e encontra-as pelo nome.**

As contas de jogo nunca podem ser renomeadas, e no servidor Tigerghost o launcher até lhes dá
identificadores gerados como `playerg123456789`. Com dezenas de contas, quatro por página,
encontrar a certa é um jogo de adivinhação. Este add-on gratuito permite-te chamá-las `main`,
`buff` ou `meley1`, diretamente na lista de contas do próprio launcher.

https://github.com/user-attachments/assets/29c72fac-e7bd-4ce5-8bd2-43fdb9114b08

▶ **[Ver a demonstração no YouTube](https://www.youtube.com/watch?v=24Nq1rZX88w)** ·
⬇ **[Transferir a versão mais recente](https://github.com/mt2-coder/mt2-account-aliases/releases/latest)** ·
gratuito e de código aberto ([MIT](LICENSE))

> Add-on não oficial: não é afiliado à Gameforge nem aprovado pela Gameforge.

## O que faz

No launcher, **Definições > Conta de jogo** (no launcher em português do Brasil:
**Configurações > Conta do Jogo**):

- **Dá nomes às tuas contas.** O lápis ao lado do nome de uma conta dá-lhe um alias: Enter guarda,
  Esc cancela, um alias vazio remove-o. O alias aparece primeiro, o nome real ao lado, em letra
  pequena e cinzenta; um alias comprido é cortado no ecrã e mostrado por inteiro na dica que
  aparece ao passar o rato por cima.
- **Encontra-as pelo nome.** A caixa de pesquisa do próprio launcher (a lupa por cima da tabela)
  também encontra as contas pelo alias, e as suas páginas continuam a funcionar.
- **Guarda uma cópia de segurança.** O botão **Manage**, em baixo à direita, mostra todos os teus
  alias como texto: copia-o para guardares uma cópia de segurança, ou cola-o e carrega em
  **Apply** para a restaurar ou para passar os teus alias para outro PC.

O add-on e o seu instalador só existem em inglês: os botões chamam-se **Manage**, **Copy** e
**Apply**, e as mensagens do instalador aparecem em inglês.

## É seguro?

O add-on foi construído em torno de uma regra: nunca pôr em risco o teu jogo nem a tua conta.

- **Nunca toca no jogo.** Nem no `metin2client.exe`, nem em nenhum ficheiro do jogo, nem no seu
  anti-cheat. Nenhuma parte do add-on é executada dentro do jogo.
- **É apenas uma camada por cima da janela do launcher.** A interface do launcher é uma página web
  guardada num único ficheiro, `resources\frontend.pak`. O add-on acrescenta um pequeno script a
  essa página e mais nada: o programa do launcher, e a forma como inicia o jogo, ficam exatamente
  iguais.
- **A tua conta fica intacta.** Os alias só existem no teu PC: os nomes reais das tuas contas
  nunca mudam, nem no teu PC nem nos servidores da Gameforge. O add-on não faz nenhum pedido de
  rede e nunca lê a tua palavra-passe, a tua sessão nem os dados da tua conta; só lê os nomes das
  contas que já estão no ecrã.
- **Podes anular tudo a qualquer momento.** O instalador faz uma cópia de segurança do ficheiro do
  launcher antes de o alterar, e o `Uninstall.cmd` repõe o original, byte a byte.
- **Nada está escondido.** Nenhum `.exe`: o add-on é um único ficheiro JavaScript que podes ler,
  [`src/alias-addon.js`](src/alias-addon.js), e o instalador um único script PowerShell,
  [`scripts/alias-addon.ps1`](scripts/alias-addon.ps1). Cada versão é compilada pelo GitHub a
  partir deste código público e vem com o seu hash SHA-256 e um
  [atestado de proveniência](https://github.com/mt2-coder/mt2-account-aliases/attestations)
  (provenance attestation).

O add-on é software livre sob a licença MIT, o que significa que é fornecido sem qualquer
garantia.

## Instalação

Precisas do Windows 10 ou 11, do Gameforge Client e de direitos de administrador.

1. Transfere `mt2-account-aliases-x.y.z.zip` da
   [versão mais recente](https://github.com/mt2-coder/mt2-account-aliases/releases/latest).
2. Clica com o botão direito no ZIP > **Propriedades** > marca **Desbloquear** > **OK** e depois
   extrai-o. Caso contrário, o Windows pede confirmação sempre que executas um dos seus ficheiros
   `.cmd`, porque não estão assinados digitalmente.
3. Fecha os teus clientes de Metin2 e depois fecha completamente o Gameforge Client, incluindo o
   seu ícone na área de notificação.
4. Faz duplo clique em **`Install.cmd`** e clica em **Sim** no pedido do Windows (Controlo de
   Conta de Utilizador): os ficheiros do launcher estão em `Program Files` («Programas» ou
   «Arquivos de Programas» no Explorador), por isso alterá-los exige direitos de administrador.
5. Inicia o launcher e abre **Definições > Conta de jogo**.

O instalador encontra o launcher onde quer que esteja instalado. Verificado com o Gameforge Client
2.8.5.1959 (interface 0.486.2).

O launcher guarda os teus alias só neste PC. Tudo o que apagar os dados do launcher também os
apagaria, por isso guarda uma cópia de segurança com **Manage**.

## Desinstalação

Fecha o launcher e depois faz duplo clique em **`Uninstall.cmd`**: o ficheiro original do launcher
volta, byte a byte. Os teus alias continuam guardados no launcher, por isso voltam quando o
instalares de novo.

## Quando o launcher atualiza a sua interface

O launcher não consegue atualizar uma interface que o add-on modificou. Quando anunciar uma
atualização, ou disser que não conseguiu aplicar uma:

1. fecha-o e depois faz duplo clique em `Uninstall.cmd`;
2. inicia o launcher, deixa-o atualizar e depois fecha-o;
3. faz de novo duplo clique em `Install.cmd`.

## Resolução de problemas

- **O que está instalado?** O `Status.cmd` diz-te, sem alterar nada.
- **«Gameforge Client not found».** Abre uma linha de comandos na pasta extraída (escreve `cmd` na
  barra de endereço do Explorador de Ficheiros e carrega em Enter) e indica o caminho do
  `frontend.pak` do launcher:
  `Install.cmd -PakPath "D:\Jogos\GameforgeClient\resources\frontend.pak"`.
- **Não aparecem lápis na lista de contas.** Executa `Install.cmd -Diagnostic` da mesma forma.
  Aparece uma pequena etiqueta em baixo à esquerda da janela principal do launcher, que indica até
  onde o add-on chegou:

  | Etiqueta | Significado |
  | --- | --- |
  | nenhuma | o launcher não mostrou a página modificada |
  | vermelha, `script did not run` | a página é mostrada, mas o add-on nunca foi executado |
  | `active - no account on screen`, com a lista de contas aberta | o add-on está a funcionar, mas não encontra nenhuma conta |
  | `active - 4 account(s) on screen (2 windows)` | a lista de contas foi encontrada e completada com os alias |
  | `... error (...): ...` | a mensagem diz o que falhou |

  `Install.cmd` sem `-Diagnostic` retira a etiqueta.
- **O launcher mudou para outro idioma.** O add-on não tem nada a ver com isso: o ícone do globo,
  no canto superior direito do launcher, repõe-no.

---

## Para programadores e as equipas da Gameforge

A parte técnica (como o add-on funciona, como a funcionalidade poderia ser integrada no próprio
launcher, testes, versões) só existe em inglês:
[For developers and Gameforge's teams](README.md#for-developers-and-gameforges-teams).

## Licença

[MIT](LICENSE). Abrange apenas este repositório: o Gameforge Client e os seus ficheiros,
incluindo o `frontend.pak`, continuam a pertencer à Gameforge.
