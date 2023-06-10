public class apx_parserprueba {
     
   /* public List<Map<String,String>> XMLElements{get;set;}
    public Map<String,string> mapcolRows { get; set;}
    public String numBoleta {set;get;}
    public List<String> subChildElementsList { get; set; }
    public Datetime dat {get;set;}
    String responseBody;
    public List<Map<String,String>> rowValues{get;set;}
      
     //constructor
    public apx_parserprueba(ApexPages.StandardController controller)
      {
          RetrieveArchivedRecords();//desplegar todos los registros
          
      }
    
    //call-in de servicio web de capris de consulta de boletas
    public String responseWS(){
        
        Http http = new Http();
        
        HttpRequest req = new HttpRequest();
        system.debug('Fecha busqueda'+dat);
        //obtenemos de la subcuenta compania y codigocliente
        String codigoCliente ='';
        String codigoCompania='';
        codigoCompania = ApexPages.currentPage().getParameters().get('codcompania');
        codigoCliente = ApexPages.currentPage().getParameters().get('codcliente');
        
         
        
        //validamos como se va a realizar el filtro si por todos o por numero de boleta
        if(numBoleta == '*'){
             system.debug('con * todos valor='+numBoleta+' - http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getIdBoleta/'+codigoCompania+'-'+codigoCliente);
             req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getCliBol/'+codigoCompania+'-'+codigoCliente);
        }
        
        
        if(numBoleta != null){//filtrar por numero de boleta
           
              req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getIdBoleta/'+codigoCompania+'-'+codigoCliente+'-'+numBoleta);
        }else{
             req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getCliBol/'+codigoCompania+'-'+codigoCliente);
            
        }
        if(dat != null){//filtrar por numero de boleta
            
            String fecha=dat.format();
            system.debug('fecha '+fecha);
            String fecha2=fecha.replace('/', '.');
            system.debug('fecha2 '+fecha2);
            String fecha3=fecha2.replace('-', '.');
            system.debug('fecha3 '+fecha3);
            Integer index=fecha3.lastIndexOf(':');
            fecha3=fecha3.substring(0, index);
            system.debug('fecha final '+fecha3);  
         system.debug('fecha '+fecha);
          req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getFechaBoleta/'+codigoCompania+'-'+fecha2);
        }
        req.setMethod('GET');
        
        HttpResponse res = http.send(req);
        
        Boolean result=validarXML(res);
      system.debug('result '+result); 
       //cambiamos tags a nombres mas legibles en el display de la tabla al usuario
      
        
        // Log de XML content
        String xmlContent='';
        if(result != null){
            String xmlRemplace=cambiarNombreTags(res.getBody()); 
            xmlContent=xmlRemplace;
            system.debug('Remplazar encabezados xml '+xmlRemplace);  
        
        }else{
            //system.debug('entre a else de result'+result);
            xmlContent='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Boletass><Boletas><Boleta></Boleta><Cliente></Cliente><Producto></Producto><Descripcion></Descripcion><Estado></Estado><Fecha></Fecha><NumProforma></NumProforma><Observacion></Observacion><PtoProforma></PtoProforma><Serie></Serie></Boletas></Boletass>';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'El cliente no posee boletas para mostrar.'));
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'El cliente no posee boletas para mostrar.'));
        }
        return xmlContent;
        
    }
    
    private Boolean validarXML(HttpResponse res){
        Dom.Document doc = new Dom.Document();
        Boolean flag;
        doc.load(res.getBody());
        Dom.XmlNode root = doc.getRootElement();
        if(root.getName()=='boletass') {
            for(Dom.XmlNode node1: root.getChildElements()) {
                if(node1.getName()==null) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'El cliente no posee boletas para mostrar.'));
                    flag=false;
                }
                if(node1.getName()=='boletas') {
                    flag=true;
                }
            }
        }
        return flag;
    }
    
    private String cambiarNombreTags(String xmlNode){
        String resultadoXML='';
        String target1 = 'boleta';
        String replacement1 = 'Boleta';
        String target2 = 'codcli';
        String replacement2 = 'Cliente';
        String target3 = 'codprod';
        String replacement3 = 'Producto';
        String target4 = 'desprod';
        String replacement4 = 'Descripcion';
        String target5 = 'estado';
        String replacement5 = 'Estado';
        String target6 = 'fecha';
        String replacement6 = 'Fecha';
        String target7 = 'numprof';
        String replacement7 = 'NumProforma';
        String target8 = 'obs';
        String replacement8 = 'Observacion';
        String target9 = 'ptoprof';
        String replacement9 = 'PtoProforma';
        String target10 = 'serie';
        String replacement10 = 'Serie';
        
        if(xmlNode.contains('boleta')){
           
           resultadoXML=xmlNode.replace(target1, replacement1);
           //system.debug('Paso por boleta'+resultadoXML); 
        }
        if(xmlNode.contains('codcli')){
           
           resultadoXML=resultadoXML.replace(target2, replacement2);
           //system.debug('Paso por codcli'+resultadoXML); 
        }
        if(xmlNode.contains('codprod')){
            
           resultadoXML=resultadoXML.replace(target3, replacement3);
           //system.debug('Paso por codprod '+resultadoXML); 
        }
        if(xmlNode.contains('desprod')){
           
           resultadoXML=resultadoXML.replace(target4, replacement4);
            //system.debug('Paso por desprod '+resultadoXML); 
        }
        if(xmlNode.contains('estado')){
            
           resultadoXML=resultadoXML.replace(target5, replacement5);
           //system.debug('Paso por estado'+resultadoXML); 
        }
        if(xmlNode.contains('fecha')){
            
           resultadoXML=resultadoXML.replace(target6, replacement6);
           //system.debug('Paso por fecha '+resultadoXML); 
        }
        if(xmlNode.contains('numprof')){
           
           resultadoXML=resultadoXML.replace(target7, replacement7);
            //system.debug('Paso por obs '+resultadoXML); 
        }
        if(xmlNode.contains('obs')){
           
           resultadoXML=resultadoXML.replace(target8, replacement8);
            //system.debug('Paso por obs '+resultadoXML); 
        }
        if(xmlNode.contains('ptoprof')){
           
           resultadoXML=resultadoXML.replace(target9, replacement9);
            //system.debug('Paso por obs '+resultadoXML); 
        }
        if(xmlNode.contains('serie')){
          
           resultadoXML=resultadoXML.replace(target10, replacement10);
           
        }
         system.debug('Paso por serie '+resultadoXML); 
        return resultadoXML;
    }
    
    public void RetrieveArchivedRecords()
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
        
        system.debug('Cadena de xml '+responseWS());
        responsebody = responseWS();//'<queryResult><records><type>Case</type><Id>5009000000C5YKJAA3</Id><CaseNumber>00001026</CaseNumber><ContactId>0039000000NwhLQAAZ</ContactId><AccountId>0019000000X2WtUAAV</AccountId><Type>Electrical</Type><OwnerId>00590000001WkjdAAC</OwnerId><CreatedDate>2013-07-19T11:12:25.000Z</CreatedDate><CreatedById>00590000001WkjdAAC</CreatedById></records><records><type>Case</type><Id>5009000000Dec3SAAR</Id><CaseNumber>00001031</CaseNumber><ContactId>0039000000NwhLVAAZ</ContactId><AccountId>0019000000X2WtUAAV</AccountId><Type>Electrical</Type><OwnerId>00590000001WkjdAAC</OwnerId><CreatedDate>2013-09-23T07:00:13.000Z</CreatedDate><CreatedById>00590000001WkjdAAC</CreatedById></records></queryResult>';
        


        Dom.Document doc = new Dom.Document();
        List<Dom.XmlNode> childelements;
        doc.load(responsebody);
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
                //rowValues.add(mapcolRows);  //Remove rowValuds list from here
             }  
             rowValues.add(mapcolRows);  //Add rowValuds list to here
             
             //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Error al generar filas con valores.Verificar log de Salesforce.'));
             
         }
        
     }*/

}