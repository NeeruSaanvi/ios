//
//  DLFPhotosPickerViewController.m
//  PhotosPicker
//
//  Created by  on 11/28/14.
//  Copyright (c) 2014 Delightful. All rights reserved.
//

#import "DLFPhotosPickerViewController.h"
#import "DLFConstants.h"
#import "DLFMasterViewController.h"
#import "DLFDetailViewController.h"
#import "DLFPhotosSelectionManager.h"
#import "DLFPhotosLibrary.h"
#import "DLFAssetsLayout.h"

@interface DLFPhotosPickerViewController () <DLFMasterViewControllerDelegate, DLFDetailViewControllerDelegate>

@property (nonatomic, strong) UISplitViewController *splitVC;

@end

@implementation DLFPhotosPickerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _multipleSelections = YES;
        
        self.splitVC = [[UISplitViewController alloc] init];
        [self.splitVC setDelegate:self];
        
        DLFMasterViewController *masterVC = [[DLFMasterViewController alloc] initWithStyle:UITableViewStyleGrouped];
        DLFDetailViewController *detailVC = [[DLFDetailViewController alloc] initWithCollectionViewLayout:[[DLFAssetsLayout alloc] init]];
        
        UINavigationController *masterNavVC = [[UINavigationController alloc] initWithRootViewController:masterVC];
        UINavigationController *detailNavVC = [[UINavigationController alloc] initWithRootViewController:detailVC];
        [self.splitVC setViewControllers:@[masterNavVC, detailNavVC]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _multipleSelections = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont systemFontOfSize:17.0f],
      NSFontAttributeName,[UIColor blueColor],NSForegroundColorAttributeName, nil]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.tintColor = [UIColor blueColor];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255.0 green:160/255.0 blue:223/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = YES;
    UISplitViewController *splitVC = self.splitVC;
    [self addChildViewController:splitVC];
    splitVC.view.frame = self.view.bounds;
    [self.view addSubview:splitVC.view];
    [splitVC didMoveToParentViewController:self];
    
    [[DLFPhotosSelectionManager sharedManager] removeAllAssets];
    
    self.splitVC.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    [[DLFPhotosLibrary sharedLibrary] startObserving];
    
    if (self.splitVC.viewControllers.count > 1) {
        UINavigationController *firstVC = [self.splitVC.viewControllers firstObject];
        UINavigationController *secondVC = [self.splitVC.viewControllers lastObject];
        
        DLFMasterViewController *masterVC = [firstVC.viewControllers firstObject];
        DLFDetailViewController *detailVC = [secondVC.viewControllers firstObject];
        
        [masterVC setDelegate:self];
        [detailVC setDelegate:self];
    } else {
        DLFDetailViewController *detailVC = [((UINavigationController *)[self.splitVC.viewControllers lastObject]).viewControllers firstObject];
        [detailVC setDelegate:self];
    }
    
   
    
    
}

- (UISplitViewController *)splitViewController {
    return [self.childViewControllers firstObject];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[DLFPhotosLibrary sharedLibrary] stopObserving];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
   showDetailViewController:(UINavigationController *)vc
                     sender:(id)sender {
    DLFDetailViewController *controller1 = [vc.viewControllers firstObject];
    controller1.delegate = self;
    return NO;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UINavigationController *)secondaryViewController
  ontoPrimaryViewController:(UINavigationController *)primaryViewController {
    DLFDetailViewController *controller1 = [secondaryViewController.viewControllers firstObject];
    DLFMasterViewController *controller2 = [primaryViewController.viewControllers firstObject];
    controller1.delegate = self;
    controller2.delegate = self;
    return NO;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(UINavigationController *)primaryViewController {
    DLFMasterViewController *controller1 = [primaryViewController.viewControllers firstObject];
    controller1.delegate = self;
    return nil;
}

#pragma mark - DLFMasterViewControllerDelegate

- (void)masterViewController:(DLFMasterViewController *)masterViewController didTapCancelButton:(UIButton *)sender {
    if (self.photosPickerDelegate && [self.photosPickerDelegate respondsToSelector:@selector(photosPickerDidCancel:)]) {
        [self.photosPickerDelegate photosPickerDidCancel:self];
    }
}


#pragma mark - DLFDetailViewControllerDelegate

- (void)detailViewController:(DLFDetailViewController *)detailViewController didTapNextButton:(UIButton *)nextButton photos:(NSArray *)photos {
    if (self.photosPickerDelegate && [self.photosPickerDelegate respondsToSelector:@selector(photosPicker:detailViewController:didSelectPhotos:)]) {
        [self.photosPickerDelegate photosPicker:self detailViewController:detailViewController didSelectPhotos:photos];
    }
}

- (void)detailViewController:(DLFDetailViewController *)detailViewController configureCell:(DLFPhotoCell *)cell indexPath:(NSIndexPath *)indexPath asset:(PHAsset *)asset {
    if (self.photosPickerDelegate && [self.photosPickerDelegate respondsToSelector:@selector(photosPicker:detailViewController:configureCell:indexPath:asset:)]) {
        [self.photosPickerDelegate photosPicker:self detailViewController:detailViewController configureCell:cell indexPath:indexPath asset:asset];
    }
}

- (BOOL)multipleSelectionsInDetailViewController:(DLFDetailViewController *)detailViewController {
    return self.multipleSelections;
}
- (void)detailViewController:(DLFDetailViewController *)detailViewController didSelectPhoto:(PHAsset *)photo {
    if (self.photosPickerDelegate && [self.photosPickerDelegate respondsToSelector:@selector(photosPicker:detailViewController:didSelectPhoto:)]) {
        [self.photosPickerDelegate photosPicker:self detailViewController:detailViewController didSelectPhoto:photo];
    }
}

@end
