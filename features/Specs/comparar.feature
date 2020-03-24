#language: pt
@Comparacao
Funcionalidade: Comparação de produtos
Eu como cliente do Site Casas Bahia
Quero comparar os produtos
Para poder escolher a melhor opção

Cenário: Comparar iPhones

Dado que eu esteja no resultado da busca do iPhone
Quando eu clicar em comparar os 2 primeiros iPhones da lista
E clicar no botão Comparar
Então deve trazer os dados de comparação
E validar pelo menos 3 dados iguais
