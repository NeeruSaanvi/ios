//
//  AddMarketPlaceViewController.h
//  iBlah-Blah
//
//  Created by Arun on 17/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddMarketPlaceViewController : BaseViewController
- (IBAction)cmdCatogary:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UITextField *txtSelling;
@property (weak, nonatomic) IBOutlet UITextField *txtShortDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtDescription;
- (IBAction)cmdPrice:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtPrice;
- (IBAction)cmdLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtZipCode;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)cmdPrivacyListing:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivacyListing;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImage;
- (IBAction)cmdGalary:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewAttachment;

@property (strong, nonatomic) NSDictionary *dictDetails;
@property (strong, nonatomic) NSDictionary *dictPost;
@end
