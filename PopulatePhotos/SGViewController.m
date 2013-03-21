//
//  SGViewController.m
//  PopulatePhotos
//
//  Created by Justin Williams on 3/21/13.
//  Copyright (c) 2013 Second Gear. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
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

- (void)updateLabelText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = text;
    });
}

- (IBAction)populate:(id)sender
{
    self.statusLabel.text = @"Populating...";
    dispatch_queue_t queue = dispatch_queue_create("com.secondgear.PopulatePhotos", 0);
    dispatch_async(queue, ^{        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSArray *paths = [mainBundle pathsForResourcesOfType:@"jpg" inDirectory:@"Photos"];
        [self updateLabelText:[NSString stringWithFormat:@"Found %d photos.", [paths count]]];
        
        [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *path = (NSString *)obj;
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
            [self updateLabelText:[NSString stringWithFormat:@"Adding photo %d to the library.", idx]];
            UIImageWriteToSavedPhotosAlbum(image, self, NULL, NULL);
        }];
    });
}

- (IBAction)addAlbums:(id)sender
{
    // Creating 15 albums.
    [self updateLabelText:@"Creating Albums..."];
    
    __weak typeof(self) bSelf = self;
    for (NSInteger i = 1; i < 15 ; i++)
    {        
        NSString *albumName = [NSString stringWithFormat:@"Sample Album %d", i];
        [self.library addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
            [bSelf updateLabelText:[NSString stringWithFormat:@"Created album %@.", albumName]];
            [bSelf.albums addObject:group];            
        } failureBlock:^(NSError *error) {
            NSLog(@"Bad developer. No cookie. %@", error);
        }];
    }
}

- (IBAction)insertPhotosIntoAlbums:(id)sender
{
    [self updateLabelText:@"Adding Photos to albums..."];

    // And iterate the photo library and add them to a random album
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset != nil)
            {
                int albumIndex = 0 + arc4random() % (14 - 0);
                NSString *message =[NSString stringWithFormat:@"Added photo %d to an album.", index];
                [self updateLabelText:message];
                

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
