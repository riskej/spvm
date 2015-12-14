//
//  ViewController.m
//  Speccy Viewer
//
//  Created by riskej on 1/21/15.
//  Copyright (c) 2015 Simbolbit & Debris. All rights reserved.
//

#import "ViewController.h"
#import "RKJConverterToRGB.h"

@implementation ViewController {
    
    BOOL isLoadedFilePNG;
    BOOL isDropboxActive;
    BOOL isFlashImage;
    BOOL is6912Image;
    BOOL isMG1Image;
    BOOL check;
    BOOL isNoflicMode;
    
    NSImageView *screenToShow;
    NSImageView *screenToShow2;
    
}

    int kRetina;
    NSUInteger incomingFileSize;
    NSImage *image01;
    NSImage *image02;

    NSData *currentData;
    NSURL *openedURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor = [[NSColor blackColor] CGColor];
    kRetina = 2;
    
//    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(32, 24, 256, 192)];
//    screenToShow.image = [NSImage imageNamed:@"animeeshon.png"];
//    
//    [self.view addSubview:screenToShow];
    
//    NSLog(@"%@", self.view.layer);
    
    [self convert6912Screen:2];
//    [self convert6144_n_rgb:1];
    
}


-(IBAction)openDocument:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (openedURL in [panel URLs]) {
            
            [self preparingFilesToShow];
            
        }
    }
    
}

#pragma mark - Convert methods

- (void) convert6144_n_rgb:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
//    NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString :@"https://dl.dropboxusercontent.com/u/36464659/_apptest/np.scr"]];
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_scr6144_n_rgb:currentData];
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage;
    
    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow.image = convertedImage.FinallyProcessedImage;

    
    screenToShow2 = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow2.image = convertedImage.FinallyProcessedImage;

//    curTypeFile=1;
    isNoflicMode=YES;
    [self.view addSubview:screenToShow];
//    [self.view addSubview:screenToShow2];
//    [self.view insertSubview:screenToShow2 belowSubview:mainMenu];
}

- (void) convert6912Screen:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
   
    // Test data
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_scr6912:currentData];
    
//    image01 = convertedImage.FinallyProcessedImage;
//    image02 = convertedImage.FinallyProcessedImage2;
    
    screenToShow = [[NSImageView alloc] initWithFrame:NSMakeRect(64, 48, 512, 384)];
    screenToShow.image = convertedImage.FinallyProcessedImage;
    
//    screenToShow2 = [[NSImageView alloc] initWithFrame:NSMakeRect(32, 24, 256, 192)];
//    screenToShow2.image = convertedImage.FinallyProcessedImage2;
    
    [self.view addSubview:screenToShow];
//    [self.view addSubview:screenToShow2];
   
//    isNoflicMode = NO;
//    isFlashImage = YES;
//    is6912Image = YES;
//    isMG1Image = NO;
//    [self showFlickeringPicture];
    
}


- (void)drawRect:(NSRect)rect {
    // Clear the drawing rect.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void) preparingFilesToShow {
    
    
    currentData = [NSData dataWithContentsOfURL:openedURL];
    incomingFileSize = [currentData length];
    
    if (currentData != nil) {
     
        if (incomingFileSize == 6912) {
            [self convert6912Screen:2];
        }
        
        else if (incomingFileSize == 6144) {
            [self convert6144_n_rgb:1];
        }
        
    }
    
}

@end
