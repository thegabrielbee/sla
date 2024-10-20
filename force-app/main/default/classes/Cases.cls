/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Case Object trigger actions
**/
public with sharing class Cases extends fflib_SObjectDomain  {
    Map<Id, List<Case>> identifierDomainMapping = new Map<Id, List<Case>>();

    public Cases(List<Entitlement> Cases) {
        super(Cases);
        Configuration.disableTriggerCRUDSecurity();
        setIdentifierDomainMapping();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Cases(sObjectList);
        }
    }

    private void setIdentifierDomainMapping(){
        this.identifierDomainMapping = new Map<Id, List<Case>>();
        List<Case> cases = (List<Case>) Records;
        for(Case each: cases) {
            List<Case> values = this.identifierDomainMapping.get(each.RecordTypeId);
            if(values == null) {
                 values = new List<Case>();
                 this.identifierDomainMapping.put(each.RecordTypeId, values);
            }
            values.add(each);
        }
    }

    public override void onApplyDefaults(){}

    public override void onAfterUpdate(Map<Id, Sobject> existingRecords) {
        List<Case> cases = (List<Case>) Records;
        Map<Id, Case> oldCases = (Map<Id, Case>) existingRecords;

        for(Id identifier: identifierDomainMapping.keySet()){
            List<Case> cases = identifierDomainMapping.get(identifier);
            fflib_SObjectDomain domain = CasesDomainFactory.getInstance().newDomain(identifier, cases);
            doamin.onAfterUpdate();
        }
    }
}