# Compilações do cliente Minetest em formato AppImage (não-oficial)

[Read in English](./README.md)

Com base no Debian 11, este projeto constrói AppImages para ajudar você a testar
uma versão de desenvolvimento do [Minetest](https://www.minetest.net) bem como
baixar e executar facilmente o jogo em qualquer distribuição Linux através de um
download que contém todas as dependências necessárias em um único arquivo.

Testado em:

* Debian 11
* Debian 12
* Ubuntu 22.04
* Ubuntu 24.04

Provavelmente não irá funcionar em:

* Ubuntu 18.04 - Use o AppImage produzido pelo Gitlab oficial do Minetest

## Por quê?

Este projeto foi criado porque as AppImages oficiais do Minetest são compiladas
usando o Ubuntu Bionic como base, e por alguma razão obscura, ele não executa
nem no Debian 11 nem no Ubuntu 22.04.

Este projeto usa o Debian 11 como base, e produz AppImages que funcionam tanto
no Debian quanto no Ubuntu mais recentes.

## Como usar essas imagens?

O formato [AppImage](https://appimage.org/) é uma forma simples de distribuir
programas no Linux para usuários de qualquer distribuição. Ele inclui uma camada
de portabilidade em tempo de execução, e inclui todas as dependências da
aplicação em um único arquivo, então ele deve rodar sem modificações em qualquer
máquina.

Para começar a usar o AppImage, basta fazer o download da página de 
[Releases](https://github.com/ronoaldo/minetestclient/releases) no Github, Em
seguida, é necessário torná-lo executável pela interface gráfica do seu
gerenciador de arquivos ou pela linha de comandos com `chmod +x
Minetest*.AppImage`.  Então, basta executá ele com um clique duplo no navegador
de arquivos ou pelo terminal de comandos com `./Minetest*AppImage`.

### FUSE faltando

Se você receber uma mensagem de erro informando que o FUSE está faltando
(aconteceu comigo ao testar no Ubuntu 22.04), basta instalar o pacote
`libfuse2`:

    sudo apt-get install libfuse2 -yq

Nota: isso não deveria ocorrer desde a versão 5.12.0 já que alteramos para
construir as imagens utilizando `linuxdeploy` que utiliza uma implementação
melhor com uma vesão estática do libfuse.

## Diretório pessoal portátil

Quer testar um **release candidate** sem quebrar os seus mundos? Sem problemas!
Você pode ter uma pasta portátil alternativa para ser o seu diretório HOME.

Para usar esta funcionalidade, basta criar um diretório com o mesmo nome do
programa, e um sufixo `.home`. Por exemplo, o programa:
`Minetest-5.6.0-rc1_x86_64.AppImage` vai usar o diretório
`Minetest-5.6.0-rc1_x86_64.AppImage.home` se ele existir.

Outra opção, é configurar o programa com a opção `--appimage-portable-home` pelo
terminal de comandos:

    ./Minetest*.AppImage --appimage-portable-home

## Melhor integração com o ambiente gráfico

Você pode também utilizar um programa auxiliar `appimagelauncher` que irá
ajudá-lo a usar AppImage em seu ambiente de trabalho, realizando uma melhor
integração com ele. No Debian e derivados, você pode instalar este programa pelo
`apt`:

    sudo apt-get install appimagelauncher -yq
