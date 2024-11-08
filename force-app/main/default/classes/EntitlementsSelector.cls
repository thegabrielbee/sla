public with sharing class EntitlementsSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Entitlement.SlaProcessId,
            Entitlement.Id,
            Entitlement.Name,
            Entitlement.StartDate
        };
    }
    
    public Schema.SObjectType getSObjectType(){
        return Entitlement.SObjectType;
    }

    public List<Entitlement> selectEntitlementsByIds(Set<Id> validEntitlementProcessIds){
        return [
            SELECT 
                SLAPROCESS.NAMENORM 
            FROM 
                ENTITLEMENT 
            WHERE 
                ID IN :validEntitlementProcessIds
        ];
    }

}