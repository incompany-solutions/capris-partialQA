/**
 * @description       : 
 * @author            : ???
 * @group             : 
 * @last modified on  : 21-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
private class WebServiceAccountTest {
    
    @isTest
    static void testHttpPost() {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WebServiceAccount'; //Request URL
        req.httpMethod = 'POST';
        
        String requestBody = WebServiceAccountData.getAccountJSON();//'{"AccountMainList":[{"codCliente":"3030996","org":"CAP","nombreFantasia":"TOMASFEDERICO OBANDO","direccion":"Test","estado":"CONTADO","razonSocial":"TOMASFEDERICO OBANDO","canton":"303","cedula":"303680453","tipocli":"CONSUMIDOR","reqOc":"NO","observaciones":"Cliente creado desde el sitio web","sitioWeb":"Tomas.obando@gmail.com","provincia":"3","porcExoIva":"null","usuModifica":"null","fyhModifica":"null","horaEntrega":"null","obsEntrega":"null","reqOcEntrega":"null","reqFacEntrega":"null","rutaCobro":"null","limiteCredito":"null","diaTramite":"null","cobradorCxc":"-","fyhIngreso":"1585243203","plazoCxc":"-","nombre1":"TOMASFEDERICO","nombre2":"null","apellido1":"OBANDO","apellido2":"OBANDO","usuIngreso":"CRONOS","envEmail":"S","envSms":"S","fyhNacimiento":"null","idPuesto":"null","plazoTec":"-","cobradorTec":"-","region":"null","zona":"null","dirComercial":"CR - La Una","origen":"S","excepTrans":"null","indMixto":"null","fyhVenLetc":"null","claCli":"null","vendedor":"N/A","idSalesforce":"null"}]}}';
        
        RestContext.request = req;
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        RestContext.response= res;
        
        Test.startTest();
        String actual = null;//HttpClass.updateCustomObject();
        WebServiceAccount.getResponsePOST();
        Test.stopTest();
    }
    
    
    // @isTest
    // static void testHttpPost2() {
        
    //     RestRequest req = new RestRequest();
    //     RestResponse res = new RestResponse();
    //     req.requestURI = '/services/apexrest/WebServiceAccount'; //Request URL
    //     req.httpMethod = 'POST';
        
    //     DateTime dt = DateTime.newInstance(2007, 6, 23, 3, 3, 3);
    //     //Long gettime = dt.getTime();
        
    //     DeserializeJSONAccount.AccountMainList   objdata = new DeserializeJSONAccount.AccountMainList();
    //     objdata.porcExoIva = '1.1';
    //     objdata.fyhModifica = String.valueOf(dt);//String.valueof(gettime );
    //     objdata.reqOcEntrega = 'true';
    //     objdata.limiteCredito = '1.1';
    //     objdata.envSms = 'true';
    //     objdata.fyhNacimiento = String.valueOf(Date.today());//String.valueof(gettime );
    //     objdata.excepTrans = 'true';
    //     objdata.indMixto = 'true';
    //     objdata.excepTrans = 'true';
    //     objdata.envSms = 'true';
    //     objdata.envEmail = 'true';
        
    //     objdata.fyhIngreso= String.valueOf(dt);//String.valueof(gettime );
        
    //     DeserializeJSONAccount.DeserializeJSON objdata1 = new DeserializeJSONAccount.DeserializeJSON ();
    //     objdata1.AccountMainList = new List<DeserializeJSONAccount.AccountMainList >();
        
    //     objdata1.AccountMainList.add(objdata);
        
    //     RestContext.request = req;
    //     RestContext.request.requestBody = Blob.valueof(JSON.serialize(objdata1));
        
        
    //     RestContext.request = req;
    //     RestContext.request.requestBody = Blob.valueof(JSON.serialize(objdata1 ));
    //     RestContext.response= res;
        
    //     Test.startTest();
    //     String actual = null;//HttpClass.updateCustomObject();
    //     WebServiceAccount.getResponsePOST();
    //     Test.stopTest();
    // }
}