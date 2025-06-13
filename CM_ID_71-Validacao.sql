WITH MM_NU AS (
    SELECT
        ELVMIL.DESCR              AS "MICROMERCADO_NM",
        ELVMI.F1_EXT_LOOKUP_VALUE AS "MICROMERCADO_CODE",
        LVN.DESCR                 AS "NUCLEO_NM",
        VM.DESCR                  AS "MERCADO_NM",
        EXTRACT(XMLTYPE(CONCAT(CONCAT('<inicio>',BO_DATA_AREA),'</inicio>')),'//nucleo/text()').GETSTRINGVAL()          AS "NUCLEO",
        EXTRACT(XMLTYPE(CONCAT(CONCAT('<inicio>',BO_DATA_AREA),'</inicio>')),'//mercado/text()').GETSTRINGVAL()          AS "MERCADO"
    FROM
        F1_EXT_LOOKUP_VAL   ELVMI
        LEFT JOIN CI_LOOKUP_VAL_L     LVN ON LVN.FIELD_NAME = 'CM_NUCLEO'
                                         AND LVN.LANGUAGE_CD = 'PTB'
                                         AND LVN.FIELD_VALUE = TRIM(EXTRACT(XMLTYPE(CONCAT(CONCAT('<inicio>',BO_DATA_AREA),'</inicio>')),'//nucleo/text()').GETSTRINGVAL())
        LEFT JOIN CI_LOOKUP_VAL_L     VM ON VM.FIELD_NAME = 'CM_MERCADO'
                                        AND VM.LANGUAGE_CD = 'PTB'
                                        AND VM.FIELD_VALUE = TRIM(EXTRACT(XMLTYPE(CONCAT(CONCAT('<inicio>',BO_DATA_AREA),'</inicio>')),'//mercado/text()').GETSTRINGVAL())
        JOIN F1_EXT_LOOKUP_VAL_L ELVMIL ON ELVMIL.F1_EXT_LOOKUP_VALUE = ELVMI.F1_EXT_LOOKUP_VALUE
                                           AND ELVMIL.LANGUAGE_CD = 'PTB'
    WHERE
        ELVMI.BUS_OBJ_CD = 'CM-MicroMercado'
),
CAPE AS (
    SELECT * FROM (
  select cape.per_id , cape.acct_id, row_number () over ( partition by cape.acct_id order by case when cape.acct_rel_type_cd='COND' then 0 else 1 end desc) as rownumber_
                 from ci_acct_per cape) WHERE rownumber_=1
)
SELECT 
    PCUC.SRCH_CHAR_VAL          AS "ID_UC",
    PICOND.PER_ID_NBR           AS "ID_CONDOMINIO",
    CPI.PER_ID_NBR              AS "ERP_MORADOR",
    PNM.ENTITY_NAME             AS "NOME_MORADOR",
    APCONDID.PER_ID_NBR         AS "ERP_CONDOMINIO",
    CNM.ENTITY_NAME             AS "NOME_CONDOMINIO",
    PNFA.ENTITY_NAME            AS "FILIAL",
    MM_NU.MERCADO_NM            AS "MERCADO",

    DECODE(SPCS.SRCH_CHAR_VAL,
        'SUSPEN' ,'SUSPENSO',
        'FECHAD', 'FECHADA',
        'AGUHAB', 'AGUARDANDO HABILITACAO',
        SPCS.SRCH_CHAR_VAL)       AS "STATUS_UC"   ,          

    PGS.VAL                     AS "PRECO_UNITARIO_GAS",
    
    DECODE(FOS.FLAG_GERA_OS_RECORRENTE,
        'SIM', 'Abre OS Recorrente',
        'Nao abre OS Recorrente') AS "CONDOMINIO_OS_RECORRENTE",
       
    SUBSTR(AUC.BILL_CYC_CD, 3, 2)          AS "DIA_FATURAMENTO",
    -- DFAT.DIA_FATURAMENTO,
    CASE
    WHEN CDI.ID_TYPE_CD = 'CNPJ' THEN
    REGEXP_REPLACE(
        CDI.PER_ID_NBR, '(CHR(92)d{2})(CHR(92)d{3})(CHR(92)d{3})(CHR(92)d{4})(CHR(92)d{2})', 'CHR(92)1.CHR(92)2.CHR(92)3/CHR(92)4-CHR(92)5'
    )
    WHEN CDI.ID_TYPE_CD = 'CPF'  THEN
    REGEXP_REPLACE(
        CDI.PER_ID_NBR, '(CHR(92)d{3})(CHR(92)d{3})(CHR(92)d{3})(CHR(92)d{2})', 'CHR(92)1.CHR(92)2.CHR(92)3-CHR(92)4'
    )
    ELSE
    NULL
    END                         AS "DOCUMENTO_CONDOMINIO",
    'SIM'                       AS "UC_MORADOR_ESTA_REGUA",
    CASE
        WHEN AUC.COLL_CL_CD IS NULL THEN 'N?O'
        ELSE 'SIM'
    END                         AS "UC_MOR_ESTA_REGUA_SUSPENSAO",-- campo que indica se o morador est? com a regua ativa ou n?o
    nvl(cpch.char_val,'N')      AS "CLIENTE_VIP",
    APR.BILL_RTE_TYPE_CD        AS "TIPO_REC_DOCUMENTO",
    '''' || SA.SA_ID            AS "NUMERO_CONTRATO",
    NULL                        AS "COBRA_MEDICAO",
    CASE
        WHEN ACP.END_DT IS NULL THEN 'Y'
        ELSE 'N'
    END                         AS "OPTANTE_DEBITO_AUTOMATICO",
    -- -- SA.SA_STATUS_FLG            AS "STATUS_CONTRATO",
    CLV.DESCR                   AS "STATUS_CONTRATO",    
    PCD.CONTACT_VALUE           AS "EMAIL",
    PHN.PHONE                   AS "TELEFONE",
    CPI.PER_ID_NBR              AS "MORADOR_ATUAL",
    PUC.ADDRESS2                AS "MORADOR_LOGRADOURO",
    REGEXP_SUBSTR(
        PUC.ADDRESS2, '[^,]+', 1, 2
    )                           AS "MORADOR_LOG_NUMERO",
    PUC.ADDRESS3                AS "MORADOR_LOG_COMPLEMENTO",
    PUC.ADDRESS4                AS "MORADOR_LOG_BAIRRO",
    PUC.POSTAL                  AS "MORADOR_LOG_CEP",
    PUC.STATE                   AS "MORADOR_LOG_UF",
    PUC.CITY                    AS "MORADOR_LOG_CIDADE",
    TO_CHAR(TO_DATE(CPC.ADHOC_CHAR_VAL, 'YYYY-MM-DD'), 'DD/MM/YYYY') AS "DATA_ANIVERSARIO",

    REPLACE(REPLACE(CSP.CHAR_VAL,'FC',''),'.',',')                AS "FATOR_CONVERSAO_UC",
    TO_CHAR(AUC.SETUP_DT, 'YYYY-MM-DD') AS DATA_CRIACAO_UC,
    PUC.PREM_TYPE_CD            AS "TIPO_UC",
    PUC.ADDRESS1 || ' ' || PUC.CITY || ' ' || PUC.STATE || ' ' || PUC.POSTAL               AS "VALOR_CONTEXTO_BLOCO"
    
FROM
    CI_PREM PCOND
    JOIN CI_PREM         PBLOC ON PBLOC.PRNT_PREM_ID = PCOND.PREM_ID
    JOIN CI_PREM         PUC ON PUC.PRNT_PREM_ID = PBLOC.PREM_ID
    JOIN CI_ACCT         AUC ON AUC.MAILING_PREM_ID = PUC.PREM_ID

    JOIN CI_SA           SA ON SA.ACCT_ID = AUC.ACCT_ID               
                     AND SA.CIS_DIVISION = AUC.CIS_DIVISION
                     AND SA.SA_TYPE_CD LIKE 'G-RES%'
                     AND SA.END_DT IS NULL -- lima SA j? encerrados, evita duplicar onde ja tem um SA ativo.



    JOIN CI_LOOKUP_VAL_L CLV ON SA.SA_STATUS_FLG = CLV.FIELD_VALUE
                     AND FIELD_NAME  = 'SA_STATUS_FLG                 '
                     AND LANGUAGE_CD = 'PTB'
                     /*AND SA.SA_STATUS_FLG IN ( 20, 30, 40, 50 )*/

    LEFT JOIN CI_ACCT_APAY    ACP ON ACP.ACCT_ID = AUC.ACCT_ID
                             AND ACP.END_DT IS NULL      

    LEFT JOIN CI_ACCT_CHAR    ACC ON ACC.ACCT_ID = AUC.ACCT_ID
                                  AND ACC.CHAR_TYPE_CD = 'CM_VIP'

    JOIN CI_SP           SP ON SP.PREM_ID = PUC.PREM_ID
    
    JOIN CI_SP_CHAR      CSP ON CSP.SP_ID = SP.SP_ID
                           AND CSP.CHAR_TYPE_CD = 'CM_CFCAT'          

    JOIN CI_SP_CHAR      SPCS ON SPCS.SP_ID = SP.SP_ID
                            AND SPCS.CHAR_TYPE_CD = 'CM-SPSTA'
    
    
    JOIN CI_ACCT_PER     APR ON APR.ACCT_ID = AUC.ACCT_ID
                            AND APR.MAIN_CUST_SW = 'Y'
    LEFT JOIN CI_PER_ID       CPI ON APR.PER_ID = CPI.PER_ID  
                               AND CPI.ID_TYPE_CD = 'IDCONSSF'

    JOIN CI_PER_NAME     PNM ON APR.PER_ID = PNM.PER_ID
                            AND PNM.PRIM_NAME_SW = 'Y'  
                            
    LEFT JOIN CI_PER_CHAR     CPC ON CPC.PER_ID = APR.PER_ID
                                 AND CPC.CHAR_TYPE_CD = 'C2MBTHDT'

    JOIN CI_ACCT_PER     APC ON APC.ACCT_ID = AUC.ACCT_ID
                                    AND APC.ACCT_REL_TYPE_CD = 'COND'

    LEFT JOIN CI_PER_ID         PICOND ON PICOND.PER_ID = APC.PER_ID
                                    AND PICOND.ID_TYPE_CD = 'CNDMID'
    LEFT JOIN CI_PER_ID           APCONDID ON APCONDID.PER_ID = APC.PER_ID
                                    AND APCONDID.ID_TYPE_CD = 'CONSID'
    
    LEFT JOIN CI_PER_PER      PPCONDFA ON PPCONDFA.PER_ID1 = APC.PER_ID
                            AND PPCONDFA.PER_REL_TYPE_CD = 'ABSTECED'
                            AND PPCONDFA.END_DT IS NULL
    LEFT JOIN CI_PER_NAME   PNFA ON PNFA.PER_ID = PPCONDFA.PER_ID2
                             AND PNFA.PRIM_NAME_SW = 'Y'
    JOIN CI_PER          CDP ON CDP.PER_ID = APC.PER_ID
                       AND CDP.LANGUAGE_CD = 'PTB'
    LEFT JOIN CI_PER_ID       CDI ON CDP.PER_ID = CDI.PER_ID
                               AND CDI.ID_TYPE_CD = 'CNPJ'
    JOIN CI_PER_NAME     CNM ON CDP.PER_ID = CNM.PER_ID
                            AND CNM.PRIM_NAME_SW = 'Y'
    LEFT JOIN (
        SELECT
            PER_ID,
            LISTAGG(DISTINCT CONTACT_VALUE, '; ') WITHIN GROUP(
            ORDER BY
                PER_ID
            ) PHONE
        FROM
            C1_PER_CONTDET
        WHERE
            COMM_RTE_TYPE_CD IN ( 'CELLPHONE', 'HOMEPHONE', 'WORKPHONE' )
        GROUP BY
            PER_ID
    )               PHN ON PHN.PER_ID = APR.PER_ID

    LEFT JOIN C1_PER_CONTDET  PCD ON PCD.PER_ID = APR.PER_ID
                                    AND COMM_RTE_TYPE_CD = 'PRIMARYEMAIL'  

    LEFT JOIN CI_PER_PER      PPCONDCONS ON PPCONDCONS.PER_ID1 = APC.PER_ID
                                       AND PPCONDCONS.PER_REL_TYPE_CD = 'CONSULTO'
                                       AND PPCONDCONS.END_DT IS NULL
    LEFT JOIN CI_PER_CHAR     PCMIC ON PCMIC.PER_ID = PPCONDCONS.PER_ID2
                                   AND PCMIC.CHAR_TYPE_CD = 'CM-MCROM'
    LEFT JOIN MM_NU ON MM_NU.MICROMERCADO_CODE = PCMIC.SRCH_CHAR_VAL

    LEFT JOIN CI_PREM_CHAR    LPG ON LPG.PREM_ID = PUC.PREM_ID
                                  AND LPG.CHAR_TYPE_CD = 'CM-LHEAD'
    LEFT JOIN CI_PREM_CHAR        PCUC ON PCUC.PREM_ID = PUC.PREM_ID
                                   AND PCUC.CHAR_TYPE_CD = 'CM-IDUC'
    LEFT JOIN (
        SELECT
            CV.*
        FROM
            CI_BF_VAL CV
            INNER JOIN (
                SELECT
                    CHAR_VAL,
                    MAX(EFFDT) AS ED
                FROM
                    CI_BF_VAL
                GROUP BY
                    CHAR_VAL
            ) QV ON CV.CHAR_VAL = QV.CHAR_VAL
                    AND CV.EFFDT = QV.ED
    )               PGS ON PGS.CHAR_VAL = LPG.CHAR_VAL
LEFT JOIN (
        SELECT
            PREM_ID,
            CASE
                WHEN QTDE_BIN = ( BIN_INATIVA + BIN_EXPIRADA + BIN_EM_INATIVACAO ) THEN 'NAO'
                WHEN BIN_ATIVA > 0                                                 THEN 'SIM'
                WHEN BIN_IRREGULAR > 0                                             THEN 'SIM'
                WHEN QTDE_BIN = BIN_EM_CONSTRUCAO                                  THEN 'NAO'
                ELSE 'SIM'
            END AS FLAG_GERA_OS_RECORRENTE
        FROM
            (
                SELECT
                    PRM.PREM_ID,
                    SUM(CASE
                            WHEN DSC.ADHOC_CHAR_VAL LIKE 'Em Constru%o' THEN 1
                            ELSE 0
                        END)                                                     AS BIN_EM_CONSTRUCAO,
                    SUM(CASE
                            WHEN DSC.ADHOC_CHAR_VAL LIKE 'Ativa' THEN 1
                            ELSE 0
                        END)                                                     AS BIN_ATIVA,
                    SUM(CASE
                            WHEN DSC.ADHOC_CHAR_VAL LIKE 'Irregular' THEN 1
                            ELSE 0
                        END)                                                     AS BIN_IRREGULAR,
                    SUM(CASE
                            WHEN DSC.ADHOC_CHAR_VAL LIKE 'Em Inativa%o' THEN 1
                            ELSE 0
                        END)                                                     AS BIN_EM_INATIVACAO,
                    SUM(CASE
                            WHEN DSC.ADHOC_CHAR_VAL LIKE 'Inativa' THEN 1
                            ELSE 0
                        END)                                                     AS BIN_INATIVA,
                    SUM(CASE
                            WHEN DSC.ADHOC_CHAR_VAL LIKE 'EXPIRED' THEN 1
                            ELSE 0
                        END)                                                     AS BIN_EXPIRADA,
                    COUNT(*) AS QTDE_BIN
                FROM
                    CI_PREM          PRM
                    LEFT JOIN D1_SP_IDENTIFIER DSI ON PRM.PREM_ID = DSI.ID_VALUE
                                                      AND DSI.SP_ID_TYPE_FLG = 'D1EP'
                    LEFT JOIN D1_SP_CHAR       DSC ON DSI.D1_SP_ID = DSC.D1_SP_ID
                                                AND DSC.CHAR_TYPE_CD = 'CM-SBINS'
                WHERE
                    PRM.PREM_TYPE_CD = 'COND'
                GROUP BY
                    PRM.PREM_ID
            ) FOS
    )               FOS ON FOS.PREM_ID = PCOND.PREM_ID

JOIN CAPE on auc.acct_id=cape.acct_id                

left join ci_per_char cpch on cpch.per_id=cape.per_id and cpch.char_type_cd = 'CM-VIPPE'  and trim(cpch.char_val) = 'Y'

where (TRIM(PICOND.PER_ID_NBR) in (:ID_CONDOMINIO)
          or  'ALL' IN (:ID_CONDOMINIO||'ALL'))  
        and (TRIM(APCONDID.PER_ID_NBR ) in (:ERP_CONDOMINIO)
          or  'ALL' IN (:ERP_CONDOMINIO||'ALL'))  
        and (TRIM(PCUC.SRCH_CHAR_VAL) in (:ID_UC)
          or  'ALL' IN (:ID_UC||'ALL'))  
       and (MM_NU.MERCADO_NM in (:MERCADO)
		or  'ALL' IN (:MERCADO||'ALL')) 
       and (PNFA.ENTITY_NAME in (:FILIAL)
            or  'ALL' IN (:FILIAL||'ALL'))  