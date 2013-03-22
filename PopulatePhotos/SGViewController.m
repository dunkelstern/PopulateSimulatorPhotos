//
//  SGViewController.m
//  PopulatePhotos
//
//  Created by Justin Williams on 3/21/13.
//  Copyright (c) 2013 Second Gear. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "SGViewController.h"

#define NOT_DONE 0
#define DONE 1

@interface SGViewController ()
@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic, strong) NSMutableArray *albums;
@end

@implementation SGViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.library = [[ALAssetsLibrary alloc] init];
        self.albums = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)populate:(id)sender
{
    self.statusLabel.text = @"Populating...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSArray *paths = [mainBundle pathsForResourcesOfType:@"jpg" inDirectory:@"Photos"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.statusLabel setText:[NSString stringWithFormat:@"Found %d photos.", [paths count]]];
            [self.spinner startAnimating];
        });

        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [paths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            CGImageSourceRef source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], nil);
            if (source) {
                CGImageRef rawImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
                CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil);
                CFRelease(source);
                [lib writeImageToSavedPhotosAlbum:rawImage metadata:(__bridge NSDictionary *)(imageProperties) completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        NSLog(@"Failed to write image to library: %@", error);
                    } else {
                        NSLog(@"Wrote image to library: %@", assetURL);
                    }
                    if (imageProperties) {
                        CFRelease(imageProperties);
                    }
                    if (rawImage) {
                        CGImageRelease(rawImage);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressBar setProgress:(CGFloat)idx / (CGFloat)paths.count];
                        [self.statusLabel setText:[NSString stringWithFormat:@"Adding photo %d to the library.", idx]];
                    });
                }];
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
        });
    });
}

- (IBAction)addAlbums:(id)sender
{
    // Creating 15 albums.
    [self.statusLabel setText:@"Creating Albums..."];
    
    __weak typeof(self) bSelf = self;
    for (NSInteger i = 1; i < 15 ; i++)
    {        
        NSString *albumName = [NSString stringWithFormat:@"Sample Album %d", i];
        [self.library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [bSelf.statusLabel setText:[NSString stringWithFormat:@"Created album %@.", albumName]];
            });
            [bSelf.albums addObject:group];
        } failureBlock:^(NSError *error) {
            NSLog(@"Bad developer. No cookie. %@", error);
        }];
    }
}

- (IBAction)insertPhotosIntoAlbums:(id)sender
{
    [self.statusLabel setText:@"Adding Photos to albums..."];

    // And iterate the photo library and add them to a random album
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset != nil)
            {
                int albumIndex = 0 + arc4random() % (14 - 0);
                NSString *message =[NSString stringWithFormat:@"Added photo %d to an album.", index];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.statusLabel setText:message];
                });

                ALAssetsGroup *randomAlbum = self.albums[albumIndex];
                [randomAlbum addAsset:asset];
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Bad developer. No cookie. %@", error);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
