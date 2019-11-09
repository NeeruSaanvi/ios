//
//  ApiClient.h
//  
//
//  
//  Copyright (c) 2017 Arun. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface ApiClient : NSObject
+ (instancetype)sharedInstance;

//Login
- (void)getLogin:(NSString *)userName password:(NSString *)password success:(void (^)(id responseObject))success
         failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
//Forgot pass
- (void)forgotPass:(NSString *)email success:(void (^)(id responseObject))success
           failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
//signUp
- (void)signUp:(NSString *)Name email:(NSString *)email zipCode:(NSString *)zipCode  password:(NSString *)password success:(void (^)(id responseObject))success
       failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
    // Get Post
- (void)getPost:(NSString *)pageNum success:(void (^)(id responseObject))success
        failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
//Add Group
- (void)AddGroup:(NSDictionary *)dict success:(void (^)(id responseObject))success
         failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
//change pass
- (void)changePass:(NSString *)oldPass newPass:(NSString *)newPass success:(void (^)(id responseObject))success
           failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
//Get Notification
- (void)getNotification:(void (^)(id responseObject))success
                failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure;
-(void)allAPIResponce;
-(void)getAllPostResponce;
-(void)uploadImageVideo;
@end
