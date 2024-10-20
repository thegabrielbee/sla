/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Entitlements Object trigger actions
**/
public with sharing class Entitlements extends fflib_SObjectDomain  {
    public Entitlements(List<Entitlement> entitlements) {
        super(entitlements);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Entitlements(sObjectList);
        }
    }

    public override void onApplyDefaults(){}

    public override void onAfterInsert() {
        List<Entitlement> entitlements = (List<Entitlement>) Records;
        fflib_SObjectDomain domain = EntitlementsDomainFactory.getInstance().newDomain('Default', entitlements);
        if(domain == null){
            return;
        }
        domain.onAfterInsert();
    }
}