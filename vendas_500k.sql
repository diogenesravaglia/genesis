-- Consulta para retornar oportunidades de vendas >= 500.00 com status Concluido
SELECT 
    c.NOME as "Nome do Cliente",
    c.CIDADE as "Região",
    c.TIPO_CLIENTE as "Tipo do Cliente",
    v.VALOR as "Valor da Venda",
    TO_CHAR(v.DATA_VENDA, 'DD/MM/YYYY') as "Data da Venda"
FROM 
    clientes c
    LEFT JOIN vendas v ON c.CLIENTE_ID = v.CLIENTE_ID
WHERE 
    v.VALOR >= 500.00
    AND UPPER(v.STATUS) = UPPER('Concluido')
ORDER BY 
    v.VALOR DESC,
    c.NOME ASC;