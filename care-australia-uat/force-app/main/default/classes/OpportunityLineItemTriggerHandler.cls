public class OpportunityLineItemTriggerHandler {
    public static void OppLineItemHandler(List<OpportunityLineItem> OppLineItemList){
        System.debug('OppLineItemList'+OppLineItemList);
        for(OpportunityLineItem OppLine : OppLineItemList)
        {
            If(OppLine.HIC_ShopifySync__Shopify_Id__c!=NULL && OppLine.Product_Properties__c !=NULL) 
            {
                system.debug('shopify id :::'+OppLine.HIC_ShopifySync__Shopify_Id__c);
                system.debug('OppLine.Product_Properties__c  :::'+OppLine.Product_Properties__c);
                system.debug('OppLine.Product_Properties__c  :::'+OppLine.Product_Properties__c);
                
                IF(OppLine.Product_Properties__c !='()')
                { 
                    /*String Product_Properties = OppLine.Product_Properties__c;
                    String[] strList = OppLine.Product_Properties__c.split('},');
                    system.debug('strList  :::'+strList);
                    if(strList[0]!=NULL)
                    {
                        String[] product_value_array = strList[0].split(',');
                        if(product_value_array[1]!= NULL)
                        {
                            String[] product_type = product_value_array[1].split('=');
                            if(product_type[1]!=NULL)
                            {
                                if(OppLine.Product_Type__c != product_type[1] )
                                    OppLine.Product_Type__c = product_type[1] ;
                                system.debug('product_type[1]  :::'+product_type[1]);
                            }
                            
                        }
                        
                    }*/
                    
                    system.debug('OppLine.Product_Properties__c  :::@@@@@@@'+OppLine.Product_Properties__c);
                    
                    List<ProductPropertyWrapper> lstPPWrapper= (List<ProductPropertyWrapper>)System.JSON.deserialize(OppLine.Product_Properties__c, List<ProductPropertyWrapper>.class);
                    system.debug('lstPPWrapper  :::@@@@@@@@@'+lstPPWrapper);
                    for(ProductPropertyWrapper eachInst:lstPPWrapper)
                    {
                        if(eachInst.name=='Gift Type')
                        {
                            OppLine.Product_Type__c=eachInst.value;
                            System.debug('OppLine@@@@@@@@::::'+OppLine.Product_Type__c);
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    class ProductPropertyWrapper
    {
        String value;
        String name;
    }
    
    
}