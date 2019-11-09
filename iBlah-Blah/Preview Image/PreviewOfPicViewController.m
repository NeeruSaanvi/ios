//
//  PreviewOfPicViewController.m
//  iBlah-Blah
//
//  Created by Piyush Agarwal on 05/12/18.
//  Copyright © 2018 webHax. All rights reserved.
//

#import "PreviewOfPicViewController.h"
#import "PreviewCollectionViewCell.h"

@interface PreviewOfPicViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation PreviewOfPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}




#pragma mark - Collection view data source
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imgArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *identifier = @"cell";

    PreviewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    NSURL *url;
    id images = [self.imgArray objectAtIndex:indexPath.row];
    if([images isKindOfClass:[NSString class]])
    {
        url = [NSURL URLWithString:images];
    }
    else if([images isKindOfClass:[NSURL class]]){
        url = images;
    }

    [cell.imgPic sd_setImageWithURL:url completed:nil];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    return CGSizeMake(self.view.frame.size.width, collectionView.frame.size.height);
}


- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    AsyncImageView *img=(AsyncImageView *)tapRecognizer.view;

    NSURL *url;
    id images = [self.imgArray objectAtIndex:indexPath.row];
    if([images isKindOfClass:[NSString class]])
    {
        url = [NSURL URLWithString:images];
    }
    else if([images isKindOfClass:[NSURL class]]){
        url = images;
    }

    UIImageView *img = [[UIImageView alloc]init];
    [img sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];

        imageInfo.image = img.image;
        imageInfo.referenceRect = img.frame;
        imageInfo.referenceView = img.superview;
        imageInfo.referenceContentMode = img.contentMode;
        imageInfo.referenceCornerRadius = img.layer.cornerRadius;

        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];

        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }];


}


- (void)smallButtonTapped:(UITapGestureRecognizer *)tapRecognizer {


}

- (IBAction)btnCloseClick:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
