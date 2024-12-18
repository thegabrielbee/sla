/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Entitlement Object trigger actions
**/
public with sharing class Entitlements extends fflib_SObjectDomain  {
    public Entitlements(List<Entitlement> objects) {
        super(objects);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> objects) {
            return new Entitlements(objects);
        }
    }

    public override void onApplyDefaults(){}

    public override void onAfterInsert() {
        List<Entitlement> entitlements = (List<Entitlement>) Records;
        fflib_SObjectDomain domain = EntitlementsDomainFactory.getInstance().newDomain(EntitlementsDomainFactory.DEFAULT_DOMAIN_TYPE, entitlements);
        if(domain == null){
            return;
        }
        domain.onAfterInsert();
    }
}