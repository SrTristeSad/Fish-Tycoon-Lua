# Aquário de Isola — Fish Tycoon em Lua (v14)

Reconstrução experimental em **Lua + LÖVE 2D 11.4** que continua diretamente o código da v13, com referência ao JAR J2ME 1.0.1 fornecido pelo usuário. Não é um port oficial nem uma reimplementação completa da lógica proprietária.

## Iniciar no Windows

1. Instale o [LÖVE 2D](https://love2d.org/) (11.4 ou compatível).
2. Abra `Aquario-de-Isola-v14.love`. Alternativamente, extraia `FishTycoonLua_v14_codigo_fonte.zip` e abra `INICIAR_WINDOWS.bat` dentro da pasta do projeto.
3. Clique ou toque nos peixes para selecionar. As teclas **1–4** mudam de página, **espaço** alterna a velocidade e **Esc** fecha diálogos.

**Não contém APK Android nem executável Windows independente.** A execução gráfica real em uma janela LÖVE não foi verificada neste ambiente; os testes de UI usam mocks.

## O que funciona no projeto

- 18 peixes por tanque de criação, dois peixes no isolamento, tanque de venda, segundo tanque desbloqueável;
- 21 tipos de corpo e 21 de barbatanas, cruzamento, ovos, nascimento, crescimento, sete descobertas especiais;
- alimentação, doenças, tratamentos, lojas, compradores automáticos, cotação por variedade, pesquisas e equipamentos;
- cinco faixas de áudio OGG convertidas dos MIDI originais e gráficos recuperados do JAR;
- salvar/carregar com backup anterior, histórico de visitas, simulação offline limitada a 24 horas.

## Novo na v14

- **Tanque de isolamento corrigido:** a interface usa `assets/original/isolation_tank.png`, em vez de repetir o cenário `tank1.png`; a imagem respeita sua proporção original, e o peixe aparece dentro do recipiente.
- **Renderização de fallback corrigida:** chamada de elipse usa 16 segmentos inteiros, evitando parâmetros fracionários incompatíveis com algumas implementações do LÖVE quando a arte do fundo não está disponível.
- **Navegação modal:** relatórios e caixas de cuidados bloqueiam atalhos de troca de tela e velocidade; **Esc** ou **Voltar** continuam fechando a janela aberta.
- **Novos testes gráficos sem janela:** verifica PNGs reais, dimensões e recortes dos atlas, 441 combinações de corpo/barbatana nas duas orientações, cinco faixas etárias de desenho (adultos, juvenis e filhotes), fundos corretos, páginas, modais e redimensionamento. O teste detalhado usa uma implementação restrita da API de desenho e **não constitui execução gráfica real do LÖVE**.
- **Compatibilidade:** preserva formato de save `version=9`, identidade `mar_de_isola_lua` e todos os arquivos de arte e áudio. Nenhum progresso precisa ser reiniciado.

Não altera as regras econômicas ou genéticas da v13. As regras originais ainda não decifradas do JAR permanecem identificadas como aproximações.

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
texlua tests/view_smoke.lua
```

Ou execute `TESTAR_LUA.bat` no Windows para repetir todas as suítes. A v14 preserva as suítes anteriores e acrescenta validação gráfica dos atlas e dos controles. O `TESTAR_LUA.bat` executa todas as suítes de testes e desempenho.

## Direitos e fidelidade

Uma parte das regras de criação e economia foi inferida do bytecode Java; outras seguem aproximadas. Sprites, músicas e nomes originais têm seus titulares de direitos. A extração para estudo não equivale a uma licença para distribuir ou comercializar esses recursos. Antes de publicar, substitua recursos sem permissão por assets próprios ou licenciados.

Detalhes em [`docs/FASE_14.md`](docs/FASE_14.md) e [`docs/FASE_13.md`](docs/FASE_13.md).
