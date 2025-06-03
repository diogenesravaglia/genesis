SELECT
    v.ID AS ID_VENDA,
    v.VALOR,
    v.STATUS,
    c.NOME AS NOME_CLIENTE,
    c.CIDADE AS REGIAO,
    c.TIPO_CLIENTE
FROM
    vendas v
JOIN
    clientes c ON v.CLIENTE_ID = c.CLIENTE_ID
WHERE
    v.VALOR >= 500.00
    AND v.STATUS = 'Concluido';
