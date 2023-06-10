public class Apx_Tramite {
public List<Map<String,String>> XMLElements{get;set;}
    //paginacion
    public Integer rec { get; set; }
    public Integer tot { get; set; }
    public String nomcuenta {set;get;}
    integer totalRecs = 0;
    integer count= 0;
    integer LimitSize= 1;

    //variables otras
    public static Map<String,string> mapcolRows { get; set;}
    public String numTramite {set;get;}
    public String tipoTramite {set;get;}
    public String codcliente {set;get;}
    public static List<String> subChildElementsList { get; set; }
   
    String responseBody;
    public static List<Map<String,String>> rowValues{get;set;}
    public static List<Tramite> listTramite{get;set;}
    public static Tramite tramite;
    
    public static String codigoCliente;
    public static String codigoCompania;
     //constructor
    public Apx_Tramite()
      {
          nomcuenta = ApexPages.currentPage().getParameters().get('nomcuenta');
          
      }
    
     public PageReference verTramites() {
			
        HttpRequest request=requestWS();
        Http h=new Http();
        HttpResponse responses=responseWS(h, request);
        //parsear datos
        RetrieveArchivedRecords(responses);
        
       return null; 
    }
    
    public static HttpRequest requestWS(){
        Http http = new Http();
        
        codigoCompania = ApexPages.currentPage().getParameters().get('codcompania');
        codigoCliente = ApexPages.currentPage().getParameters().get('codcliente');
        
       // codcliente=codigoCliente;
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Tramite/webresources/app.entities.tramites/'+codigoCompania+'-'+codigoCliente);
        req.setMethod('GET');
        
        return req;
    }
    //call-in de servicio web de capris de consulta de boletas
    public static HttpResponse responseWS(Http h, HttpRequest req){
        HttpResponse res =new HttpResponse();
        try{
            
          res = h.send(req);
            
                 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error en comunicacion con servicio web de tramites.Intente de nuevo la consulta.'));
            system.debug('Error recibiendo respuesta de WS Tramites.'+'Descripcion de Error: '+e.getMessage());
        } 
        
        return res;
    }
    
   /* private Boolean validarXML(HttpResponse res){
        Dom.Document doc = new Dom.Document();
        Boolean flag;
        doc.load(res.getBody());
        Dom.XmlNode root = doc.getRootElement();
        if(root.getName()=='tramitess') {
            for(Dom.XmlNode node1: root.getChildElements()) {
                if(node1.getName()==null) {
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'El cliente no posee tramites para mostrar.'));
                    flag=false;
                }
                if(node1.getName()=='tramites') {
                    flag=true;
                }
            }
        }
        return flag;
    }
    
    private String cambiarNombreTags(String xmlNode){
        String resultadoXML='';
        String target1 = 'bodega';
        String replacement1 = 'Bodega';
        String target2 = 'bodegaDestino';
        String replacement2 = 'Bodega_Destino';
        String target3 = 'codInstitucional';
        String replacement3 = 'Codigo_Institucional';
        String target4 = 'codcli';
        String replacement4 = 'Codigo_Cliente';
        String target5 = 'descripcion';
        String replacement5 = 'Descripcion';
        String target6 = 'estado';
        String replacement6 = 'Estado';
        String target7 = 'fechaInicia';
        String replacement7 = 'Fecha_Inicia';
        String target8 = 'numContrato';
        String replacement8 = 'Num_Contrato';
        String target9 = 'numMovimiento';
        String replacement9 = 'Num_Movimiento';
        String target10 = 'numTramite';
        String replacement10 = 'Num_Tramite';
        String target11 = 'obsEntrega';
        String replacement11 = 'Observacion_Entrega';
        String target12 = 'obsTramite';
        String replacement12 = 'Observacion_Tramite';
        String target13 = 'pasoAct';
        String replacement13 = 'Paso_Act';
        String target14 = 'pasoSig';
        String replacement14 = 'Paso_Sig';
        String target15 = 'tipoMov';
        String replacement15 = 'Tipo_Mov';
        String target16 = 'tipoMovInv';
        String replacement16 = 'Tipo_Mov_Inv';
        String target17 = 'tipoTramite';
        String replacement17 = 'Tipo_Tramite';
        String target18 = 'usuarioInicia';
        String replacement18 = 'Usuario_Inicia';
        
        
        if(xmlNode.contains('bodega')){
           
           resultadoXML=xmlNode.replace(target1, replacement1);
           //system.debug('Paso por boleta'+resultadoXML); 
        }
        if(xmlNode.contains('bodegaDestino')){
           
           resultadoXML=resultadoXML.replace(target2, replacement2);
           //system.debug('Paso por codcli'+resultadoXML); 
        }
        if(xmlNode.contains('codInstitucional')){
            
           resultadoXML=resultadoXML.replace(target3, replacement3);
           //system.debug('Paso por codprod '+resultadoXML); 
        }
        if(xmlNode.contains('codcli')){
           
           resultadoXML=resultadoXML.replace(target4, replacement4);
            //system.debug('Paso por desprod '+resultadoXML); 
        }
        if(xmlNode.contains('descripcion')){
            
           resultadoXML=resultadoXML.replace(target5, replacement5);
           //system.debug('Paso por estado'+resultadoXML); 
        }
        if(xmlNode.contains('estado')){
            
           resultadoXML=resultadoXML.replace(target6, replacement6);
           //system.debug('Paso por fecha '+resultadoXML); 
        }
        if(xmlNode.contains('fechaInicia')){
           
           resultadoXML=resultadoXML.replace(target7, replacement7);
            //system.debug('Paso por obs '+resultadoXML); 
        }
        if(xmlNode.contains('numContrato')){
           
           resultadoXML=resultadoXML.replace(target8, replacement8);
            //system.debug('Paso por obs '+resultadoXML); 
        }
        if(xmlNode.contains('numMovimiento')){
           
           resultadoXML=resultadoXML.replace(target9, replacement9);
            //system.debug('Paso por obs '+resultadoXML); 
        }
        if(xmlNode.contains('numTramite')){
          
           resultadoXML=resultadoXML.replace(target10, replacement10);
           
        }
        
        if(xmlNode.contains('obsEntrega')){
          
           resultadoXML=resultadoXML.replace(target11, replacement11);
           
        }
        
        if(xmlNode.contains('obsTramite')){
          
           resultadoXML=resultadoXML.replace(target12, replacement12);
           
        }
        if(xmlNode.contains('pasoAct')){
          
           resultadoXML=resultadoXML.replace(target13, replacement13);
           
        } 
        if(xmlNode.contains('pasoSig')){
          
           resultadoXML=resultadoXML.replace(target14, replacement14);
           
        } 
        
        if(xmlNode.contains('tipoMov')){
          
           resultadoXML=resultadoXML.replace(target15, replacement15);
           
        }
        if(xmlNode.contains('tipoMovInv')){
          
           resultadoXML=resultadoXML.replace(target16, replacement16);
           
        }
        if(xmlNode.contains('tipoTramite')){
          
           resultadoXML=resultadoXML.replace(target17, replacement17);
           
        } 
        if(xmlNode.contains('usuarioInicia')){
          
           resultadoXML=resultadoXML.replace(target18, replacement18);
           
        } 
        system.debug('Paso por serie '+resultadoXML); 
        return resultadoXML;
    }*/
    
    //Manejo de parseo de xml enviado por el servicio web
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
                 //rowValues.add(mapcolRows);  //Remove rowValuds list from here
             }  
             rowValues.add(mapcolRows);  //Add rowValuds list to here             
         }
         
         String bodega; 
         String bodegaDestino; 
         String codIns; 
         String codcliente; 
         String descripcion; 
         String estado; 
         String fechaIni; 
         String numContrato; 
         String numMov; 
         String numTramite;
         String obsE; 
         String obsT; 
         String pasoAct; 
         String pasoSig; 
         String tipoMov; 
         String tipoMovInv;
         String tipoTramite; 
         String usuarioInicia;
         String codInstitucional;
          
         listTramite=new List<Tramite>();      
         
         for (Integer e = 0 ; e < rowValues.size() ; e++) {
             tramite=new Tramite();
             Map<String, String> myMap = rowValues.get(e);
             
             for (String key : myMap.keySet()) {
                 
                 if(key=='bodega'){
                   bodega=myMap.get(key);
                   system.debug('bodega '+bodega);
                 }
                 
                 if(Key=='bodegaDestino'){
                   bodegaDestino=myMap.get(key); 
                   system.debug('bodegaDestino '+bodegaDestino);
                 }
                 if(Key=='codInstitucional'){
                    codIns=myMap.get(key); 
                    system.debug('codInstitucional '+codInstitucional);
                 }
                 
                 if(Key=='codcli'){
                    codcliente=myMap.get(key); 
                    system.debug('codcliente '+codcliente);
                 }
                 if(Key=='descripcion'){
                     descripcion=myMap.get(key);
                     system.debug('descripcion '+descripcion);
                 }
                 if(Key=='estado'){
                    estado=myMap.get(key);
                    system.debug('estado '+estado);
                 }
                 if(Key=='fechaInicia'){
                    fechaIni=myMap.get(key);
                    system.debug('fechaIni '+fechaIni);
                 }
                 if(Key=='numContrato'){
                    numContrato=myMap.get(key); 
                 }
                 if(Key=='numMovimiento'){
                    numMov=myMap.get(key); 
                 }
                 if(Key=='numTramite'){
                    numTramite=myMap.get(key); 
                 } 
                 if(Key=='obsEntrega'){
                    obsE=myMap.get(key); 
                 }
                 if(Key=='obsTramite'){
                    obsT=myMap.get(key); 
                 }
                 if(Key=='pasoAct'){
                   pasoAct=myMap.get(key); 
                 }
                if(Key=='pasoSig'){
                    pasoSig=myMap.get(key); 
                 }
                 if(Key=='tipoMov'){
                   tipoMov=myMap.get(key); 
                 }
                if(Key=='tipoMovInv'){
                    tipoMovInv=myMap.get(key); 
                 } 
                 if(Key=='tipoTramite'){
                    tipoTramite=myMap.get(key); 
                 } 
                 if(Key=='usuarioInicia'){
                   usuarioInicia=myMap.get(key); 
                 }
                 
             }
             tramite.Bodega=(bodega == 'null') ? ' ' : bodega;
             tramite.BodegaDestino=(bodegaDestino == 'null') ? ' ' : bodegaDestino;
             tramite.TipoTramite=(tipoTramite == 'null') ? ' ' : tipoTramite;
             tramite.Descripcion=(descripcion == 'null') ? ' ' : descripcion ;
             tramite.NumeroTramite=(numTramite == 'null') ? ' ' : numTramite;
             tramite.FechaEstado=(fechaIni == 'null') ? ' ' : fechaIni;
             tramite.ObservacionesEntrega=(obsE == 'null') ? ' ' : obsE;
             tramite.ObservacionesTramite=(obsT == 'null') ? ' ' : obsT;
             tramite.NumeroContrato=(numContrato == 'null') ? ' ' : numContrato;
             tramite.CodigoInstitucional=(codIns == 'null') ? ' ' : codIns;
             tramite.UsuarioInicia=(usuarioInicia == 'null') ? ' ' : usuarioInicia;
             tramite.PasoActual=(pasoAct == 'null') ? ' ' : pasoAct;
             tramite.PasoSiguiente=(pasoSig == 'null') ? ' ' : pasoSig;
             tramite.TipoMovimientoInventario=(tipoMovInv == 'null') ? ' ' : tipoMovInv;
             tramite.TipoMovimiento=(tipoMov == 'null') ? ' ' : tipoMov;
             tramite.NumeroMovimiento=(numMov == 'null') ? ' ' : numMov;
             system.debug('tramite '+tramite);
             listTramite.add(tramite);
             
             
         }
        
     }
    
    ///Entidad de objeto Tramite
    public class Tramite{
      public String Bodega{get;set;}
      public String BodegaDestino{get;set;}
      public String TipoTramite{get;set;}
      public String Descripcion{get;set;}
      public String NumeroTramite{get;set;} 
      public String FechaEstado{get;set;} 
      public String ObservacionesEntrega{get;set;}
      public String ObservacionesTramite{get;set;}
      public String NumeroContrato{get;set;}
      public String CodigoInstitucional{get;set;}
      public String UsuarioInicia{get;set;}
      public String PasoActual{get;set;}
      public String PasoSiguiente{get;set;}
      public String TipoMovimientoInventario{get;set;}
      public String TipoMovimiento{get;set;}
      public String NumeroMovimiento{get;set;} 
        
     public Tramite(){
      Bodega='';
      BodegaDestino='';
      TipoTramite='';
      Descripcion='';
      NumeroTramite=''; 
      FechaEstado=''; 
      ObservacionesEntrega='';
      ObservacionesTramite='';
      NumeroContrato='';
      CodigoInstitucional='';
      UsuarioInicia='';
      PasoActual='';
      PasoSiguiente='';
      TipoMovimientoInventario='';
      TipoMovimiento='';
      NumeroMovimiento='';   
     }
        
    }
}