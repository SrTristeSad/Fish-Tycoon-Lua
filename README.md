# Fish Tycoon Lua — v19: reconstrução de apresentação J2ME (240 × 320)

A partir da v19, **a interface padrão é `ui/retro.lua`**, desenhada em 240 × 320 e ampliada sem perder proporção. A tela anterior (`ui/view.lua`) foi preservada para regressão, mas não é mais o menu principal. O motor Lua, sprites e estrutura de saves permanecem.

## Jogar

Abra `Aquario-de-Isola-v19.love` usando [LÖVE 2D 11.4](https://love2d.org/) ou execute `love .` no diretório. Inicialmente aparece um menu com **CONTINUE, NEW GAME, OPTIONS, ABOUT**. Para criar uma partida nova, clique em **NEW GAME**. Se já existir jogo salvo, há confirmação antes de substituí-lo; o save antigo é arquivado em `fish_tank_save_before_new_game.json` e permanece recuperável. Uma falha ao criar arquivo arquivado bloqueia a substituição.

No aquário, toque em um peixe para abrir a seleção (informações e comandos **SELECT/BACK**). Na parte inferior, **FISH** seleciona um peixe e **MENU** abre o menu do jogo. A barra superior seleciona tanques e abre loja, pesquisa e coleção. O recipiente azul inferior dá acesso ao isolamento. Dentro do menu, os comandos **MOVE**, **FEED**, **TREAT**, compra de suprimentos, venda e pesquisa seguem ativos, usando o mesmo motor da v18.

**Configurações**: música, velocidade e intervalo de crescimento. Não há necessidade de editar arquivos para jogar de novo. A simulação fica pausada no menu inicial e nas configurações; continua durante a partida.

## Fidelidade e recursos do JAR

Foram adotadas as proporções 240 × 320, a composição `tanktop.png` + `tank1/2/3.png`, o recipiente `isolation_tank.png`, a barra superior compacta e a estrutura da tela de seleção da imagem de referência do jogo original. O pacote local `.love` inclui também `splash.png`, `assets.png` e `gameMenuTank.png`, extraídos do JAR de referência.

Por direitos de redistribuição, os **três PNGs adicionais não foram publicados no GitHub público**. Para completar visualmente uma instalação criada apenas a partir do repositório, utilize o JAR que você possui e execute:

```sh
python3 scripts/import_j2me_assets.py /caminho/para/Fish_Tycoon_240x320.jar
```

Sem os três PNGs, o jogo continua jogável, com título desenhado pelo código e fundos já existentes. O `.love` de teste disponibilizado na conversa contém a arte do JAR. O `README` separa o que já se aproxima visualmente do original do que ainda exige investigação: fontes gráficas exatas, layout de todos os menus, nomes reais e telas não fornecidas nas referências.

## Testes

```sh
texlua tests/v19_retro.lua
# regressão completa
for file in tests/*.lua; do texlua "$file"; done
```

GitHub Actions contém dois testes nativos no LÖVE/Xvfb: o anterior para a interface legada e o novo `FISH_RETRO_SMOKE=1`, que captura sete telas J2ME em 480 × 640. **Isso valida renderização e navegação, não comprova correspondência pixel a pixel com todo o jogo Java.**

A base canônica é a branch `main` de https://github.com/SrTristeSad/Fish-Tycoon-Lua. Toda alteração deve ter commit. Consulte também `AGENTS.md` e `RECURSOS_E_DIREITOS.md`.
