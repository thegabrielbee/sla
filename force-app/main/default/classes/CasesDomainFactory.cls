/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to provide a interface to ordered 
* retrieve a Cases domain implementation by a Identifier
**/
public with sharing class CasesDomainFactory {
    private static CasesDomainFactory instance;
    public static String DEFAULT_DOMAIN_TYPE = 'Default';

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
        String typeConstructorName;

        for(String rtDeveloperName: CasesDomainFactoryMap__mdt.getall().keySet()) {
            RecordTypeInfo rtInformation = indentifierToType.get(rtDeveloperName);
            if(rtInformation.getRecordTypeId() == identifier) {
                typeConstructorName = CasesDomainFactoryMap__mdt.getInstance(rtDeveloperName).DomainConstructorName__c;
                break;
            }
        }

        if(typeConstructorName == null){
            if(CasesDomainFactoryMap__mdt.getInstance(DEFAULT_DOMAIN_TYPE) == null){
                throw new FactoryException('You should implement a Default Factory.');
            }
            typeConstructorName = CasesDomainFactoryMap__mdt.getInstance(DEFAULT_DOMAIN_TYPE).DomainConstructorName__c;
        }
        return typeConstructorName;
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