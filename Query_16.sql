/*********************************************************************************************************************************/
/* #16 - INDICADORES MI - QTDE TOTAL DE UCS                                                                                      */
/*********************************************************************************************************************************/

with hie as ( select distinct trim(ccvlmm.char_val) as cod_micromercado
                   , ccvlmm.descr as micromercado
                   , regexp_substr(replace(replace(replace(dbms_lob.substr(bo_data_area),'</mercado>',''),'<nucleo>',''),'</nucleo><mercado>','|'),'[^|]+',1,1) as cod_nucleo
                   , vl.descr as nucleo
                   , regexp_substr(replace(replace(replace(dbms_lob.substr(bo_data_area),'</mercado>',''),'<nucleo>',''),'</nucleo><mercado>','|'),'[^|]+',1,2) as cod_mercado
                   , vj.descr as mercado
                   , cast(bo_data_area as varchar2(5000)) as bo_data_area
                from ci_char_val_l ccvlmm
                left join f1_ext_lookup_val felv on trim(ccvlmm.char_val) = felv.f1_ext_lookup_value and felv.bus_obj_cd = 'CM-MicroMercado'
                left join ci_lookup_val_l vl on vl.field_name = 'CM_NUCLEO' and vl.language_cd = 'PTB' 
                 and trim(vl.field_value) = regexp_substr(replace(replace(replace(dbms_lob.substr(bo_data_area),'</mercado>',''),'<nucleo>',''),'</nucleo><mercado>','|'),'[^|]+',1,1) 
                left join ci_lookup_val_l vj on vj.field_name = 'CM_MERCADO' and vj.language_cd = 'PTB' 
                 and trim(vj.field_value) = regexp_substr(replace(replace(replace(dbms_lob.substr(bo_data_area),'</mercado>',''),'<nucleo>',''),'</nucleo><mercado>','|'),'[^|]+',1,2)
               where ccvlmm.char_type_cd = 'CM-MCROM' and ccvlmm.language_cd = 'PTB'
)
,    per as ( select distinct act.mailing_prem_id as prem_id
                   , act.acct_id as acct_id
                   , capm.per_id as per_id_morador , cpnm.entity_name_upr as nome_morador
                   , capc.per_id as per_id_condominio , cpnc.entity_name_upr as nome_condominio
                   , cppa.per_id2 as per_id_filial_abastecedora , cppe.per_id2 as per_id_filial_emissora , cppv.per_id2 as per_id_consultor
                   , cpim4.per_id_nbr as id_consumidor_salesforce
                   , cpic3.per_id_nbr as id_condominio
                   , cpic2.per_id_nbr as cod_cliente_ebs
                   , '<Start.Data>' as tag_start_data
                   , decode ( trim(act.cis_division) , 'DIV1' , 5 , 'DIV2' , 430 , -1 ) as cod_org_id
                   , nvl(cpia1.per_id_nbr,cpie2.per_id_nbr) as cod_organization_id
                   , capm.per_id as cod_customer_id
                   , cpcv.char_val as cod_micromercado
                   , cpiv.per_id_nbr as cod_equipe_venda
                   , regexp_substr(cpic2.per_id_nbr,'[^-]+',1,1) as cod_cliente_erp
                   , regexp_substr(cpic2.per_id_nbr,'[^-]+',1,2) as cod_endereco_erp
                   , substr(nvl(cpia2.per_id_nbr,cpie2.per_id_nbr),1,2) as cod_cia
                   , substr(nvl(cpia2.per_id_nbr,cpie2.per_id_nbr),3,4) as cod_filial
                   , cpcv.char_val as cod_gl_code_segment4
                   , cpnfa.entity_name as nome_filial_abastecedora
                   , cpim1.per_id_nbr as cnpj_morador
                   , cpim2.per_id_nbr as cpf_morador
                   , cpim3.id_type_cd as tipo_documento_morador
                   , hie.mercado
                   , hie.nucleo
                   , hie.micromercado
                   , capm.bill_rte_type_cd as tipo_envio_boleto
                   , cpic1.per_id_nbr as documento_condominio
                   , cpim3.per_id_nbr as documento_morador
                   , case when nvl(capm.bill_addr_srce_flg,capc.bill_addr_srce_flg) = 'ACOV' then cpnc.entity_name_upr || ', ' || cpao.address1 else null end as endereco_correspondencia
                   , '<End.Data>' as tag_end_data
                from 
                          ci_acct act 
                left join ci_acct_per capm on act.acct_id = capm.acct_id and capm.acct_rel_type_cd='MAIN' and capm.main_cust_sw='Y'
                left join ci_acct_per capc on act.acct_id = capc.acct_id and capc.acct_rel_type_cd='COND' 
                left join ci_per_per cppa on capc.per_id = cppa.per_id1 and cppa.per_rel_type_cd = 'ABSTECED' and cppa.end_dt is null
                left join ci_per_per cppe on capc.per_id = cppe.per_id1 and cppe.per_rel_type_cd = 'EMISSORA' and cppe.end_dt is null
                left join ci_per_per cppv on capc.per_id = cppv.per_id1 and cppv.per_rel_type_cd = 'CONSULTO'
                left join ci_per_id cpim1 on cpim1.per_id = nvl(capm.per_id,capc.per_id) and cpim1.id_type_cd = 'CNPJ'
                left join ci_per_id cpim2 on cpim2.per_id = nvl(capm.per_id,capc.per_id) and cpim2.id_type_cd = 'CPF'
                left join ci_per_id cpim3 on cpim3.per_id = nvl(capm.per_id,capc.per_id) and cpim3.id_type_cd IN ('CPF','CNPJ')         
                left join ci_per_id cpim4 on cpim4.per_id = nvl(capm.per_id,capc.per_id) and cpim4.id_type_cd = 'IDCONSSF' --ID do Consumidor Salesforce
                left join ci_per_id cpia1 on cppa.per_id2 = cpia1.per_id and cpia1.id_type_cd = 'FILIALID'
                left join ci_per_id cpia2 on cppa.per_id2 = cpia2.per_id and cpia2.id_type_cd = 'CM-IDCCP'
                left join ci_per_id cpie1 on cppe.per_id2 = cpie1.per_id and cpie1.id_type_cd = 'FILIALID'
                left join ci_per_id cpie2 on cppe.per_id2 = cpie2.per_id and cpie2.id_type_cd = 'CM-IDCCP'
                left join ci_per_id cpiv on cppv.per_id2 = cpiv.per_id and cpiv.id_type_cd = 'IDCON'
                left join ci_per_name cpnm on cpnm.per_id = nvl(capm.per_id,capc.per_id) and cpnm.prim_name_sw = 'Y'
                left join ci_per_name cpnc on capc.per_id = cpnc.per_id and cpnc.prim_name_sw = 'Y'
                left join ci_per_name cpnfa on cppa.per_id2 = cpnfa.per_id and cpnfa.prim_name_sw='Y'    
                left join ci_per_id cpic1 on cpic1.per_id = capc.per_id and cpic1.id_type_cd IN ('CPF','CNPJ')         
                left join ci_per_id cpic2 on cpic2.per_id = capc.per_id and cpic2.id_type_cd = 'CONSID' --Codigo do Cliente no Oracle EBS
                left join ci_per_id cpic3 on cpic3.per_id = capc.per_id and cpic3.id_type_cd = 'CNDMID' --ID do Condominio
                left join ci_per_char cpcv on cpcv.per_id = cppv.per_id2 and cpcv.char_type_cd = 'CM-MCROM' --Micromercado do Consultor
                left join hie hie on trim(cpcv.char_val) = hie.cod_micromercado
                left join ci_per_addr_ovrd cpao on cpao.acct_id = act.acct_id and cpao.per_id = nvl(capm.per_id,capc.per_id)
)
,    msr as ( select e.d1_sp_id 
                   , m.msrmt_local_dttm
                   , to_char ( m.reading_val , '999G999G990D000' , 'NLS_NUMERIC_CHARACTERS = '',.''' ) as rv
                   , m.reading_val org
                   , f.id_value 
                   , row_number () over ( partition by e.d1_sp_id order by m.msrmt_local_dttm desc ) as rn
                from d1_install_evt e
               inner join d1_dvc_cfg g on e.device_config_id = g.device_config_id
               inner join d1_measr_comp c on g.device_config_id = c.device_config_id
               inner join d1_dvc_identifier f on g.d1_device_id = f.d1_device_id and f.dvc_id_type_flg='D1SN'
               inner join d1_msrmt m on c.measr_comp_id = m.measr_comp_id
               order by e.d1_sp_id , m.msrmt_local_dttm desc
)
,    bsr as ( select d1_sp_id 
                   , max ( case when rn = 1 then msrmt_local_dttm else null end ) as data_leitura 
                   , max ( case when rn = 1 then rv else null end ) as leitura_atual
                   , max ( case when rn = 2 then rv else null end ) as leitura_os_menos_1
                   , max ( case when rn = 3 then rv else null end ) as leitura_os_menos_2
                   , max ( case when rn = 4 then rv else null end ) as leitura_os_menos_3
                   , max ( case when rn = 5 then rv else null end ) as leitura_os_menos_4
                   , max ( case when rn = 6 then rv else null end ) as leitura_os_menos_5
                   , max ( case when rn = 7 then rv else null end ) as leitura_os_menos_6
                   , max ( case when rn = 1 then id_value else null end ) as numero_medidor_uc
                from msr
               where rn < 8
               group by d1_sp_id
)
,    lpc as ( select pc.prem_id , bv.* , bc.intv_pf_ext_id as listname_lp
                   , nvl(lag(bv.effdt,1,null) over (partition by pc.prem_id , bv.char_type_cd , bv.char_val order by bv.effdt desc),sysdate) as end_effdt
                from ci_prem_char pc 
               inner join ci_bf_val bv on bv.char_type_cd = pc.char_type_cd and pc.char_val=bv.char_val
               inner join ci_bf_char bc on bv.bf_cd = bc.bf_cd and trim(bc.char_val) = trim(bv.char_val)
            )

-- O conte?do completo do arquivo foi truncado para evitar problemas de tamanho na chamada. --