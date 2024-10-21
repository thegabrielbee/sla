/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Case Object
* trigger actions in Default Domain
**/
public with sharing class CasesDefaultService extends fflib_SObjectDomain {
    public CasesDefaultService(List<Case> sObjects) {
        super(sObjects);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new CasesDefaultService(sObjects);
        }
    }

    public override void onApplyDefaults(){}
    
    public override void onAfterUpdate(Map<Id, Sobject> existingRecords) {
        List<Case> cases = (List<Case>) Records;
        Map<Id, Case> oldCases = (Map<Id, Case>) existingRecords;
        
        ((EntitlementsHandler) Injector.getInstance().instantiate(EntitlementsHandler.class)).finishMilestones(cases, oldCases);
    }
}