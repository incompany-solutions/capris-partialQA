public class Apx_EncMovimientosProcess {

  //************************* WSEncabezados *****************************************
  @future(callout = true)
  public static void ProcesarEncabezados(String compania) {
    HttpResponse res = new HttpResponse();
    res = CallWSEncabezados(compania);
    if (res != null && res.getBody() != null && res.getBody() != '') {
      List<Encabezado__c> listenc = ParserEncabezado(res.getBody(), compania); //Obtenemos datos de WS encabezados.
      system.debug('listado de encabezados ' + listenc);
      if (!listenc.isEmpty()) {
        insertaractualizarEncabezados(listenc, compania); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
      }
    }
    //List<Detalle_de_Movimiento__c> listmov =ParserMovimientos(responseMov);//Obtenemos datos de WS movimientos. 
  }
  //Invocacion del servicio web de Capris

  public static HttpResponse CallWSEncabezados(String compania) {
    HttpResponse res = new HttpResponse();
    try {
      HttpRequest req = new HttpRequest();
      /*string fecha = system.now().format();
      fecha = fecha.replace('/', '.');
      fecha = fecha.substring(0, fecha.length() - 3);*/
      //String responseMov=CallWSMovimientos(fecha);//WS de Movimientos
      Integer dia = system.now().day();
      Integer mes = system.now().month();
      Integer anno = system.now().year();
      Integer hora = system.now().hour()-1;
      system.debug('fecha 0 *** ' +dia+'.'+mes+'.'+anno+' '+ hora);
      string fecha = dia+'.'+mes+'.'+anno+' '+ hora;
      req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_EncMovimiento/webresources/app.entities.encmov/getEncFecha/' + compania + '-' + fecha);
      req.setBody(CredentialHelper.CREDENTIALS);
      req.setMethod('GET');
      req.setTimeout(120000);
      Http h = new Http();
      res = h.send(req);


    } catch(Exception e) {
      system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
    }
    return res;
  }

  /*
   
    version anterior
   
    try {
    Set<String> allenc = new Set<String> ();
    Map<String, Account> accMap = new Map<String, Account> ();
    List<Encabezado__c> evaluadosEnc = new List<Encabezado__c> ();
    //Encabezado__c item;
    for (Encabezado__c enc : listaencabezados) {
    allenc.add(enc.EMV_NUM_CLIENTE__c);
    }
   
    //Cuentas que coiciden con encabezados para relacionarlas
    List<Account> potentialAccount = [SELECT Id, num_cliente__c FROM Account WHERE num_cliente__c IN :allenc and org_id__c = :'CAP' and Maestra__c = :false];
    if (!potentialAccount.isEmpty()) {
    for (Account u : potentialAccount) {
    accMap.put(u.num_cliente__c, u);
    }
    }
   
    //buscar coicidencia de cuenta en lista de encabzados
    for (Encabezado__c item : listaencabezados) {
    Account a = accMap.get(item.EMV_NUM_CLIENTE__c);
    if (a != null) {
    evaluadosEnc.add(item);
    }
    }
   
    //Realizamos el upsert con la lista depurada para asociar a cuentas existentes 
    //upsert evaluadosEnc Encabezado__c.EMV_NUM_DOCUMENTO__c;
   
    upsert evaluadosEnc Encabezado__c.ID_Capris__c; //Adicionado por SAO
    } catch(DmlException e) {
    System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
    }*/

  //Parseo de datos obtenidos del response del WS 
  public static List<Encabezado__c> ParserEncabezado(String xmlfile, String compania) {

    List<Encabezado__c> listEncabezado = new List<Encabezado__c> ();
    Encabezado__c encabezadoItem;
    System.Debug('$$$$ xmlfile ' + xmlfile);
    DOM.Document xmlDOC = new DOM.Document();
    xmlDOC.load(xmlfile);
    Set<string> encabezadosUnicos = new set<string>();
    
    if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
      for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
        encabezadoItem = new Encabezado__c();
        Boolean bandera = false;
        for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
          if (xmlNodeObjChild.getName() == 'emvCodMoneda' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_COD_MONEDA__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvCodPuntoFact' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_COD_PUNTO_FACT__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvCodUsuarioVend' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_COD_USUARIO_VEND__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvEstadoDoc' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_ESTADO_DOC__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvFecMovimiento' && xmlNodeObjChild.getText() != 'null'){
            string fecha = xmlNodeObjChild.getText();
            list<string> fechaList = fecha.split('-');
            string fechaCorrecta = fechaList[2]+'-'+fechaList[1]+'-'+fechaList[0]+' 06:00:00';
            encabezadoItem.EMV_FEC_MOVIMIENTO__c = fechaCorrecta;
          }
          if (xmlNodeObjChild.getName() == 'emvIdtarj' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_IDTARJ__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvMonRecargo' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_MON_RECARGO__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'emvNomCliente' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_NOM_CLIENTE__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvNumCliente' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_NUM_CLIENTE__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvNumDocumento' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_NUM_DOCUMENTO__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvObservImpresa' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_OBSERV_IMPRESA__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvObservInterna' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_OBSERV_INTERNA__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvPlazoDoc' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_PLAZO_DOC__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvTipCambio' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_TIP_CAMBIO__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'emvTipoMov' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_TIPO_MOV__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'emvVia' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.EMV_VIA__c = xmlNodeObjChild.getText();
          //Incorporados por SAO 2017-11-10
          if (xmlNodeObjChild.getName() == 'saldo' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.SaldoTotal__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'saldoVencido' && xmlNodeObjChild.getText() != 'null')
          encabezadoItem.SaldoVencido__c = Decimal.valueOf(xmlNodeObjChild.getText());
          //Nota SAO: al 8 de febrero no se estaban mapeando ni subtotal, descuento, total de impuesto, muelle y observaciones adicionales
          if(xmlNodeObjChild.getName() == 'emvMonTotal' && xmlNodeObjChild.getText() != 'null')
            encabezadoItem.Subtotal__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if(xmlNodeObjChild.getName() == 'emvMonDescuento' && xmlNodeObjChild.getText() != 'null')
            encabezadoItem.Total_de_Descuento__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if(xmlNodeObjChild.getName() == 'emvMonIva' && xmlNodeObjChild.getText() != 'null')
            encabezadoItem.Total_de_Impuesto__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if(xmlNodeObjChild.getName() == 'emvMuelle' && xmlNodeObjChild.getText() != 'null')
            encabezadoItem.EMV_MUELLE__c = xmlNodeObjChild.getText();
          if(xmlNodeObjChild.getName() == 'emvObsAdd' && xmlNodeObjChild.getText() != 'null')
            encabezadoItem.EMV_OBS_ADD__c = xmlNodeObjChild.getText();          
            
        
          if(compania!=null&&encabezadoItem.EMV_TIPO_MOV__c!=null&&encabezadoItem.EMV_COD_PUNTO_FACT__c!=null&&encabezadoItem.EMV_NUM_DOCUMENTO__c!=null&&!encabezadosUnicos.contains(compania + '|' + encabezadoItem.EMV_TIPO_MOV__c + '|' + encabezadoItem.EMV_COD_PUNTO_FACT__c + '-' + encabezadoItem.EMV_NUM_DOCUMENTO__c)){
            encabezadosUnicos.add(compania + '|' + encabezadoItem.EMV_TIPO_MOV__c + '|' + encabezadoItem.EMV_COD_PUNTO_FACT__c + '-' + encabezadoItem.EMV_NUM_DOCUMENTO__c);
            encabezadoItem.EMV_COD_ORG__c = compania;
            encabezadoItem.EMV_FYH_MODIFICA__c = Datetime.valueOf(system.now());
            encabezadoItem.ID_Capris__c = compania + '|' + encabezadoItem.EMV_TIPO_MOV__c + '|' + encabezadoItem.EMV_COD_PUNTO_FACT__c + '-' + encabezadoItem.EMV_NUM_DOCUMENTO__c; //Adicionado por SAO
            bandera = true;
          }
          
        }
        if(bandera){
          System.Debug(encabezadoItem);
          listEncabezado.add(encabezadoItem); //lista de encabezado  
        }
      }
    }

    System.Debug('$$$$$$$ listaaa ' + listEncabezado);
    return listEncabezado;
  }

  //Realizacion de upsert de datos enviados 
  public static void insertaractualizarEncabezados(List<Encabezado__c> listaencabezados, String compania) {

    if (!listaencabezados.isEmpty()) {

      Set<String> cuentasRelacionadasCod = new Set<String> ();
      Set<String> puntosRelacionados = new Set<String> ();
      Map<String, String> mapCuentaIds = new map<String, String> ();
      Map<String, String> mapPuntosIds = new Map<String, String> ();
      List<Encabezado__c> encabezadosActualizados = new list<Encabezado__c> ();
      Id idSubCuenta = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sub Cuenta').getRecordTypeId();

      for (Encabezado__c e : listaencabezados) {

        if (e.EMV_NUM_CLIENTE__c != null && e.EMV_COD_ORG__c != null) {
          cuentasRelacionadasCod.add(e.EMV_NUM_CLIENTE__c);
        }

        if (e.EMV_COD_PUNTO_FACT__c != null && e.EMV_COD_ORG__c != null) {
          puntosRelacionados.add(e.EMV_COD_PUNTO_FACT__c);
        }

      } //for (Encabezado__c e : listaencabezados)           

      if (!cuentasRelacionadasCod.isEmpty()) {
        for (Account acc :[select id, name, num_cliente__c, org_id__c from Account where num_cliente__c != null and num_cliente__c in :cuentasRelacionadasCod and org_id__c != null and org_id__c = :compania and RecordTypeId = :idSubCuenta]) {
          mapCuentaIds.put(acc.num_cliente__c + acc.org_id__c, acc.Id);
        } //for (Account acc ...
      } //if(!cuentasRelacionadasCod.isEmpty())

      if (!puntosRelacionados.isEmpty()) {
        for (GES_PTO_FAC__c pun :[select id, PTO_COD_PTO__c, PTO_COD_ORG__c from GES_PTO_FAC__c where PTO_COD_PTO__c != null and PTO_COD_PTO__c in :puntosRelacionados and PTO_COD_ORG__c != null and PTO_COD_ORG__c = :compania]) {
          mapPuntosIds.put(pun.PTO_COD_PTO__c + pun.PTO_COD_ORG__c, pun.id);
        }
      }

      System.debug('**** mapCuentaIds ***** ' + mapCuentaIds.values().size());

      for (Encabezado__c e : listaencabezados) {
        if (mapPuntosIds != null && !mapPuntosIds.values().isEmpty() && mapPuntosIds.containsKey(e.EMV_COD_PUNTO_FACT__c + e.EMV_COD_ORG__c)) {
          e.PuntoFactRelacionado__c = mapPuntosIds.get(e.EMV_COD_PUNTO_FACT__c + e.EMV_COD_ORG__c);
        } //if(mapPuntosIds != null &&...        
        if (mapCuentaIds != null && !mapCuentaIds.values().isEmpty() && mapCuentaIds.containsKey(e.EMV_NUM_CLIENTE__c + e.EMV_COD_ORG__c)) {
          e.Cliente__c = mapCuentaIds.get(e.EMV_NUM_CLIENTE__c + e.EMV_COD_ORG__c);
          e.Por_ws__c = true;
          encabezadosActualizados.add(e);
        } //if (mapCuentaIds != null &&...

      } //for (Encabezado__c e : listaencabezados)

      if (!encabezadosActualizados.isEmpty()) {
        try {
          upsert encabezadosActualizados Encabezado__c.ID_Capris__c;
        } catch(DmlException e) {
          System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
        }

      } //if (!encabezadosActualizados.isEmpty())    

    } //if (!listaencabezados.isEmpty())        
  }



  //********************** WSMovimientos **********************************************
  @future(callout = true)
  public static void ProcesarMovimientos(String compania) {
    HttpResponse res = new HttpResponse();
    res = CallWSMovimientos(compania);
    if (res != null && res.getBody() != null && res.getBody() != '') {
      List<Detalle_de_Movimiento__c> listmov = ParserMovimientos(res.getBody(), compania); //Obtenemos datos de WS movimientos.
      if (!listmov.isEmpty()) {
        insertaractualizarMovimientos(listmov, compania); //Insertamos o actualizamos movientos segun sea el caso del resgistro enviado. 
      }
    }
  }

  public static HttpResponse CallWSMovimientos(String compania) {
    HttpRequest req = new HttpRequest();
    HttpResponse res = new HttpResponse();

    try {

      String response = '';
      /*string fecha = system.now().format();
      fecha = fecha.replace('/', '.');
      fecha = fecha.substring(0, fecha.length() - 3);*/
      Integer dia = system.now().day();
      Integer mes = system.now().month();
      Integer anno = system.now().year();
      Integer hora = system.now().hour()-1;
      system.debug('fecha 0 *** ' +dia+'.'+mes+'.'+anno+' '+ hora);
      string fecha = dia+'.'+mes+'.'+anno+' '+ hora;
      req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_DetMovimiento/webresources/app.entities.detmov/getDetFecha/' + compania + '-' + fecha);
      req.setBody(CredentialHelper.CREDENTIALS);
      req.setMethod('GET');
      req.setTimeout(120000);
      Http h = new Http();
      res = h.send(req);
      //response=res.getBody();


    } catch(Exception e) {
      system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
    }

    return res;
  }

  //Parseo de datos obtenidos del response del WS 
  public static List<Detalle_de_Movimiento__c> ParserMovimientos(String xmlfile, String compania) {

    List<Detalle_de_Movimiento__c> listMovimientos = new List<Detalle_de_Movimiento__c> ();
    Detalle_de_Movimiento__c movimientosItem;
    System.Debug('****  xmlfile ParserMovimientos **** ' + xmlfile);
    DOM.Document xmlDOC = new DOM.Document();
    xmlDOC.load(xmlfile);
    set<string> detallesUnicos = new set<string>();
    
    if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
      for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
        movimientosItem = new Detalle_de_Movimiento__c();
        Boolean bandera = false;
        for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren())
        {


          if (xmlNodeObjChild.getName() == 'dmvCanMovimiento' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_CAN_MOVIMIENTO_3__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'dmvCodOferta' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_COD_OFERTA_3__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'dmvCodProducto' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_COD_PRODUCTO_3__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'dmvCodPuntoFact' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_COD_PUNTO_FACT__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'dmvDescEsp' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_DESC_ESP_3__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'dmvNumDocumento' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_NUM_DOCUMENTO_3__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'dmvNumLinea' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_NUM_LINEA_3__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'dmvPrecioEspecial' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_PRECIO_ESPECIAL_3__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'dmvPrecioNormal' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_PRECIO_NORMAL_3__c = Decimal.valueOf(xmlNodeObjChild.getText());
          if (xmlNodeObjChild.getName() == 'dmvTipoMov' && xmlNodeObjChild.getText() != 'null')
          movimientosItem.DMV_TIPO_MOV__c = xmlNodeObjChild.getText();
          if (xmlNodeObjChild.getName() == 'dmvPorIva' && xmlNodeObjChild.getText() != 'null')
           movimientosItem.DMV_POR_IVA__c = Decimal.valueOf(xmlNodeObjChild.getText());

          //Id externo
          
          if(compania!=null&&movimientosItem.DMV_TIPO_MOV__c!=null&&movimientosItem.DMV_COD_PUNTO_FACT__c!=null&&movimientosItem.DMV_NUM_DOCUMENTO_3__c!=null&&movimientosItem.DMV_NUM_LINEA_3__c!=null&&!detallesUnicos.contains(compania + '|' + movimientosItem.DMV_TIPO_MOV__c + '|' + movimientosItem.DMV_COD_PUNTO_FACT__c + '-' + movimientosItem.DMV_NUM_DOCUMENTO_3__c + '|' + movimientosItem.DMV_NUM_LINEA_3__c)){
            detallesUnicos.add(compania + '|' + movimientosItem.DMV_TIPO_MOV__c + '|' + movimientosItem.DMV_COD_PUNTO_FACT__c + '-' + movimientosItem.DMV_NUM_DOCUMENTO_3__c + '|' + movimientosItem.DMV_NUM_LINEA_3__c);
            movimientosItem.DMV_COD_ORG_3__c = compania;
            movimientosItem.IDMOV__c = compania + movimientosItem.DMV_TIPO_MOV__c + movimientosItem.DMV_NUM_LINEA_3__c + movimientosItem.DMV_NUM_DOCUMENTO_3__c;
            movimientosItem.ID_Capris__c = compania + '|' + movimientosItem.DMV_TIPO_MOV__c + '|' + movimientosItem.DMV_COD_PUNTO_FACT__c + '-' + movimientosItem.DMV_NUM_DOCUMENTO_3__c + '|' + movimientosItem.DMV_NUM_LINEA_3__c;
            movimientosItem.Name = movimientosItem.DMV_NUM_LINEA_3__c;
            bandera=true;
          }
        }
        if(bandera){
          listMovimientos.add(movimientosItem); //lista de movimientos
        }
          
      }

    }

    system.debug('listMovimientos *** ' + listMovimientos);
    return listMovimientos;
  }

  //Realizacion de upsert de datos enviados 
  public static void insertaractualizarMovimientos(List<Detalle_de_Movimiento__c> listamovimientos, String compania) {

    try {
      Set<String> allmov = new Set<String> ();
      Set<String> setProd = new Set<String> ();
      Map<String, String> encMap = new Map<String, String> ();
      Map<String, String> proMap = new Map<String, String> ();
      List<Detalle_de_Movimiento__c> evaluadosMov = new List<Detalle_de_Movimiento__c> ();

      for (Detalle_de_Movimiento__c mov : listamovimientos) {

        if (mov.DMV_COD_ORG_3__c != null && mov.DMV_TIPO_MOV__c != null && mov.DMV_COD_PUNTO_FACT__c != null && mov.DMV_NUM_DOCUMENTO_3__c != null) {
          allmov.add(compania + '|' + mov.DMV_TIPO_MOV__c + '|' + mov.DMV_COD_PUNTO_FACT__c + '-' + mov.DMV_NUM_DOCUMENTO_3__c);
        }
        if (mov.DMV_COD_PRODUCTO_3__c != null && mov.DMV_COD_ORG_3__c != null) {
          setProd.add(compania + mov.DMV_COD_PRODUCTO_3__c);
        }
      }

      //Cuentas que coiciden con encabezados para relacionarlas
      for (Encabezado__c e :[SELECT Id, ID_Capris__c FROM Encabezado__c WHERE ID_Capris__c != null and ID_Capris__c IN :allmov and EMV_COD_ORG__c = :compania]) {
        encMap.put(e.ID_Capris__c, e.Id);
      }

      for (Product2 pro :[select id, idExternoArticulo__c, ORG__c from Product2 where idExternoArticulo__c != null and idExternoArticulo__c in :setProd and ORG__c = :compania]) {
        proMap.put(pro.idExternoArticulo__c, pro.Id);
      }

      //buscar coicidencia de encabezado en lista de movimientos 

        for (Detalle_de_Movimiento__c item : listamovimientos) {
            /*if (proMap != null && !proMap.values().isEmpty() && proMap.containsKey(compania + item.DMV_COD_PRODUCTO_3__c)) {
                item.ArtRelacionado__c = proMap.get(compania + item.DMV_COD_PRODUCTO_3__c);
            }*/
            if(compania!=null&&item.DMV_COD_PRODUCTO_3__c!=null&&proMap != null && !proMap.values().isEmpty() && proMap.containsKey(compania + item.DMV_COD_PRODUCTO_3__c)){
                item.ArtRelacionado__c = proMap.get(compania + item.DMV_COD_PRODUCTO_3__c);
            }
            if (encMap != null && !encMap.values().isEmpty() && encMap.containsKey(compania + '|' + item.DMV_TIPO_MOV__c + '|' + item.DMV_COD_PUNTO_FACT__c + '-' + item.DMV_NUM_DOCUMENTO_3__c)) {
                item.Encabezado__c = encMap.get(compania + '|' + item.DMV_TIPO_MOV__c + '|' + item.DMV_COD_PUNTO_FACT__c + '-' + item.DMV_NUM_DOCUMENTO_3__c);
                item.Por_ws__c = true;
                evaluadosMov.add(item);
            }           
        }

      //Realizamos el upsert con la lista depurada para asociar a cuentas existentes 
      if (!evaluadosMov.isEmpty()) {
        upsert evaluadosMov Detalle_de_Movimiento__c.ID_Capris__c;
      }


    } catch(DmlException e) {
      System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
    }
  }



}