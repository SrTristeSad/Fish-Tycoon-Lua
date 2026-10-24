# Aquário de Isola — Fish Tycoon em Lua (v16)

Reconstrução experimental em **Lua + LÖVE 2D 11.4** que continua diretamente o código da v15, com referência ao JAR J2ME 1.0.1 fornecido pelo usuário. Não é um port oficial nem uma reimplementação completa da lógica proprietária.

## Iniciar no Windows

1. Instale o [LÖVE 2D](https://love2d.org/) (11.4 ou compatível).
2. Abra `Aquario-de-Isola-v16.love`. Alternativamente, extraia `FishTycoonLua_v16_codigo_fonte.zip` e abra `INICIAR_WINDOWS.bat` dentro da pasta do projeto.
3. Clique ou toque nos peixes para selecionar. As teclas **1–4** mudam de página, **espaço** alterna a velocidade e **Esc** fecha diálogos.

**Não contém APK Android nem executável Windows independente.** A v16 inclui um teste nativo do LÖVE no GitHub Actions (Xvfb), com PNGs das telas. Verifique o resultado do workflow antes de tratar a validação nativa como concluída; Android continua não testado.

## O que funciona no projeto

- 18 peixes por tanque de criação, dois peixes no isolamento, tanque de venda, segundo tanque desbloqueável;
- 21 tipos de corpo e 21 de barbatanas, cruzamento, ovos, nascimento, crescimento, sete descobertas especiais;
- alimentação, doenças, tratamentos, lojas, compradores automáticos, cotação por variedade, pesquisas e equipamentos;
- cinco faixas de áudio OGG convertidas dos MIDI originais e gráficos recuperados do JAR;
- salvar/carregar com backup anterior, histórico de visitas, simulação offline limitada a 24 horas.

## Novo na v16

- **Teste nativo automático:** workflow GitHub Actions inicia o LÖVE em tela virtual e captura sete imagens reais; script Python inspeciona os PNGs e os disponibiliza como artefatos.
- **Controles reais:** teste de troca entre aquário, isolamento, vendas, loja, pesquisas e coleção usando `love.mousepressed`, além de mudança para modo paisagem.
- **Proteção de dados:** modo de teste só é habilitado por `FISH_NATIVE_SMOKE=1` e não lê ou escreve o save do jogador.
- **Sem mudança de gameplay:** recursos, pesquisas, genética e formato do save v15 continuam iguais.

## Mudanças acumuladas da v15

- **Distribuição dos peixes:** os 18 peixes agora utilizam uma grade com margens de segurança para o corpo, as barbatanas e o aro de seleção, preservando o nado determinístico da v10. Evita que peixes da primeira e da última coluna fiquem parcialmente encobertos pelo painel.
- **Controles:** nova suíte `tests/v15_controls.lua` para toques nas abas, resolução pequena, letterboxing em paisagem, seleção por toque, bloqueio por modais e limites dos botões.
- **Genética JAR:** corrigida a mutação no nascimento de vários filhotes: ocorre uma vez por gestação, antes das cópias; as fórmulas de média continuam preservadas. As probabilidades de pesquisa autenticadas por bytecode permanecem inalteradas.
- **Verificação:** testes de interface com API LÖVE simulada e os PNGs reais. **Não houve abertura de janela real nem validação em Android**; esses testes continuam pendentes.

## Verificar

Em um terminal na pasta do código-fonte, com `texlua` ou TeX Live:

```sh
texlua tests/run.lua
texlua tests/v9_regression.lua
texlua tests/v9_storage.lua
texlua tests/v10_swim.lua
texlua tests/v10_ui_smoke.lua
texlua tests/v11_timeline.lua
texlua tests/v11_research.lua
texlua tests/v11_ui_smoke.lua
texlua tests/v12_offline.lua
texlua tests/v12_save_safety.lua
texlua tests/v13_integrity.lua
texlua tests/v14_render.lua
texlua tests/v15_controls.lua
texlua tests/v15_jar_genetics.lua
FISH_NATIVE_SMOKE=1 texlua tests/v16_native_driver.lua
texlua tests/view_smoke.lua
```

Ou execute `TESTAR_LUA.bat` no Windows para repetir todas as suítes. A v16 preserva as suítes anteriores e amplia a validação dos alvos de toque e das margens visuais. O `TESTAR_LUA.bat` executa todas as suítes de testes e desempenho.

## Direitos e fidelidade

Uma parte das regras de criação e economia foi inferida do bytecode Java; outras seguem aproximadas. Sprites, músicas e nomes originais têm seus titulares de direitos. A extração para estudo não equivale a uma licença para distribuir ou comercializar esses recursos. Antes de publicar, substitua recursos sem permissão por assets próprios ou licenciados.

Detalhes em [`docs/FASE_16.md`](docs/FASE_16.md), [`docs/FASE_15.md`](docs/FASE_15.md) e [`docs/FASE_15_JAR.md`](docs/FASE_15_JAR.md) e [`docs/FASE_14.md`](docs/FASE_14.md) e [`docs/FASE_13.md`](docs/FASE_13.md).
