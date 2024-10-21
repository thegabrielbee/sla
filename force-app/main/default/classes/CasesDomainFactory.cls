/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to provide a interface to ordered 
* retrieve a Cases domain implementation by a Identifier
**/
public with sharing class CasesDomainFactory {
    private static CasesDomainFactory instance;
    private static String DEFAULT_DOMAIN_TYPE = 'Default';

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to retieve a instance 
    * of the Factory
    **/
    public static CasesDomainFactory getInstance(){
        if(instance == null){
            instance = new CasesDomainFactory();
        }
        return instance;
    }
    
    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to map the corresponding 
    * domain Type Name implementation by a Identifier
    * @param identifier the identifier that map the object domain implementation
    **/
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

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to map the corresponding 
    * domain implementation by a Identifier
    **/
    public Map<String, String> getIndentifierToType(){
        return new Map<String, String> {
            'Default' => 'CasesDefaultService.Constructor'
        };
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to retrieve the corresponding 
    * domain implementation by a Identifier
    * @param identifier the identifier that map the object domain implementation
    * @param objects the objects to be mapped by identifier
    **/
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