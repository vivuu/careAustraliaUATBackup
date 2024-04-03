public without sharing class RedirectLoginURL {
	@AuraEnabled
    public static String redirecttoLoginURL(){
        List<String> URL=new List<String>();
            List<Network> lenderNet=[SELECT Id,Name FROM Network WHERE Name='Lendwithcare - Lender Site' LIMIT 1];
        if(lenderNet.size()>0)
        {
			URL.add(Network.getLoginUrl(lenderNet[0].Id));
            System.debug('URL---->'+URL[0]);
            return URL[0];     
        }
        return null;
          	
    } 
   
}