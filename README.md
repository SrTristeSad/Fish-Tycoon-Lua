# Fish Tycoon Lua — v27: menu J2ME (240 × 320)

Desde a v19, **a interface padrão é `ui/retro.lua`**, desenhada em 240 × 320 e ampliada sem perder proporção. A tela anterior (`ui/view.lua`) foi preservada para regressão, mas não é mais o menu principal. O motor Lua, sprites e estrutura de saves permanecem.

## Novo na v27 — menu e navegação derivados do JAR

- O menu de pausa agora usa a nomenclatura confirmada pela tabela inglesa do próprio JAR: **RESUME, START NEW GAME, OPTIONS, TROPHY, STATS, HELP, ABOUT** e **SAVE & EXIT**. A disposição gráfica compacta ainda precisa ser comparada pixel a pixel com uma captura desse menu Java.
- **TROPHY** abre a coleção das sete espécies mágicas; **STATS** mostra peixes vivos, nascimentos, vendas, descobertas, mortes e balanço; **HELP** mostra os controles já implementados no port Lua. As duas páginas novas são funcionais, mas seu layout ainda não é apresentado como nativo comprovado.
- **START NEW GAME** dentro do jogo usa confirmação e o arquivamento de salvamentos já existente. **CANCEL** retorna ao menu de origem, evitando jogar o usuário no menu errado.
- Suprimentos e pesquisas continuam disponíveis na barra superior dos aquários e nos seus respectivos botões; o teste nativo cobre a navegação atualizada.
- O motor e o formato de salvamento permanecem inalterados. A lógica **SAVE & EXIT** salva e retorna ao menu inicial da versão Lua (não fecha a aplicação), deixando **RESUME** acessível.

## Novo na v26 — placas de venda nativas e menu sem marca provisoria

- **Tanque de vendas fiel ao JAR:** duas placas de madeira com `For Sale!` ja fazem parte do proprio `tank3.png`, nas laterais do cascalho. Removidas as etiquetas desenhadas em cada peixe que duplicavam as placas e se moviam de forma errada. A selecao e os precos dos peixes continuam funcionando.
- **Menu inicial sem splash:** corrigido texto de reserva para **FISH TYCOON / MOBILE**, sem o sufixo inventado `- LUA`; quando `splash.png` foi importado do JAR, o arquivo original continua sendo mostrado integralmente.
- **Teste nativo ampliado:** captura adicional do tanque de vendas e de um peixe selecionado nesse tanque, totalizando 11 imagens verificadas pelo LÖVE real no GitHub Actions.
- **Regressao:** atualizado o teste v25 para nao exigir sobreposicao duplicada, adicionado `tests/v26_sale_art.lua` cobrindo desenho do fundo e ausencia do rotulo flutuante. Sem mudancas no motor Lua ou nos salvamentos.

## Novo na v25 — controles 1:1 da barra e selecao

- Barra de 11 comandos com limites inteiros, usando tres miniaturas de tanques com 18px cada e oito controles restantes de 23 a 24px. Os botões não deixam frestas e mantêm o atlas original quando importado.
- A área de seleção acompanha o tamanho efetivo do peixe (adulto, jovem ou alevino), evitando selecionar um filhote ao tocar longe do seu sprite.
- A etiqueta **For Sale!** continua visível sobre adultos no tanque de vendas mesmo na tela de detalhes, como na captura J2ME fornecida.
- Teclas **F1/F2** acionam respectivamente os comandos inferiores à esquerda/direita, em complemento ao mouse e às teclas de celular **2/4/5/6/8**. O comando só é executado se estiver visível e habilitado.
- `tests/v25_controls.lua` cobre os limites da barra, dimensões dos alvos, etiquetas e botões inferiores. Não modifica genética, economia, fontes ou salvamentos. O trabalho 1:1 completo exige conferir outras telas do MIDlet.

## Novo na v24 — dimensões e seleção 240×320

- **Escala real:** a janela usa toda a largura/altura cabível, inclusive em tamanhos não múltiplos de 240×320 (por exemplo, 468×858). O filtro de texturas continua nearest; o motor biológico e o salvamento não mudaram.
- **Corpos inteiros:** posições visuais dos peixes são limitadas pela metade da largura de cada faixa etária, evitando peixes adultos cortados nas bordas da água.
- **Seleção:** peixes adultos selecionados recuperam o corpo de 50 pixels do atlas do JAR; o destaque amarelo e os alvos de toque acompanham a posição efetivamente desenhada.
- **Painel de saúde:** a barra normal usa verde, como na captura J2ME; quando a saúde cai abaixo de 35 a barra fica avermelhada.
- **Testes:** `tests/v24_viewport.lua` verifica a área lógica, escala em tamanhos fracionários, alvo de seleção, ordem de desenho, bordas e preservação dos dados do jogo. **Não equivale a uma comparação pixel a pixel com o JAR.**

## Novo na v23 — tipografia bitmap original

- As três fontes de `1.dat` (104 glifos cada) são extraídas **localmente** pelo script `scripts/import_j2me_fonts.py` sem copiar fontes comerciais para o GitHub. O `.love` de teste local inclui os dados recuperados do JAR fornecido pelo usuário.
- `ui/bitmap_font.lua` usa as posições exatas por glifo da classe `i` do Java, respeitando largura variável, alinhamento central/direita e corte de textos longos.
- Os menus 240×320 usam fonte bitmap quando presente; o CI público usa a fonte LÖVE reserva, porque não inclui o JAR comercial.
- Nenhuma alteração na lógica do jogo ou na estrutura dos salvamentos.

**Para usar seu JAR em uma cópia do código:** `python scripts/import_j2me_fonts.py Fish_Tycoon.jar`. Então inicie com LÖVE normalmente. As fontes são de uso privado para estudo.


## Novidades da v22 — teclado J2ME e interface compacta

- **Navegação por teclado:** teclas **2/4/6/8** ou setas movimentam o foco nos menus e **5/Enter/Espaço** ativam a opção. Um contorno amarelo indica qual botão está selecionado. `Esc` continua retornando. Na seleção de peixes, as teclas 4/6 ainda percorrem os exemplares.
- **Novo jogo e opções:** menus acessíveis sem mouse; com um salvamento existente, CONTINUE é o padrão, e sem save o foco inicia em NEW GAME. Comprar um item ainda exige focar o botão **BUY**, sem compra acidental ao destacar uma linha da loja.
- **Barra superior:** os 11 slots ocupam toda a largura do J2ME, e o valor do dinheiro não cobre o último ícone. Corrigidos os recortes de alimentação e tratamentos do atlas `assets.png` opcional; a quantia permanece visível na loja.
- **Menus:** loja, pesquisas e comandos usam como base `menutank.png`, recurso do JAR que já estava no pacote, em vez de desenhar os corais do aquário principal atrás de todos os diálogos.
- **Testes:** 8 novos cenários em `tests/v22_keypad.lua`. O teste anterior do atalho alimentar foi ajustado para as novas posições da barra. Não houve mudança no motor nem no formato dos saves.
- **Limite da fidelidade:** ainda faltam mapear corretamente as **fontes bitmap** e comprovar a geometria dos menus com capturas diretas do MIDlet. Não confundir testes de renderização com verificação pixel a pixel do J2ME.

## Novidades da v21 — loja e pesquisas no layout compacto

- **Loja de suprimentos:** até quatro produtos por página com miniaturas reais do `store.png` do JAR, seleção de um produto separada do botão **BUY**, preço sempre visível, descrição contextual, navegação por páginas e botão **BACK**. Em cópias sem esse PNG, mantém um quadro de reserva, sem impedir compras.
- **Pesquisas:** painéis compactos de três áreas com nível atual, barra de progresso, efeito atual, botão **START/MAX** e estado da pesquisa ativa. O motor de estudos e os valores continuam os da v20; **não** foram inventados novos custos ou tempos do JAR.
- **Validação:** nova suíte `tests/v21_shop_research.lua` com oito verificações, incluindo compra, paginação, seleção, limite de pesquisas, compatibilidade com fallback e retorno ao menu. Total: 34 arquivos de testes Lua executados sem falha.
- **Capturas nativas:** smoke do LÖVE agora cobre nove telas, acrescentando outra página da loja e a pesquisas. A execução real é comprovada apenas depois da aprovação do GitHub Actions, não pelos testes com mocks.
- **Continuidade:** nenhuma alteração no motor de peixes, recursos comerciais existentes, formato de saves ou progresso de usuários. O projeto continua **parcialmente aproximado** ao Java: a correspondência pixel a pixel de menus e os nomes/preços de produtos não foram comprovados com screenshots do MIDlet.

## Novidades da v20 — referência visual J2ME

- Barra superior: miniaturas dos três tanques e ícones recortados diretamente de `assets.png` (peixe, alimentação, medicamentos, reprodução, loja, pesquisa, dinheiro). O atlas permanece **opcional no GitHub público**; importe o JAR para obter os ícones originais. Sem ele, os comandos continuam funcionando com símbolos de reserva.
- A seleção usa os 21 nomes de corpo e 21 nomes de barbatana recuperados dos textos ingleses do JAR (exemplo: **GREENFIN FRUITFISH**), mantendo os índices genéticos intactos.
- Isolamento: corrigida a sobreposição — os peixes agora são renderizados **sobre** o recipiente azul.
- Tanque de vendas: indicação **For Sale!** junto aos adultos.
- Controles: `F` ou espaço para escolher peixe, `4/6` e `2/8` ou setas para navegar, `5` para abrir ações, `Esc` para voltar. Mouse e toque funcionam normalmente. O botão de alimento na barra executa alimentação e a pesquisa/loja abrem pelas novas miniaturas.
- Não há mudanças nos salvamentos nem nas regras de crescimento e genética. Ainda não há correspondência pixel a pixel certificada com todas as telas J2ME; para capturar diferenças, consulte `docs/FASE_20.md`.

## Jogar

Abra `Aquario-de-Isola-v27.love` usando [LÖVE 2D 11.4](https://love2d.org/) ou execute `love .` no diretório. Inicialmente aparece um menu com **CONTINUE, NEW GAME, OPTIONS, ABOUT**. Para criar uma partida nova, clique em **NEW GAME**. Se já existir jogo salvo, há confirmação antes de substituí-lo; o save antigo é arquivado em `fish_tank_save_before_new_game.json` e permanece recuperável. Uma falha ao criar arquivo arquivado bloqueia a substituição.

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
texlua tests/v20_visual_controls.lua
texlua tests/v21_shop_research.lua
texlua tests/v22_keypad.lua
texlua tests/v24_viewport.lua
texlua tests/v25_controls.lua
texlua tests/v26_sale_art.lua
texlua tests/v27_menu.lua
# regressão completa
for file in tests/*.lua; do texlua "$file"; done
```

GitHub Actions contém dois testes nativos no LÖVE/Xvfb: o anterior para a interface legada e o novo `FISH_RETRO_SMOKE=1`, que captura onze telas J2ME em 480 × 640. **Isso valida renderização e navegação, não comprova correspondência pixel a pixel com todo o jogo Java.**

A base canônica é a branch `main` de https://github.com/SrTristeSad/Fish-Tycoon-Lua. Toda alteração deve ter commit. Consulte também `AGENTS.md` e `RECURSOS_E_DIREITOS.md`.

Consulte [`docs/FASE_26.md`](docs/FASE_26.md) e [`docs/FASE_22.md`](docs/FASE_22.md) e [`docs/FASE_21.md`](docs/FASE_21.md) para os detalhes de construção e o que permanece diferente do JAR.

