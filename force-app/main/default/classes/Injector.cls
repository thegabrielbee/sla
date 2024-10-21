/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle Dependency Injection
* of the Classes
**/
public with sharing class Injector {
    private static Injector instance;
    @TestVisible
    private static Injector mockInstance;
 
    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to retrieve the current
    * or a new instance of the Injector
    **/
    public static Injector getInstance() {
        if(instance != null){
            return instance;
        }
        if(mockInstance != null){
            return mockInstance;
        }
        return new Injector();
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to instantiate a Apex Type
    **/
    public Object instantiate(Type classType){
        Object instance = classType.newInstance();
        return instance;
    }
}