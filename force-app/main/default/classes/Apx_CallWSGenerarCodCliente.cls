public class Apx_CallWSGenerarCodCliente {
    @future(callout = true)
    public static void getCodCliente(String comp, String acId) {
        String codigo = '';
        try {
            // build callout
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            system.debug('name=:acId ' + acId);
            
            id RT_SubCuenta = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sub Cuenta').getRecordTypeId();
            system.debug('RT_SubCuenta getCodCliente * ' + RT_SubCuenta);
            
            Account ac2 = [Select id, Zona_o_Distrito_Sub_Cuentas__c, recordtypeid from Account where name = :acId and recordtypeid =:RT_SubCuenta];
            system.debug('cuenta zona ' + ac2.Zona_o_Distrito_Sub_Cuentas__c);
            
            if(ac2.Zona_o_Distrito_Sub_Cuentas__c!=null&&ac2.Zona_o_Distrito_Sub_Cuentas__c!=''){
                String zona = ac2.Zona_o_Distrito_Sub_Cuentas__c;
                String[] zonaspl = zona.split('-');
                system.debug('zona ' + zonaspl[0]);
                if (zonaspl.size() > 0) {
                    zona = zonaspl[0];
                }
                req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_CodigoCliente/webresources/cliente/getCodCli/' + comp + '-' + zona);
                req.setMethod('GET');
                req.setTimeout(60000);
                system.debug('WS ' + 'http://bd2.capris.cr:64423/Salesforce_CodigoCliente/webresources/cliente/getCodCli/' + comp + '-' + zona);
    
                // callout
                HttpResponse res = h.send(req);
    
                system.debug('WS ' + res.getBody());
                Dom.Document doc = res.getBodyDocument();
                DOM.XMLNode root = doc.getRootElement();
    
    
                if ((root.getChildElement('cliente', null).getChildElement('org', null).getText()) != 'null') {
                    codigo = root.getChildElement('cliente', null).getChildElement('org', null).getText(); //1
                    system.debug('asignacion codigo ' + codigo);
                }
                system.debug('filtro ced ' + acId);
                Account ac = [Select id, name, num_cliente__c from Account where name = :acId];
                if (ac != null) {
                    ac.num_cliente__c = codigo;
                    system.debug('asignacion codigo ' + ac.num_cliente__c);
                    system.debug('a cuenta ' + ac.num_cliente__c);
                }
                update ac;          
            }

            
            
        } catch(Exception e) {
            system.debug('Error ' + e.getMessage() + '- Line number ' + e.getLineNumber());
        }

    }


}