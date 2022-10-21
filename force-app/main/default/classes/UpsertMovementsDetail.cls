/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 12-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public class UpsertMovementsDetail {

    public static DeserializeJSONMovementsDetail.DeserializeJSON resultwrap { get; set; }

    public static string doUpsert(String jsonStr) {

        resultwrap = DeserializeJSONMovementsDetail.parse(jsonStr);
        List<Detalle_de_Movimiento__c> MovementDetailLst = new List<Detalle_de_Movimiento__c> ();
        //Esteban Segura Benavides
        Map<String,Detalle_de_Movimiento__c> mapMovementDetail = new Map<String,Detalle_de_Movimiento__c>();

        Integer Counter1 = - 1;
        Integer Counter2 = - 1;
        Map<Integer, String> CounterMap = new Map<Integer, String> ();

        for (DeserializeJSONMovementsDetail.MovementsDetailMainList wrap : resultwrap.MovementsDetailMainList) {
            Detalle_de_Movimiento__c detalle = new Detalle_de_Movimiento__c();
            detalle.DMV_COD_ORG_3__c = wrap.dmvCodOrg;
            detalle.DMV_TIPO_MOV__c = wrap.dmvTipoMov;
            detalle.DMV_COD_PUNTO_FACT__c = wrap.dmvCodPuntoFact;
            detalle.DMV_NUM_DOCUMENTO_3__c = wrap.dmvNumDocumento;
            detalle.DMV_NUM_LINEA_3__c = wrap.dmvNumLinea;
            detalle.Name = wrap.dmvNumLinea;
            detalle.DMV_COD_PRODUCTO_3__c = wrap.dmvCodProducto;
            detalle.DMV_CAN_MOVIMIENTO_3__c = Double.valueOf(wrap.dmvCanMovimiento.replace(',','.'));
            detalle.DMV_PRECIO_NORMAL_3__c = Double.valueOf(wrap.dmvPrecioNormal.replace(',','.'));
            detalle.DMV_PRECIO_ESPECIAL_3__c = wrap.dmvPrecioEspecial != null ? Double.valueOf(wrap.dmvPrecioEspecial) : null;
            detalle.DMV_DESC_ESP_3__c = wrap.dmvDescEsp != '0' ? Double.valueOf(wrap.dmvDescEsp.replace(',','.')) : null;
            detalle.Monto_I_V_NUMBER__c = Double.valueOf(wrap.dmvPorIva.replace(',','.'));
            detalle.DMV_FYH_MODIFICA_3__c = Datetime.newInstance(LONG.valueOf(wrap.dmvFyhModifica));//dmvFyhModifica
            detalle.DMV_USU_MODIFICA_3__c = wrap.dmvUsuModifica;//dmvUsuModifica
            detalle.DMV_COD_OFERTA_3__c = wrap.dmvCodOferta;
            detalle.ID_Capris__c = wrap.dmvCodOrg+'-'+wrap.dmvTipoMov+'-'+wrap.dmvCodPuntoFact+'-'+wrap.dmvNumDocumento+'-'+wrap.dmvNumLinea;

            Product2 prod = new Product2(idExternoArticulo__c = wrap.dmvCodOrg+'-'+wrap.dmvCodProducto);
            detalle.ArtRelacionado__r = prod;

            Encabezado__c encabezado = new Encabezado__c(Id_Capris__c = wrap.dmvCodOrg+'-'+wrap.dmvTipoMov+'-'+wrap.dmvCodPuntoFact+'-'+wrap.dmvNumDocumento);
            detalle.Encabezado__r = encabezado;

            Counter1 = Counter1 + 1;
            CounterMap.put(Counter1, wrap.dmvCodOrg+'-'+wrap.dmvTipoMov+'-'+wrap.dmvCodPuntoFact+'-'+wrap.dmvNumDocumento+'-'+wrap.dmvNumLinea);

            //MovementDetailLst.add(detalle);
            //Esteban Segura Benavides
            mapMovementDetail.put(detalle.ID_Capris__c,detalle);
        }

        Schema.SObjectField f = Detalle_de_Movimiento__c.Fields.Id_Capris__c;
        Database.UpsertResult[] saveResultList = Database.upsert(mapMovementDetail.values(), f, false);

        List<WebServiceLog__c> lerrors = new List<WebServiceLog__c> ();

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeFieldName('ResponseMainList');
        gen.writeStartArray();
        for (Database.UpsertResult res : saveResultList) {
            Counter2 = Counter2 + 1;
            if (res.isSuccess()) {
                gen.writeStartObject();
                gen.writeStringField('codigo', 'Se procesó correctamente el registro');
                gen.writeStringField('Status', CounterMap.get(Counter2));
                gen.writeEndObject();
            } else {
                For (Database.Error e : res.getErrors()) {
                    System.debug(e);
                    gen.writeStartObject();
                    gen.writeStringField('codigo', 'Error al procesar el registro '+e.getMessage());
                    gen.writeStringField('Status', CounterMap.get(Counter2));
                    gen.writeEndObject();

                    WebServiceLog__c log = new WebServiceLog__c();
                    log.Web_Services__c='Detalle Movimiento';
                    log.WebServiceMethod__c = 'WebServiceMovementDetail';
                    log.ErrorDetail__c = 'Error message : ' +  e.getMessage() + '\nStatus Code : '+e.getStatusCode()+'\n Fields : '+e.getFields();
                    log.hasErrors__c = true;
                    lerrors.add(log);
                }
            }
        }
        gen.writeEndArray();
        gen.writeEndObject();

        if (lerrors.size() > 0){
            insert lerrors;
        }

        return gen.getAsString();
		//return '{"ResponseMainList":[{"codigo":"Se procesó correctamente el registro","Status":"CAP"}]}';
    }
}