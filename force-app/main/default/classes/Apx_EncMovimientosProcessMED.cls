public class Apx_EncMovimientosProcessMED {

	/*public Apx_EncMovimientosProcessMED(){
	 
	  }*/
/*
	//************************* WSEncabezados *****************************************
	@future(callout = true)
	public static void ProcesarEncabezadosMED() {

		HttpResponse res = CallWSEncabezadosMED();
		if (res != null && res.getBody() != null && res.getBody() != '') {
			List<Encabezado__c> listenc = ParserEncabezado(res.getBody()); //Obtenemos datos de WS encabezados.
			//List<Detalle_de_Movimiento__c> listmov =ParserMovimientos(responseMov);//Obtenemos datos de WS movimientos.
			system.debug('listado de encabezados ' + listenc.size());
			// system.debug('listado de movimientos '+listmov.size()); 
			if (!listenc.isEmpty()) {
				insertaractualizarEncabezados(listenc); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}
		}
	}

	//Invocacion del servicio web de Capris

	public static HttpResponse CallWSEncabezadosMED() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);
			//String responseMov=CallWSMovimientos(fecha);//WS de Movimientos
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_EncMovimiento/webresources/app.entities.encmov/getEncFecha/MED-' + fecha);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);



		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarEncabezados(List<Encabezado__c> listaencabezados) {

		if (!listaencabezados.isEmpty()) {

			List<String> cuentasRelacionadasCod = new List<String> ();
			Map<String, String> mapCuentaIds = new map<String, String> ();
			List<Encabezado__c> encabezadosActualizados = new list<Encabezado__c> ();
			Id idSubCuenta = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sub Cuenta').getRecordTypeId();

			for (Encabezado__c e : listaencabezados) {

				if (e.EMV_NUM_CLIENTE__c != null && e.EMV_COD_ORG__c != null) {
					cuentasRelacionadasCod.add(e.EMV_NUM_CLIENTE__c);
				}

			} //for (Encabezado__c e : listaencabezados)           

			if (!cuentasRelacionadasCod.isEmpty()) {
				for (Account acc :[select id, name, num_cliente__c, org_id__c from Account where num_cliente__c != null and num_cliente__c in :cuentasRelacionadasCod and org_id__c != null and org_id__c = :'MED' and RecordTypeId = :idSubCuenta]) {
					mapCuentaIds.put(acc.num_cliente__c + acc.org_id__c, acc.Id);
				} //for (Account acc ...
			} //if(!cuentasRelacionadasCod.isEmpty())

			System.debug('**** mapCuentaIds ***** ' + mapCuentaIds.values().size());

			for (Encabezado__c e : listaencabezados) {
				if (mapCuentaIds != null && !mapCuentaIds.values().isEmpty() && mapCuentaIds.containsKey(e.EMV_NUM_CLIENTE__c + e.EMV_COD_ORG__c)) {
					e.Cliente__c = mapCuentaIds.get(e.EMV_NUM_CLIENTE__c + e.EMV_COD_ORG__c);
					encabezadosActualizados.add(e);
				}//if (mapCuentaIds != null & ...
			} //for (Encabezado__c e : listaencabezados)

			if (!encabezadosActualizados.isEmpty()) {
				try {
					upsert encabezadosActualizados Encabezado__c.ID_Capris__c;
				} catch(DmlException e) {
					System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
				}

			} //if (!encabezadosActualizados.isEmpty())		

		}//if (!listaencabezados.isEmpty())

	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Encabezado__c> ParserEncabezado(String xmlfile) {

		List<Encabezado__c> listEncabezado = new List<Encabezado__c> ();
		Encabezado__c encabezadoItem;
		System.Debug('**** xmlfile ParserEncabezado MED ***** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				encabezadoItem = new Encabezado__c();
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
					if (xmlNodeObjChild.getName() == 'emvCodMoneda' && xmlNodeObjChild.getText() != 'null')
					encabezadoItem.EMV_COD_MONEDA__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'emvCodPuntoFact' && xmlNodeObjChild.getText() != 'null')
					encabezadoItem.EMV_COD_PUNTO_FACT__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'emvCodUsuarioVend' && xmlNodeObjChild.getText() != 'null')
					encabezadoItem.EMV_COD_USUARIO_VEND__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'emvEstadoDoc' && xmlNodeObjChild.getText() != 'null')
					encabezadoItem.EMV_ESTADO_DOC__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'emvFecMovimiento' && xmlNodeObjChild.getText() != 'null')
					encabezadoItem.EMV_FEC_MOVIMIENTO__c = xmlNodeObjChild.getText();
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


					encabezadoItem.EMV_COD_ORG__c = 'MED';
					encabezadoItem.EMV_FYH_MODIFICA__c = Datetime.valueOf(system.now());
					//Incorporados por SAO 2017-11-10
					encabezadoItem.ID_Capris__c = encabezadoItem.EMV_COD_ORG__c + '|' + encabezadoItem.EMV_TIPO_MOV__c + '|' + encabezadoItem.EMV_COD_PUNTO_FACT__c + '-' + encabezadoItem.EMV_NUM_DOCUMENTO__c; //Adicionado por SAO
				}
				System.Debug(encabezadoItem);
				listEncabezado.add(encabezadoItem); //lista de encabezado  
			}
			Integer i = 0;
			for (Encabezado__c item : listEncabezado) {
				system.debug('Item de lista ' + i + ' encabezado ' + item);
				i++;
			}
		}

		System.Debug('$$$$$$$ listaaa ' + listEncabezado);
		return listEncabezado;
	}


	//********************** WSMovimientos **********************************************
	@future(callout = true)
	public static void ProcesarMovimientosMED() {
		HttpResponse res = new HttpResponse();
		res = CallWSMovimientosMED();
		if (res != null && res.getBody() != null && res.getBody() != '') {
			List<Detalle_de_Movimiento__c> listmov = ParserMovimientos(res.getBody()); //Obtenemos datos de WS movimientos.
			if (!listmov.isEmpty()) {
				insertaractualizarMovimientos(listmov); //Insertamos o actualizamos movientos segun sea el caso del resgistro enviado. 
			}
		}
	}

	public static HttpResponse CallWSMovimientosMED() {
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();

		try {
			string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_DetMovimiento/webresources/app.entities.detmov/getDetFecha/MED-' + fecha);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);


		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}

		return res;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarMovimientos(List<Detalle_de_Movimiento__c> listamovimientos) {

		try {
			Set<String> allmov = new Set<String> ();
			Map<String, String> encMap = new Map<String, String> ();
			List<Detalle_de_Movimiento__c> evaluadosMov = new List<Detalle_de_Movimiento__c> ();

			for (Detalle_de_Movimiento__c mov : listamovimientos) {
				//allmov.add(mov.DMV_NUM_DOCUMENTO_3__c); //guardamos numeros de documento para luego comparar contra encabezados
				allmov.add('MED'+'|'+mov.DMV_TIPO_MOV__c+'|'+mov.DMV_COD_PUNTO_FACT__c+'-'+mov.DMV_NUM_DOCUMENTO_3__c);
			}

			//Cuentas que coiciden con encabezados para relacionarlas
			for(Encabezado__c e:[SELECT Id, ID_Capris__c FROM Encabezado__c WHERE ID_Capris__c IN :allmov and EMV_COD_ORG__c = :'MED']){
				encMap.put(e.ID_Capris__c, e.Id);
			}

			//buscar coicidencia de encabezado en lista de movimientos 
			if(!encMap.values().isEmpty()){
				for (Detalle_de_Movimiento__c item : listamovimientos) {
					if(encMap.containsKey('MED'+'|'+item.DMV_TIPO_MOV__c+'|'+item.DMV_COD_PUNTO_FACT__c+'-'+item.DMV_NUM_DOCUMENTO_3__c)){

						item.Encabezado__c = encMap.get('MED'+'|'+item.DMV_TIPO_MOV__c+'|'+item.DMV_COD_PUNTO_FACT__c+'-'+item.DMV_NUM_DOCUMENTO_3__c);
						evaluadosMov.add(item);
					}
				}

				//Realizamos el upsert con la lista depurada para asociar a cuentas existentes 
				if(!evaluadosMov.isEmpty()){
					upsert evaluadosMov Detalle_de_Movimiento__c.IDMOV__c;			
				}
			}

		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Detalle_de_Movimiento__c> ParserMovimientos(String xmlfile) {

		List<Detalle_de_Movimiento__c> listMovimientos = new List<Detalle_de_Movimiento__c> ();
		Detalle_de_Movimiento__c movimientosItem;
		System.Debug('*** xmlfile  ParserMovimientos MED **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		//DOM.XMLNode rootElement = xmlDOC.getRootElement();
		//DOM.XMLNode rootElementSub = rootElement.getChildElements()[0];

		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {


				movimientosItem = new Detalle_de_Movimiento__c();

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

					//Id externo
					movimientosItem.IDMOV__c = 'MED' + movimientosItem.DMV_TIPO_MOV__c + movimientosItem.DMV_NUM_LINEA_3__c + movimientosItem.DMV_NUM_DOCUMENTO_3__c;
					movimientosItem.ID_Capris__c = 'MED'+'|'+movimientosItem.DMV_TIPO_MOV__c+'|'+movimientosItem.DMV_COD_PUNTO_FACT__c+'-'+movimientosItem.DMV_NUM_DOCUMENTO_3__c+'|'+movimientosItem.DMV_NUM_LINEA_3__c;
					movimientosItem.Name = movimientosItem.DMV_NUM_LINEA_3__c;

				}
				System.Debug(movimientosItem);
				listMovimientos.add(movimientosItem); //lista de movimientos  
			}
			Integer i = 0;
			for (Detalle_de_Movimiento__c item : listMovimientos) {
				system.debug('Item de lista ' + i + ' movimiento ' + item);
				i++;
			}
		}


		return listMovimientos;
	}

	*/
}