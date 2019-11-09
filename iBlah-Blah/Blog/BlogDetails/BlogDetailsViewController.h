//
//  BlogDetailsViewController.h
//  iBlah-Blah
//
//  Created by Arun on 20/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogDetailsViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tblBlogDetails;
@property (nonatomic, strong)NSDictionary *dictPost;
@end
