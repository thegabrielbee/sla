public with sharing class EntitlementsDomainFactory {
    private static EntitlementsDomainFactory instance;

    public static EntitlementsDomainFactory getInstance(){
        if(instance == null){
            instance = new EntitlementsDomainFactory();
        }
        return instance;
    }

    public Map<String, String> indentifierToType(){
        return new Map<String, String> {
            'Default' => 'EntitlementsService.Constructor'
        };
    }

    public fflib_SObjectDomain newDomain(String identifier, List<SObject> objects){
        String domainTypeName = indentifierToType().get(identifier);
        if(domainTypeName == null){
            return null;
        }
        fflib_SObjectDomain.IConstructable domainContructor = (fflib_SObjectDomain.IConstructable) Type.forName(domainTypeName).newInstance();
        return domainContructor.construct(objects);
    }
}