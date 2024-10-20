public with sharing class CasesDomainFactory {
    private static CasesDomainFactory instance;
    private static String DEFAULT_DOMAIN_TYPE = 'Default';

    public static CasesDomainFactory getInstance(){
        if(instance == null){
            instance = new CasesDomainFactory();
        }
        return instance;
    }

    public String getDomainByIdentifierType(String identifier){
        Map<String, Schema.RecordTypeInfo> indentifierToType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        Map<String, String> identifierToType = getIndentifierToType();
        String typeKey;

        for(String rtDeveloperName: identifierToType.keySet()) {
            RecordTypeInfo rtInformation = indentifierToType.get(rtDeveloperName);
            if(rtInformation == null) {
                continue;
            }
            if(rtInformation.getRecordTypeId() == identifier) {
                typeKey = rtDeveloperName;
                break;
            }            
        }
        if(typeKey == null){
            typeKey = DEFAULT_DOMAIN_TYPE;
        }
        return identifierToType.get(typeKey);
    }

    public Map<String, String> getIndentifierToType(){
        return new Map<String, String> {
            'Default' => 'CasesService.Constructor'
        };
    }

    public fflib_SObjectDomain newDomain(String identifier, List<SObject> objects){
        String domainTypeName = getDomainByIdentifierType(identifier);

        if(domainTypeName == null){
            return null;
        }
        fflib_SObjectDomain.IConstructable domainContructor = (fflib_SObjectDomain.IConstructable) Type.forName(domainTypeName).newInstance();
        
        List<Case> cases = (List<Case>) objects;
        List<Case> validCases = new List<Case>();
        for(Case each: cases){
            if(each.RecordTypeId != identifier){
                continue;
            }
            validCases.add(each);
        }
        return domainContructor.construct(validCases);
    }
}