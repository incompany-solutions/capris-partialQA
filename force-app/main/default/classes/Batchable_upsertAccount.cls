/**
 * @description       : 
 * @author            : ???
 * @group             : 
 * @last modified on  : 21-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public class Batchable_upsertAccount implements Database.Batchable<DeserializeJSONAccount.AccountMainList>, Database.Stateful{
    public List<DeserializeJSONAccount.AccountMainList> accmainList;
    
    public List<DeserializeJSONAccount.AccountMainList> start(Database.BatchableContext context) {
        return accmainList;
    }
    
    public void execute(Database.BatchableContext context, List<DeserializeJSONAccount.AccountMainList> scope) {
        List<Account> AccountLst = new List<Account>();
        List<Account> ParentLst = new List<Account>();
        Integer Counter1 = - 1;
        Integer Counter2 = - 1;
        Map<Integer, String> CounterMap = new Map<Integer, String>();
        String OrgId;
        
        Map<String, String> pickListValuesList = new Map<String, String> ();
        Schema.DescribeFieldResult fieldResult = Account.zonaCanton__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.put(pickListVal.getLabel().left(3), pickListVal.getLabel());
        }
        
        for (DeserializeJSONAccount.AccountMainList wrap : scope) {
            Account acc = new Account();
            acc.num_cliente__c = wrap.codCliente;
            acc.org_id__c = wrap.org;
            acc.baja__c = wrap.estado;
            acc.Name = wrap.razonSocial;
            acc.razon_social__c = wrap.razonSocial;
            acc.cedula__c = wrap.cedula;
            acc.ced_juridica__c = wrap.cedula;
            acc.tipo_cliente__c = wrap.tipocli;
            acc.observaciones__c = wrap.observaciones;
            acc.Website = wrap.sitioWeb;
            acc.C_digo_de_Pa_s__c = 'CRI';
            acc.provincia__c = wrap.provincia;
            acc.zonaCanton__c = pickListValuesList.get(wrap.canton);
            acc.forma_pago__c = Double.valueOf(wrap.porcExoIva);
            acc.merc_usu_modifica__c = wrap.usuModifica;
            acc.merc_fyh_modifica__c = wrap.fyhModifica != '' ? Datetime.valueOf(wrap.fyhModifica) : null;
            acc.mcl_hor_entr__c = wrap.horaEntrega;
            acc.mcl_obs_entr__c = wrap.obsEntrega;
            acc.sucursal_vendedor__c = wrap.reqOc;
            acc.mcl_roc_entr__c = wrap.reqOcEntrega;
            acc.ruta__c = wrap.rutaCobro;
            acc.limit_credit__c = Double.valueOf(wrap.limiteCredito);
            acc.dias_tramit_cob__c = wrap.diaTramite;
            acc.cod_cobrador__c = wrap.cobradorCxc;
            if (wrap.fyhIngreso != '') {
                acc.fecha_ing__c = Datetime.valueOf(wrap.fyhIngreso);
            }
            acc.plazo_credito__c = wrap.plazoCxc;
            acc.mcl_nombre1__c = wrap.nombre1;
            acc.mcl_nombre2__c = wrap.nombre2;
            acc.mcl_apellido1__c = wrap.apellido1;
            acc.mcl_apellido2__c = wrap.apellido2;
            acc.mcl_usu_ing__c = wrap.usuIngreso;
            acc.mcl_env_email__c = Boolean.valueOf(wrap.envEmail);
            acc.mcl_env_sms__c = Boolean.valueOf(wrap.envSms);
            acc.mcl_fec_nac__c = wrap.fyhNacimiento!=''?Date.valueOf(wrap.fyhNacimiento):null;
            acc.mcl_id_puesto__c = wrap.idPuesto;
            acc.mcl_plazo_tec__c = wrap.plazoTec;
            acc.mcl_cob_tec__c = wrap.cobradorTec;
            acc.C_digo_de_Vendedor__c = wrap.vendedor;
            acc.Direccion_Entrega__c = wrap.direccion;
            acc.Direccion_Comercial__c = wrap.dirComercial;
            acc.mcl_origen__c = wrap.origen;
            acc.mcl_excep_trans__c = Boolean.valueOf(wrap.excepTrans);
            acc.mcl_ind_mixto__c = Boolean.valueOf(wrap.indMixto);
            acc.abcDelCliente__c = wrap.claCli;
            acc.Id_Capris__c = wrap.org + '-' + wrap.codCliente;
            acc.Maestra__c = false;
            acc.cod_ciiu_principal__c = wrap.codigoPrincipal;
            acc.desc_ciiu__c = wrap.descripcionCIIU;
            acc.cod_gerencia__c = wrap.SEM;
            
            OrgId = wrap.org;
            
            
            if (wrap.org == 'CAP') {
                if (wrap.cedula.length() == 9) {
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Técnica Físico').getRecordTypeId();
                }
                else {
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Técnica Jurídico').getRecordTypeId();
                }
            }
            if (wrap.org == 'MED') {
                if (wrap.cedula.length() == 9) {
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Médica Físico').getRecordTypeId();
                }
                else {
                    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Médica Jurídico').getRecordTypeId();
                }
            }
            
            Counter1 = Counter1 + 1;
            CounterMap.put(Counter1, wrap.org + '-' + wrap.codCliente);
            
            Account accm = new Account();
            accm.Name = wrap.razonSocial;
            accm.Id_Capris__c = 'M-' + wrap.codCliente;
            accm.Maestra__c = true;
            accm.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta Maestra').getRecordTypeId();
            
            ParentLst.add(accm);
            
            Account parent = new Account(Id_Capris__c = 'M-' + wrap.codCliente);
            acc.Parent = parent;
            
            AccountLst.add(acc);
        }
        
        Schema.SObjectField f = Account.Fields.Id_Capris__c;
        if(Test.isRunningTest() == false) {
            Database.UpsertResult[] saveResultListParent = Database.upsert(ParentLst, f, true);
            Database.UpsertResult[] saveResultList = Database.upsert(AccountLst, f, true);
        }
    }
    
    public void finish(Database.BatchableContext context) {
        
    }
    
}