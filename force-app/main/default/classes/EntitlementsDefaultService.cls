/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Entitlement Object
* trigger actions in Default Domain
**/
public with sharing class EntitlementsDefaultService extends fflib_SObjectDomain {
    public EntitlementsDefaultService(List<Entitlement> sObjects) {
        super(sObjects);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new EntitlementsDefaultService(sObjects);
        }
    }

    public override void onApplyDefaults(){}
    
    public override void onAfterInsert() {
        List<Entitlement> entitlements = (List<Entitlement>) Records;
        saveEntitlement(entitlements);
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to handle the execution of
    * the batch the will create/update the Custom Setting Records
    * for the Entitlement Process
    * @param entitlements the entitlements to create/update their
    * corresponding Custom Setting Records
    **/
    public void saveEntitlement(List<Entitlement> entitlements) {
        List<String> entitlementNames = new List<String>();
        Map<String, Id> slaProcessNameToentitlementId = new Map<String, Id>();
        Set<Id> validEntitlementProcessIds = new Set<Id>(); 
        for(Entitlement each: entitlements){
            if(
                each.SlaProcessId == null || 
                (each.StartDate == null || each.StartDate > Date.today()) ||
                (each.EndDate == null || each.EndDate < Date.today())
            ) {
                continue;
            }
            validEntitlementProcessIds.add(each.Id);
         }
        if(validEntitlementProcessIds.isEmpty()){
            return;
        }
        
        System.enqueueJob(new MetadataEntitlementQueueable(validEntitlementProcessIds));
    }
}
