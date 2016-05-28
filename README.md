# PES-3

# Configurando ambiente
1. instale docker-engine. https://docs.docker.com/engine/installation/
2. instale docker-compose. https://docs.docker.com/compose/install/
3. entre no diretório do projeto
4. rode no terminal: docker-compose build
5. rode no terminal: docker-compose up
6. teste acessando: http://localhost:3005/ ou http://localhost:3005/hellolua/



# Fontes úteis sobre o que estamos usando
* NGINX: http://nginx.org/en/docs/beginners_guide.html
* Módulo de lua para NGINX: https://www.nginx.com/resources/wiki/modules/lua/
* Módulo de Upload para NGINX: https://www.nginx.com/resources/wiki/modules/upload/
* Driver de mongo para lua: https://github.com/mongodb-labs/mongorover
* Sessões para lua com nginx (Talvez a gente nem precise): https://github.com/bungle/lua-resty-session

# Paths importantes
* GET /articles.json - JSON com todos os artigos existentes
* POST /articles - Cria um artigo fazendo upload do PDF (tem que enviar como 'multipart/form-data')
* GET /articles/$id.pdf - Baixa PDF contabilizando o número de downloads
* POST /articles/$id/update - Atualiza um artigo  (tem que enviar como 'multipart/form-data') PS.: Não usei PUT por que estava tendo problemas em habilitar upload pro PUT :P
* DELETE /articles/$id - Deleta um artigo
* GET /form.html - Exemplo de formulário onde pode-se criar um artigo
* GET /update-form.html - Exemplo de formulário que atualiza o último artigo adicionado
