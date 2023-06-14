public class APX_OportunidadesConsultas {

  //Declaracion de variables de contexto de controlador
   public static Articulos__c artic {set;get;}
   public static Precios__c prec {set;get;}
   public static Existencias__c exist {set;get;}
   public static String codArticulo {set;get;}
   public static String garantia {set;get;}
   public static String codCliente{set;get;}
   public static String cantidad{set;get;} 
   public Integer porcentage{set;get;}
   public static String selectedCompId {set;get;}
   public static String perfilUsuario {set;get;} 
   public List<Account> clientes=new List<Account>();
   public String userId;
   public String valor;
   public Map<String, String> oportunidadMap=new Map<String, String>();
  // public OpportunityLineItem OpProduct=new OpportunityLineItem();
   public static String codComp;
    //Constructor de clase
    public APX_OportunidadesConsultas(){
        
        //Constructor 
        //selectedCompId='';
        perfilUsuario=[Select name from Profile where id=:UserInfo.getProfileId()].name;
        String usr=UserInfo.getUserName(); //sacar el usuario loggeado
        system.debug('usr '+usr);
        User useritem=[Select id,USU_COD_ORG__c,Usuario_Base_de_Datos__c from User where Username=:usr limit 1];
        system.debug('useritem '+useritem.USU_COD_ORG__c);
        codComp=useritem.USU_COD_ORG__c;
    }
    //llena combo de clientes
    /*public List<SelectOption> getItems() {
        Id userId=UserInfo.getUserId();
        List<Account> clientes=new List<Account>();
        if(perfilUsuario.contains('Técnica') || perfilUsuario.equals('Administrador del sistema') ){
            clientes=[SELECT num_cliente__c, name, org_id__c FROM Account WHERE org_id__c ='CAP' limit 100];
        }
       
        List<SelectOption> options = new List<SelectOption>();
       system.debug('clientes '+clientes);
        options.add(new SelectOption( ' ' ,'--- CodigoCliente ---'));
        for (Account item:clientes){
           options.add(new SelectOption(item.org_id__c+'-'+item.num_cliente__c,item.org_id__c+'-'+item.num_cliente__c)); 
        }
        system.debug('opciones '+options);
        return options;
    }*/
    
    
   //Informacion de articulo
   public static HttpRequest requestWSArticulo() {
   
       perfilUsuario=[Select name from Profile where id=:UserInfo.getProfileId()].name;
        String usr=UserInfo.getUserName(); //sacar el usuario loggeado
        system.debug('usr '+usr);
        User useritem=[Select id,USU_COD_ORG__c,Usuario_Base_de_Datos__c from User where Username=:usr limit 1];
        system.debug('useritem '+useritem.USU_COD_ORG__c);
        codComp=useritem.USU_COD_ORG__c;
       system.debug('Parametros '+codComp+' - '+codArticulo );
       HttpRequest req = new HttpRequest();
       req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Articulos/webresources/app.entities.articulos/'+codComp+'-'+codArticulo+'-C');
       req.setBody(CredentialHelper.CREDENTIALS);
       req.setMethod('GET');
       
      return req; 
      
   }
    
    public static HttpResponse responseArticulo(Http h, HttpRequest req){
        HttpResponse res = h.send(req);
        return res;
    }
    
    public static void parserArticulo(HttpResponse res){
       
    try{
       Dom.Document doc = res.getBodyDocument();
       DOM.XMLNode root = doc.getRootElement();
        
        artic=new Articulos__c();
        if((root.getChildElement('articulos', null).getChildElement('codigo',null).getText())!='null'){
            artic.C_digo_de_art_culo__c=root.getChildElement('articulos', null).getChildElement('codigo',null).getText();//1
        }
        
        if((root.getChildElement('articulos',null).getChildElement('descripcion', null).getText())!='null'){
            artic.Descripci_n__c= root.getChildElement('articulos',null).getChildElement('descripcion', null).getText();//2
        }        
        if((root.getChildElement('articulos',null).getChildElement('estado', null).getText())!= 'null'){
           artic.Estado__c = root.getChildElement('articulos',null).getChildElement('estado', null).getText();//3 
        }
        
        if((root.getChildElement('articulos',null).getChildElement('estrellas', null).getText())!= 'null'){
            artic.Estrellas__c = Decimal.valueOf(root.getChildElement('articulos',null).getChildElement('estrellas', null).getText());//4
        }
        
        if((root.getChildElement('articulos',null).getChildElement('fechaLlegada', null).getText())!= 'null'){
            artic.Fecha_de_llegada__c =root.getChildElement('articulos',null).getChildElement('fechaLlegada', null).getText().replace('-','/');
          }
        
        if((root.getChildElement('articulos',null).getChildElement('marca', null).getText())!= 'null'){
            artic.Marca__c = root.getChildElement('articulos',null).getChildElement('marca', null).getText();//6
        }
        
        if((root.getChildElement('articulos',null).getChildElement('modelo', null).getText())!= 'null'){
            artic.Modelo__c = root.getChildElement('articulos',null).getChildElement('modelo', null).getText();//7
        }
 
        if((root.getChildElement('articulos',null).getChildElement('indMixto', null).getText())!='null'){
            artic.Art_culo_mixto__c = root.getChildElement('articulos',null).getChildElement('indMixto', null).getText();
        }
        
        } catch (System.Exception e) {  // invalid XML
         if(e.getMessage()=='Attempt to de-reference a null object' || e.getMessage()=='List index out of bounds: 0'){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No existe informacion del articulo con ese codigo de producto ingresado.'));
       }else{
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No existe informacion para el articulo.'+e.getMessage()));
       }
      }
                
    }
       
    
   //Existencia de articulo
    public static HttpRequest requestWSExistencia() {
       
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_ExistenciaArticulo/webresources/app.entities.existencias/'+codComp+'-'+codArticulo+'-C');
        req.setBody(CredentialHelper.CREDENTIALS);
        req.setMethod('GET');
        return req;
    }
    public static HttpResponse responseExistencia(Http h, HttpRequest req) {
        
        HttpResponse res = h.send(req);
        return res;
    }
    public static void parserExistencia(HttpResponse res){
        
        try{
            String existV;
            String codigoV;
            exist=new Existencias__c();  
           // Integer index=selectedCompId.lastIndexOf('-');
            //selectedCompId=selectedCompId.substring(0, index+1);
            Dom.Document doc = res.getBodyDocument();
            
            DOM.XMLNode root = doc.getRootElement();
            DOM.XMLNode rootElementSub = root.getChildElements()[0];
            system.debug('root lleno o vacio '+rootElementSub);
            if(rootElementSub!=null){ 
                if((root.getChildElement('existencias',null).getChildElement('codigo', null).getText())!=null)
                {
                    codigoV = root.getChildElement('existencias',null).getChildElement('codigo', null).getText();//2
                    
                }/*else{
                    codigoV='';
                }*/
                
                
                if((root.getChildElement('existencias',null).getChildElement('exist', null).getText())!=null)
                {
                    existV =root.getChildElement('existencias',null).getChildElement('exist', null).getText();//2
                    
                }/*else{
                    existV='';
                }*/
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'nose encontraron datos de existencias para el articulo.'));
            }  
            exist.C_digo_de_art_culo__c=codigoV;
            exist.Existencia__c=Decimal.valueOf(existV);
            
        }catch(Exception e){
            if(e.getMessage()=='Attempt to de-reference a null object' || e.getMessage()=='List index out of bounds: 0'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No existe informacion de existencias de este articulo.'));
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No existe informacion de existencias de este articulo.'+e.getMessage()));
            }
        } 
        
        
    }
    
    //Garantia de articulo
    public static HttpRequest requestWSGarantia() {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_ArticulosGarantia/webresources/app.entities.articulosgaran/'+codComp+'-'+codArticulo+'-C');
        req.setBody(CredentialHelper.CREDENTIALS);
        req.setMethod('GET'); 
        return req;
    }
    
    public static HttpResponse responseGarantia(Http h, HttpRequest req) {
        HttpResponse res = h.send(req);
        return res;
    }
    
    public static void parserGarantia(HttpResponse res){
        try{
            String garV;
            garantia='';  
  
            Dom.Document doc = res.getBodyDocument();

            DOM.XMLNode root = doc.getRootElement();
            DOM.XMLNode rootElementSub = root.getChildElements()[0];
            system.debug('root lleno o vacio '+rootElementSub);
            
            if((root.getChildElement('articulosGaran',null).getChildElement('garantia', null).getText())!=null)
            {
                garV = root.getChildElement('articulosGaran',null).getChildElement('garantia', null).getText();//2
                
            }/*else{
                garV='';
            }*/
            
            garantia=garV;
        }catch(Exception e){
            if(e.getMessage()=='Attempt to de-reference a null object' || e.getMessage()=='List index out of bounds: 0'){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No existe informacion para garantias de este articulo.'));
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No existe informacion para garantias de este articulo.'+e.getMessage()));
            }
            
        } 
    }
    
 
   //Eventos 
    public void getArticulo(){
        HttpRequest request=requestWSArticulo();
        Http h=new Http();
        HttpResponse responses=responseArticulo(h,request);
        //parsear datos
        parserArticulo(responses);
        
    }
    public void getExistenciaArticulo(){
        HttpRequest request=requestWSExistencia();
        Http h=new Http();
        HttpResponse responses=responseExistencia(h,request);
        //parsear datos
        parserExistencia(responses);

   }
    public void getGarantiaArticulo(){
        HttpRequest request=requestWSGarantia();
        Http h=new Http();
        HttpResponse responses=responseGarantia(h,request);
        //parsear datos
        parserGarantia(responses); 
    }
    
    //boton buscar articulo
    public void buscar() {
        getArticulo();
        getExistenciaArticulo();
        getGarantiaArticulo();
    }
    

    
}