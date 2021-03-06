//
//  SGViewController.h
//  PopulatePhotos
//
//  Created by Justin Williams on 3/21/13.
//  Copyright (c) 2013 Second Gear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SGViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

- (IBAction)populate:(id)sender;
- (IBAction)addAlbums:(id)sender;
- (IBAction)insertPhotosIntoAlbums:(id)sender;

@end
