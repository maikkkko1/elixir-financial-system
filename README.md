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

O último passo é criar o banco de dados e suas tabelas, para isso execute o comando:

```
mix ecto.migrate
```

## Utilização

Existem duas formas de utilização do sistema, pelo **IEX** ou via **API**.

### Utilizando pelo IEX

Primeiramente abra o terminal na raiz do projeto e acesse o IEX com o comando: 

```iex -S mix```

Após esse comando, você deve estar dentro do IEX e então agora conseguimos utilizar todas as funcionalidades do nosso sistema financeiro.

Todas as operações necessitam de uma conta existente e se baseiam ou no **número** da conta ou no **ID** da conta.

#### Operações de conta 

Não são permitidas contas com o mesmo número de conta, este é um campo de indíce único.

```elixir
# Criar uma conta com os seguintes dados: Nome: Maikon, Numero: 1234, Agência: 1111, Moeda: BRL e Saldo: 10,00.
iex(1)> AccountService.create_account("Maikon", 1234, 1111, "BRL", 1000)

# Atualizar uma conta pelo seu ID do banco de dados.
iex(1)> AccountService.update_account_by_id(1, %{name: "Nome atualizado", currency: "USD"})

# Retornar o saldo formatado de uma conta pelo seu número.
iex(1)> AccountService.get_account_balance_by_number(1234)

# Retornar todos os dados de uma conta pelo seu número.
iex(1)> AccountService.get_account_by_number(1234)

# Retornar todos os dados de uma conta pelo seu ID do banco de dados.
iex(1)> AccountService.get_account_by_id(1)

# Retornar todas as contas do banco de dados.
iex(1)> AccountService.get_all_accounts()
```

#### Operações financeiras e transações 

Todas as operações realizam o câmbio de valores em sua execução, com excessão da operação de **split**.

Todas as operações financeiras são também transações, por esse motivo todas operações geram registros de transações no banco de dados de acordo com o tipo de operação. Também todos os valores devem ser representados por números inteiros.

```elixir
# Realizar um depósito na conta número 1234, na moeda "BRL" e no valor de 25,00. 
# Considerar que a conta 1234 possuí a moeda BRL.
iex(1)> TransactionService.deposit(1234, "BRL", 2500) # Sem câmbio pois a moeda é a mesma da conta.
iex(1)> TransactionService.deposit(1234, "USD", 2500) # Com câmbio pois a moeda é diferente da conta.

# Realizar um saque na conta número 1234, na moeda "BRL" e no valor de 12,50.
# Considerar que a conta 1234 possuí a moeda BRL.
iex(1)> TransactionService.withdraw(1234, "BRL", 2500) # Sem câmbio pois a moeda é a mesma da conta.
iex(1)> TransactionService.withdraw(1234, "USD", 2500) # Com câmbio pois a moeda é diferente da conta.

# Realizar uma transferência da conta número 1234, no valor de 200,33 para a conta número 4321.
# Caso as duas contas possuam moedas diferentes, será realizado o câmbio dos valores antes da efetivação.
iex(1)> TransactionService.transfer(1234, 4321, 20033)

# Realizar o split de uma transação no valor de 500,00 entre duas contas.
# O calculo da porcentagem de todas as contas deve ser igual a 100%.
split_details = [
  %{account_number: 1234, percentage: 25},
  %{account_number: 4321, percentage: 75}
]

iex(1)> TransactionService.split(split_details, 50000)

# Retornar todas as transações do banco de dados.
iex(1)> TransactionService.get_all_transactions()
```

#### Câmbio de moedas

No caso do câmbio de valores, os valores devem ser informados no formato **float**.

```elixir

# Realizar o câmbio de valores entre BRL e USD no valor de 10,00.
iex(1)> CurrencyService.handle_conversion("BRL", "USD", 10.00)
```

### Utilizando pela API

Para realizar o teste das requisições é recomendado a utilização dos clientes REST [Insomnia](https://insomnia.rest/) ou [Postman](https://www.postman.com/).

No momento nenhuma requisição necessita de **autenticação**.

Antes de realizar as requisições para a API, é necessário iniciar o servidor HTTP com o comando:

```
mix run --no-halt
```

Agora com o servidor HTTP online, podem ser realizadas as requisições.

A documentação completa de todas as rotas disponíveis pela API está disponível no Postman pelo link:

https://documenter.getpostman.com/view/5866737/SzfCSkA6?version=latest

## Testes

O projeto possuí tanto testes de unidade como testes de cobertura.

Para rodar os testes sem os detalhes de cobertura, no terminal e na raiz do projeto, execute o comando:

```
MIX_ENV=test mix test
```

Para rodar com os detalhes de cobertura:

```
MIX_ENV=test mix coveralls
```

Também é possivel gerar um relatório HTML de cobertura que estará disponível na pasta **cover/**:

```
MIX_ENV=test mix coveralls.html
```

## Integração Contínua

Para a integração contínua, foi utilizado o [Github Actions](https://github.com/features/actions), a configuração utilizada está disponível no arquivo **elixir.yml** no diretório **.github/workflows**.

## Padronização de código

Utilizando o comando ```mix format``` é possivel garantir que a base de código esteja de acordo com os padrões do Elixir.

## Documentação

Utilizando o comando ```mix docs``` é possivel gerar a documentação completa do projeto, que estará disponível nos arquivos **HTML** no diretório **/doc**.

## Referências

