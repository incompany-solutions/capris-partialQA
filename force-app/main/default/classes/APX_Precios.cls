public with sharing class APX_Precios {

	public Account cAccount { get; set; }
	public Boolean mostrar { get; set; }

	public String cantidad { set; get; }
	public String nomcuenta { set; get; }
	public String codCli { set; get; }
	public String codigoCompania {get;set;}
	public String codigoCliente {get;set;}
	public String IdCliente { get; set; }

	public String prodId { get; set; }
	public String code { get; set; }
	public String description { get; set; }

	public ResponseMainList resultwrap { get; set; }
	public List<Response> responseLst { get; set; }

	public Double total { get; set; }
	public Double totalPRECIO_FERIA_NORMAL { get; set; }
	public Double totalPRECIO_FERIA_MAYORISTA { get; set; }
	public Double totalPRECIO_ESPECIAL { get; set; }
	public Double totalPRECIO_MAYORISTA { get; set; }



	public APX_Precios() {

		Id objId = ApexPages.currentPage().getParameters().get('id');
		if (String.valueOf(objId.getSobjectType()) == 'Account') {
			System.debug('Entra constructor');
			Account cuenta = [select Id, Name, org_id__c, num_cliente__c from Account where Id = :objId LIMIT 1];
			IdCliente = cuenta.Id;
			nomcuenta = cuenta.Name;
			codigoCompania = cuenta.org_id__c;
			codigoCliente = cuenta.num_cliente__c;
			codCli = codigoCliente;
		}
		System.debug(String.valueOf(objId.getSobjectType()));
		if(String.valueOf(objId.getSobjectType()) == 'Product2'){
			Product2 pro = [SELECT Id,CODIGO__c FROM Product2 WHERE Id =: objId];
			code = pro.CODIGO__c;
		}
	}

	public PageReference busquedaArticulo() {

		Price pri = new Price();
		pri.cant = cantidad;
		pri.codart = code;
		pri.codcli = codCli;
		pri.org = codigoCompania;
		pri.ptofact = '';

		List<Price> priceLst = new List<Price> ();
		priceLst.add(pri);

		PriceMainList lst = new PriceMainList();
		lst.PriceMainList = priceLst;

		System.debug(JSON.serializePretty(lst));

		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(Label.EndpointPrecios);
		req.setBody(JSON.serializePretty(lst));
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setMethod('POST');

		Try {
			HttpResponse res = h.send(req);
			System.debug(res);
			System.debug(res.getBody());
			String jsonStr = res.getBody();
			resultwrap = (ResponseMainList) System.JSON.deserialize(jsonStr, ResponseMainList.class);
			responseLst = resultwrap.ResponseMainList;
			mostrar = true;
		}
		Catch(System.CalloutException e) {
			System.Debug(e);
		}

		return null;
	}



	public PageReference backAcc() {
		PageReference cuenta = new PageReference('/' + cAccount.Id);
		cuenta.setRedirect(true);
		return cuenta;
	}

	public class ResponseMainList {
		public List<Response> ResponseMainList { get; set; }
	}

	public class Response {
		public String org { get; set; }
		public String codArt { get; set; }
		public String cant { get; set; }
		public String codCli { get; set; }
		public String ptoFact { get; set; }
		public String preNormal { get; set; }
		public String preEspecial {get;set;}
		public String descuento { get; set; }
	}

	public class Price {
		public String org;
		public String codart;
		public String cant;
		public String codcli;
		public String ptofact;
	}

	public class PriceMainList {
		public List<Price> PriceMainList;
	}
}