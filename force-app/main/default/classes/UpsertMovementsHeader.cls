/**
 * @description       : 
 * @author            : ???
 * @group             : 
 * @last modified on  : 13-04-2023
 * @last modified by  : esteban@incompany.cr
**/
public class UpsertMovementsHeader {

    public static DeserializeJSONMovementsHeader.DeserializeJSON resultwrap { get; set; }

    public static string doUpsert(String jsonStr) {

        resultwrap = DeserializeJSONMovementsHeader.parse(jsonStr);
        List<Encabezado__c> MovementHeaderLst = new List<Encabezado__c> ();
        List<Opportunity> OpportunityLst = new List<Opportunity> ();
        Integer Counter1 = - 1;
        Integer Counter2 = - 1;
        Map<Integer, String> CounterMap = new Map<Integer, String> ();
        Map<String, String> CounterMapOpp = new Map<String, String> ();
        Set<Id> OpportunityIds = new Set<Id> ();

        Map<String, String> userMap = new Map<String, String>();
        for(User us : [SELECT Id,Usuario_Base_de_Datos__c FROM User WHERE IsActive = true]){
            userMap.put(us.Usuario_Base_de_Datos__c,us.Id);
        }
        
        List<Account> aList = [SELECT Id, Id_Capris__c 
                               FROM Account 
                               WHERE Id_Capris__c =: MovementHeaderSettings__mdt.getInstance('Cuenta_Inexistente').Default_Account_Name__c];
        
        List<Opportunity> oppList = [SELECT Id, Id_Capris__c 
                                     FROM Opportunity 
                                     WHERE Id_Capris__c =: MovementHeaderSettings__mdt.getInstance('Cuenta_Inexistente').Default_Account_Name__c];
        
        List<Encabezado__c> eList = [SELECT Id, Id_Capris__c 
                                     FROM Encabezado__c 
                                     WHERE Id_Capris__c =: MovementHeaderSettings__mdt.getInstance('Cuenta_Inexistente').Default_Account_Name__c];
        
        Set<String> caprisIdSet = new Set<String>();
        Set<String> oppIdSet = new Set<String>();
        Set<String> encabezadoCaprisIdSet = new Set<String>();
        for (DeserializeJSONMovementsHeader.MovementsHeaderMainList wrap : resultwrap.MovementsHeaderMainList)
        {
            caprisIdSet.add(wrap.emvCodOrg + '-' + wrap.emvNumCliente);
            oppIdSet.add(wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento);
            encabezadoCaprisIdSet.add(wrap.emvEmvCodOrg + '-' + wrap.emvEmvTipoMov + '-' + wrap.emvEmvCodPuntoFact + '-' + wrap.emvEmvNumDocumento);
        }
        
        Map<String, Account> accountMap = new Map<String, Account>();
        Map<String, Opportunity> opportunityMap = new Map<String, Opportunity>();
        Map<String, Encabezado__c> encabezadoMap = new Map<String, Encabezado__c>();
        
        for(Account acc : [SELECT Id, Id_Capris__c FROM Account WHERE Id_Capris__c in : caprisIdSet])
        {
            accountMap.put(acc.Id_Capris__c, acc);
        }
        
        for(Opportunity opp : [SELECT Id, Id_Capris__c FROM Opportunity WHERE Id_Capris__c in : oppIdSet])
        {
            opportunityMap.put(opp.Id_Capris__c, opp);
        }
        
        for(Encabezado__c enc : [SELECT Id, Id_Capris__c FROM Encabezado__c WHERE Id_Capris__c in : encabezadoCaprisIdSet])
        {
            encabezadoMap.put(enc.Id_Capris__c, enc);
        }
        
        for (DeserializeJSONMovementsHeader.MovementsHeaderMainList wrap : resultwrap.MovementsHeaderMainList) {
            Encabezado__c encabezado = new Encabezado__c();
            encabezado.EMV_COD_ORG__c = wrap.emvCodOrg;
            encabezado.EMV_TIPO_MOV__c = wrap.emvTipoMov;
            encabezado.EMV_COD_PUNTO_FACT__c = wrap.emvCodPuntoFact;
            encabezado.EMV_NUM_DOCUMENTO__c = wrap.emvNumDocumento;
            //encabezado.EMV_FEC_MOVIMIENTO__c = wrap.envFecMovimiento;
            encabezado.Name = wrap.emvTipoMov + ' ' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento;
            encabezado.EMV_NUM_CLIENTE__c = wrap.emvNumCliente;

            //Validar el Null
            encabezado.EMV_NOM_CLIENTE__c = ' ';
            if (wrap.emvNomCliente != 'null') {
                encabezado.EMV_NOM_CLIENTE__c = wrap.emvNomCliente;
            }

            //Validar el Null
            encabezado.EMV_PLAZO_DOC__c = ' ';
            if (wrap.emvPlazoDoc != 'null') {
                encabezado.EMV_PLAZO_DOC__c = wrap.emvPlazoDoc;
            }
            
            encabezado.EMV_COD_USUARIO_VEND__c = wrap.emvCodUsuarioVend;
            encabezado.EMV_COD_MONEDA__c = wrap.emvCodMoneda;
            encabezado.CurrencyIsoCode = wrap.emvCodMoneda;
            encabezado.EMV_TIP_CAMBIO__c = Double.valueOf(wrap.emvTipCambio.replace(',', '.'));
            encabezado.EMV_ESTADO_DOC__c = wrap.emvEstadoDoc;
            encabezado.EMV_VIA__c = wrap.emvVia;
            encabezado.Total_de_Descuento__c = Double.valueOf(wrap.emvTipCambio.replace(',', '.'))!=0?Double.valueOf(wrap.emvMonDescuento.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.')):Double.valueOf(wrap.emvMonDescuento.replace(',', '.'));
            encabezado.Total_de_Impuesto__c =  Double.valueOf(wrap.emvTipCambio.replace(',', '.'))!=0?Double.valueOf(wrap.emvMonIVA.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.')):Double.valueOf(wrap.emvMonIVA.replace(',', '.'));
            encabezado.Subtotal__c =  Double.valueOf(wrap.emvTipCambio.replace(',', '.'))!=0?Double.valueOf(wrap.emvMonTotal.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.')):Double.valueOf(wrap.emvMonTotal.replace(',', '.'));
            encabezado.EMV_MON_RECARGO__c =  Double.valueOf(wrap.emvTipCambio.replace(',', '.'))!=0?Double.valueOf(wrap.emvMonRecargo.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.')):Double.valueOf(wrap.emvMonRecargo.replace(',', '.'));
            encabezado.EMV_USU_MODIFICA__c = wrap.emvUsuModifica;
            encabezado.EMV_FEC_MOVIMIENTO__c = Date.valueOf(Datetime.newInstance(LONG.valueOf(wrap.emvFecMovimiento) * 1000));
            encabezado.EMV_FYH_MODIFICA__c = Datetime.newInstance(LONG.valueOf(wrap.emvFyhModifica));
            encabezado.EMV_OBSERV_IMPRESA__c = wrap.emvObservImpresa;
            encabezado.EMV_OBSERV_INTERNA__c = wrap.emvObservInterna;
            encabezado.EMV_OBS_ADD__c = wrap.emvObsAdd;

            //Validar el Null
            encabezado.EMV_MUELLE__c = ' ';
            if (wrap.emvMuelle != 'null') {
                encabezado.EMV_MUELLE__c = wrap.emvMuelle;
            }

            encabezado.EMV_IDTARJ__c = wrap.emvIdTarj;
            encabezado.Orden_Compra__c = wrap.ordenCompra;

            //Validar el Null
            encabezado.EMV_CODURE__c = ' ';
            if (wrap.emvCodure != 'null') {
                encabezado.EMV_CODURE__c = wrap.emvCodure;
            }

             Account acc = new Account();
            encabezado.Cliente__c = '00174000003nleYAAQ';
            if (accountMap.containsKey(wrap.emvCodOrg + '-' + wrap.emvNumCliente)){
                acc = accountMap.get(wrap.emvCodOrg + '-' + wrap.emvNumCliente);
               encabezado.Cliente__c = '00174000003nleYAAQ';//acc.Id; 
            }
            else{
                if (aList.size() > 0){
                	acc = aList[0];
                }    
            }

            
            //Account accSoportet = new Account(Id_Capris__c = 'Cuenta-inexistente');
            
            /*if(wrap.emvCodOrg == null || wrap.emvNumCliente == null)
            {
                if(aList.size() > 0) encabezado.Cliente__c = aList[0].Id;
            }
            else
            {
                encabezado.Cliente__r = acc; 
            }*/
            
            

            if ((wrap.emvTipoMov == 'PROFORMA' || wrap.emvTipoMov == 'COT') && encabezado.Subtotal__c > 500000) {
                if (wrap.emvEstadoDoc == 'PEND' || wrap.emvEstadoDoc == 'IMP') {
                    Opportunity opp = new Opportunity();
                    opp.Name = 'OPORTUNIDAD ' + wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento;
                    opp.CloseDate = System.today().addMonths(1);
                    opp.Id_Capris__c = wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento;
                    opp.StageName = 'Nueva';
                    
                    //
                    //Paso 3: Validación para cambiar o no el stagename.
                    //
                    //if (opp.StageName == null) {
                    //  opp.StageName = 'Nueva';
                    //}

                    //
                    //Paso 4: se le asigna el usuario a la oportnidad, tener el cuenta que el usuario debe de estar creado
                    //
                    //Id usu = [select Id, Name FROM User WHERE Alias =: wrap.emvUsuModifica].Id;
                    if (userMap.get(wrap.emvUsuModifica) != null){
                        opp.OwnerId = userMap.get(wrap.emvUsuModifica);
                    } 
                    
                    opp.EMV_VIA__c = wrap.emvVia;
                    opp.AccountId = acc.Id; //acc != null ? acc : accSoportet;
                    opp.CurrencyIsoCode = wrap.emvCodMoneda;
                    opp.Subtotal__c = Double.valueOf(wrap.emvMonTotal.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.'));
                    opp.totalDescuento__c = Double.valueOf(wrap.emvMonDescuento.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.'));
                    opp.totalImpuesto__c = Double.valueOf(wrap.emvMonIVA.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.'));
                    opp.EMV_MON_RECARGO__c = Double.valueOf(wrap.emvMonRecargo.replace(',', '.')) / Double.valueOf(wrap.emvTipCambio.replace(',', '.'));
                    opp.EMV_COD_USUARIO_VEND__c = wrap.emvCodUsuarioVend;
                    if (wrap.emvFecEnt != 'null') {
                        opp.EMV_FEC_ENT__c = Date.valueOf(Datetime.newInstance(LONG.valueOf(wrap.emvFecEnt)));
                    }
                    opp.NumeroDocumento__c = wrap.emvNumDocumento;

                    opp.Fecha_Movimiento__c = Date.valueOf(Datetime.newInstance(LONG.valueOf(wrap.emvFecMovimiento) * 1000));

                    String ven = wrap.emvCodUsuarioVend;
                    String first = ven.substring(0,1);
                    System.debug('el primer digito del vendedor: ' + first);
                    //if (!Test.isRunningTest()) {
                        if (wrap.emvCodOrg == 'CAP') {
                            if (first == '5') {
                                if (encabezado.Subtotal__c > 1000000) {
                                    opp.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Licitación Técnica').getRecordTypeId();
                                }
                            } else {
                                opp.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Técnica').getRecordTypeId();
                            }
                        }
                        if (wrap.emvCodOrg == 'MED') {
                            opp.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Médica').getRecordTypeId();
                        }
                        if (wrap.emvTipoMov == 'COT') {
                            if (first == '5') {
                                if (encabezado.Subtotal__c > 1000000) {
                                    opp.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Licitación Técnica').getRecordTypeId();
                                }                           
                            } else {
                                opp.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('OpportunityTécnica').getRecordTypeId();
                            }
                        }
                    //}
                    OpportunityLst.add(opp);

                    /*Opportunity o = new Opportunity(Id_Capris__c = wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento);
                    
                    if(wrap.emvCodOrg == null || 
                       wrap.emvTipoMov == null || 
                       wrap.emvCodPuntoFact == null || 
                       wrap.emvNumDocumento == null)
                    {
                        if(oppList.size() > 0) o = oppList[0];
                    }*/
                    
                    if(opportunityMap.containskey(wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento))
                        encabezado.Oportunidad__c = opportunityMap.get(wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento).Id;
                    else
                        if(oppList.size() > 0){
                        	encabezado.Oportunidad__c = oppList[0].Id;
                        }    
                        
                    //encabezado.Oportunidad__r = o;
                }
            }
            
            //Validar el Null
            if (wrap.numguia != 'null') {
                encabezado.NumeroGuia__c = wrap.numguia;
            } else {
                encabezado.NumeroGuia__c = ' ';
            }

            if (wrap.emvFecEnt != 'null') {
                encabezado.EMV_FEC_ENT__c = Date.valueOf(Datetime.newInstance(LONG.valueOf(wrap.emvFecEnt) * 1000));
            }
            encabezado.SaldoTotal__c = Double.valueOf(wrap.saldo.replace(',', '.'));
            encabezado.SaldoVencido__c = Double.valueOf(wrap.saldoVencido.replace(',', '.'));
            encabezado.ID_Capris__c = wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento;

            /*if (wrap.emvEmvCodOrg != 'null') {
                Encabezado__c ped = new Encabezado__c(ID_Capris__c = wrap.emvEmvCodOrg + '-' + wrap.emvEmvTipoMov + '-' + wrap.emvEmvCodPuntoFact + '-' + wrap.emvEmvNumDocumento);
                
                if(wrap.emvEmvCodOrg == null || 
                   wrap.emvEmvTipoMov == null || 
                   wrap.emvEmvCodPuntoFact == null || 
                   wrap.emvEmvNumDocumento == null)
                {
                    if(eList.size() > 0) ped = eList[0];
                }
                
                //if (ped != null) {
                encabezado.PedidoOrigen__r = ped;
                //}
            }*/
            
            if(encabezadoMap.containskey(wrap.emvEmvCodOrg + '-' + wrap.emvEmvTipoMov + '-' + wrap.emvEmvCodPuntoFact + '-' + wrap.emvEmvNumDocumento))
                encabezado.PedidoOrigen__c = encabezadoMap.get(wrap.emvEmvCodOrg + '-' + wrap.emvEmvTipoMov + '-' + wrap.emvEmvCodPuntoFact + '-' + wrap.emvEmvNumDocumento).Id;
            else
                if (eList.size() > 0){
                	encabezado.PedidoOrigen__c = eList[0].Id;
               	}
                
            Counter1 = Counter1 + 1;
            CounterMap.put(Counter1, wrap.emvCodOrg + '-' + wrap.emvTipoMov + '-' + wrap.emvCodPuntoFact + '-' + wrap.emvNumDocumento);

            MovementHeaderLst.add(encabezado);
        }

        Schema.SObjectField h = Opportunity.Fields.Id_Capris__c;
        system.debug('Oportunidades a actualizar: '+OpportunityLst);
       	Database.UpsertResult []  resu =  DataBase.Upsert(OpportunityLst,h,false);
        //upsert OpportunityLst Id_Capris__c;

        System.debug(OpportunityLst);
        for (Opportunity opp : OpportunityLst) {
            CounterMapOpp.put(opp.Id_Capris__c, opp.Id);
        }

        Schema.SObjectField f = Encabezado__c.Fields.Id_Capris__c;
        Database.UpsertResult[] saveResultList = Database.upsert(MovementHeaderLst, f, false);
        //upsert MovementHeaderLst Id_Capris__c;
        System.debug('MovementHeaderLst ::::::' + MovementHeaderLst[0].Id);

        // List<WebServiceLog__c> lerrors = new List<WebServiceLog__c> ();
        
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('ResponseMainList');
        gen.writeStartArray();
        for (Database.UpsertResult res : saveResultList) {
            Counter2 = Counter2 + 1;
            if (res.isSuccess()) {
                gen.writeStartObject();
                gen.writeStringField('codOrg', CounterMap.get(Counter2).split('-') [0]);
                gen.writeStringField('tipoMov', CounterMap.get(Counter2).split('-') [1]);
                gen.writeStringField('codPuntoFact', CounterMap.get(Counter2).split('-') [2]);
                gen.writeStringField('numDocum', CounterMap.get(Counter2).split('-') [3]);
                gen.writeStringField('idOport', ValidateNull.doValidation(CounterMapOpp.get(CounterMap.get(Counter2))) != '' ? ValidateNull.doValidation(CounterMapOpp.get(CounterMap.get(Counter2))) : 'null');
                gen.writeStringField('status', 'Se procesó correctamente el registro');
                gen.writeEndObject();
            } else {
                For (Database.Error e : res.getErrors()) {
                    OpportunityIds.add(CounterMapOpp.get(CounterMap.get(Counter2)));
                    System.debug('e ::::::' + e.getMessage());
                    //System.debug(CounterMap.get(Counter2));
                    gen.writeStartObject();
                    gen.writeStringField('codOrg', CounterMap.get(Counter2).split('-') [0]);
                    gen.writeStringField('tipoMov', CounterMap.get(Counter2).split('-') [1]);
                    gen.writeStringField('codPuntoFact', CounterMap.get(Counter2).split('-') [2]);
                    gen.writeStringField('numDocum', CounterMap.get(Counter2).split('-') [3]);
                    gen.writeNullField('idOport');
                    gen.writeStringField('status', 'Error al procesar el registro ' + e.getMessage());
                    gen.writeEndObject();
                    
                    //  WebServiceLog__c log = new WebServiceLog__c();
                    // log.Web_Services__c='Movimientos';
                    // log.ErrorDetail__c = 'codOrg=' + CounterMap.get(Counter2).split('-') [0] + ' --tipoMov=' + CounterMap.get(Counter2).split('-') [1] + ' --codPuntoFact=' + CounterMap.get(Counter2).split('-') [2] + ' --numDocum=' + CounterMap.get(Counter2).split('-') [3] + ' --- ' + e.getMessage() + '\nStatus Code : '+e.getStatusCode();
                    // log.hasErrors__c = true;
                    // lerrors.add(log);
                }
            }
        }

        Delete[Select Id FROM Opportunity WHERE Id IN : OpportunityIds];

        gen.writeEndArray();
        gen.writeEndObject();

        //  if (lerrors.size() > 0){
        //     insert lerrors;
        // }
        
        return gen.getAsString();
    }
}