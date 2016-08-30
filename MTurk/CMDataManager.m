//
//  CMDataManager.m
//  MTurk
//
//  Created by Connor R Mounts on 11/26/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import "CMDataManager.h"
#import <Parse/Parse.h>

#define BC_TO_SATOSHI 100000000
#define SATOSHI_TO_BC (1/(float)100000000)
#define BLOCKCHAIN_API_KEY @"74c72cf4-9042-4d46-8506-3ceac4f862f9"

@implementation CMDataManager

+ (CMDataManager *)sharedManager {
    static CMDataManager *obj;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[CMDataManager alloc] init];
    });
    return obj;
}

- (BOOL)isUserLoggedIn {
    return [[PFUser currentUser] isAuthenticated];
}


- (void)userSignUp:(NSString *)username withPass:(NSString *)password withEmail:(NSString *)email completion:(void (^)(NSString *result))completionBlock {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            completionBlock(nil);
        }
        else {
            NSString *result = [error userInfo][@"error"];
            completionBlock(result);
        }
    }];
}

- (void)userSignIn:(NSString *)username withPass:(NSString *)password completion:(void (^)(NSString *result))completionBlock {
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            completionBlock(nil);
                                        } else {
                                            NSString *result = [error userInfo][@"error"];
                                            completionBlock(result);
                                        }
                                    }];
}

- (void)logOutUser {
    [PFUser logOut];
}

- (float)BCtoUSD {
    NSString* conversionURLString = @"https://blockchain.info/ticker?api_code=$api_key";
    conversionURLString = [conversionURLString stringByReplacingOccurrencesOfString:@"$api_key" withString:BLOCKCHAIN_API_KEY];
    
    NSError* conversionError = nil;
    
    NSString* GETconversion = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:conversionURLString] encoding:NSUTF8StringEncoding error:&conversionError];
    
    NSDictionary* conversionDict = [NSJSONSerialization JSONObjectWithData:[GETconversion dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    float conversionRate = [conversionDict[@"USD"][@"last"] floatValue];
    
    return conversionRate;
}

-(void)transfer:(NSNumber *)amount completion:(void (^)(NSString *result))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"PayoutWallet"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            NSString* transferURLString = @"https://blockchain.info/merchant/$guid/payment?password=$main_password&to=$address&amount=$amount&from=$from&api_key=$api_key";
            transferURLString = [transferURLString stringByReplacingOccurrencesOfString:@"$from" withString:object[@"address"]];
            transferURLString = [transferURLString stringByReplacingOccurrencesOfString:@"$amount" withString:[NSString stringWithFormat:@"%i", (int)([amount intValue] / [self BCtoUSD] * BC_TO_SATOSHI)]];
            transferURLString = [transferURLString stringByReplacingOccurrencesOfString:@"$address" withString:[PFUser currentUser][@"address"]];
            transferURLString = [transferURLString stringByReplacingOccurrencesOfString:@"$main_password" withString:object[@"password"]];
            transferURLString = [transferURLString stringByReplacingOccurrencesOfString:@"$guid" withString:object[@"guid"]];
            transferURLString = [transferURLString stringByReplacingOccurrencesOfString:@"$api_key" withString:BLOCKCHAIN_API_KEY];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString* transferResponse = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:transferURLString] encoding:NSUTF8StringEncoding error:nil];
                NSDictionary* responseDictionary = [NSJSONSerialization JSONObjectWithData:[transferResponse dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
                if (responseDictionary[@"tx_hash"]) {
                    //successful transfer to middle man
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(transferResponse);
                    });
                } else {
                    NSLog(@"Error");
                }
            });
        } else {
            
        }
    }];
}

- (void)getBalance:(void (^)(NSString *address, NSString *balance))completionBlock {
    NSString* URLString = @"https://blockchain.info/merchant/$guid/balance?password=$main_password&api_code=$api_key";
    URLString = [URLString stringByReplacingOccurrencesOfString:@"$guid" withString:[PFUser currentUser][@"guid"]];
    URLString = [URLString stringByReplacingOccurrencesOfString:@"$main_password" withString:[PFUser currentUser][@"walletPass"]];
    URLString = [URLString stringByReplacingOccurrencesOfString:@"$api_key" withString:BLOCKCHAIN_API_KEY];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError* error = nil;
        NSString* GETbalance = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:URLString] encoding:NSUTF8StringEncoding error:&error];
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:[GETbalance dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        float conversionRate = [self BCtoUSD];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                float BC = ([dictionary[@"balance"] intValue] * SATOSHI_TO_BC);
                NSString *address = [NSString stringWithFormat:@"%@", [PFUser currentUser][@"address"]];
                NSString *balance = [NSString stringWithFormat:@"$%.2f (฿%.4f)", BC * conversionRate, BC];
                completionBlock(address,balance);
           
            }
        });
    });
}


- (void)createWallet:(NSString *)password completion:(void (^)(NSString *address, NSString *guid))completionBlock {
    NSString* URLString = @"https://blockchain.info/api/v2/create_wallet?password=$main_password&api_code=$api_key";
    URLString = [URLString stringByReplacingOccurrencesOfString:@"$main_password" withString:password];
    URLString = [URLString stringByReplacingOccurrencesOfString:@"$api_key" withString:BLOCKCHAIN_API_KEY];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSError* error = nil;
        NSString* account = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:URLString] encoding:NSUTF8StringEncoding error:&error];
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:[account dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [PFUser currentUser][@"address"] = [dictionary objectForKey:@"address"];
                [PFUser currentUser][@"guid"] = [dictionary objectForKey:@"guid"];
                [PFUser currentUser][@"walletPass"] = password;
                [[PFUser currentUser] save];
                completionBlock([dictionary objectForKey:@"address"],[dictionary objectForKey:@"guid"]);
            }
        });
    });

}





@end
