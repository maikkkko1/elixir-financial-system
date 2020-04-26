# Elixir Financial System [![Actions Status](https://github.com/maikkkko1/elixir-financial-system/workflows/Build%20and%20Test/badge.svg)](https://github.com/maikkkko1/elixir-financial-system/actions) [![Coverage Status](https://coveralls.io/repos/github/maikkkko1/elixir-financial-system/badge.svg?branch=master)](https://coveralls.io/github/maikkkko1/elixir-financial-system?branch=master)

Projeto de um sistema financeiro desenvolvido utilizando Elixir para o desafio da [**Tech Challenge**]( https://github.com/stone-payments/tech-challenge) da **Stone**.

## Sobre

O objetivo deste projeto é ser um sistema financeiro capaz de disponibilizar diversas operações financeiras, como:

* Depósitos em conta;
* Saques de contas;
* Transferências entre contas;
* Split de transações entre diversas contas;
* Cãmbio de valores monetários;

Todas as operações acima estão em conformidade com a [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217)

## Solução

Para atender o que foi proposto e eliminar os problemas com aritmética dos pontos flutuantes, todos os valores foram encodificados em valores inteiros, por exemplo a representação do valor 10,00 seria 1000, sem os pontos.

Exemplos de como os valores são representados:

* 10,00 = 1000
* 100,00 = 10000
* 1,00 = 100
* 5,50 = 550
* 0,10 - 10
* 0,01 - 1

Para a persistência de dados foi utilizado o SQLite3.

Também além do sistema utilizavel pelo shell interativo do Elixir(IEX), também foi desenvolvida uma API Rest capaz de realizar todas as mesmas operações que o shell interativo.

## Dependências

* [sqlite_ecto2](https://github.com/elixir-sqlite/sqlite_ecto2) - Adaptador para utilização do banco de dados SQLite3.
* [Tesla](https://github.com/teamon/tesla) - Cliente HTTP utilizado para realizar as requisições.
* [ExDoc](https://github.com/elixir-lang/ex_doc) - Utilizado para gerar a documentação completa do projeto.
* [Cowboy](https://github.com/ninenines/cowboy) - Client HTTP utilizado para servir a API Rest.
* [Poison](https://github.com/devinus/poison) - JSON Parser utilizado para realizar o encode/decode das requisições Rest.
* [Plug](https://github.com/elixir-plug/plug) - Adaptador para o web server.
* [Money](https://github.com/elixirmoney/money) - Biblioteca para trabalhar com dinheiro.
* [ExCoveralls](https://github.com/parroty/excoveralls) - Ferramenta utilizada para cobertura de testes.

## Instalação

Para iniciarmos, o primeiro passo caso ainda não possua o Elixir instalado, é realizar a instalação do mesmo.

O guia oficial pode ser seguido para realizar a instalação: [Guia oficial](https://elixir-lang.org/install.html)

Após ter realizado a instalação caso necessário, clone o repositório e então na raiz do projeto, instale todas as dependências com o comando:

```
mix deps.get
```

Com o sucesso deste comando, todas as dependências para o projeto funcionar devem estar instaladas.

## Utilização

Existem duas formas de utilização do sistema, pelo **IEX** ou via **API**.

### Utilizando pelo IEX

Primeiramente abra o terminal na raiz do projeto e acesse o IEX com o comando: 

```iex -S mix```

Após esse comando, você deve estar dentro do IEX e então agora conseguimos utilizar todas as funcionalidades do nosso sistema financeiro.

Todas as operações necessitam de uma conta existente e se baseiam ou no **número** da conta ou no **ID** da conta.

#### Operações de conta 

```elixir
# Criar uma conta bancária com os seguintes dados: Nome: Maikon, Numero: 1234, Agência: 1111, Moeda: BRL e Saldo: 10,00.
iex(1)> AccountService.create_account("Maikon", 1234, 1111, "BRL", 1000)

# Retornar o saldo formatado de uma conta pelo seu número.
iex(1)> AccountService.get_account_balance_by_number(1234)

# Retornar todos os dados de uma conta pelo seu número.
iex(1)> AccountService.get_account_by_number(1234)

# Retornar todos os dados de uma conta pelo seu ID do banco de dados.
iex(1)> AccountService.get_account_by_id(1)
```
