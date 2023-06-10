public class Apx_JsonInsertEncabezados
{
	public String vacio{get;set;}
	public String IdOp{get;set;}
	public String compania{get;set;}
	public String codcliente{get;set;}
	public String numdoc{get;set;}
	public String ptoFac{get;set;}
	public String tipoMov{get;set;}
	public String idPrep{get;set;}
	public String etapa{get;set;}
	public String validador{get;set;}
	public String cantidad{get;set;}

	public Apx_JsonInsertEncabezados() {
		vacio = '';
		IdOp = ApexPages.currentPage().getParameters().get('IdOp');
		compania = ApexPages.currentPage().getParameters().get('compania');
		codcliente = ApexPages.currentPage().getParameters().get('codcliente');
		numdoc = ApexPages.currentPage().getParameters().get('numdoc');
		ptoFac = ApexPages.currentPage().getParameters().get('ptoFac');
		tipoMov = ApexPages.currentPage().getParameters().get('tipMov');
		idPrep = ApexPages.currentPage().getParameters().get('idPrep');
		etapa = ApexPages.currentPage().getParameters().get('etapa');
		validador = String.valueOf(ApexPages.currentPage().getParameters().get('validador'));
		cantidad = String.valueOf(ApexPages.currentPage().getParameters().get('cantidad'));

		System.debug('IdOp * ' + IdOp + ' compania * ' + compania + ' codcliente * ' + codcliente + ' numdoc * ' +numdoc + ' ptoFac * '+ ptoFac + ' tipoMov * ' + tipoMov + ' idPrep * ' +idPrep + ' etapa * ' + etapa + ' validador * ' +validador + ' cantidad * ' + cantidad);

		if (numdoc != null&&numdoc.contains('-')) {
			String[] numd = numdoc.split('-');
			numdoc = numd[0];
		}
		System.debug('numdoc * ' + numdoc);
		if (ptoFac != null &&ptoFac.contains('-')) {
			String[] ptof = ptoFac.split('-');
			ptoFac = ptof[0];
		}
		System.debug('ptoFac * ' + ptoFac);
	}

	//pedidos a procesar y enviar a Capris 
	public String EnviaDatosPedidos(String IdOp, String compania, String codcliente, String numdoc) {
		List<Opportunity> pedidosEnc = new List<Opportunity> ();
		String vacio = '';
		system.debug('Dentro de envioencabezados ' + IdOp + compania + codcliente + numdoc);
		//pedidosEnc=[Select Id,EMV_COD_ORG__c,EmvCodBodega__c,EMV_CODURE__c, EMV_TIPO_MOV__c,StageName, EMV_NUM_CLIENTE__c,EMV_NOM_CLIENTE__c, EMV_COD_USUARIO_VEND__c, EMV_ESTADO_DOC_del__c, EMV_VIA__c, EMV_TIP_CAMBIO__c, EMV_MON_RECARGO__c, EMV_OBSERV_IMPRESA__c, EMV_OBSERV_INTERNA__c, EMV_OBS_ADD__c, EMV_ID_WEB__c, EMV_IDTARJ__c, EMV_COD_PUNTO_FACT__c, Muelle__c, EMV_COD_UBIC_ENTR__c, EMV_FEC_ENT__c, EMV_NUM_DOCUMENTO__c, EMV_COD_MONEDA__c, EMV_PLAZO_DOC__c, EMV_FEC_MOVIMIENTO__c,Gran_Total__c,Total_de_Impuesto__c,Total_de_Descuento__c,EMV_USU_MODIFICA__c,EMV_FYH_MODIFICA__c,LastModifiedDate,Enviar_a_Cr_dito__c  FROM Opportunity WHERE Id=:IdOp];
		pedidosEnc = [Select Id, EMV_COD_ORG__c, EmvCodBodega__c, EMV_CODURE__c, EMV_TIPO_MOV__c, StageName, EMV_NUM_CLIENTE__c, EMV_NOM_CLIENTE__c, EMV_USU_FACTURA__c, EMV_USU_FACTURA__r.Name, EMV_ESTADO_DOC_del__c, EMV_VIA__c, EMV_TIP_CAMBIO__c, EMV_MON_RECARGO__c, EMV_OBSERV_IMPRESA__c, EMV_OBSERV_INTERNA__c, EMV_OBS_ADD__c, EMV_ID_WEB__c, EMV_IDTARJ__c, PuntoFactRelacionado__c, PuntoFactRelacionado__r.PTO_COD_PTO__c, MuelleRelacion__c, MuelleRelacion__r.GES_MUE_COD__c, EMV_COD_UBIC_ENTR__c, EMV_FEC_ENT__c, NumeroDocumento__c, EMV_COD_MONEDA__c, EMV_PLAZO_DOC__c, EMV_FEC_MOVIMIENTO__c, Gran_Total__c, Total_de_Impuesto__c, Total_de_Descuento__c, EMV_USU_MODIFICA__c, EMV_FYH_MODIFICA__c, LastModifiedDate, Enviar_a_Cr_dito__c FROM Opportunity WHERE Id = :IdOp];
		String Url;
		String datos;
		String resultado;
		if (!pedidosEnc.isEmpty()) {
			system.debug('pedidosEnc ' + pedidosEnc.size());
			system.debug('pedidosEnc data encontrada' + pedidosEnc);
			for (Opportunity item : pedidosEnc) {
				Url = '';
				datos = '';
				Datetime GMTDate = item.EMV_FYH_MODIFICA__c;
				String strConvertedDate = GMTDate.format('dd-MM-yyyy%20HH:mm:ss');
				system.debug('Fecha dataformat ' + strConvertedDate);
				String fecmovimiento = String.valueOf(item.EMV_FEC_MOVIMIENTO__c);
				fecmovimiento = fecmovimiento.replace('/', '-');
				fecmovimiento = fecmovimiento.substring(0, fecmovimiento.length() - 9);

				//seteo de campos
				String PLAZO_DOC;
				String ID_WEB;
				String IDTARJ;
				String CODURE;
				String VIA;
				String CodBodega;
				String COD_MUELLE;
				String UBIC_ENTR;
				String COD_USUARIO;
				String PTO_F;
				String USUR_ENVIAR_CREDITO;

				if (item.Enviar_a_Cr_dito__c) {
					USUR_ENVIAR_CREDITO = 'C';
				} else {
					USUR_ENVIAR_CREDITO = 'P';
				}

				if (item.EMV_PLAZO_DOC__c == null) {
					PLAZO_DOC = '0';
				} else {
					PLAZO_DOC = item.EMV_PLAZO_DOC__c;
				}
				if (item.EMV_ID_WEB__c == null) {
					ID_WEB = '0';
				} else {
					ID_WEB = '0';
				}
				if (item.EMV_IDTARJ__c == null) {
					IDTARJ = '0';
				} else {
					IDTARJ = item.EMV_IDTARJ__c;
				}
				if (item.EMV_CODURE__c == null) {
					CODURE = '0';
				} else {
					CODURE = item.EMV_CODURE__c;
				}
				if (item.EMV_VIA__c == null) {
					VIA = '0';
				} else {
					VIA = '0';
				}
				if (item.EmvCodBodega__c == null) {
					CodBodega = '0';
				} else {
					CodBodega = item.EmvCodBodega__c;
				}
				/*if(item.Muelle__c==null){
				  COD_MUELLE='0';
				  }else{
				  String[] muelle=item.Muelle__c.split('-');
				  COD_MUELLE=muelle[0];// 
				  }*/
				if (item.MuelleRelacion__c == null) {
					COD_MUELLE = '0';
				} else {
					COD_MUELLE = item.MuelleRelacion__r.GES_MUE_COD__c;
				}

				if (item.EMV_COD_UBIC_ENTR__c == null) {
					UBIC_ENTR = '0';
				} else {
					UBIC_ENTR = item.EMV_COD_UBIC_ENTR__c;
				}

				/*if(item.EMV_COD_USUARIO_VEND__c==null){
				  COD_USUARIO='0';
				  }else{
				  String[] codusu=item.EMV_COD_USUARIO_VEND__c.split('-');
				  COD_USUARIO=codusu[0];// 
				  }*/
				if (item.EMV_USU_FACTURA__c == null) {
					COD_USUARIO = '0';
				} else {
					COD_USUARIO = item.EMV_USU_FACTURA__r.Name;
				}

				/*if(item.EMV_COD_PUNTO_FACT__c==null){
				  PTO_F='0';
				  }else{
				  String[] pto=item.EMV_COD_PUNTO_FACT__c.split('-');
				  PTO_F=pto[0];// 
				  }*/

				if (item.PuntoFactRelacionado__c == null) {
					PTO_F = '0';
				} else {
					PTO_F = item.PuntoFactRelacionado__r.PTO_COD_PTO__c;
				}

				/*String NUM_DOCUMENTO;
				  if(item.EMV_NUM_DOCUMENTO__c==null){
				  NUM_DOCUMENTO='0';
				  }else{
				  //String[] doc=item.EMV_NUM_DOCUMENTO__c.split('-');
				  NUM_DOCUMENTO=item.EMV_NUM_DOCUMENTO__c;// 
				  }*/
				String NUM_DOCUMENTO;
				if (item.NumeroDocumento__c == null) {
					NUM_DOCUMENTO = '0';
				} else {
					NUM_DOCUMENTO = item.NumeroDocumento__c;
				}

				String MON_RECARGO;
				if (item.EMV_MON_RECARGO__c == null) {
					MON_RECARGO = '%20';
				} else {
					MON_RECARGO = String.valueOf(item.EMV_MON_RECARGO__c.round(System.RoundingMode.CEILING)); // 
				}
				String OBSERV_IMPRESA;
				if (item.EMV_OBSERV_IMPRESA__c == null) {
					OBSERV_IMPRESA = '%20';
				} else {
					OBSERV_IMPRESA = item.EMV_OBSERV_IMPRESA__c.replace('/', '|'); // 
				}
				String OBSERV_INTERNA;
				if (item.EMV_OBSERV_INTERNA__c == null) {
					OBSERV_INTERNA = '%20';
				} else {
					OBSERV_INTERNA = item.EMV_OBSERV_INTERNA__c.replace('/', '|'); // 
				}

				system.debug('MON_RECARGO ' + MON_RECARGO + 'NUM_DOCUMENTO ' + NUM_DOCUMENTO + 'COD_USUARIO ' + COD_USUARIO + ' PTO_F' + PTO_F + ' UBIC_ENTR ' + UBIC_ENTR + 'COD_MUELLE ' + COD_MUELLE);
				datos = item.EMV_COD_ORG__c + '/' + item.EMV_TIPO_MOV__c + '/' + PTO_F + '/' + CodBodega + '/' + NUM_DOCUMENTO + '/' + fecmovimiento + '/' + fecmovimiento + '/' + item.EMV_NUM_CLIENTE__c + '/' + item.EMV_NOM_CLIENTE__c + '/' + PLAZO_DOC + '/' + '0' + '/' + '0' + '/' + USUR_ENVIAR_CREDITO + '/' + COD_USUARIO + '/' + item.EMV_COD_MONEDA__c + '/' + item.EMV_TIP_CAMBIO__c.round(System.RoundingMode.CEILING) + '/' + item.EMV_ESTADO_DOC_del__c + '/' + VIA + '/' + '0' + '/' + item.Total_de_Descuento__c.round(System.RoundingMode.CEILING) + '/' + item.Total_de_Impuesto__c.round(System.RoundingMode.CEILING) + '/' + item.Gran_Total__c.round(System.RoundingMode.CEILING) + '/' + MON_RECARGO + '/' + item.EMV_COD_ORG__c + '/' + item.EMV_TIPO_MOV__c + '/' + PTO_F + '/' + NUM_DOCUMENTO + '/' + item.EMV_USU_MODIFICA__c + '/' + strConvertedDate + '/' + item.EMV_OBSERV_IMPRESA__c + '/' + item.EMV_OBSERV_INTERNA__c + '/' + UBIC_ENTR + '/' + COD_MUELLE + '/' + '0' + '/' + '0' + '/' + '0' + '/' + strConvertedDate + '/' + ID_WEB + '/' + IDTARJ + '/' + '0';

				System.debug('Datos ' + datos);
				Url = 'http://bd2.capris.cr:64423/Salesforce_EncMov/webresources/app.entities.sfcencmov/' + datos.replaceAll('null', '%20');
				System.debug('URL encabezado -- ' + Url);
				String response = CallWSInsertEncabezados(Url);
				resultado = response + '-' + Url;
				//Envio de datos a Capris

				Boolean procesada = VerificarResponse(response); //verificar si retorna un xml valido indicando que se insertaron los datos.
				System.debug('Procesados = ' + procesada + '-->' + response);
				//verificar si pedido fue procesado o enviado a la bd y ponerlo en estado de enviado o procesado
				if (procesada) {
					// ActualizaEstadoTransOP(item.Id);
					item.Procesado__c = true;
					item.Procesar__c = false;

				} else {
					item.Procesado__c = false;
					item.Procesar__c = true;

				}
			} }
		return resultado;
	}

	/*public void ActualizaEstadoTransOP(String idOp) {
		try {
			Opportunity opt = new Opportunity();
			opt = [Select id, EMV_ESTADO_DOC_del__c from Opportunity where id = :idOp];
			opt.EMV_ESTADO_DOC_del__c = 'TRANS';
			Upsert opt;
		} catch(Exception e) {
			System.debug('Error en actualizacion ' + ' Message ' + e.getMessage() + '- Linea code' + e.getLineNumber());
		}

	}*/

	//genera string json para envio de encabezados
	public String EnviarDetallesPedidos(String idOP, String numDoc, String compania, String ptoF) {
		String result;
		List<Opportunity> pedidos = new List<Opportunity> ();
		List<OpportunityLineItem> detalles = new List<OpportunityLineItem> ();
		Map<String, Opportunity> pedidosMap = new Map<String, Opportunity> ();
		Set<String> allPedidos = new Set<String> ();
		String vacio = '';
		String Url;
		String datos;
		//Obtener detalles de oportunidad
		detalles = [Select Id, OpportunityId, DMV_COD_OFERTA__c, Monto_de_Descuento__c, DMV_COD_ORG__c, DMV_TIPO_MOV__c, DMV_NUM_DOCUMENTO__c, DMV_NUM_LINEA__c, Precio_especial_c__c, Subtotal__c, ID_de_Salesforce__c, DMV_USU_MODIFIC__c, DMV_FYH_MODIFICA__c, DMV_COD_PRODUCTO__c, ESTADO__c, Quantity, UnitPrice, Discount, Description FROM OpportunityLineItem where OpportunityId = :idOP and DMV_NUM_DOCUMENTO__c = :numDoc and DMV_COD_ORG__c = :compania];

		system.debug('Detalles encontrados ' + detalles.size());
		if (!detalles.isEmpty()) {
			for (OpportunityLineItem opdetItem : detalles)
			{
				//Opportunity op = pedidosMap.get(opdetItem.OpportunityId);//encontro id asociado
				// if(op!=null){
				Url = '';
				datos = '';
				Datetime GMTDate = opdetItem.DMV_FYH_MODIFICA__c;
				String strConvertedDate = GMTDate.format('dd-MM-yyyy%20HH:mm:ss');
				String COD_OFERTA;
				if (opdetItem.DMV_COD_OFERTA__c == null) {
					COD_OFERTA = '0';
				} else {
					COD_OFERTA = opdetItem.DMV_COD_OFERTA__c;
				}
				String DESCUENTO;
				if (opdetItem.Discount == null) {
					DESCUENTO = '%20';
				} else {
					DESCUENTO = String.valueOf(opdetItem.Discount.round(System.RoundingMode.CEILING));
				}
				String PRECIOESPECIAL;
				if (opdetItem.Precio_especial_c__c == null) {
					PRECIOESPECIAL = '%20';
				} else {
					PRECIOESPECIAL = String.valueOf(opdetItem.Precio_especial_c__c.round(System.RoundingMode.CEILING));
				}
				String DESCRIPCION;
				if (opdetItem.Description == null) {
					DESCRIPCION = '%20';
				} else {
					DESCRIPCION = opdetItem.Description.replace('/', '|');
				}

				system.debug('Pto ' + ptoF);
				//+opdetItem.UnitPrice.round(System.RoundingMode.CEILING)+'&dmvPrecioEspecial='+'0'+'&dmvDescDet='+opdetItem.Discount.round(System.RoundingMode.CEILING)+'&dmvDescDis='+'0'+'&dmvDescEsp='+'0'+'&dmvPorIva='+opdetItem.Precio_I_V_I__c.round(System.RoundingMode.CEILING)+'&dmvEstado='+opdetItem.ESTADO__c=null?vacio:opdetItem.ESTADO__c+'&dmvFyhModifica='+opdetItem.DMV_FYH_MODIFICA__c+'&dmvUsuModifica='+opdetItem.DMV_USU_MODIFIC__c+'&dmvObservaciones='+opdetItem.Description==null?vacio:opdetItem.Description+'&dmvCodOferta='+opdetItem.DMV_COD_OFERTA__c==null? vacio:opdetItem.DMV_COD_OFERTA__c;
				datos = opdetItem.DMV_COD_ORG__c + '/' + opdetItem.DMV_TIPO_MOV__c + '/' + ptoF + '/' + opdetItem.DMV_NUM_DOCUMENTO__c + '/' + opdetItem.DMV_NUM_LINEA__c + '/' + opdetItem.DMV_COD_PRODUCTO__c + '/' + opdetItem.Quantity.round(System.RoundingMode.CEILING) + '/' + 'B' + '/' + opdetItem.UnitPrice.round(System.RoundingMode.CEILING) + '/' + '0' + '/' + '0' + '/' + '0' + '/' + '0' + '/' + '0' + '/' + DESCUENTO + '/' + opdetItem.ESTADO__c + '/' + strConvertedDate + '/' + opdetItem.DMV_USU_MODIFIC__c + '/' + DESCRIPCION + '/' + 'usr' + '/' + COD_OFERTA;

				//System.debug('Datos '+opdetItem.DMV_COD_ORG__c+'/'+opdetItem.DMV_TIPO_MOV__c+'/'+ptoF+'/'+opdetItem.DMV_NUM_DOCUMENTO__c+'/'+opdetItem.DMV_NUM_LINEA__c+'/'+opdetItem.DMV_COD_PRODUCTO__c+'/'+opdetItem.Quantity.round(System.RoundingMode.CEILING)+'/'+'B'+'/'+opdetItem.UnitPrice.round(System.RoundingMode.CEILING)+'/'+'0'+'/'+'0'+'/'+'0'+'/'+'0'+'/'+'0'+'/'+DESCUENTO+'/'+opdetItem.ESTADO__c+'/'+strConvertedDate+'/'+opdetItem.DMV_USU_MODIFIC__c+'/'+opdetItem.Description+'/'+'usr'+'/'+COD_OFERTA);
				Url = 'http://bd2.capris.cr:64423/Salesforce_DetMov/webresources/app.entities.sfcdetmov/' + datos.replace('null', '%20');
				System.debug('URL detalles' + Url);

				String response = CallWSInsertDetalles(Url); //Envio de datos a Capris
				System.debug('response ' + response);
				result = response;
				Boolean procesada = VerificarResponse(response); //verificar si retorna un xml valido indicando que se insertaron los datos.    
				//verificar si pedido fue procesado o enviado a la bd y ponerlo en estado de enviado o procesado
				if (procesada) {
					System.debug('Procesado item ' + opdetItem);
				} else {
					System.debug('No Procesado item ' + opdetItem);
				}
			}
		}

		//}
		return result;
	}

	//proformas a procesar y enviar a Capris
	public String EnviaDatosProformas(String idPrep) {
		String respuesta;
		List<Quote> proformasEnc = new List<Quote> ();

		//proformasEnc = [Select Id, Name, EMV_FYH_MODIFICA__c, OpportunityId, Subtotal, TotalPrice, LineItemCount, GrandTotal, EMV_CODURE__c, Status, EMV_COD_BODEGA__c, EMV_OBS_ADD__c, EMV_VIA__c, EMV_OBSERV_IMPRESA__c, Total_de_Impuesto__c, Total_I_V_I__c, EMV_COD_USUARIO_VEND__c, EMV_TIP_CAMBIO__c, EMV_USU_MODIFICA__c, EMV_OBSERV_INTERNA__c, EMV_IDTARJ__c, EMV_COD_MONEDA__c, EMV_PLAZO_DOC__c, EMV_TIPO_MOV__c, Cant_de_Art_culos_en_este_Pedido__c, EMV_FEC_ENT__c, EMV_FEC_MOVIMIENTO__c, EMV_ID_WEB__c, EMV_MON_RECARGO__c, EMV_COD_MUELLE__c, EMV_COD_PUNTO_FACT__c, EMV_NUM_DOCUMENTO__c, Total_de_Descuento__c, Gran_Total__c, EMV_COD_ORG__c, EMV_NUM_CLIENTE__c, EMV_NOM_CLIENTE__c, EMV_COD_UBIC_ENTR__c FROM Quote WHERE Id = :idPrep];
		proformasEnc = [Select Id, Name, EMV_FYH_MODIFICA__c, OpportunityId, Subtotal, TotalPrice, LineItemCount, GrandTotal, EMV_CODURE__c, Status, EMV_COD_BODEGA__c, EMV_OBS_ADD__c, EMV_VIA__c, EMV_OBSERV_IMPRESA__c, Total_de_Impuesto__c, Total_I_V_I__c, EMV_COD_USUARIO_VEND__c, EMV_TIP_CAMBIO__c, EMV_USU_MODIFICA__c, EMV_OBSERV_INTERNA__c, EMV_IDTARJ__c, EMV_COD_MONEDA__c, EMV_PLAZO_DOC__c, EMV_TIPO_MOV__c, Cant_de_Art_culos_en_este_Pedido__c, EMV_FEC_ENT__c, EMV_FEC_MOVIMIENTO__c, EMV_ID_WEB__c, EMV_MON_RECARGO__c, EMV_COD_MUELLE__c, PuntoFactQuote__c,EMV_NUM_DOCUMENTO__c, Total_de_Descuento__c, Gran_Total__c, EMV_COD_ORG__c, EMV_NUM_CLIENTE__c, EMV_NOM_CLIENTE__c, EMV_COD_UBIC_ENTR__c FROM Quote WHERE Id = :idPrep];

		String Url;
		String datos;
		if (!proformasEnc.isEmpty()) {
			for (Quote itemQ : proformasEnc) {
				Url = '';
				datos = '';
				Datetime GMTDate = itemQ.EMV_FYH_MODIFICA__c;
				String strConvertedDate = GMTDate.format('dd-MM-yyyy%20HH:mm:ss');
				String fecmovimiento = String.valueOf(itemQ.EMV_FEC_MOVIMIENTO__c);
				fecmovimiento = fecmovimiento.replace('/', '-');
				fecmovimiento = fecmovimiento.substring(0, fecmovimiento.length() - 9);

				//seteo de campos
				String PLAZO_DOC;
				String ID_WEB;
				String IDTARJ;
				String CODURE;
				String VIA;
				String CodBodega;
				String COD_MUELLE;
				String UBIC_ENTR;
				String COD_USUARIO;
				String PTO_F;
				String USUR_ENVIAR_CREDITO;
				String ESTADO_DOC;


				if (itemQ.EMV_PLAZO_DOC__c == null) {
					PLAZO_DOC = '0';
				} else {
					PLAZO_DOC = itemQ.EMV_PLAZO_DOC__c;
				}
				if (itemQ.EMV_ID_WEB__c == null) {
					ID_WEB = '0';
				} else {
					ID_WEB = '0';
				}
				if (itemQ.EMV_IDTARJ__c == null) {
					IDTARJ = '0';
				} else {
					IDTARJ = itemQ.EMV_IDTARJ__c;
				}
				if (itemQ.EMV_CODURE__c == null) {
					CODURE = '0';
				} else {
					CODURE = itemQ.EMV_CODURE__c;
				}
				if (itemQ.EMV_VIA__c == null) {
					VIA = '0';
				} else {
					VIA = itemQ.EMV_VIA__c;
				}
				if (itemQ.EMV_COD_BODEGA__c == null) {
					CodBodega = '0';
				} else {
					CodBodega = itemQ.EMV_COD_BODEGA__c;
				}
				if (itemQ.EMV_COD_MUELLE__c == null) {
					COD_MUELLE = '0';
				} else {
					String[] muelle = itemQ.EMV_COD_MUELLE__c.split('-');
					COD_MUELLE = muelle[0]; // 

				}
				if (itemQ.EMV_COD_UBIC_ENTR__c == null) {
					UBIC_ENTR = '0';
				} else {
					UBIC_ENTR = itemQ.EMV_COD_UBIC_ENTR__c;
				}

				if (itemQ.EMV_COD_USUARIO_VEND__c == null) {
					COD_USUARIO = '0';
				} else {
					String[] codusu = itemQ.EMV_COD_USUARIO_VEND__c.split('-');
					COD_USUARIO = codusu[0]; // 
				}

				/*
				**** PROFORMAS **** 
				if (itemQ.EMV_COD_PUNTO_FACT__c == null) {
					PTO_F = '0';
				} else {
					String[] pto = itemQ.EMV_COD_PUNTO_FACT__c.split('-');
					PTO_F = pto[0];
				}*/

				if (itemQ.PuntoFactQuote__c == null) {
					PTO_F = '0';
				} else {
					PTO_F = itemQ.PuntoFactQuote__c;
				}
				

				String NUM_DOCUMENTO;
				if (itemQ.EMV_NUM_DOCUMENTO__c == null) {
					NUM_DOCUMENTO = '0';
				} else {
					NUM_DOCUMENTO = itemQ.EMV_NUM_DOCUMENTO__c; // 
				}
				String MON_RECARGO;
				if (itemQ.EMV_MON_RECARGO__c == null) {
					MON_RECARGO = '%20';
				} else {
					MON_RECARGO = String.valueOf(itemQ.EMV_MON_RECARGO__c.round(System.RoundingMode.CEILING)); // 
				}
				String OBSERV_IMPRESA;
				if (itemQ.EMV_OBSERV_IMPRESA__c == null) {
					OBSERV_IMPRESA = '%20';
				} else {
					OBSERV_IMPRESA = (itemQ.EMV_OBSERV_IMPRESA__c).replace('/', '-'); // 
				}
				String OBSERV_INTERNA;
				if (itemQ.EMV_OBSERV_INTERNA__c == null) {
					OBSERV_INTERNA = '%20';
				} else {
					OBSERV_INTERNA = (itemQ.EMV_OBSERV_INTERNA__c).replace('/', '-'); // 
				}
				String ESTADO_PROFORMA;
				if (itemQ.Status == 'PEND') {
					ESTADO_PROFORMA = itemQ.Status;
				}
				datos = itemQ.EMV_COD_ORG__c + '/' + itemQ.EMV_TIPO_MOV__c + '/' + PTO_F + '/' + CodBodega + '/' + NUM_DOCUMENTO + '/' + fecmovimiento + '/' + fecmovimiento + '/' + itemQ.EMV_NUM_CLIENTE__c + '/' + itemQ.EMV_NOM_CLIENTE__c + '/' + PLAZO_DOC + '/' + '0' + '/' + '0' + '/' + '%20' + '/' + COD_USUARIO + '/' + itemQ.EMV_COD_MONEDA__c + '/' + itemQ.EMV_TIP_CAMBIO__c.round(System.RoundingMode.CEILING) + '/' + ESTADO_PROFORMA + '/' + VIA + '/' + '0' + '/' + itemQ.Total_de_Descuento__c.round(System.RoundingMode.CEILING) + '/' + itemQ.Total_de_Impuesto__c.round(System.RoundingMode.CEILING) + '/' + itemQ.Gran_Total__c.round(System.RoundingMode.CEILING) + '/' + MON_RECARGO + '/' + itemQ.EMV_COD_ORG__c + '/' + itemQ.EMV_TIPO_MOV__c + '/' + PTO_F + '/' + NUM_DOCUMENTO + '/' + itemQ.EMV_USU_MODIFICA__c + '/' + strConvertedDate + '/' + OBSERV_IMPRESA + '/' + OBSERV_INTERNA + '/' + UBIC_ENTR + '/' + COD_MUELLE + '/' + '0' + '/' + '0' + '/' + '0' + '/' + strConvertedDate + '/' + ID_WEB + '/' + IDTARJ + '/' + '0';
				System.debug('Datos 0 ' + datos);
				System.debug('Datos 1 ' + datos.replaceAll('null', '%20'));
				Url = 'http://bd2.capris.cr:64423/Salesforce_EncMov/webresources/app.entities.sfcencmov/' + datos.replace('null', '%20');
				System.debug('URL ' + Url);

				String response = CallWSInsertEncabezados(Url); //Envio de datos a Capris
				Boolean procesada = VerificarResponse(response); //verificar si retorna un xml valido indicando que se insertaron los datos.

				//verificar si pedido fue procesado o enviado a la bd y ponerlo en estado de enviado o procesado
				if (procesada) {
					//ActualizaEstadoTransPrep(itemQ.Id);
					respuesta = response;
				} else {
					respuesta = response;
				}
			}
		}
		return respuesta;
	}

	//Actualiza estado de enviado
	/*public void ActualizaEstadoTransPrep(String idPrep) {
		try {
			Quote prep = new Quote();
			prep = [Select id, Status
			        from Quote where id = :idPrep];
			prep.Status = 'Transmitir';
			Upsert prep prep.Id;
		} catch(Exception e) {
			System.debug('Error en actualizacion ' + ' Message ' + e.getMessage() + '- Linea code' + e.getLineNumber());
		}

	}*/

	//genera envio de detalles proformas
	public String EnviarDetallesProformas(String idPrep, String numDoc, String ptoF) {
		String respuesta;
		List<Quote> proformas = new List<Quote> ();
		List<QuoteLineItem> detalles = new List<QuoteLineItem> ();
		Map<String, Quote> proformasMap = new Map<String, Quote> ();
		Set<String> allProformas = new Set<String> ();

		detalles = [Select Id, DMV_COD_OFERTA__c, QuoteId, Quantity, UnitPrice, Discount, Description, Monto_I_V__c, Precio_I_V_I__c, Monto_de_Descuento__c, DMV_NUM_LINEA_2__c, DMV_COD_PRODUCTO_2__c, Precio_Especial__c, ID_de_Salesforce__c, Subtotal__c, DMV_USU_MODIFICA__c, DMV_FYH_MODIFICA_2__c, DMV_COD_ORG__c, DMV_TIPO_MOV__c, DMV_NUM_DOCUMENTO__c, ESTADO_PROFORMA__c FROM QuoteLineItem WHERE QuoteId = :idPrep];

		String Url;
		String datos;
		system.debug('Detalles encontrados ' + detalles);
		if (!detalles.isEmpty()) {
			for (QuoteLineItem qdetItem : detalles)
			{
				Url = '';
				datos = '';
				Datetime GMTDate = qdetItem.DMV_FYH_MODIFICA_2__c;
				String strConvertedDate = GMTDate.format('dd-MM-yyyy%20HH:mm:ss');
				String COD_OFERTA;
				if (qdetItem.DMV_COD_OFERTA__c == null) {
					COD_OFERTA = '0';
				} else {
					COD_OFERTA = qdetItem.DMV_COD_OFERTA__c;
				}
				String DESCUENTO;
				if (qdetItem.Discount == null) {
					DESCUENTO = '%20';
				} else {
					DESCUENTO = String.valueOf(qdetItem.Discount.round(System.RoundingMode.CEILING));
				}
				String PRECIOESPECIAL;
				if (qdetItem.Precio_Especial__c == null) {
					PRECIOESPECIAL = '%20';
				} else {
					PRECIOESPECIAL = String.valueOf(qdetItem.Precio_Especial__c.round(System.RoundingMode.CEILING));
				}

				String OBSERVA;
				if (qdetItem.Description == null) {
					OBSERVA = '%20';
				} else {
					OBSERVA = qdetItem.Description.replace('/', '-');
				}
				String ESTADO_PROFORMA;
				if (qdetItem.ESTADO_PROFORMA__c == 'Pediente') {
					ESTADO_PROFORMA = 'PEND';
				}
				datos = qdetItem.DMV_COD_ORG__c + '/' + qdetItem.DMV_TIPO_MOV__c + '/' + ptoF + '/' + qdetItem.DMV_NUM_DOCUMENTO__c + '/' + qdetItem.DMV_NUM_LINEA_2__c + '/' + qdetItem.DMV_COD_PRODUCTO_2__c + '/' + qdetItem.Quantity.round(System.RoundingMode.CEILING) + '/' + 'B' + '/' + qdetItem.UnitPrice.round(System.RoundingMode.CEILING) + '/' + '0' + '/' + '0' + '/' + '0' + '/' + '0' + '/' + '0' + '/' + DESCUENTO + '/' + ESTADO_PROFORMA + '/' + strConvertedDate + '/' + qdetItem.DMV_USU_MODIFICA__c + '/' + OBSERVA + '/' + 'usr' + '/' + COD_OFERTA;

				System.debug('Datos ' + datos.replaceAll('null', '%20'));
				Url = 'http://bd2.capris.cr:64423/Salesforce_DetMov/webresources/app.entities.sfcdetmov/' + datos.replace('null', '%20');
				System.debug('URL ' + Url);
				String response = CallWSInsertDetalles(Url); //Envio de datos a Capris
				Boolean procesada = VerificarResponse(response); //verificar si retorna un xml valido indicando que se insertaron los datos.    

				//verificar si pedido fue procesado o enviado a la bd y ponerlo en estado de enviado o procesado
				if (procesada) {
					respuesta = response;
				} else {
					respuesta = response;
				}

			}
		}
		return respuesta;
	}

	//Verificar si se ingreso correctamente el registro en la BD
	public Boolean VerificarResponse(String xmlresponse) {
		Boolean resultado;

		try {
			DOM.Document xmlDOC = new DOM.Document();

			xmlDOC.load(xmlresponse);
			DOM.XMLNode rootElement = xmlDOC.getRootElement();
			DOM.XMLNode rootElementSub = rootElement.getChildElements() [0];

			if (rootElement != null && rootElementSub != null) {
				resultado = true; //se inserto satisfactoriamente.
				system.debug('Response verificado es un xml valido ' + xmlresponse);
			}
		} catch(Exception e) {
			resultado = false;
			system.debug('Response verificado no es un xml valido.Error ' + e.getMessage());
		}

		return resultado;
	}

	//Invocacion del servicio web de Capris para renotorno de encabezados de Pedidos y Proformas
	public String CallWSInsertEncabezados(String Url) {
		HttpResponse res;
		String respuesta = '';
		try {
			//Request del servicio
			HttpRequest req = new HttpRequest();
			req.setEndpoint(Url);
			req.setMethod('GET');
			//req.setBody(body)
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);
			respuesta = res.getBody();

			if (res.getStatus().equals('Internal Server Error') || res.getStatus().equals('Not Found')) {
				respuesta = 'Codigo error' + res.getStatusCode() + '-' + res.getStatus();
			} else {
				respuesta = res.getBody();
			}
			system.debug('Response ' + res.getBody());
			system.debug('Response cause ' + res.getStatus());
			system.debug('Response cause ' + res.getStatusCode());

		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return respuesta;
	}

	//Invocacion del servicio web de Capris para renotorno de detalles de Pedidos y Proformas
	public String CallWSInsertDetalles(String Url) {
		HttpResponse res;
		String respuesta = '';
		try {
			//Request del servicio
			HttpRequest req = new HttpRequest();
			req.setEndpoint(Url);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);
			if (res.getStatus().equals('Internal Server Error')) {
				respuesta = 'Codigo error' + res.getStatusCode() + '-' + res.getStatus();
			} else {
				respuesta = res.getBody();
			}
			system.debug('Response ' + res.getBody());
			system.debug('Response cause ' + res.getStatus());
			system.debug('Response cause ' + res.getStatusCode());

		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return respuesta;
	}

	//Enviar pedido
	public PageReference enviar() {

		//Procesar envio de pedidos

		List<Opportunity> encabezadoPedidos = new List<Opportunity> ();
		List<OpportunityLineItem> detallePedidos = new List<OpportunityLineItem> ();
		List<Quote> encabezadoProforma = new List<Quote> ();
		List<QuoteLineItem> detalleProforma = new List<QuoteLineItem> ();
		QuoteLineItem itm = new QuoteLineItem();
		PageReference pageRef;

		try {
			system.debug('entra a enviar Page Reference | op: ' + IdOp + ' | numdoc ' + numdoc + ' | tipoMov ' + tipoMov);
			
			if (tipoMov.equals('PEDIDO')) { //PEDIDOS  
				//verificar si existen productos en el pedido para enviar 
				detallePedidos = [Select id, name from OpportunityLineItem where OpportunityId = :IdOp and DMV_NUM_DOCUMENTO__c = :numdoc];
				if (!detallePedidos.isEmpty()) {
					System.debug('datos dentro de servicios encabezados ' + IdOp + compania + codcliente + numdoc);
					//Encabezados
					String encabeResult = EnviaDatosPedidos(IdOp, compania, codcliente, numdoc);
					//Detalle
					String detalleResult = EnviarDetallesPedidos(idOP, numDoc, compania, ptoFac);

					System.debug('encabeResult ' + encabeResult);
					System.debug('detalleResult ' + detalleResult);
					if (encabeResult.contains('Error') && detalleResult.contains('Error')) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No se ha enviado el pedido.'));

					} else {
						Opportunity opt = new Opportunity();
						opt = [Select id, EMV_ESTADO_DOC_del__c,StageName from Opportunity where id = :idOp];
						opt.EMV_ESTADO_DOC_del__c = 'TRANS';
						opt.StageName = 'TRANS';
						system.debug('opt ****** ' + opt);
						TriggerHandler.bypass('OpportunityTriggerHandler');
							update opt;
						TriggerHandler.clearBypass('OpportunityTriggerHandler');
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Se ha enviado el pedido.'));
						return backOP();
					}
				} else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Se debe de adjuntar articulos/productos al pedido antes de ser enviado.'));
				}

			} else if (tipoMov.equals('PROFORMA')) { //PROFORMA
				//verificar si existen productos en el pedido para enviar 
				detalleProforma = [Select id from QuoteLineItem where QuoteId = :idPrep];
				if (!detalleProforma.isEmpty()) {

					//Encabezados
					String encabeQResult = EnviaDatosProformas(idPrep);
					//Detalle
					String detalleQResult = EnviarDetallesProformas(idPrep, numDoc, ptoFac);

					System.debug('encabeQResult ' + encabeQResult);
					System.debug('detalleQResult ' + detalleQResult);
					if (encabeQResult.contains('Error') && detalleQResult.contains('Error')) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'No se ha enviado la proforma.'));

					} else {
						Quote prep = new Quote();
						prep = [Select id, Transmitido__c from Quote where id = :idPrep];
						prep.Transmitido__c = true;

						Update prep;

						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Se ha enviado la proforma.'));
						return backQu();

					}

				} else {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Se debe de adjuntar articulos/productos a la proforma antes de ser enviado.'));
				}
			}


		} catch(Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Problemas al enviar el pedido.Debido a ' + e.getMessage() + ', revisar la linea #' + e.getLineNumber() + '.Contacte a soporte.'));
		}

		return pageRef;

	}

	//Evebnto para cancelar el proceso de envio
	/*public PageReference cancel() {
		return new PageReference('javascript:window.self.close()'); 
	}*/

	public PageReference backOP() {
		if (IdOp != null) {
			System.debug('entra a backOp');
			PageReference opportunity = new PageReference('/' + IdOp);
			System.debug('opportunity ' + opportunity);
			opportunity.setRedirect(true);
			return opportunity;
		}
		return null;
	}

	public PageReference backQu() {
		if (idPrep != null) {
			PageReference quote = new PageReference('/' + idPrep);
			quote.setRedirect(true);
			return quote;
		}
		return null;
	}
}