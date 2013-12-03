//
//  ViewController.m
//
//  Created by Nick Lockwood on 03/02/2013.
//  Copyright (c) 2013 Charcoal Design. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <UITableViewDataSource>

@property (nonatomic, copy) NSArray *items;
@property (nonatomic, copy) NSArray *folders;
@property (nonatomic, strong) NSMutableDictionary *results;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) dispatch_queue_t queue;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set up images
    self.results = [NSMutableDictionary dictionary];
    self.folders = @[@"Coast Photos (PNG Unfriendly)", @"Gradient Images (PNG Friendly)"];
    self.items = @[@"2048x1536", @"1024x768", @"512x384",
                   @"256x192", @"128x96", @"64x48", @"32x24"];
    
}

- (CFTimeInterval)loadImageForOneSec:(NSString *)path
{
    //start timing
    NSInteger imagesLoaded = 0;
    CFTimeInterval endTime = 0;
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    while (endTime - startTime < 1)
    {
        @autoreleasepool
        {
            //load image
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            //decompress image by drawing it into a new context and extracting result
            BOOL opaque = CGImageGetAlphaInfo(image.CGImage) == kCGImageAlphaNone;
            UIGraphicsBeginImageContextWithOptions(image.size, opaque, 0.0f);
            [image drawAtPoint:CGPointZero];
            UIGraphicsEndImageContext();
            
            //update totals
            imagesLoaded ++;
            endTime = CFAbsoluteTimeGetCurrent();
        }
    }
    
    //close context
    UIGraphicsEndImageContext();
    
    //calculate time per image
    return (endTime - startTime) / imagesLoaded;
}

- (void)loadImageForIndexPath:(NSIndexPath *)indexPath
{
    if (!_queue)
    {
        _queue = dispatch_queue_create("com.charcoaldesign.imageloading", NULL);
    }
    
    //load on background thread so as not to
    //prevent the UI from updating between runs
    dispatch_async(_queue, ^{
        
        //setup
        NSString *fileName = self.items[indexPath.row];
        NSString *folder = self.folders[indexPath.section];
        NSString *pngPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"png" inDirectory:folder];
        NSString *jpgPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg" inDirectory:folder];

        //load
        NSInteger pngTime = [self loadImageForOneSec:pngPath] * 1000;
        NSInteger jpgTime = [self loadImageForOneSec:jpgPath] * 1000;
        
        //updated UI on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //find table cell and update
            self.results[indexPath] = [NSString stringWithFormat:@"PNG: %03ims  JPG: %03ims", pngTime, jpgTime];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.detailTextLabel.text = self.results[indexPath];
        });
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.folders count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.folders[section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //dequeue cell
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:@"Cell"];
    }
    
    //set up cell
    NSString *imageName = self.items[indexPath.row];
    cell.textLabel.text = imageName;
    
    //load image
    if (self.results[indexPath])
    {
        cell.detailTextLabel.text = self.results[indexPath];
    }
    else
    {
        cell.detailTextLabel.text = @"Loading...";
        [self loadImageForIndexPath:indexPath];
    }

    return cell;
}

@end
