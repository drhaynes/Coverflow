//
//	CDemoCollectionViewController.m
//	Coverflow
//
//	Created by Jonathan Wight on 9/24/12.
//	Copyright 2012 Jonathan Wight. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//
//	   1. Redistributions of source code must retain the above copyright notice, this list of
//		  conditions and the following disclaimer.
//
//	   2. Redistributions in binary form must reproduce the above copyright notice, this list
//		  of conditions and the following disclaimer in the documentation and/or other materials
//		  provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of Jonathan Wight.

#import "CDemoCollectionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CDemoCollectionViewCell.h"
#import "CCoverflowTitleView.h"
#import "CCoverflowCollectionViewLayout.h"
#import "CReflectionView.h"

@interface CDemoCollectionViewController ()
@property (readwrite, nonatomic, assign) NSInteger cellCount;
@property (readwrite, nonatomic, strong) NSArray *imageFileURLs;
@property (readwrite, nonatomic, strong) CCoverflowTitleView *titleView;
@property (readwrite, nonatomic, strong) NSCache *imageCache;
@end

@implementation CDemoCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cellCount = 10;
    self.imageCache = [[NSCache alloc] init];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CCoverflowTitleView class]) bundle:NULL] forSupplementaryViewOfKind:@"title" withReuseIdentifier:@"title"];

    NSMutableArray *imageURLsFromBundle = [NSMutableArray array];
    NSURL *theURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Images"];
    NSEnumerator *theEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:theURL includingPropertiesForKeys:NULL options:NSDirectoryEnumerationSkipsPackageDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
    for (theURL in theEnumerator) {
        if ([[theURL pathExtension] isEqualToString:@"jpg"]) {
            [imageURLsFromBundle addObject:theURL];
        }
    }
    self.imageFileURLs = imageURLsFromBundle;
    self.cellCount = self.imageFileURLs.count;
}

- (void)updateTitle {
    // Asking a collection view for indexPathForItem inside a scrollViewDidScroll: callback seems unreliable.
    NSIndexPath *theIndexPath = ((CCoverflowCollectionViewLayout *)self.collectionView.collectionViewLayout).currentIndexPath;
    if (theIndexPath == NULL) {
        self.titleView.titleLabel.text = NULL;
    } else {
        NSURL *theURL = [self.imageFileURLs objectAtIndex:theIndexPath.row];
        self.titleView.titleLabel.text = [NSString stringWithFormat:@"%@", theURL.lastPathComponent];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section; {
    return (self.cellCount);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    CDemoCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"demoCell" forIndexPath:indexPath];

    if (cell.gestureRecognizers.count == 0) {
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)]];
    }

    cell.backgroundColor = [UIColor colorWithHue:(CGFloat)indexPath.row / (CGFloat)self.cellCount saturation:0.333f brightness:1.0 alpha:1.0];

    NSURL *url = [self.imageFileURLs objectAtIndex:indexPath.row];
    UIImage *image = [self.imageCache objectForKey:url];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:url.path];
        [self.imageCache setObject:image forKey:url];
    }

    cell.imageView.image = image;
    cell.reflectionImageView.image = image;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind
                                                                                                      atIndexPath:(NSIndexPath *)indexPath {
    CCoverflowTitleView *titleView = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                             withReuseIdentifier:@"title"
                                                                                    forIndexPath:indexPath];
    self.titleView = titleView;
    [self updateTitle];
    return titleView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateTitle];
}

- (void)tapCell:(UITapGestureRecognizer *)inGestureRecognizer {
    NSIndexPath *tappedCellIndexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    NSLog(@"%@", [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:tappedCellIndexPath]);
    NSURL *theURL = [self.imageFileURLs objectAtIndex:tappedCellIndexPath.row];
    NSLog(@"%@", theURL);
}

@end
