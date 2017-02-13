//
//  ViewController.m
//  PhotoApp
//
//  Created by Administrator on 2016/05/28.
//  Copyright © 2016年 Shota Nakagami. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong, nonatomic) PHFetchResult *imageAssets;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView reloadData];
    
    __weak typeof(self) weakSelf = self;
    
    //PHAssetCollectionSubtypeSmartAlbumFavorites:お気に入り
    //PHAssetCollectionSubtypeSmartAlbumPanoramas:パノラマ
    //PHAssetCollectionSubtypeSmartAlbumRecentlyAdded:最近に追加した項目
    //PHAssetCollectionSubtypeSmartAlbumUserLibrary:カメラロール
    //PHAssetCollectionSubtypeSmartAlbumSelfPortraits:セルフィー
    //PHAssetCollectionSubtypeSmartAlbumScreenshots:スクリーンショット
    
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                               subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary
                                                                               options:nil];
    
    [assetCollections enumerateObjectsUsingBlock:^(PHAssetCollection *smartFolderAssetCollection, NSUInteger idx, BOOL *stop){
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        
        weakSelf.imageAssets = [PHAsset fetchAssetsInAssetCollection:smartFolderAssetCollection options:fetchOptions];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                                           forIndexPath:indexPath];
    
    __block UIImageView *imageView = (UIImageView *)[cell viewWithTag:777];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.userInteractionEnabled = NO;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.synchronous = YES;
    
    CGFloat imageWidth = [self getCellWidth] * [[UIScreen mainScreen] scale];
    
    [[PHImageManager defaultManager] requestImageForAsset:self.imageAssets[indexPath.row]
                                               targetSize:CGSizeMake(imageWidth,imageWidth)
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                
                                                if (result) {
                                                    imageView.image = result;
                                                }
                                            }];
    
    return cell;
}

- (CGFloat)getCellWidth{
    //1つのセルあたりのサイズを計算(横幅に4つ収まるようにする)
    CGRect screenSize = [[UIScreen mainScreen] bounds];
    NSUInteger borderWidth = 1;
    NSUInteger divisionNumber = 4;
    CGFloat cellWidth = (screenSize.size.width - borderWidth * (divisionNumber - 1)) / divisionNumber;
    return cellWidth;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = [self getCellWidth];
    CGSize cellSize = CGSizeMake(cellWidth,cellWidth);
    return cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{    
    CGFloat retina = [[UIScreen mainScreen] scale];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    // 同期処理にする場合にはYES (デフォルトはNO)
    options.synchronous = YES;
    
    __weak typeof(self) weakSelf = self;
    
    
    CGSize targetSize = CGSizeMake(self.imageView.frame.size.width * retina,self.imageView.frame.size.height *retina);
    
    //高解像の画像を取得
    [[PHImageManager defaultManager] requestImageForAsset:self.imageAssets[indexPath.row]
                                               targetSize:targetSize
                                              contentMode:PHImageContentModeAspectFit
                                                  options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                if (result) {
                                                    weakSelf.imageView.image = result;
                                                }
                                            }];
    
}

@end
