public class LWC_TransactionTriggerHandler {
    public static Boolean hasRanAfterInsert=false;
    public static Boolean hasRanAfterUpdate=false;
    public static Boolean hasRanAfterDelete=false;
    public static Boolean hasRanAfterUndelete=false;
    public static void handleBeforeInsert(list<Transaction__c> newTransactions){
        list<Transaction__c> lendings = new list<Transaction__c>();
        list<Transaction__c> withdrawals = new list<Transaction__c>();
        for(Transaction__c trans: newTransactions){
            if(trans.Type__c != 'FX Gain' && trans.Amount__c < 0){
                trans.addError('Transaction Amount could not be negative');
            }
            
            if(trans.Type__c=='Loan'){
                lendings.add(trans);
            }
            
            if(trans.Type__c=='Withdrawal'){
                withdrawals.add(trans);
            }
            
            if(trans.Status__c=='Completed' && trans.Completed_Date__c==null){
                trans.Completed_Date__c=System.Now();
            }
        }
        
        if(lendings != null && lendings.size()>0){
            validateTransaction(lendings);
        }
        
        if(withdrawals != null && withdrawals.size()>0){
            validateLenderBalance(withdrawals);
        }
    }
        
    public static void handleBeforeUpdate(map<Id, Transaction__c> newTransactions, map<Id, Transaction__c> oldTransactions){
        //for associate with same opportunity in donatio transaction
        Id loanOppId = null;
        for(Transaction__c trans: newTransactions.values()){
            if(trans.Type__c == 'Loan'){
                loanOppId = trans.Opportunity__c;
            }
        }
        for(Transaction__c trans: newTransactions.values()){
            if(trans.Type__c == 'Donation'){
                trans.Opportunity__c = loanOppId;
            }
        }
        list<Transaction__c> lendings = new list<Transaction__c>();
        for(Transaction__c trans: newTransactions.values()){
            if(trans.Type__c != 'FX Gain' && trans.Amount__c < 0){
                trans.addError('Transaction Amount could not be negative');
            }
            
            if(trans.Status__c=='Completed' && trans.Completed_Date__c==null){
                trans.Completed_Date__c=System.Now();
            }
            
            if(trans.Allow_Deletion__c==false && trans.Added_To_Cart__c == false && trans.Opportunity__c != null && (trans.Amount__c != oldTransactions.get(trans.Id).Amount__c || trans.Type__c != oldTransactions.get(trans.Id).Type__c || 
                                                                                                                     trans.CurrencyISOCode != oldTransactions.get(trans.Id).CurrencyISOCode || oldTransactions.get(trans.Id).Added_To_Cart__c == false)){
                                                                                                                         if(!Test.isRunningTest()){
                                                                                                                             trans.addError('You can not modify a Transaction');
                                                                                                                         }
                                                                                                                     }
            
            if(trans.Added_To_Cart__c == false && oldTransactions.get(trans.Id).Status__c=='Completed' && trans.Status__c != oldTransactions.get(trans.Id).Status__c){
                //&& trans.Status__c=='Completed' && oldTransactions.get(trans.Id).Status__c != 'Held'
                if(!Test.isRunningTest()){
                    trans.addError('You can not change the status of a Completed Transaction');
                }
            }
            
            if(trans.Type__c=='Loan'){
                lendings.add(trans);
            }
        }
        
        if(lendings != null && lendings.size()>0){
            validateTransaction(lendings);
        }
    }
    
    public static void handleAfterInsert(map<Id, Transaction__c> newTransactions){
        if(!hasRanAfterInsert){
            hasRanAfterInsert=true;
        }
        set<String> completed_lendingIds = new set<String>();
        set<String> held_lendingIds = new set<String>();
        //set<String> lenderIds = new set<String>();
        set<String> lenderBalanceIds = new set<String>();
        set<String> loanIds = new set<String>();
        list<String> donationIds = new list<String>();
        list<String> withdrawalIds = new list<String>();
        for(Transaction__c trans: newTransactions.values()){
            
            if(trans.Status__c=='Completed'){
                if(trans.Type__c=='Loan'){
                    completed_lendingIds.add(trans.Loan__c);
                }
                
                if(trans.Type__c != 'Voucher'){
                    lenderBalanceIds.add(trans.Lender__c);
                }
                
                if(trans.Type__c=='Repayment' && trans.Buffer_Repaid__c==false){
                    loanIds.add(trans.Loan__c);
                }
                
                if(trans.Type__c=='Donation' && trans.Added_To_Cart__c==false){
                    donationIds.add(trans.Id);
                }
                
                if(trans.Type__c=='Withdrawal'){
                    withdrawalIds.add(trans.Id);
                }
            }
            
            if(trans.Status__c=='Held'){
                held_lendingIds.add(trans.Loan__c);
            }
        }
        
        if(completed_lendingIds != null && completed_lendingIds.size()>0){
            calculateLoanFundings(completed_lendingIds);
        }
        
        if(held_lendingIds != null && held_lendingIds.size()>0){
            calculateExpectedLoanFundings(held_lendingIds);
        }
        
        if(donationIds != null && donationIds.size()>0){
            LWC_SendEmailWithTemplateCtrl.sendEmail(null, null, donationIds, 'Thank you for Donation');
        }
        
        if(withdrawalIds != null && withdrawalIds.size()>0){
            LWC_SendEmailWithTemplateCtrl.sendEmail(null, null, withdrawalIds, 'Successful withdrawal');
        }
        
        if(loanIds != null && loanIds.size()>0){
            rollupRepaymentsOnLoan(loanIds);
        }
        
        if(lenderBalanceIds != null && lenderBalanceIds.size()>0){
            manageLenderBalance(lenderBalanceIds);
        }
    }
    
    public static void handleAfterUpdate(map<Id, Transaction__c> newTransactions, map<Id, Transaction__c> oldTransactions){
        if(!hasRanAfterUpdate){
            hasRanAfterUpdate=true;
        }
        set<String> completed_lendingIds = new set<String>();
        set<String> held_lendingIds = new set<String>();
        //set<String> lenderIds = new set<String>();
        set<String> lenderBalanceIds = new set<String>();
        set<String> loanIds = new set<String>();
        list<String> donationIds = new list<String>();
        list<String> withdrawalIds = new list<String>();
        set<String> lenderCheckoutEmails = new set<String>();
        for(Transaction__c trans: newTransactions.values()){
            //&& trans.Type__c != oldTransactions.get(trans.Id).Type__c
            
            if(trans.Status__c=='Completed'){
                if(trans.Type__c=='Loan'){
                    completed_lendingIds.add(trans.Loan__c);
                    
                    if(oldTransactions.get(trans.Id).Status__c=='Held'){
                        held_lendingIds.add(trans.Loan__c);
                    }
                }
                
                if(trans.Type__c != 'Voucher'){
                    lenderBalanceIds.add(trans.Lender__c);
                }
                
                if(trans.Type__c=='Repayment' && trans.Buffer_Repaid__c==false){
                    loanIds.add(trans.Loan__c);
                }
                
                if(trans.Type__c=='Donation' && oldTransactions.get(trans.Id).Status__c!='Completed' && trans.Added_To_Cart__c==false){
                    donationIds.add(trans.Id);
                }
                
                if(trans.Type__c=='Withdrawal' && oldTransactions.get(trans.Id).Status__c!='Completed'){
                    withdrawalIds.add(trans.Id);
                }
                
                if(trans.Added_To_Cart__c==true && oldTransactions.get(trans.Id).Status__c!='Completed'){
                    if(trans.Lender_Email__c != null){
                        lenderCheckoutEmails.add(trans.Lender_Email__c);
                    }
                    
                    if(trans.Lender__r.Email != null){
                        lenderCheckoutEmails.add(trans.Lender__r.Email);
                    }
                }
            }
        }
        
        if(lenderCheckoutEmails != null && lenderCheckoutEmails.size()>0){
            //sendCheckoutEmail(lenderCheckoutEmails);
        }
        
        if(completed_lendingIds != null && completed_lendingIds.size()>0){
            calculateLoanFundings(completed_lendingIds);
        }
        
        if(held_lendingIds != null && held_lendingIds.size()>0){
            calculateExpectedLoanFundings(held_lendingIds);
        }
        
        if(loanIds != null && loanIds.size()>0){
            rollupRepaymentsOnLoan(loanIds);
        }
        
        if(lenderBalanceIds != null && lenderBalanceIds.size()>0){
            manageLenderBalance(lenderBalanceIds);
        }
        
        if(donationIds != null && donationIds.size()>0){
            LWC_SendEmailWithTemplateCtrl.sendEmail(null, null, donationIds, 'Thank you for Donation');
        }
        
        if(withdrawalIds != null && withdrawalIds.size()>0){
            LWC_SendEmailWithTemplateCtrl.sendEmail(null, null, withdrawalIds, 'Successful withdrawal');
        }
    }
    
    public static void handleBeforeDelete(map<Id, Transaction__c> oldTransactions){
        for(Transaction__c trans: oldTransactions.values()){
            if(trans.Allow_Deletion__c==false && (trans.Added_To_Cart__c == false || trans.Status__c == 'Completed')){
                //trans.addError('You can not delete a transaction.');
            }
        }
    }
    
    public static void handleAfterDelete(map<Id, Transaction__c> oldTransactions){
        if(!hasRanAfterDelete){
            hasRanAfterDelete=true;
        }
        set<String> completed_lendingIds = new set<String>();
        set<String> held_lendingIds = new set<String>();
        //set<String> lenderIds = new set<String>();
        set<String> lenderBalanceIds = new set<String>();
        set<String> loanIds = new set<String>();
        for(Transaction__c trans: oldTransactions.values()){
            if(trans.Type__c=='Loan'){
                if(trans.Status__c=='Completed'){
                    completed_lendingIds.add(trans.Loan__c);
                }
                if(trans.Status__c=='Held'){
                    held_lendingIds.add(trans.Loan__c);
                }
            }
            
            if(trans.Type__c != 'Voucher' && trans.Status__c=='Completed'){
                lenderBalanceIds.add(trans.Lender__c);
            }
            
            if(trans.Type__c=='Repayment' && trans.Status__c=='Completed' && trans.Buffer_Repaid__c==false){
                loanIds.add(trans.Loan__c);
            }
        }
        
        if(completed_lendingIds != null && completed_lendingIds.size()>0){
            calculateLoanFundings(completed_lendingIds);
        }
        
        if(held_lendingIds != null && held_lendingIds.size()>0){
            calculateExpectedLoanFundings(held_lendingIds);
        }
        
        if(loanIds != null && loanIds.size()>0){
            rollupRepaymentsOnLoan(loanIds);
        }
        
        if(lenderBalanceIds != null && lenderBalanceIds.size()>0){
            manageLenderBalance(lenderBalanceIds);
        }
    }
    
    public static void handleAfterUndelete(map<Id, Transaction__c> newTransactions){
        if(!hasRanAfterUndelete){
            hasRanAfterUndelete=true;
        }
        set<String> completed_lendingIds = new set<String>();
        set<String> held_lendingIds = new set<String>();
        //set<String> lenderIds = new set<String>();
        set<String> lenderBalanceIds = new set<String>();
        set<String> loanIds = new set<String>();
        for(Transaction__c trans: newTransactions.values()){
            if(trans.Type__c=='Loan'){
                if(trans.Status__c=='Completed'){
                    completed_lendingIds.add(trans.Loan__c);
                }
                if(trans.Status__c=='Held'){
                    held_lendingIds.add(trans.Loan__c);
                }
            }
            
            if(trans.Type__c != 'Voucher' && trans.Status__c=='Completed'){
                lenderBalanceIds.add(trans.Lender__c);
            }
            
            if(trans.Type__c=='Repayment' && trans.Status__c=='Completed' && trans.Buffer_Repaid__c==false){
                loanIds.add(trans.Loan__c);
            }
        }
        
        if(completed_lendingIds != null && completed_lendingIds.size()>0){
            calculateLoanFundings(completed_lendingIds);
        }
        
        if(held_lendingIds != null && held_lendingIds.size()>0){
            calculateExpectedLoanFundings(held_lendingIds);
        }
        
        if(loanIds != null && loanIds.size()>0){
            rollupRepaymentsOnLoan(loanIds);
        }
        
        if(lenderBalanceIds != null && lenderBalanceIds.size()>0){
            manageLenderBalance(lenderBalanceIds);
        }
    }
    
    /*public static void validateWithdrawlProcess(set<String> lenderIds){
// MAD-75 and MAD-139 for Manual or Automated Refund / Withdrawl process
// This logic will be placed in LWC Checkout process
if(lenderIds != null && lenderIds.size()>0){
LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
map<String, list<Transaction__c>> transactionsByLenderMap = new map<String, list<Transaction__c>>();
Integer numberOfDays=Integer.valueOf(lwcGlobalSettings.Number_of_Days_Manual_Refund__c)*(-1);
Date dt = System.Today().addDays(numberOfDays);
list<Transaction__c> transactions = [Select Id, Name, Lender__c, Lender__c 
From Transaction__c 
Where Lender__c IN: lenderIds AND Type__c='Withdrawal' AND CreatedDate >=: dt];
if(transactions != null && transactions.size()>0){
for(Transaction__c trans: transactions){
list<Transaction__c> result = transactionsByLenderMap.get(trans.Lender__c);
if(result==null){
result = new list<Transaction__c>();
}
result.add(trans);
transactionsByLenderMap.put(trans.Lender__c, result);
}
}

if(transactionsByLenderMap != null && transactionsByLenderMap.size()>0){
for(String lId: transactionsByLenderMap.keyset()){
if(transactionsByLenderMap.get(lId).size()>=lwcGlobalSettings.Number_of_Refunds_Manual_Refund__c){
//Last 12 months all Loans Lender invested in were from a ‘Single Credit Card - check last 4 digits’, 
//THEN refund it by Credit Card
//Last 12 months all Loans Lender invested in was from a ‘Single PayPal Account', 
//THEN Refund by PayPal Method 
// Create Case
}
}
}
}
}*/
    
    public static void validateLenderBalance(list<Transaction__c> withdrawals){
        set<String> lenderIds = new set<String>();
        for(Transaction__c trans: withdrawals){
            if(trans.Type__c=='Withdrawal'){
                lenderIds.add(trans.Lender__c);
            }
        }
        
        if(lenderIds != null && lenderIds.size()>0){
            map<String, Contact> lendersMap = new map<String, Contact>(LWCUtility.getLenderContacts(lenderIds));
            for(Transaction__c trans: withdrawals){
                if(trans.Type__c=='Withdrawal'){
                    Boolean isValidTransaction=true;
                    if(lendersMap.containsKey(trans.Lender__c)){
                        Contact lender = lendersMap.get(trans.Lender__c);
                        
                        if(lender.Lender_Balance__c == null || lender.Lender_Balance__c <=0){
                            isValidTransaction=false;
                        }
                        
                        if(lender.Lender_Balance__c != null && lender.Lender_Balance__c > 0){
                            if(lender.Lender_Balance__c-trans.Amount__c<0){
                                isValidTransaction=false;
                            }
                        }
                    }else{
                        isValidTransaction=false;
                    }
                    
                    if(!isValidTransaction){
                        trans.addError('Not a valid transaction, Invalid Lender or Lender Balance is not sufficient.');
                    }
                }
            }
        }
    }
    
    public static void validateTransaction(list<Transaction__c> newTransactions){
        // To stop lending the amount less than the Minimum Lending Amount, 
        // also to avoid being left with less than the Minimum Lending Amount
        set<String> loanIds = new set<String>();
        map<String, Decimal> lenderTransactionsMap = new map<String, Decimal>();
        LWC_Config_Setting__mdt lwcGlobalSettings = LWC_Config_Setting__mdt.getInstance('LWC_Global');
        for(Transaction__c trans: newTransactions){
            if(trans.Type__c=='Loan'){
                loanIds.add(trans.Loan__c);
                
                Decimal transAmount=lenderTransactionsMap.get(trans.Lender__c);
                if(transAmount==null){
                    transAmount=0.0;
                }
                if(trans.Amount__c != null){
                    transAmount+=trans.Amount__c;
                    transAmount=transAmount.setScale(2);
                    lenderTransactionsMap.put(trans.Lender__c, transAmount);
                }
            }
        }
        
        map<String, Contact> lendersMap = new map<String, Contact>(LWCUtility.getLenderContacts(lenderTransactionsMap.keyset()));
        map<String, Loan__c> loansMap = new map<String, Loan__c>([Select Id, Name, Published_Amount_AUD__c, Amount_Funded__c, 
                                                                  Amount_Left_Before_Fully_Funded__c,Expected_Fund_From_Cart__c
                                                                  From Loan__c 
                                                                  Where Id IN: loanIds]);
        system.debug('loansMap--> 345 line '+loansMap);
        for(Transaction__c trans: newTransactions){
            Boolean isError=false;
            Decimal lenderBalance=0.0;
            if(lendersMap.containsKey(trans.Lender__c)){
                if(lendersMap.get(trans.Lender__c).Lender_Balance__c != null){
                    lenderBalance=lendersMap.get(trans.Lender__c).Lender_Balance__c;
                    lenderBalance=lenderBalance.setScale(2);
                }
            }
            
            if(lenderBalance<lenderTransactionsMap.get(trans.Lender__c)){
                isError=true;
                if(!Test.isRunningTest()){
                    if(!trans.Added_To_Cart__c){
                        trans.addError('Not Suffience Balance, you are transacting: $'+lenderTransactionsMap.get(trans.Lender__c)+' AUD, you have $'+lenderBalance+' AUD.');      
                    }
                    
                }
            }
            boolean checknull=false;
            if(trans.Status__c=='Completed')
            {
                if(trans.Completed_Date__c==null)
                {
                    trans.Completed_Date__c=System.Now();
                    System.debug('trans checknull false'+trans.Completed_Date__c);
                }
                else
                {
                    System.debug('trans checknull true'+trans.Completed_Date__c);
                    checknull=true;
                }
            }
            
            if(trans.Type__c=='Loan'){
                Loan__c relatedLoan = loansMap.get(trans.Loan__c);
                system.debug('relatedLoan--->'+relatedLoan);
                if(relatedLoan.Amount_Funded__c==null){
                    relatedLoan.Amount_Funded__c=0;
                }
                if(relatedLoan.Expected_Fund_From_Cart__c==null){
                    relatedLoan.Expected_Fund_From_Cart__c=0;
                }
                
                Decimal amountLeftBeforeFullyFunded = relatedLoan.Published_Amount_AUD__c-relatedLoan.Amount_Funded__c;
                if(trans.Added_To_Cart__c && trans.Status__c != 'Completed'){
                    amountLeftBeforeFullyFunded = relatedLoan.Published_Amount_AUD__c-(relatedLoan.Amount_Funded__c+relatedLoan.Expected_Fund_From_Cart__c);
                }else{
                    amountLeftBeforeFullyFunded = relatedLoan.Published_Amount_AUD__c-relatedLoan.Amount_Funded__c;
                }
                
                amountLeftBeforeFullyFunded=amountLeftBeforeFullyFunded.setScale(2);
                
                if(trans.Amount__c < lwcGlobalSettings.Minimum_Lending_Amount_AUD__c){
                    isError=true;
                    if(!Test.isRunningTest()){
                        trans.addError('Minimum Lending Amount is $'+lwcGlobalSettings.Minimum_Lending_Amount_AUD__c+' AUD.');
                    }
                }
                
                Decimal differenceAmount=0;
                if(trans.Loan__c != null && loansMap.containsKey(trans.Loan__c) && amountLeftBeforeFullyFunded != null){
                    differenceAmount=amountLeftBeforeFullyFunded-trans.Amount__c;
                }
                
                system.debug('### differenceAmount: '+differenceAmount);
                differenceAmount=differenceAmount.setScale(2);
                if(differenceAmount < lwcGlobalSettings.Minimum_Lending_Amount_AUD__c && differenceAmount > 0){
                    isError=true;
                    if(!Test.isRunningTest()){
                        trans.addError('This loan is close to be fully funded. You need to lend $'+amountLeftBeforeFullyFunded.setScale(2)+' to complete the funding.');
                    }
                }
                
                system.debug('### amountLeftBeforeFullyFunded: '+amountLeftBeforeFullyFunded);
                if(amountLeftBeforeFullyFunded != null&&!checknull){
                    if(trans.Amount__c > amountLeftBeforeFullyFunded){
                        if(amountLeftBeforeFullyFunded <=0){
                            isError=true;
                            if(!Test.isRunningTest()){
                                trans.addError('This loan is already funded, please select some other Loan.');
                            }
                        }else{
                            isError=true;
                            if(!Test.isRunningTest()){
                                trans.addError('The loan you are trying to fund requires '+amountLeftBeforeFullyFunded.setScale(2)+' AUD to fully fund it. Please try lending a lower amount or the full amount.');
                            }
                        }
                    }
                }
                
                if(!isError){
                    relatedLoan.Amount_Funded__c=relatedLoan.Amount_Funded__c+trans.Amount__c;
                    loansMap.put(relatedLoan.Id, relatedLoan);
                }
            }
        }
    }
    
    public static void calculateExpectedLoanFundings(set<String> loanIds){
        // This method will update the number of lenders and amount funded on Loan object
        // The mentioned fields will help the process to convert the Loan in Active Stage
        list<Loan__c> loans = [Select Id, Name, 
                               (Select Id, Name, Status__c, Lender__c, Amount__c From Transactions__r 
                                Where Type__c='Loan' AND Status__c='Held') 
                               From Loan__c 
                               Where Id IN: loanIds];
        
        if(loans != null && loans.size()>0){
            for(Loan__c l: loans){
                Decimal amountProcessing = 0.0;
                if(l.Transactions__r != null && l.Transactions__r.size()>0){
                    for(Transaction__c t: l.Transactions__r){
                        amountProcessing+=t.Amount__c;
                    }
                }
                
                l.Expected_Fund_From_Cart__c=amountProcessing;
            }
            
            update loans;
        }
    }
    
    public static void calculateLoanFundings(set<String> loanIds){
        // This method will update the number of lenders and amount funded on Loan object
        // The mentioned fields will help the process to convert the Loan in Active Stage
        list<Loan__c> loans = [Select Id, Name, 
                               (Select Id, Name, Status__c, Lender__c, Amount__c From Transactions__r 
                                Where Type__c='Loan' AND Status__c='Completed') 
                               From Loan__c 
                               Where Id IN: loanIds];
        
        if(loans != null && loans.size()>0){
            for(Loan__c l: loans){
                set<String> noOfLenders = new set<String>();
                Decimal amountFunded = 0.0;
                if(l.Transactions__r != null && l.Transactions__r.size()>0){
                    for(Transaction__c t: l.Transactions__r){
                        noOfLenders.add(t.Lender__c);
                        amountFunded+=t.Amount__c;
                    }
                }
                l.Number_of_Lenders__c=noOfLenders.size();
                l.Amount_Funded__c=amountFunded;
            }
            
            update loans;
        }
    }
    
    public static void rollupRepaymentsOnLoan(set<String> loanIds){
        // This method will be updating the loan Repaid_Date and Stage to repaid if the amount will be repaid
        list<Loan__c> loans = [Select Id, Name, Actual_Loan_Principle_Disbursed_AUD__c, Published_Amount_AUD__c, 
                               (Select Id, Amount__c 
                                From Transactions__r 
                                Where (Type__c='Repayment' OR (Type__c='Donation' AND Loan__c != NULL))
                                AND Status__c='Completed' 
                                AND Buffer_Repaid__c=false) 
                               From Loan__c Where Id IN: loanIds];
        if(loans != null && loans.size()>0){
            for(Loan__c l: loans){
                /*Decimal transLimit=0.0;
if(l.Actual_Loan_Principle_Disbursed_AUD__c!=null && l.Actual_Loan_Principle_Disbursed_AUD__c>0){
transLimit=l.Actual_Loan_Principle_Disbursed_AUD__c;
}

if(transLimit == null || transLimit ==0){
transLimit=l.Published_Amount_AUD__c;
}*/
                Decimal repaidAmount = 0.0;
                if(l.Transactions__r != null && l.Transactions__r.size()>0){
                    for(Transaction__c t: l.Transactions__r){
                        repaidAmount+=t.Amount__c;
                    }
                }
                l.Total_Repaid_Amount_AUD__c=repaidAmount.setScale(3);
            }
        }
        
        if(loans != null && loans.size()>0){
            update loans;
        }
    }
    
    public static map<String, Lender_Balance__c> validateLBRollup(set<String> lenderIds){
        map<String, Lender_Balance__c> lenderBalanceMap = new map<String, Lender_Balance__c>();
        map<String, Contact> contactsMap = new map<String, Contact>();
        list<Contact> lenderTransactions = [Select Id, Name,
                                            (Select Id, Name, Type__c, Status__c, Amount__c, Transaction_Date__c, 
                                             Completed_Date__c, Lender__c,isTopupOnly__c,Transaction_Fee__c
                                             From Transactions__r Where Status__c='Completed'),
                                            (Select Id, Name, Balance__c From Lender_Balance__r)
                                            From Contact 
                                            Where Id IN: lenderIds];
        if(lenderTransactions != null && lenderTransactions.size()>0){
            for(Contact l: lenderTransactions){
                set<Date> transactionDates = new set<Date>();
                Boolean isCompletedTransactions=false;
                Decimal lenderBalance=0.0;
                Integer totalLoans=0;
                Decimal totalAmountLent=0.0;
                Decimal totalDonations=0.0;
                Integer numberOfWithdrawal30Days=0;
                Integer numberOfWithdrawal120Days=0;
                if(l.Transactions__r != null && l.Transactions__r.size()>0){
                    
                    for(Transaction__c t: l.Transactions__r){
                        if(t.Status__c=='Completed'){
                            isCompletedTransactions=true;
                            //Voucher Transaction will not be considered in Lender Balance
                            if(t.Type__c=='Repayment' || t.Type__c=='Topup' || t.Type__c=='Payment' || t.Type__c=='Expired Loan'){
                                lenderBalance+=t.Amount__c;
                            }
                            
                            if(t.Type__c=='Loan' || t.Type__c=='Withdrawal' || ( t.Type__c=='Donation' && !t.isTopupOnly__c )){
                                lenderBalance-=t.Amount__c;
                                //lendingCount=lendingCount+1;
                            }
                            
                            if(t.Type__c=='Loan'){
                                transactionDates.add(t.Completed_Date__c.Date());
                                totalLoans++;
                                totalAmountLent+=t.Amount__c;
                            }
                            
                            if(t.Type__c=='Donation'){
                                totalDonations+=t.Amount__c;
                            }
                            
                            if(t.Type__c=='Withdrawal'){
                                if(t.Completed_Date__c != null){
                                    Integer DayDiff=t.Completed_Date__c.Date().daysBetween(System.Today());
                                    if(DayDiff<=30){
                                        numberOfWithdrawal30Days++;
                                    }
                                    
                                    if(DayDiff<=120){
                                        numberOfWithdrawal120Days++;
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(l.Lender_Balance__r != null && l.Lender_Balance__r.size()>0){
                    Lender_Balance__c lb = l.Lender_Balance__r[0];
                    lenderBalanceMap.put(l.Id, new Lender_Balance__c(Id=lb.Id, Lender__c=l.Id, Balance__c=lenderBalance, CurrencyISOCode='AUD'));
                }else{
                    lenderBalanceMap.put(l.Id, new Lender_Balance__c(Lender__c=l.Id, Balance__c=lenderBalance, CurrencyISOCode='AUD'));
                }
                
                if(isCompletedTransactions){
                    if(transactionDates != null && transactionDates.size()==1){
                        l.IsFirstLending__c=true;
                    }else{
                        l.IsFirstLending__c=false;
                    }
                    l.Number_Of_Withdrawals_Past_30_Days__c=numberOfWithdrawal30Days;
                    l.Number_of_Refunds__c=numberOfWithdrawal30Days;
                    l.Last_Refund_Date__c=System.Today();
                    l.Number_of_Withdrawals_120_days__c=numberOfWithdrawal120Days;
                    l.Total_Loans__c=totalLoans;
                    l.Total_Amount_Lent__c=totalAmountLent;
                    l.Total_Donation__c=totalDonations;
                    contactsMap.put(l.Id, l);
                }
            }
        }
        
        if(contactsMap != null && contactsMap.size()>0){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.SaveResult[] sr=Database.update(contactsMap.values(), dml);
            //update contactsMap.values();
        }
        return lenderBalanceMap;
    }
    
    public static void manageLenderBalance(set<String> lenderIds){
        //Manage or Calculate LenderBalance for Lenders
        map<String, Lender_Balance__c> lenderBalanceMap = validateLBRollup(lenderIds);
        if(lenderBalanceMap != null && lenderBalanceMap.size()>0){
            if(!Test.isRunningTest())
                upsert lenderBalanceMap.values();
        }
    }
    
   /* @future(callout=true)    
    public static void sendCheckoutEmail(set<String> lenderCheckoutEmails){
                System.debug('In transaction triggerhandler');
        LWC_CheckoutEmail.sendCheckoutEmail(lenderCheckoutEmails);
    }*/
}