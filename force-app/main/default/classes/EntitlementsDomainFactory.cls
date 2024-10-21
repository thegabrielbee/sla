/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to provide a interface to ordered 
* retrieve a Entitlements domain implementation by a Identifier
**/
public with sharing class EntitlementsDomainFactory {
    private static EntitlementsDomainFactory instance;
    public static String DEFAULT_DOMAIN_TYPE = 'Default';

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to retieve a instance 
    * of the Factory
    **/
    public static EntitlementsDomainFactory getInstance(){
        if(instance == null){
            instance = new EntitlementsDomainFactory();
        }
        return instance;
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to map the corresponding 
    * domain Type Name implementation by a Identifier
    * @param identifier the identifier that map the object domain implementation
    **/
    public String getDomainByIdentifierType() {
        String typeConstructorName;
        if(typeConstructorName == null){
            if(EntitlementsDomainFactoryMap__mdt.getInstance(DEFAULT_DOMAIN_TYPE) == null){
                throw new FactoryException('You should implement a Default Factory.');
            }
            typeConstructorName = EntitlementsDomainFactoryMap__mdt.getInstance(DEFAULT_DOMAIN_TYPE).DomainConstructorName__c;
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
        String domainTypeName = getDomainByIdentifierType();
        fflib_SObjectDomain.IConstructable domainContructor = (fflib_SObjectDomain.IConstructable) Type.forName(domainTypeName).newInstance();
        return domainContructor.construct(objects);
    }
}