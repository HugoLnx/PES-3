# PES-3 - README
* Autoria: Bernardo, Hugo, Guilherme, Lucas, Robert e Pedro
* Data: 30/06
* Versão: 16
* Tamanho: 229 linhas

## Para uso da equipe
### Configurando ambiente
1. instale [docker-engine](https://docs.docker.com/engine/installation/)
2. instale [docker-compose](https://docs.docker.com/compose/install/)
3. entre no diretório do projeto
4. rode no terminal: docker-compose build
5. rode no terminal: docker-compose up
5. rode em outro terminal: ./scripts/create_indexes.sh (Se não rodar não vai conseguir buscar artigos)
6. teste acessando: http://localhost:3005/ ou http://localhost:3005/hellolua/

### Fontes úteis sobre o que estamos usando
* [NGINX](http://nginx.org/en/docs/beginners_guide.html)
* [Módulo de lua para NGINX](https://www.nginx.com/resources/wiki/modules/lua/)
* [Módulo de Upload para NGINX](https://www.nginx.com/resources/wiki/modules/upload/)
* [Driver de mongo para lua](https://github.com/mongodb-labs/mongorover)
* [Sessões para lua com nginx](https://github.com/bungle/lua-resty-session) (Talvez a gente nem precise)
* [Academic Search Engine Optimization](https://docear.org/papers/Academic%20Search%20Engine%20Optimization%20(ASEO)%20--%20preprint.pdf)
* [Videos explicando a estrutura do projeto](https://drive.google.com/folderview?id=0B1IQXiIP0vpWOVdrNWtpRDR5ZjQ&usp=sharing)

### Paths importantes
* GET /
* GET /articles.html
* GET /conferences.html
* GET /conference/$id.html

* GET /form.html - Exemplo de formulário onde pode-se criar um artigo
* GET /update-form.html - Exemplo de formulário que atualiza o último artigo adicionado

* POST /articles - Cria um artigo fazendo upload do PDF (tem que enviar como 'multipart/form-data')
* POST /articles/$id/update - Atualiza um artigo  (tem que enviar como 'multipart/form-data') PS.: Não usei PUT por que estava tendo problemas em habilitar upload pro PUT :P
* GET /articles/$id.pdf - Baixa PDF contabilizando o número de downloads

* POST /conferences - Cria uma conferencia
* POST /conferences/$id/update - Atualiza uma conferencia

## Marcação dos documentos
### /Dockerfile
* Autoria: Hugo
* Data: 8/06
* Versão: 6
* Tamanho: 126 linhas

### /nginx.conf
* Autoria: Hugo e Guilherme
* Data: 29/06
* Versão: 17
* Tamanho: 253 linhas

### /docker-compose.yml
* Autoria: Hugo
* Data: 24/05
* Versão: 1
* Tamanho: 19 linhas

### /diagrams/Arquitetura.asta
* Autoria: Lucas, Robert e Pedro
* Data: 29/06
* Versão: 4
* Tamanho: 31.3 KB

### /diagrams/DFD.pdf
* Autoria: Bernardo
* Data: 29/06
* Versão: 2
* Tamanho: 431 KB

### /documents/Cronograma.xls
* Autoria: Bernardo
* Data: 29/06
* Versão: 4
* Tamanho: 9.5 KB

### /lib/front_controller.lua
* Autoria: Hugo
* Data: 27/06
* Versão: 4
* Tamanho: 75 linhas

### /lib/utils.lua
* Autoria: Hugo
* Data: 09/06
* Versão: 2
* Tamanho: 42 linhas

### /lib/view.lua
* Autoria: Hugo
* Data: 29/06
* Versão: 2
* Tamanho: 40 linhas

### /public/form.html
* Autoria: Hugo
* Data: 29/06
* Versão: 4
* Tamanho: 40 linhas

### /public/update_form.html
* Autoria: Hugo
* Data: 28/05
* Versão: 1
* Tamanho: 40 linhas

### /public/css/bootstrap.min.css
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 14 linhas

### /public/css/config.json
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 435 linhas

### /public/css/style.css
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 60 linhas

### /public/fonts/glyphicons-halflings-regular.eot
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 19.7 KB

### /public/fonts/glyphicons-halflings-regular.svg
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 106 KB

### /public/fonts/glyphicons-halflings-regular.ttf
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 44.3 KB

### /public/fonts/glyphicons-halflings-regular.woff
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 22.9 KB

### /public/fonts/glyphicons-halflings-regular.woff2
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 17.6 KB

### /public/js/bootstrap.min.js
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 7 linhas

### /public/js/jquery.min.js
* Autoria: Guilherme
* Data: 02/06
* Versão: 1
* Tamanho: 5 linhas

### /public/js/script.js
* Autoria: Guilherme e Hugo
* Data: 09/06
* Versão: 3
* Tamanho: 37 linhas

### /scripts/create_indexes.sh
* Autoria: Hugo
* Data: 16/06
* Versão: 1
* Tamanho: 3 linhas

### Diretório /src/

Os arquivos desse diretório estão cada um com seu cabeçalho. Como eles não estão em suas versões finais, preferimos deixá-los cada um com seu cabeçalho, em vez de adicioná-los a essa lista.

## Livro diário
### 19/05
* Primeira reunião para definição das tarefas iniciais e divisão geral do grupo. (Todos)
* Criado e compartilhado o Github para uso do grupo. (Guilherme)

### 23/05
* Preparação do ambiente de desenvolvimento a ser utilizado pelo grupo, com uso de docker e nginx. (Hugo)

### 31/05
* Primeira apresentação. (Hugo e Bernardo)

### 01/06
* Versão inicial do frontend. (Guilherme)

### 02/06
* Segunda apresentação. (Guilherme e Bernardo)
* Criação do livro diário e TODO list para organização das tarefas. (Bernardo)

### 06/06
* Criada a pasta diagrams e esboçar o diagrama de arquitetura. (Lucas)

### 07/06
* Correções no diagrama de arquitetura nível 0. (Lucas)

### 09/06
* Apresentação técnica. (Hugo, Guilherme e Robert)

### 21/06
* Apresentação técnica. (Hugo, Guilherme e Robert)

### 23/06
* Apresentação do DFD e do Diagrama de Sequência. (Bernardo e Robert)

### 29/06
* Atualizado o DFD. (Bernardo)
* Atualizada a Arquitetura. (Pedro)
* Integração. (Guiherme e Hugo)
* Preparação para a apresentação. (Bernardo, Guilherme e Hugo)

### 30/06
* Cronograma atualizado para a versão final. (Bernardo)

### 02/07
* Aplicação da regra 2 de disciplina aos arquivos da pasta models, controllers e lib (Robert)
* Inclusão de diagramas de sequência para as operações de conferência e autenticação. (Robert)
