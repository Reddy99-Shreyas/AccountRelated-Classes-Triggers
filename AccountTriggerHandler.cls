public class with sharing AccTriggerHandler {
    
    //after Undelete
    public static void sendEmailOnUndelete(List<Account>accList){
        List<Messaging.SingleEmailMessage> emailObjs = new List<Messaging.SingleEmailMessage>();
        for(Account accNew: accList){
            Messaging.SingleEmailMessage emailObj= new Messaging.SingleEmailMessage();
            List<String> emailAddress = new List<String>();
            emailAddress.add(Userinfo.getUserEmail());
            emailObj.setToAddresses(emailAddress);
            emailObj.setSubject('Account has been successfully restored: '+accNew.Name);
            emailObj.setPlainTextBody('Refer Subject');
            emailObjs.add(emailObj);
        }
        Messaging.sendEmail(emailObjs);
    }
    
    //after delete
    public static void sendEmailOnAfterDelete(List<Account>accListOld){
        List<Messaging.SingleEmailMessage> emailObjs = new List<Messaging.SingleEmailMessage>();
        for(Account accOld: accListOld){
            Messaging.SingleEmailMessage emailObj= new Messaging.SingleEmailMessage();
            List<String> emailAddress = new List<String>();
            emailAddress.add(Userinfo.getUserEmail());
            emailObj.setToAddresses(emailAddress);
            emailObj.setSubject('Account has been successfully deleted: '+accOld.Name);
            emailObj.setPlainTextBody('Refer Subject');
            emailObjs.add(emailObj);
        }
        Messaging.sendEmail(emailObjs);
    }
    
    //After Update
    public static void aftUpdTri(List<Account>accListUp, Map<Id, Account> accMapUp){
        Set<Id> accIdWhichAreChanged = new Set<Id>();
        for(Account accRecNew : accListUp){
            Account accRecOld = accMapUp.get(accRecNew.Id);
            if(accRecNew.BillingStreet!=accRecOld.BillingStreet){
                accIdWhichAreChanged.add(accRecNew.Id);
            }
        }
        
        List<Account> AccsWithContacts = [SELECT Id, Name,billingcity,billingstreet,billingcountry,billingstate, 
                                          (SELECT Id, Name FROM Contacts) 
                                          FROM Account 
                                          WHERE Id IN: accIdWhichAreChanged];
        List<contact> contactsToUpdate = new List<contact>();
        
        for(Account acc : AccsWithContacts){
            List<contact> conOfTheLoopAccount=acc.contacts;
            for(contact con:conOfTheLoopAccount){
                con.mailingstreet = acc.BillingStreet;
                con.MailingCity = acc.BillingCity;
                con.MailingState = acc.BillingState;
                con.MailingCountry = acc.BillingCountry;
                contactsToUpdate.add(con);
            }
        }
        if(contactsToUpdate.size()>0){
            update contactsToUpdate;
        }
    }
    
    //before Delete
    public static void befDel(List <Account> OldAccList){
        for(Account accOld : OldAccList){
            if(accOld.Active__c=='Yes'){
                accOld.addError('You cannot delete active account');
            }
        }
    }
    
    //before Insert
    public static void befIns(List<Account> InsAccList){
            for(Account accrec: InsAccList){
                if(accRec.ShippingCity==null){
                    accRec.ShippingCity=accRec.BillingCity;
                }
                if(accRec.ShippingCountry==null){
                    accRec.ShippingCountry=accRec.BillingCountry;
                }
                if(accRec.ShippingState==null){
                    accRec.ShippingState=accRec.BillingState;
                }
                if(accRec.ShippingStreet==null){
                    accRec.ShippingStreet=accrec.ShippingStreet;
                }
                if(accRec.ShippingPostalCode==null){
                    accRec.ShippingPostalCode=accrec.BillingPostalCode;
                }
            }
    }
    
    //After Insert
    public static void aftIns(List<Account> aftInsAccList){
        List<contact> conList = new List<contact>();
        for(Account acc: aftInsAccList){
            Contact con = new Contact();
            con.LastName=acc.Name;
            con.AccountId=acc.Id;
            conList.add(con);
        }
        if(conList.size()>0){
            insert conList;
        }
    }
    
    //before Update
    public static void befUp(List<Account>buAccList,Map<Id,Account>buAccMap){
        for(Account accRecNew: buAccList){
            Account accRecOld = buAccMap.get(accRecNew.Id);
            if(accRecNew.Name != accRecOld.Name){
                accRecNew.addError('Account Name cannot be modified/changed once it is created');
            }
        }
    }
}