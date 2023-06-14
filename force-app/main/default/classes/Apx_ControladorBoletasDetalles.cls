public class Apx_ControladorBoletasDetalles {
    public static Boletas__c boletas{get;set;}
    public static List<Boletas__c> boletaList{get;set;}
    public static List<Boletas__c> blta{get;set;}
    public static String numBoletaTitle {set;get;}
    
    public Date dat {get;set;}
    public static List<Map<String,String>> XMLElements{get;set;}
    public static Map<String,string> mapcolRows { get; set;}
    public static List<String> subChildElementsList { get; set; }
    String responseBody;
    public static List<Map<String,String>> rowValues{get;set;}
    
    
    public Apx_ControladorBoletasDetalles(){
       
        //RetrieveArchivedRecords();
    }
    
    public static HttpResponse responseWS(Http http,HttpRequest req){
        HttpResponse res = http.send(req);
        return res;
    }
    
   //call-in de servicio web de capris de consulta de boletas
    public static HttpRequest requestWS(){
     
       HttpRequest req = new HttpRequest();
      try{

        //obtenemos de la subcuenta compania y codigocliente numBoleta=126451&&codCliente=1510255&&codComp=CAP
        String codigoCliente ='';
        String codigoCompania='';
        String numBoleta='';
        codigoCompania = ApexPages.currentPage().getParameters().get('codComp');
        codigoCliente = ApexPages.currentPage().getParameters().get('codCliente');
       
        numBoleta = ApexPages.currentPage().getParameters().get('numBoleta');
        numBoletaTitle=numBoleta;
       
       req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getIdBoleta/'+codigoCompania+'-'+codigoCliente+'-'+numBoleta);
       req.setBody(CredentialHelper.CREDENTIALS);
        req.setMethod('GET');

       // xmlContent=res;           
            
      }catch(Exception e){
           
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'El cliente no posee detalle de boletas para mostrar.'));
      }
        return req;
        
    }
    
    //Recorrero documento xml y cargar datos a objeto
    public static void RetrieveArchivedRecords(HttpResponse res)
     {
          
        String elementValues;
        Integer i;       
        Integer lastcount=0;
        //String childElementName;        
        List<String> elementValuesList = new List<String>();
        List<Dom.XmlNode> childlist = new List<Dom.XmlNode>();
       // Set<String> childelementslist = new Set<String>();
        mapcolRows = new map<String,String>();
        String subChildElementName;
        subChildElementsList = new List<String>();
        rowValues= new List<Map<String,String>>();
       // Map<String, string> mapvalues = new Map<String, string>();
         
        Integer childElementCount =0;
        Integer subChildElementsCount = 0;
        String data=res.getBody();
        //system.debug('Cadena de xml '+responseWS());
       // responsebody = responseWS();//'<queryResult><records><type>Case</type><Id>5009000000C5YKJAA3</Id><CaseNumber>00001026</CaseNumber><ContactId>0039000000NwhLQAAZ</ContactId><AccountId>0019000000X2WtUAAV</AccountId><Type>Electrical</Type><OwnerId>00590000001WkjdAAC</OwnerId><CreatedDate>2013-07-19T11:12:25.000Z</CreatedDate><CreatedById>00590000001WkjdAAC</CreatedById></records><records><type>Case</type><Id>5009000000Dec3SAAR</Id><CaseNumber>00001031</CaseNumber><ContactId>0039000000NwhLVAAZ</ContactId><AccountId>0019000000X2WtUAAV</AccountId><Type>Electrical</Type><OwnerId>00590000001WkjdAAC</OwnerId><CreatedDate>2013-09-23T07:00:13.000Z</CreatedDate><CreatedById>00590000001WkjdAAC</CreatedById></records></queryResult>';
        


        Dom.Document doc = new Dom.Document();
        List<Dom.XmlNode> childelements;
        doc.load(data);
        Dom.XMLNode rootElement = doc.getRootElement();
        String rootElementName = rootElement.getName();
       // system.debug('@@@@@'+rootElementName);
      //  List<Dom.XmlNode> childelement = rootElement.getChildElements();
        for(Dom.XmlNode childelement : rootElement.getChildElements())
        
        {
             
              childlist.add(childelement);
            //childElementName =  childelement.getName();
            //childelementslist.add(childElementName);
            childElementCount++;
            //System.debug('Child element : ' +childElementCount +' ' + childelement);
            
            
        }
        
        for (Dom.XmlNode subchildelement:childlist[0].getChildElements())
            {
                subChildElementName = subchildelement.getName();
                subChildElementsList.add(subChildElementName);
                elementValues = subchildelement.getText();
                elementValuesList.add(elementValues);
                //mapvalues.put(subChildElementName,elementValues);
                              
                
            }
            
           
        
         for(Dom.XmlNode childelement : rootElement.getChildElements())    
         {
         mapcolRows = new map<String,String>();
           for (Dom.XmlNode subchildelement:childelement.getChildElements())
            {

                 mapcolRows.put(subchildelement.getName(),subchildelement.getText());
                system.debug('mapcolRows '+mapcolRows);
               

             } 
             String boletanum;
             String compania;
             String serie;
             String cliente;
             String numprof;
             String ptoprof;
             String producto;
             String descripcion;
             String fecha;
             String estado;
             String obs;
             boletaList=new List<Boletas__c>();
             blta=new List<Boletas__c>();
             Map<String,Boletas__c> mapB=new Map<String,Boletas__c>();
             rowValues.add(mapcolRows);  //Add rowValuds list to here
             
             
             String codigoCompania='';
             codigoCompania = ApexPages.currentPage().getParameters().get('codcompania');
             for (Integer e = 0 ; e < rowValues.size() ; e++) {
                boletas=new Boletas__c();
                 Map<String, String> myMap = rowValues.get(e);
                 System.debug('Data For Map' + e);
                 for (String key : myMap.keySet()) {
                     System.debug('Key = ' + key + ' , Value = ' + myMap.get(key));
               
               
                if(key=='boleta'){
                   boletanum=myMap.get(key); 
                }
                     
                if(Key=='codcli'){
                   cliente=myMap.get(key); 
                }
                if(Key=='codprod'){
                   producto=myMap.get(key); 
                }
                
                if(Key=='desprod'){
                   descripcion=myMap.get(key); 
                }
                if(Key=='serie'){
                   serie=myMap.get(key); 
                }
                if(Key=='numprof'){
                   numprof=myMap.get(key); 
                }
                if(Key=='ptoprof'){
                   ptoprof=myMap.get(key); 
                }
                if(Key=='estado'){
                   estado=myMap.get(key); 
                }
                if(Key=='fecha'){
                   fecha=myMap.get(key); 
                } 
                if(Key=='obs'){
                   obs=myMap.get(key); 
                }      
              }
                 boletas.Boleta__c=(boletanum == 'null') ? ' ' : boletanum;
                 boletas.C_digo_de_compa_a__c=(codigoCompania == 'null') ? ' ' : codigoCompania;
                 boletas.C_digo_del_cliente__c=(cliente == 'null') ? ' ' : cliente;
                 boletas.C_digo_de_art_culo__c=(producto == 'null') ? ' ' : producto ;
                 boletas.Descripci_n_del_art_culo__c=(descripcion == 'null') ? ' ' : descripcion;
                 boletas.Serie_del_art_culo__c=(serie == 'null') ? ' ' : serie;
                 boletas.N_mero__c=(numprof == 'null') ? ' ' : numprof;
                 boletas.Factura_de_la_proforma__c=(ptoprof == 'null') ? ' ' : ptoprof;
                 boletas.Observaciones_del_estado__c=(obs == 'null') ? ' ' : obs;
                 boletas.Estado_de_la_boleta__c=(estado == 'null') ? ' ' : estado;
                 boletas.Fecha_del_estado__c=(fecha == 'null') ? ' ' : fecha;
                 system.debug('boletas '+boletas);
                 boletaList.add(boletas);
                // mapB.put(boletas.Boleta__c,boletas);
                 
             }

            // for(String key:mapB.keySet()){
                // boletaList.add(mapB.get(key));
             //}
             
             
            // boletaList.add(boletas);
             system.debug('rowValues '+rowValues);
             //system.debug('Boletas lista '+boletaList);
             
             
         }
        
     }
    
    public PageReference verDetalleBoleta() {
			
        HttpRequest request=requestWS();
        Http h=new Http();
        HttpResponse response=responseWS(h, request);
        //parsear datos
        RetrieveArchivedRecords(response);
        
       return null; 
    }

}