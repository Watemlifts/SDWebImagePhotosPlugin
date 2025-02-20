//
//  ViewController.m
//  SDWebImagePhotosPlugin_Example macOS
//
//  Created by lizhuoli on 2018/7/19.
//  Copyright © 2018年 DreamPiggy. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImagePhotosPlugin/SDWebImagePhotosPlugin.h>
#import "TestCollectionViewItem.h"
#import "PHCollection.h" // Currently seems `PHAssetCollection` is not list in public header, but it works

@interface ViewController () <NSCollectionViewDelegate, NSCollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<NSURL *> *objects;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView *collectionView;


@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.objects = [NSMutableArray array];
        // Setup Photos Loader
        SDWebImageManager.defaultImageLoader = [SDWebImagePhotosLoader sharedLoader];
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.sd_targetSize = CGSizeMake(500, 500); // The original image size may be 4K, we only query the max view size :)
        SDWebImagePhotosLoader.sharedLoader.imageRequestOptions = options;
        
        // Reload
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuItemDidTap:) name:NSMenuDidSendActionNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Photos Library Demo
    [self reloadData];
}

- (void)fetchAssets {
    [self.objects removeAllObjects];
    PHFetchResult<PHAssetCollection *> *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                          subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                                          options:nil];
    PHAssetCollection *collection = result.firstObject;
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
    for (PHAsset *asset in assets) {
        // You can use local identifier of `PHAsset` to create URL
//        NSURL *url = [NSURL sd_URLWithAssetLocalIdentifier:asset.localIdentifier];
        // Or even `PHAsset` itself
        NSURL *url = [NSURL sd_URLWithAsset:asset];
        [self.objects addObject:url];
    }
}

- (void)menuItemDidTap:(NSNotification *)notification {
    NSMenuItem *menuItem = notification.userInfo[@"MenuItem"];
    if ([menuItem.title isEqualToString:@"Reload"]) {
        [self reloadData];
    }
}

- (void)reloadData {
    [self fetchAssets];
    [self.collectionView reloadData];
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewItem *cell = [collectionView makeItemWithIdentifier:@"TestCollectionViewItem" forIndexPath:indexPath];
    NSURL *photosURL = self.objects[indexPath.item];
    cell.imageViewDisplay.sd_imageTransition = SDWebImageTransition.fadeTransition;
    [cell.imageViewDisplay sd_setImageWithURL:photosURL placeholderImage:nil options:SDWebImageFromLoaderOnly context:@{SDWebImageContextStoreCacheType: @(SDImageCacheTypeNone)}];
    return cell;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.objects.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

@end
