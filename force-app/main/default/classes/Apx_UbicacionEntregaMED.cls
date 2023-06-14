public class Apx_UbicacionEntregaMED {
	//constructor

	/* public Apx_UbicacionEntregaMED(){   
	  }*/
/*
	//************************* WSUbicacionEntrega *****************************************
	@future(callout = true)
	public static void ProcesarUEMED() {

		HttpResponse res = CallWSUbicacionEntregaMED();
		List<Ubicacion_de_Entrega__c> listue;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listue = ParserUE(res.getBody()); //Obtenemos datos de WS articulos. 
			System.debug('listue ProcesarUEMED MED ' + listue);
			if (!listue.isEmpty()) {
				insertaractualizarUE(listue); //Insertamos o actualizamos articulos.
			}
		}


	}
	//Invocacion del servicio web de Capris

	public static HttpResponse CallWSUbicacionEntregaMED() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_UbicEntrega/webresources/app.entities.ubicacionesentrega/MED-' + fecha);
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

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarUE(List<Ubicacion_de_Entrega__c> listaubcentre) {

		try {
			upsert listaubcentre Ubicacion_de_Entrega__c.IDUE__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Ubicacion_de_Entrega__c> ParserUE(String xmlfile) {

		List<Ubicacion_de_Entrega__c> listUbEnt = new List<Ubicacion_de_Entrega__c> ();
		Ubicacion_de_Entrega__c ueItem;
		System.Debug('**** xmlfile ParserUE ***** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);

		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {

				ueItem = new Ubicacion_de_Entrega__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
					if (xmlNodeObjChild.getName() == 'codcli' && xmlNodeObjChild.getText() != 'null')
					ueItem.NUM_CLIENTE__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'codube' && xmlNodeObjChild.getText() != 'null')
					ueItem.COD_UBIC_ENTR__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
					ueItem.DESCRIPCION__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'dir' && xmlNodeObjChild.getText() != 'null')
					ueItem.DIRECCION__c = xmlNodeObjChild.getText();

					//id externo unico a relacionar
					ueItem.Codigo_Compania__c = 'MED';
					ueItem.IDUE__c = 'MED' + ueItem.NUM_CLIENTE__c + ueItem.COD_UBIC_ENTR__c;
				}
				System.Debug(ueItem);
				listUbEnt.add(ueItem); //lista de encabezado  
			}
			Integer i = 0;
			for (Ubicacion_de_Entrega__c item : listUbEnt) {
				system.debug('Item de lista ' + i + ' ubicacion entrega ' + item);
				i++;
			}
		}

		System.Debug('$$$$$$$ ubicacion entrega ' + listUbEnt);
		return listUbEnt;
	}*/

}