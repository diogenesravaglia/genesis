# Projeto Genesis

Este projeto contém consultas SQL para análise de vendas em um banco de dados Oracle.

## Estrutura do Banco de Dados

### Tabela: vendas
| Coluna      | Tipo          | Restrição  | Descrição                    |
|-------------|---------------|------------|------------------------------|
| ID          | NUMBER        | NOT NULL   | Identificador único da venda |
| CLIENTE_ID  | NUMBER        |            | ID do cliente               |
| DATA_VENDA  | DATE          |            | Data da realização da venda |
| VALOR       | NUMBER(10,2)  |            | Valor da venda              |
| STATUS      | VARCHAR2(20)  |            | Status da venda             |

### Tabela: clientes
| Coluna         | Tipo          | Restrição  | Descrição                     |
|----------------|---------------|------------|-------------------------------|
| CLIENTE_ID     | NUMBER        | NOT NULL   | Identificador único do cliente|
| NOME           | VARCHAR2(100) |            | Nome do cliente              |
| TIPO_CLIENTE   | VARCHAR2(20)  |            | Tipo/categoria do cliente    |
| CIDADE         | VARCHAR2(50)  |            | Cidade do cliente            |
| DATA_CADASTRO  | DATE          |            | Data de cadastro do cliente  |

## Consultas SQL

### Vendas acima de 500 (vendas_500k.sql)

Esta consulta retorna todas as oportunidades de vendas que atendem aos seguintes critérios:
- Valor igual ou superior a R$ 500,00
- Status "Concluido"

#### Campos retornados:
- Nome do Cliente
- Região (Cidade)
- Tipo do Cliente
- Valor da Venda
- Data da Venda (formato DD/MM/YYYY)

#### Características da Consulta:
- Utiliza LEFT JOIN para garantir que todos os clientes sejam considerados
- Usa UPPER() na comparação do status para evitar problemas de case sensitive
- Ordenação primária por valor (decrescente) e secundária por nome do cliente (crescente)

## Como Usar

1. Conecte-se ao banco de dados Oracle
2. Execute o arquivo SQL desejado:
   ```sql
   @vendas_500k.sql
   ```

## Desenvolvimento

Este projeto foi desenvolvido como parte da atividade NAP-23 (GAP-3030_vendas_500k) para análise de oportunidades de vendas.

### Informações da Tarefa
- **Código**: NAP-23
- **Título**: GAP-3030_vendas_500k
- **Tipo**: Task
- **Projeto**: Nina AI Project
- **Status**: To Do
- **Prioridade**: Média
- **Data Início**: 30/04/2025
- **Data Fim Prevista**: 02/05/2025

## Contribuição

Para contribuir com este projeto:
1. Faça um fork do repositório
2. Crie uma branch para sua feature
3. Faça commit das suas alterações
4. Faça push para a branch
5. Abra um Pull Request

## Versionamento

O projeto utiliza o GitHub para controle de versão. Você pode encontrar a versão mais recente em:
https://github.com/diogenesravaglia/genesis