//
//  HomeFeedTableViewCell.h
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 29/11/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
//#import <URLEmbeddedView/URLEmbeddedView-Swift.h>

@interface HomeFeedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblCountry;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIView *viewImages;
@property (weak, nonatomic) IBOutlet UIView *viewActions;
@property (weak, nonatomic) IBOutlet UIButton *btnShared;
@property (weak, nonatomic) IBOutlet UIButton *btnView;
@property (weak, nonatomic) IBOutlet UIButton *btnComents;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIImageView *imgPost;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *lblComents;
@property (weak, nonatomic) IBOutlet UILabel *lblLike;
@property (weak, nonatomic) IBOutlet UILabel *lblView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLike;
@property (weak, nonatomic) IBOutlet UILabel *lblPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblDomain;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *urlPreivewView;
@property (weak, nonatomic) IBOutlet UIView *viewURL;
@property (weak, nonatomic) IBOutlet UIView *viewDetailsOfUser;
@property (weak, nonatomic) IBOutlet UIImageView *imgLinkPreview;

@end
