//
//  AddBlogViewController.h
//  iBlah-Blah
//
//  Created by Arun on 20/04/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RTViewAttachment/RTViewAttachment.h>
#import <RTViewAttachment/RTViewAttachmentTextView.h>
@interface AddBlogViewController : BaseViewController<RTViewAttachmentTextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtPost;
- (IBAction)cmdCategory:(id)sender;
- (IBAction)cmdStatus:(id)sender;
- (IBAction)cmdPrivacy:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCategory;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblPrivacy;

@property (weak, nonatomic) IBOutlet UIButton *btnPreview;
- (IBAction)cmdGalary:(id)sender;
- (IBAction)cmdPrivew:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewAttachment;
- (IBAction)cmdAttachment:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImage;
@property (weak, nonatomic) IBOutlet RTViewAttachmentTextView *txtViewPost;
@property (strong, nonatomic) IBOutlet UIView *inputAccessoryView;

- (IBAction)onInsertImage:(id)sender;


@property (strong, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIView *viewPreviewSubView;
- (IBAction)cmdOk:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *WebView;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;



@property (strong, nonatomic) NSDictionary *dictDetails;
@property (strong, nonatomic) NSArray *imageArryDetails;
@property (nonatomic, strong)NSDictionary *dictPost;

@end
