//
//  ApiClient.m
//
//
//  Created by OSX on 13/01/16.
//  Copyright (c) 2016 Arun. All rights reserved.
//

#import "ApiClient.h"
@import Firebase;
@implementation ApiClient
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}


-(AFHTTPSessionManager *)getAFHTTPSessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [manager.securityPolicy setAllowInvalidCertificates:YES];
    [manager.operationQueue setMaxConcurrentOperationCount:1];
    
    return manager;
}

//Login
- (void)getLogin:(NSString *)userName password:(NSString *)password success:(void (^)(id responseObject))success
         failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{

    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceTokenStrKey = [prefs stringForKey:@"deviceTokenStrKey"];
   // deviceTokenStrKey=@"";
    NSString *fcmToken = [FIRMessaging messaging].FCMToken;

    NSString *url = [NSString stringWithFormat:@LOGIN];
    url =[NSString stringWithFormat:@"%@action=manullyLogin&email=%@&password=%@&tokenDevice=%@",url,userName,password,fcmToken];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(!([self checkResponce:responseObject])){
            NSDictionary *dict=responseObject;
            failure(nil,[dict objectForKey:@"message"]);
        }else{
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            
               failure(nil, error.localizedDescription);
        }
    }];
}

//Forgot pass
- (void)forgotPass:(NSString *)email success:(void (^)(id responseObject))success
         failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{
  
    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceTokenStrKey = [prefs stringForKey:@"deviceTokenStrKey"];
    NSString *url = [NSString stringWithFormat:@FORGOTPASS];
    url =[NSString stringWithFormat:@"%@action=forgot_pass&email=%@",url,email];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        if(!([self checkResponce:responseObject])){
            NSDictionary *dict=responseObject;
            failure(nil,[dict objectForKey:@"message"]);
        }else{
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            
            failure(nil, error.localizedDescription);
        }
    }];
}
//change pass
- (void)changePass:(NSString *)oldPass newPass:(NSString *)newPass success:(void (^)(id responseObject))success
           failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{
    
    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *url = [NSString stringWithFormat:@FORGOTPASS];
    url =[NSString stringWithFormat:@"%@action=changePass&user_id=%@&old_password=%@&password=%@",url,USERID,oldPass,newPass];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
      //  if(!([self checkResponce:responseObject])){
         //   NSDictionary *dict=responseObject;
       //     failure(nil,[dict objectForKey:@"message"]);
        //}else{
            success(responseObject);
       // }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            
            failure(nil, error.localizedDescription);
        }
    }];
}
//Get Notification
- (void)getNotification:(void (^)(id responseObject))success
           failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{
    
    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    NSString *url = [NSString stringWithFormat:@ADDPOST];
    url =[NSString stringWithFormat:@"%@action=showAllNotification&user_id=%@",url,USERID];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(!([self checkResponce:responseObject])){
            NSDictionary *dict=responseObject;
            failure(nil,[dict objectForKey:@"message"]);
        }else{
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            
            failure(nil, error.localizedDescription);
        }
    }];
}


//signUp
- (void)signUp:(NSString *)Name email:(NSString *)email zipCode:(NSString *)zipCode  password:(NSString *)password success:(void (^)(id responseObject))success
         failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{
    
    
//    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
//    
//    NSString *url = [NSString stringWithFormat:@SIGNUP];
//    url =[NSString stringWithFormat:@"%@&userChatName=%@&userZipCode=%@&userPass=%@&userEmail=%@",url,Name,zipCode,password,email];
//    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        if(!([self checkResponce:responseObject])){
//            NSDictionary *dict=responseObject;
//            failure(nil,[dict objectForKey:@"message"]);
//        }else{
//            success(responseObject);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        if (failure) {
//            
//            failure(nil, error.localizedDescription);
//        }
//    }];
}
// Get Post
- (void)getPost:(NSString *)pageNum success:(void (^)(id responseObject))success
           failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{
    
    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];

        //    post_number is eeual to  page number
    
    NSString *url = [NSString stringWithFormat:@FEEDS];
    url =[NSString stringWithFormat:@"%@action=showAllPost&user_id=%@&post_number=%@",url,@"1",pageNum];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if(!([self checkResponce:responseObject])){
            NSDictionary *dict=responseObject;
            failure(nil,[dict objectForKey:@"message"]);
        }else{
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {

            failure(nil, error.localizedDescription);
        }
    }];
}


    // Add Group
- (void)AddGroup:(NSDictionary *)dict success:(void (^)(id responseObject))success
        failure:(void (^)(AFHTTPSessionManager *operation, NSString *errorString))failure
{
    
    AFHTTPSessionManager *manager = [self getAFHTTPSessionManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    
        //    post_number is eeual to  page number
    
    NSString *url = [NSString stringWithFormat:@ADDGROUP];
    //url =[NSString stringWithFormat:@"%@",url,@"1",pageNum];
    url=[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [manager POST:url parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if(!([self checkResponce:responseObject])){
            NSDictionary *dict=responseObject;
            failure(nil,[dict objectForKey:@"message"]);
        }else{
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            
            failure(nil, error.localizedDescription);
        }
    }];
}

-(BOOL)checkResponce:(id)responceObject{
    
    NSDictionary *dict=responceObject;
    NSString *responce=[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]];
    if(!([responce isEqualToString:@"success"])){
        return FALSE;
    }
    return YES;
}

-(void)allAPIResponce{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [prefs stringForKey:@"USERID"];
    [appDelegate().socket on:USERID callback:^(NSArray* data, SocketAckEmitter* ack) {// 39 for get all post
        NSArray *responceData=data;
        if(responceData.count>0){
            NSString *strResponceCatogary=[NSString stringWithFormat:@"%@",[responceData objectAtIndex:0]];
            int conditionCheck=[strResponceCatogary intValue];
            switch (conditionCheck) {
                case 1://KEY_GET_ALL_GROUPS
                    [self getAllGroup:responceData];
                    break;
                case 2://KEY_GET_GROUP_DETAIL
                    [self getGroupDetails:responceData];
                    break;
                case 3://KEY_ADDEDTOGROUP
                    
                    break;
                case 4://KEY_LIKE_POST
                    
                    break;
                case 5://KEY_GET_ALL_GROUP_IMAGES
                     [self getGroupAllImages:responceData];
                    break;
                case 6://KEY_GET_ALL_PAGES
                    [self getPages:responceData];
                    break;
                case 7://KEY_GET_ALL_PAGE_IMAGES
                    
                    break;
                case 8://KEY_GET_PAGE_DETAIL
                    [self PageDetails:responceData];
                    break;
                case 9://KEY_ADDEDTOPAGE
                    
                    break;
                case 10://KEY_GET_ALL_LISTING
                    [self getMarketPlace:responceData];
                    break;
                case 11://KEY_GET_ALL_LISTING_DETAILS
                    [self getMarketPlaceLikeDetails:responceData];
                    break;
                case 12://KEY_GET_ALL_EVENTS_DETAILS
                     [self getEventDetails:responceData];
                    break;
                case 13://KEY_GET_ALL_IMAGES_OF_POST
                     [self getAllImages:responceData];
                    break;
                case 14://KEY_GET_ALL_USERS
                    
                    [self getAllUser:responceData];
                    break;
                case 15://KEY_ON_FRIEND_REQUEST_RECIVED
                    
                    break;
                case 16://KEY_GET_ALL_FRIEND_REQUESTS
                    [self getFriendsRequest:responceData];
                    break;
                case 17://KEY_GET_ON_REQUEST_ACCEPTED
                    
                    break;
                case 18://KEY_YOU_ACCEPTED_FRIEND_REQUEST
                    
                    break;
                case 19://KEY_GET_ALL_MESSAGES
                    [self getGetChat:responceData];
                    break;
                case 20://KEY_LIKE_LISTING
                    
                    break;
                case 21://KEY_GET_ALL_BLOGS
                      [self getAllBlog:responceData];
                    break;
                case 22://KEY_GET_DETAIL_BLOGS
                    [self getBlogDetails:responceData];
                    break;
                case 23://KEY_GET_ALL_IMAGES_POSTED_BY_USER
                     [self getUserAllImages:responceData];
                    break;
                case 24://KEY_GET_FULL_DETAIL_OF_USER
                    [self getUSERINFO:responceData];
                    break;
                case 25://KEY_GET_PAGES_OF_USER
                    
                    break;
                case 26://KEY_GET_FULL_LISTS_OF_USER
                    //
                    [self getMyMarketplace:responceData];
                    break;
                case 27://KEY_GET_FULL_BLOGS_OF_USER
                    [self getMyBlog:responceData];
                    break;
                case 28://KEY_GET_ALL_VIDEOS
                    [self getVideo:responceData];
                    break;
                case 29://KEY_GET_MY_VIDEOS
                     [self getMyVideo:responceData];
                    break;
                case 30://KEY_GET_MY_FAV_VIDEOS
                    
                    break;
                    
                case 31://KEY_GET_MY_LATER_VIDEOS
                    
                    break;
                case 32://KEY_DELETE_CONVERSATION
                    
                    break;
                case 33:
                    [self checkBlockedUser:responceData];
                    break;
                case 34://KEY_USER_BLOCKED
                    
                    break;
                case 35://KEY_USER_UNBLOCKED
                    
                    break;
                case 36://KEY_GET_ALL_GROUP_MEMBERS
                    
                    break;
                case 37://KEY_GET_PHONE_NUMBER
                    
                    break;
                case 38://KEY_GET_SEARCH_POST
                    [self getSearchPost:responceData];
                    break;
                case 39://KEY_GET_All_POST
                    [self getAllPostData:responceData];
                    break;
                case 40://KEY_GET_All_EVENT
                    [self getEvent:responceData];
                    break;
                case 41://KEY_GETAll group Post
                    [self getGroupAllPost:responceData];
                    break;
                case 42://KEY_GETAll group event
                    [self getGroupAllEvent:responceData];//mSocket.emit("getMyEvent", user_id);
                    break;
                case 43://KEY_GETAll group event
                    [self getMyEvent:responceData];//getAllMyGroup
                    break;
                case 44://KEY_GETAll group event
                    [self getAllMyGroup:responceData];//getAllMyGroup
                    break;
                case 46://KEY_GETAll group event
                    [self getUserActivity:responceData];//[self getGetChatList:responceData];
                    break;
                case 47://KEY_GETAll group event
                    [self getGetChatList:responceData];
                    break;
                case 53://KEY_GETAll group event
                    [self getVideoHistory:responceData];//
                    break;
                case 54://KEY_GETAll group event
                    [self getMyPlaylistname:responceData];//
                    break;
                case 56://KEY_GETAll group event
                    [self getMyPlaylist:responceData];//
                    break;
                case 57://KEY_GETAll group event
                    [self getMyPlayListVideo:responceData];//getRateVideo
                    break;
                case 58://KEY_GETAll group event
                    [self getAllPlaylist:responceData];//
                    break;
                case 59://KEY_GETAll group event
                    [self getRateVideo:responceData];//
                    break;
                case 63://KEY_GETAll group event
                    [self getstartTyping:responceData];
                    break;
                case 62://KEY_GETAll group event
                    [self getAllBlockedUsers:responceData];
                    break;
                case 64://KEY_GETAll group event
                    [self getstopTyping:responceData];
                    break;
                case 65://KEY_GETAll group event
                    [self getAllAttending:responceData];
                    break;
                    
                case 67://KEY_GETAll group event   getstopTyping
                    [self getNewMsg:responceData];//
                    break;
                case 71://KEY_GET_ALL_COMENTS_OF_POST
                    [self getComment:responceData];
                    break;
                case 72://KEY_GET_ALL_COMENTS_OF_IMAGE
                    [self getALLCommentImage:responceData];
                    break;
                case 73://not used now
                    
                    break;
                case 74://KEY_GET_ALL_COMENTS_ON_POST
                    
                    break;
                case 75://KEY_GET_RECENT_COMENTS_ON_POST
                    
                    break;
                case 76://KEY_GET_ALL_COMENTS_ON_LISTING
                    [self getNotificationList:responceData];
                    break;
                case 77://KEY_GET_ALL_COMENTS_OF_LISTING
                    [self getMarketPlaceDetails:responceData];
                    break;
                case 78://KEY_GET_ALL_LIKES_OF_POST
                    //
                    [self getLikeUser:responceData];
                    break;
                case 79://KEY_GET_ALL_LIKES_OF_POST
                    [self getNotificationCount:responceData];
                    break;
                case 82://KEY_GET_ALL_LIKES_OF_POST
                    [self UpdateApp:responceData];
                    break;
                case 91://KEY_GET_ALL_LIKES_OF_POST
                    [self getUpdateStatus:responceData];
                    break;

                default:
                    break;
            }
            
        }
        
    }];
}
//
-(void)getAllPostResponce{
    
    [appDelegate().socket on:@"postEvents" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"Hello");//4,20,74,75,76
         NSArray *responceData=data;
        NSString *strResponceCatogary=[NSString stringWithFormat:@"%@",[responceData objectAtIndex:0]];
        int conditionCheck=[strResponceCatogary intValue];
        switch (conditionCheck) {
            case 4://KEY_LIKE_POST
                [self likeClieked:responceData];
                break;
            case 20://KEY_LIKE_LISTING
                
                break;
            case 67://KEY_LIKE_LISTING
                [self getNewMsg:responceData];
                break;
            case 91://KEY_LIKE_LISTING
                [self getNewMsg:responceData];
                break;
            case 74://KEY_GET_ALL_COMENTS_ON_POST
                [self getCommentCount:responceData];
                break;
            case 75://KEY_GET_RECENT_COMENTS_ON_POST
                
                break;
            case 76://KEY_GET_ALL_COMENTS_ON_LISTING
              
                break;
            default:
                break;
        }
        
    }];
    
}

-(void)uploadImageVideo{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *USERID = [NSString stringWithFormat:@"%@UploadVideoImage",[prefs stringForKey:@"USERID"]];
    [appDelegate().socket on:USERID callback:^(NSArray* data, SocketAckEmitter* ack) {// 39 for get all post
        NSArray *responceData=data;
      //  NSLog(@"%@",responceData);
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        
        [dict setValue:responceData forKey:@"DATA"];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"VideoChunk"
         object:self userInfo:dict];
        //
    }];
    
}


//AllUser
-(void)getFriendsRequest:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"FrndRequest"
     object:self userInfo:dict];//
}
//AllUser
-(void)getAllUser:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllUser"
     object:self userInfo:dict];//
}
-(void)PageDetails:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"PageDetails"
     object:self userInfo:dict];//
}

-(void)getGroupAllImages:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupAllImages"
     object:self userInfo:dict];//
}
-(void)getGroupAllEvent:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupAllEvent"
     object:self userInfo:dict];//
}

-(void)getGroupAllPost:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupAllPost"
     object:self userInfo:dict];//
}

-(void)getGroupDetails:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupDetails"
     object:self userInfo:dict];//
}
-(void)getEventDetails:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"EventDetails"
     object:self userInfo:dict];//
}
-(void)getMarketPlaceLikeDetails:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MarketPlaceLikeDetails"
     object:self userInfo:dict];//
}

-(void)getMarketPlaceDetails:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MarketPlaceDetails"
     object:self userInfo:dict];//
}

-(void)getEvent:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllEvent"
     object:self userInfo:dict];//
}
-(void)getVideo:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllVideo"
     object:self userInfo:dict];//
}
-(void)getMyVideo:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MyVideo"
     object:self userInfo:dict];//
}
-(void)getVideoHistory:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllVideoHistory"
     object:self userInfo:dict];//
}
-(void)getComment:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ALLComment"
     object:self userInfo:dict];//
}
-(void)getPages:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllPages"
     object:self userInfo:dict];//ALLComment
}
-(void)getMarketPlace:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"Marketplace"
     object:self userInfo:dict];
}
-(void)getAllBlog:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllBlog"
     object:self userInfo:dict];
}

-(void)getAllGroup:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllGroup"
     object:self userInfo:dict];
}
-(void)getAllComment:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LikeClicked"
     object:self userInfo:dict];
}
-(void)likeClieked:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LikeClicked"
     object:self userInfo:dict];
}
-(void)getCommentCount:(NSArray *)data{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getCommentCount"
     object:self userInfo:dict];
}
//
-(void)getAllPostData:(NSArray *)data{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getAllPost"
     object:self userInfo:dict];
    
}
-(void)getMyPlaylistname:(NSArray *)data{
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MyPlayListName"
     object:self userInfo:dict];
    
}
-(void)getMyPlaylist:(NSArray *)data{//AllPlaylist
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getPlayList"
     object:self userInfo:dict];
    
}
-(void)getAllPlaylist:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllPlaylist"
     object:self userInfo:dict];
    
}
-(void)getMyPlayListVideo:(NSArray *)data{//rateVideo
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getMyPlayListVideo"
     object:self userInfo:dict];
    
}
-(void)getRateVideo:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"rateVideo"
     object:self userInfo:dict];
    
}
-(void)getMyFriends:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MyFriends"
     object:self userInfo:dict];
    
}
-(void)getAllImages:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllImages"
     object:self userInfo:dict];
    
}
-(void)getALLCommentImage:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ALLCommentImage"
     object:self userInfo:dict];
    
}
-(void)getMyMarketplace:(NSArray *)data{//MyEvent
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MyMarketplace"
     object:self userInfo:dict];
    
}
-(void)getMyEvent:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MyEvent"
     object:self userInfo:dict];
    
}
-(void)getAllMyGroup:(NSArray *)data{//USERINFO
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AllMyGroup"
     object:self userInfo:dict];
    
}
-(void)getUSERINFO:(NSArray *)data{//UserActivity
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"USERINFO"
     object:self userInfo:dict];
    
}
-(void)getUserActivity:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UserActivity"
     object:self userInfo:dict];
    
}
-(void)getGetChatList:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GetChatList"
     object:self userInfo:dict];
    
    NSArray *Arr=[dict objectForKey:@"DATA"];
   // name
    NSError *jsonError;
    NSData *objectData = [[Arr objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                    options:NSJSONReadingMutableContainers
                                                      error:&jsonError];
    
    NSArray *objs = json;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"inamed == %@", @"Admin"];
    NSArray *matchingObjs = [objs filteredArrayUsingPredicate:predicate];
    
    if ([matchingObjs count] == 0)
    {
        NSLog(@"No match");
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:json forKey:@"ChatLISTDATA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)getGetChat:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GetChat"
     object:self userInfo:dict];
    
}
-(void)getNewMsg:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getNewMsg"
     object:self userInfo:dict];
    
}

-(void)getstopTyping:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"stopTyping"
     object:self userInfo:dict];
    
}
-(void)getstartTyping:(NSArray *)data{//getstartTyping
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"startTyping"
     object:self userInfo:dict];
    
}
-(void)getUpdateStatus:(NSArray *)data{//getstartTyping
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UpdateStatus"
     object:self userInfo:dict];
    
}
//
-(void)getBlogDetails:(NSArray *)data{//MyBlog
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"BlogDetails"
     object:self userInfo:dict];
    
}
-(void)getMyBlog:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"MyBlog"
     object:self userInfo:dict];
    
}
-(void)checkBlockedUser:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"BlockedUser"
     object:self userInfo:dict];
    
}
-(void)getNotificationList:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"NotificationList"
     object:self userInfo:dict];
    
}
-(void)getUserAllImages:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UserAllImages"
     object:self userInfo:dict];
    
}

-(void)getNotificationCount:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getNotificationCount"
     object:self userInfo:dict];
    
}
-(void)getSearchPost:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"searchPost"
     object:self userInfo:dict];
    
}
-(void)getLikeUser:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getLikeUser"
     object:self userInfo:dict];
    
}
-(void)getAllAttending:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"getAllAttending"
     object:self userInfo:dict];
    
}

-(void)getAllBlockedUsers:(NSArray *)data{//
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GETAllBlockedUsers"
     object:self userInfo:dict];
    
}
-(void)UpdateApp:(NSArray *)data{//
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    [dict setValue:data forKey:@"DATA"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"UPDATEAPP"
     object:self userInfo:dict];
}

@end
