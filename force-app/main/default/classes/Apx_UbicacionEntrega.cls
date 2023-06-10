public class Apx_UbicacionEntrega {

	//************************* WSUbicacionEntrega *****************************************
	@future(callout = true)
	public static void ProcesarUE(String compania) {

		HttpResponse res = CallWSUbicacionEntrega(compania);
		List<Ubicacion_de_Entrega__c> listue;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listue = ParserUE(res.getBody(), compania); //Obtenemos datos de WS articulos. 
			System.debug('listue ProcesarUECAP CAP ' + listue);
			if (!listue.isEmpty()) {
				insertaractualizarUE(listue,compania); //Insertamos o actualizamos articulos.
			}
		}
	}

	//Invocacion del servicio web de Capris
	//@future(callout=true) 
	public static HttpResponse CallWSUbicacionEntrega(String compania) {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			/*string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);*/
			Integer dia = system.now().day();
			Integer mes = system.now().month();
			Integer anno = system.now().year();
			Integer hora = system.now().hour()-1;
			system.debug('fecha 0 *** ' +dia+'.'+mes+'.'+anno+' '+ hora);
			string fecha = dia+'.'+mes+'.'+anno+' '+ hora;
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_UbicEntrega/webresources/app.entities.ubicacionesentrega/' + compania + '-' + fecha);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);


		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Ubicacion_de_Entrega__c> ParserUE(String xmlfile, String compania) {

		List<Ubicacion_de_Entrega__c> listUbEnt = new List<Ubicacion_de_Entrega__c> ();
		Ubicacion_de_Entrega__c ueItem;
		System.Debug('**** xmlfile ParserUE *****' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		Set<string> ubicacionesUnicas = new Set<String>();
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				ueItem = new Ubicacion_de_Entrega__c();
				Boolean bandera = false;
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
						
					if (xmlNodeObjChild.getName() == 'codube' && xmlNodeObjChild.getText() != 'null'){
						ueItem.COD_UBIC_ENTR__c = xmlNodeObjChild.getText();
					}
					
					if (xmlNodeObjChild.getName() == 'codcli' && xmlNodeObjChild.getText() != 'null'){
						ueItem.NUM_CLIENTE__c = xmlNodeObjChild.getText();
					}
					
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null'){
						ueItem.DESCRIPCION__c = xmlNodeObjChild.getText();
					}
					
					if (xmlNodeObjChild.getName() == 'dir' && xmlNodeObjChild.getText() != 'null'){
						ueItem.DIRECCION__c = xmlNodeObjChild.getText();
					}
					
					if(compania!=null&&ueItem.NUM_CLIENTE__c!=null&&ueItem.COD_UBIC_ENTR__c!=null&&!ubicacionesUnicas.contains(compania+ueItem.NUM_CLIENTE__c+ueItem.COD_UBIC_ENTR__c)){
						ueItem.Codigo_Compania__c = compania;
						ueItem.IDUE__c = compania + ueItem.NUM_CLIENTE__c + ueItem.COD_UBIC_ENTR__c;
						bandera = true;
						ubicacionesUnicas.add(compania+ueItem.NUM_CLIENTE__c+ueItem.COD_UBIC_ENTR__c);
					}
				}
				if(bandera){
					listUbEnt.add(ueItem); //lista de encabezado
				} 	

			}
		}
		System.Debug('listUbEnt ubicacion entrega **** ' + listUbEnt);
		return listUbEnt;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarUE(List<Ubicacion_de_Entrega__c> listaubcentre,String compania) {

		try {
		List<Ubicacion_de_Entrega__c> listaubcentreFinal = new List<Ubicacion_de_Entrega__c>();
		if(!listaubcentre.isEmpty()){
			Set<String> cuentasRelacionadasCod = new Set<String> ();
			Map<String, String> mapCuentaIds = new map<String, String> ();
			Id idSubCuenta = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sub Cuenta').getRecordTypeId();
			

			for(Ubicacion_de_Entrega__c ue:listaubcentre){
				if (ue.NUM_CLIENTE__c != null && ue.Codigo_Compania__c != null) {
					cuentasRelacionadasCod.add(ue.NUM_CLIENTE__c);
				}			
			}

			if(!cuentasRelacionadasCod.isEmpty()){
				for (Account acc :[select id, name, num_cliente__c, org_id__c from Account where num_cliente__c != null and num_cliente__c in :cuentasRelacionadasCod and org_id__c != null and org_id__c = :compania and RecordTypeId = :idSubCuenta]) {
					mapCuentaIds.put(acc.num_cliente__c + acc.org_id__c, acc.Id);
				} //for (Account acc ...			
			}
			
			for(Ubicacion_de_Entrega__c ue:listaubcentre){
				if (mapCuentaIds != null && !mapCuentaIds.values().isEmpty() && mapCuentaIds.containsKey(ue.NUM_CLIENTE__c + compania)) {
					ue.Cuenta__c = mapCuentaIds.get(ue.NUM_CLIENTE__c + compania);
					listaubcentreFinal.add(ue);
				} //if (mapCuentaIds != null &&...			
			}

		}
			if(!listaubcentreFinal.isEmpty()){
				upsert listaubcentreFinal Ubicacion_de_Entrega__c.IDUE__c;
			}
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}



}