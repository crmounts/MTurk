//
//  CMDataManager.h
//  MTurk
//
//  Created by Connor R Mounts on 11/26/15.
//  Copyright © 2015 Connor Mounts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMDataManager : NSObject

+ (CMDataManager *)sharedManager;
- (BOOL)isUserLoggedIn;
- (void)userSignUp:(NSString *)username withPass:(NSString *)password withEmail:(NSString *)email completion:(void (^)(NSString *result))completionBlock;
- (void)userSignIn:(NSString *)username withPass:(NSString *)password completion:(void (^)(NSString *result))completionBlock;
- (void)logOutUser;
- (void)transfer:(NSNumber *)amount completion:(void (^)(NSString *result))completionBlock;
- (void)getBalance:(void (^)(NSString *address,NSString *balance))completionBlock;
- (void)createWallet:(NSString *)password completion:(void (^)(NSString *address, NSString *guid))completionBlock;

@end
