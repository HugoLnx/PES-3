# PES-3 - README

## Configurando ambiente
1. instale [docker-engine](https://docs.docker.com/engine/installation/)
2. instale [docker-compose](https://docs.docker.com/compose/install/)
3. entre no diretório do projeto
4. rode no terminal: docker-compose build
5. rode no terminal: docker-compose up
5. rode em outro terminal: ./scripts/create_indexes.sh (Se não rodar não vai conseguir buscar artigos)
6. teste acessando: http://localhost:3005/ ou http://localhost:3005/hellolua/

## Fontes úteis sobre o que estamos usando
* [NGINX](http://nginx.org/en/docs/beginners_guide.html)
* [Módulo de lua para NGINX](https://www.nginx.com/resources/wiki/modules/lua/)
* [Módulo de Upload para NGINX](https://www.nginx.com/resources/wiki/modules/upload/)
* [Driver de mongo para lua](https://github.com/mongodb-labs/mongorover)
* [Sessões para lua com nginx](https://github.com/bungle/lua-resty-session) (Talvez a gente nem precise)
* [Academic Search Engine Optimization](https://docear.org/papers/Academic%20Search%20Engine%20Optimization%20(ASEO)%20--%20preprint.pdf)
* [Videos explicando a estrutura do projeto](https://drive.google.com/folderview?id=0B1IQXiIP0vpWOVdrNWtpRDR5ZjQ&usp=sharing)

## Paths importantes
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
* Apresentação técnica.

### 21/06
* Apresentação técnica.

### 23/06
* Apresentação do DFD e do Diagrama de Sequência. (Bernardo e Robert)

### 29/06
* Atualizado o DFD. (Bernardo)

### 30/06
* Preparação para a apresentação.
* Cronograma atualizado para a versão final. (Bernardo)