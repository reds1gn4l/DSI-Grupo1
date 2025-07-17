#!/bin/bash

echo "🔧 Iniciando reorganização da estrutura..."

# Move o conteúdo do projeto Flutter para a raiz
if [ -d "smart_green" ]; then
  mv smart_green/* .
  mv smart_green/.* . 2>/dev/null
  rm -rf smart_green
fi

# Criação das pastas
mkdir -p .github/workflows
mkdir -p assets/{images,icons,lottie}
mkdir -p lib/{core/{theme,utils},models,modules/{auth/{pages,widgets,controllers},home,loja,planta,estoque},shared}
mkdir -p test/modules
mkdir -p docs

# Criação de arquivos base
touch lib/c
