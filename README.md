# Fish Tycoon Lua — v34: menu J2ME (240 × 320)

Desde a v19, **a interface padrão é `ui/retro.lua`**, desenhada em 240 × 320 e ampliada sem perder proporção. A tela anterior (`ui/view.lua`) foi preservada para regressão, mas não é mais o menu principal. O motor Lua, sprites e estrutura de saves permanecem.

## Novo na v34 — selecao sem alterar o nado dos demais peixes

- A tela de detalhes **nao desloca mais artificialmente** os peixes que cruzam a moldura do selecionado. Todos conservam suas coordenadas de movimento independente; a area da moldura e restaurada com o fundo azul do proprio `tanktop.png` antes de desenhar o selecionado por ultimo. A limpeza da imagem usa recorte de tela compativel com viewport fracionario.
- Se o peixe selecionado morrer ou for movido para outro aquario durante a visualizacao, a selecao e encerrada sem manter um ID invalido.
- O smoke test agora posiciona um **GREENFIN FRUITFISH**, idade 21, na captura `03-peixe.png` para permitir comparacao visual com a imagem Java recebida. E uma fixture isolada e nunca altera a partida do usuario.
- Novo `tests/v34_detail_overlay.lua` e ajustes de regressao na selecao; nenhuma modificacao em biologia, genetica, economia, sprites, audio ou formato de saves. A equivalencia de todos os quadros do MIDlet ainda nao foi provada.

## Novo na v33 — isolador visível e seleção com moldura superior

- **Dois peixes no recipiente:** os centros foram corrigidos para x=96 e x=144 no recipiente de 98px; a largura e a altura são ajustadas somente nesse compartimento para manter o sprite entre x=70..168 e y=274..298, sem ficar atrás dos botões inferiores.
- **Peixe selecionado no isolamento:** usa a moldura amarela e a âncora (91,53), como as demais telas de seleção. Os outros exemplares continuam visíveis no recipiente inferior.
- **Aquários sem redução artificial:** sprites dos tanques continuam com 21/35/50px nativos da v32. A redução na bandeja é uma adaptação visual de layout, ainda não confirmada contra a exibição do MIDlet Java.
- **Validação:** nova suíte `tests/v33_isolation_layout.lua` verifica todas as 441 combinações adultas no isolador, áreas de toque, teclas inferiores, desenho sem mutar o jogo e navegação. O GitHub Actions passa a capturar 22 telas, com duas novas telas do isolamento.
- **Sem alteração de simulação:** salvamentos v9, genética, pesquisas, preços e PNGs originais não foram modificados.

## Novo na v32 — sprites 1:1 por idade

- O bytecode da classe `m` do Fish Tycoon Java fornece os tamanhos de sprite
  **21 × 8 px (idade 0–5)**, **35 px de largura (idade 6–19)** e
  **50 px de largura (idade 20+)**; alturas das formas vêm das tabelas em `j`.
- A tela `ui/retro.lua` deixou de reduzir os sprites originais para 85%.
  A composição de aquário agora usa escala 1, independentemente da idade.
- Os limites e as áreas de toque usam a largura e a altura real dos sprites,
  incluindo a barbatana adulta. O peixe selecionado mantém a âncora do J2ME
  (91,53), sem modificar os dados nem o nado livre da v31.
- Adicionado `ui/fish_geometry.lua` e `tests/v32_fish_sizes.lua`, com cobertura
  das 441 combinações de adultos e das três faixas de crescimento.
- Nenhuma modificação em salvamento, biologia, genética, dinheiro ou imagens.
  O Android e a inspeção quadro a quadro do MIDlet continuam pendentes.

## Novo na v31 — nado independente baseado no JAR

- **Distribuição livre**: os peixes deixam de ocupar quatro colunas fixas. Posição inicial e direção passam a ser derivadas do identificador individual, com trajetórias independentes em todo o aquário.
- **Velocidade e direção**: o novo renderizador `ui/j2me_motion.lua` usa a representação de movimento 16.16 identificada em `m.n()`/`h.c()` no Java. A conversão para segundos (60 atualizações/segundo) e a semente visual por ID são adaptações documentadas, **não equivalência 1:1 comprovada**.
- **Sem alterar a partida**: a nova trajetória é apenas de apresentação. Não usa o gerador aleatório da simulação, não introduz campos no salvamento e não altera o antigo `ui/swim.lua` usado pelos testes da interface moderna.
- **Seleção preservada**: ao selecionar um peixe, sua moldura permanece na posição J2ME conhecida e outros peixes não devem invadi-la. `tests/v31_motion.lua` testa limites, deslocamento, direção, independência da ordem, salvamento e interação.

## Novo na v30 — seleção do peixe conforme a captura J2ME

- **Foco do peixe:** na tela de detalhes, o peixe selecionado é desenhado na região superior central, com o retângulo amarelo de 56 × 37 pixels cuja posição foi medida na captura J2ME fornecida (x=63, y=34). Antes, o destaque acompanhava a trajetória aleatória do peixe e aparecia frequentemente longe da referência.
- **Camadas:** o peixe selecionado é renderizado depois dos demais para evitar que seu corpo e o marcador amarelo sejam encobertos. Os outros peixes continuam nadando, mas sem alterar o estado da simulação.
- **Voltar e navegar:** SELECT/BACK e 2/4/6/8 continuam permitindo explorar os peixes; ao sair da seleção o peixe volta à posição normal de nado. O toque na tela do aquário mantém o alvo proporcional ao sprite.
- **Testes:** `tests/v30_selection.lua` valida posição do contorno, ordem de desenho, troca de exemplar e ausência de mutação do save. `core/retro_smoke.lua` acrescenta uma captura nativa dedicada à seleção de outro peixe. Nenhuma regra de pesquisa, genética ou economia foi alterada.

## Novo na v29 — ícones J2ME e retorno correto de menus

- Ações, transferências e tratamentos usam miniaturas do **atlas já recuperado do JAR** (ícones de comida, medicamentos, dinheiro, peixes e tanques), com texto reserva quando esses recursos ainda não foram importados. Os botões continuam compactos em 240 × 320 e os produtos continuam com as regras da v28.
- **Navegação corrigida:** loja e pesquisa abertas pela barra superior agora voltam ao aquário ou menu de origem (tecla F2/BACK ou Esc); anteriormente voltavam sempre ao menu de pausa, prejudicando a continuidade da partida. Alternar diretamente entre loja e pesquisa mantém o destino de retorno.
- Os ícones são exclusivamente visuais e não fazem nenhuma compra ou transferência. Os produtos do JAR são de estudo local e não são redistribuídos pelo repositório público.
- Os testes `tests/v29_navigation_icons.lua` conferem imagens originais, fallback, toque, retorno e estados de compra/transferência, sem modificar genética ou salvamentos. Ainda não representa confirmação pixel a pixel de todos os menus do Java original.

## Novo na v28 — menus de ações, transferências e tratamentos

- **Ações do peixe** organizadas numa lista compacta 240×320, com identificação, idade, saúde e preço. Vender diretamente e alterar preço só ficam disponíveis para **adultos no tanque de vendas**, em respeito às regras já implementadas pelo motor.
- **Transferências** mostram ocupação/capacidade e bloqueiam visualmente destino atual, tanque fechado, tanque cheio, venda de juvenis e saída do isolamento durante gestação. O motor continua sendo a autoridade para todas as transferências.
- **Tratamentos** exibem a doença e estoque disponível. Medicamentos inadequados, sem estoque ou hormônios para peixes acima de 40 ficam inativos; os demais aplicam as mesmas regras da v27.
- O retorno **BACK/F2** permanece funcional e as 3 telas foram incluídas no teste do LÖVE nativo (18 capturas ao todo). Nenhum recurso original, simulação ou formato de salvamento foi alterado.
- **Fidelidade:** essa organização é uma correção de usabilidade alinhada à resolução original, mas **a disposição exata do JAR ainda precisa de capturas dessas telas para verificação 1:1**.

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

Abra `Aquario-de-Isola-v32.love` usando [LÖVE 2D 11.4](https://love2d.org/) ou execute `love .` no diretório. Inicialmente aparece um menu com **CONTINUE, NEW GAME, OPTIONS, ABOUT**. Para criar uma partida nova, clique em **NEW GAME**. Se já existir jogo salvo, há confirmação antes de substituí-lo; o save antigo é arquivado em `fish_tank_save_before_new_game.json` e permanece recuperável. Uma falha ao criar arquivo arquivado bloqueia a substituição.

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
texlua tests/v28_actions.lua
# regressão completa
for file in tests/*.lua; do texlua "$file"; done
```

GitHub Actions contém dois testes nativos no LÖVE/Xvfb: o anterior para a interface legada e o novo `FISH_RETRO_SMOKE=1`, que captura onze telas J2ME em 480 × 640. **Isso valida renderização e navegação, não comprova correspondência pixel a pixel com todo o jogo Java.**

A base canônica é a branch `main` de https://github.com/SrTristeSad/Fish-Tycoon-Lua. Toda alteração deve ter commit. Consulte também `AGENTS.md` e `RECURSOS_E_DIREITOS.md`.

Consulte [`docs/FASE_26.md`](docs/FASE_26.md) e [`docs/FASE_22.md`](docs/FASE_22.md) e [`docs/FASE_21.md`](docs/FASE_21.md) para os detalhes de construção e o que permanece diferente do JAR.

