public with sharing class Injector {
    private static Injector instance;
    @TestVisible
    private static Injector mockInstance;
 
    public static Injector getInstance() {
        if(instance != null){
            return instance;
        }
        if(mockInstance != null){
            return mockInstance;
        }
        return new Injector();
    }

    public Object instantiate(Type classType){
        Object instance = classType.newInstance();
        return instance;
    }
}