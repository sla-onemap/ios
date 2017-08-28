//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize mapView = _mapView;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[AGSMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.mapView.layerDelegate = self;
    
    [self.view addSubview:self.mapView];
    
    
    self.wmtsInfo = [[AGSWMTSInfo alloc] initWithURL:[NSURL URLWithString:esriWMTSURL]];
    
    self.wmtsInfo.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - AGSMapViewLayerDelegate Methods

- (void)mapViewDidLoad:(AGSMapView *)mapView
{
    NSLog(@"mapViewDidLoad");
    
    [self.mapView.locationDisplay startDataSource];
}


#pragma mark - AGSWMTSInfoDelegate Methods

- (void)wmtsInfoDidLoad:(AGSWMTSInfo *)wmtsInfo
{
    NSLog(@"wmtsInfoDidLoad");
    
    NSArray * layerInfos = [wmtsInfo layerInfos];
    
    AGSWMTSLayerInfo *layerInfo = [layerInfos objectAtIndex:0];
    
    self.wmtsLayer = [wmtsInfo wmtsLayerWithLayerInfo:layerInfo andSpatialReference:nil];
    
    [self.wmtsLayer setDelegate:self];
    
    [self.mapView addMapLayer:self.wmtsLayer withName:@"wmts Layer"];
}

- (void)wmtsInfo:(AGSWMTSInfo *)wmtsInfo didFailToLoad:(NSError *)error
{
    NSLog(@"WMTS Info Failed To Load: %@", error.localizedDescription);
}



#pragma mark - AGSLayerDelegate Methods

- (void)layerDidLoad:(AGSLayer *)layer
{
    NSLog(@"layerDidLoadForLayerName : %@", layer.name);
}

- (void)layer:(AGSLayer *)layer didInitializeSpatialReferenceStatus:(BOOL)srStatusValid
{
    NSLog(@"didInitializeSpatialReferenceStatus: %@", layer.spatialReference);
}

- (void)layer:(AGSLayer *)layer didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Layer Failed To Load: %@", error.localizedDescription);
}

@end
