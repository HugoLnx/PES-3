#!/bin/bash
docker-compose exec mongo mongo pes3 --eval "db.articles.dropIndexes(); db.articles.createIndex({document_text: 'text', title: 'text', authors_text: 'text'})"
