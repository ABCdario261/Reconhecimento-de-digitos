# Reconhecimento de Dígitos (Assembly - RISC-V)

Este projeto consiste numa implementação simples de uma rede neuronal em Assembly (RISC-V), 
desenvolvida no âmbito da disciplina de Introdução á Arquitetura de Computadores.

O objetivo é classificar dígitos (0–9) a partir de imagens, usando pesos previamente fornecidos.

⚠️ Nota: O programa funciona com ficheiros de input específicos fornecidos no projeto 
(por exemplo `output0.bin`) e não com imagens arbitrárias.

## Como funciona

A "rede neuronal" implementada corresponde apenas à fase de inferência (forward pass):

1. Multiplicação matriz-vetor:
   h = m0 × input  
2. Aplicação da função ReLU  
3. Nova multiplicação:
   o = m1 × h  
4. Escolha do valor máximo (argmax)

O resultado final corresponde ao dígito previsto.

## O que está implementado
- Leitura de ficheiros binários (pesos e imagem)
- Conversão de dados para inteiros
- Operações principais:
  - `dotproduct`
  - `matmul`
  - `relu`
  - `argmax`
- Classificação final do dígito

## Tecnologias e conceitos
- Assembly (RISC-V)
- Multiplicação de matrizes
- Conceitos simples de redes neuronais
- Gestão de memória e registos
- Syscalls para leitura de ficheiros

## Como executar

1. Abrir num simulador RISC-V
2. Garantir que existem os ficheiros:
   - `m0.bin`
   - `m1.bin`
   - `output0.bin`
3. Executar o programa

O resultado (dígito) será impresso no output.

  
